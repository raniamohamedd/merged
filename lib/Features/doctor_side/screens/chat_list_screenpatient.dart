import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/Features/doctor_side/chats_doctor/chat_detailsPatient.dart'
    hide AppColors;
import 'package:flutter_application_2/core/constants/colors.dart';
import 'package:flutter_application_2/core/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

// ─── Model ────────────────────────────────────────────────────────────────────
class DoctorChatItem {
  final String userId;
  final String name;
  final String specialty;
  final String? imageUrl;
  final Map<String, dynamic> rawData; // ✅ مضاف
  String lastMessage;
  String lastMessageTime;
  int unreadCount;

  DoctorChatItem({
    required this.userId,
    required this.name,
    required this.specialty,
    this.imageUrl,
    required this.rawData, // ✅ مضاف
    this.lastMessage = '',
    this.lastMessageTime = '',
    this.unreadCount = 0,
  });
}

// ─── Screen ───────────────────────────────────────────────────────────────────
class ChatsListScreenPatient extends StatefulWidget {
  const ChatsListScreenPatient({super.key});

  @override
  State<ChatsListScreenPatient> createState() => _ChatsListScreenPatientState();
}

class _ChatsListScreenPatientState extends State<ChatsListScreenPatient> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';
  List<DoctorChatItem> doctors = [];
  bool isLoading = true;
  IO.Socket? _previewSocket;
  String _myUserId = '';

  List<DoctorChatItem> get filteredDoctors => doctors
      .where((d) => d.name.toLowerCase().contains(searchQuery.toLowerCase()))
      .toList();

  int get unreadTotal => doctors.fold(0, (s, d) => s + d.unreadCount);

  @override
  void initState() {
    super.initState();
    _searchController.addListener(
        () => setState(() => searchQuery = _searchController.text));
    _loadMyId();
    loadDoctors();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMyId() async {
    final prefs = await SharedPreferences.getInstance();
    _myUserId = prefs.getString('userId') ?? '';
  }

  // ── Load doctors ──────────────────────────────────────────────────────────
  Future<void> loadDoctors() async {
    try {
      final data = await ApiService.getmydoctors();

      final List<DoctorChatItem> loaded =
          (data as List).map<DoctorChatItem>((doc) {
        String? imageUrl;
        final imgField = doc['userId']?['image'];
        if (imgField is Map) {
          imageUrl = imgField['secure_url']?.toString();
        } else if (imgField is String && imgField.isNotEmpty) {
          imageUrl = imgField;
        }

        return DoctorChatItem(
          userId: doc['userId']?['_id'] ?? 'Unknown',
          name: doc['userId']?['fullName']?.toString() ?? 'Unknown',
          specialty: doc['specialization']?.toString() ?? 'Doctor',
          imageUrl: imageUrl,
          rawData: Map<String, dynamic>.from(doc), // ✅ مضاف
        );
      }).toList();

      setState(() {
        doctors = loaded;
        isLoading = false;
      });

      _fetchLastMessages(loaded);
    } catch (e) {
      debugPrint('LOAD ERROR: $e');
      setState(() => isLoading = false);
    }
  }

  // ── Fetch last messages via socket ────────────────────────────────────────
  Future<void> _fetchLastMessages(List<DoctorChatItem> items) async {
    if (items.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';

    _previewSocket = IO.io(
      'https://medpal-production-01b6.up.railway.app/chat',
      IO.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .setExtraHeaders({'authorization': 'Bearer $token'})
          .disableAutoConnect()
          .build(),
    );

    _previewSocket!.connect();

    _previewSocket!.onConnect((_) {
      for (final d in items) {
        if (d.userId.isNotEmpty) {
          _previewSocket!.emit('getHistory', {
            'withUserId': d.userId,
            'page': 1,
            'limit': 1000000,
          });
        }
      }
    });

    _previewSocket!.on('chatHistory', (data) {
      if (!mounted) return;
      final msgs = (data['messages'] as List?) ?? [];
      if (msgs.isEmpty) return;

      final lastMsg = msgs.last;
      final senderId = lastMsg['senderId']?.toString() ?? '';
      final receiverId = lastMsg['receiverId']?.toString() ?? '';
      final attachment = lastMsg['attachment'];
      String text = lastMsg['message']?.toString() ?? '';
      if (text.isEmpty && attachment != null) {
        final mime = (attachment['mimeType'] ?? '').toString().toLowerCase();
        if (mime.startsWith('image/')) {
          text = '📷 Photo';
        } else if (mime.startsWith('audio/')) {
          text = '🎤 Voice message';
        } else {
          text = '📎 File';
        }
      }
      final createdAt = lastMsg['createdAt']?.toString() ?? '';

      final idx = doctors
          .indexWhere((d) => d.userId == senderId || d.userId == receiverId);
      if (idx != -1 && mounted) {
        setState(() {
          doctors[idx].lastMessage =
              text.isEmpty ? 'Tap to start chatting...' : 'Tap to start chatting...';
          doctors[idx].lastMessageTime = _formatTime(createdAt);
        });
      }
    });

    _previewSocket!.on('newMessage', (data) {
      if (!mounted) return;
      final senderId = data['senderId']?.toString() ?? '';
      final receiverId = data['receiverId']?.toString() ?? '';
      final attachment = data['attachment'];
      String text = data['message']?.toString() ?? '';
      if (text.isEmpty && attachment != null) {
        final mime = (attachment['mimeType'] ?? '').toString().toLowerCase();
        if (mime.startsWith('image/')) {
          text = '📷 Photo';
        } else if (mime.startsWith('audio/')) {
          text = '🎤 Voice message';
        } else {
          text = '📎 File';
        }
      }
      final createdAt = data['createdAt']?.toString() ?? '';

      final idx = doctors
          .indexWhere((d) => d.userId == senderId || d.userId == receiverId);
      if (idx != -1 && mounted) {
        setState(() {
          doctors[idx].lastMessage = text.isEmpty ? '📎 Media' : text;
          doctors[idx].lastMessageTime = _formatTime(createdAt);
          doctors[idx].unreadCount += 1;

          // bubble to top
          final item = doctors.removeAt(idx);
          doctors.insert(0, item);
        });
      }
    });
  }

  // ── Time formatter ────────────────────────────────────────────────────────
  String _formatTime(String? iso) {
    if (iso == null || iso.isEmpty) return _nowTime();
    try {
      final dt = DateTime.parse(iso).toLocal();
      final now = DateTime.now();
      if (dt.day == now.day &&
          dt.month == now.month &&
          dt.year == now.year) {
        return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      } else if (now.difference(dt).inDays == 1) {
        return 'Yesterday';
      } else {
        return '${dt.day}/${dt.month}';
      }
    } catch (_) {
      return _nowTime();
    }
  }

  String _nowTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  // ── Initials avatar ───────────────────────────────────────────────────────
  Widget _buildInitialsAvatar(String name) {
    final parts = name.trim().split(' ').where((e) => e.isNotEmpty).toList();
    String initials = parts.isEmpty
        ? '?'
        : parts.length == 1
            ? parts[0][0].toUpperCase()
            : '${parts[0][0]}${parts[1][0]}'.toUpperCase();

    return Container(
      color: AppColors.blueColor.withOpacity(.12),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: AppColors.blueColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  // ── TOP CARD ──────────────────────────────────────────────────────────────
  Widget _buildTopCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF1976D2), Color(0xFF42A5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.blueColor.withOpacity(.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.chat_rounded, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'My Doctors',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                '${doctors.length} doctor${doctors.length == 1 ? '' : 's'}',
                style:
                    const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          if (unreadTotal > 0)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$unreadTotal new',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700),
              ),
            ),
        ],
      ),
    );
  }

  // ── SEARCH BOX ────────────────────────────────────────────────────────────
  Widget _buildSearchBox() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search doctors...',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon:
              Icon(CupertinoIcons.search, color: AppColors.blueColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  // ── CHAT TILE ─────────────────────────────────────────────────────────────
  Widget _buildChatTile(DoctorChatItem doctor) {
    final hasUnread = doctor.unreadCount > 0;
    final hasImage =
        doctor.imageUrl != null && doctor.imageUrl!.isNotEmpty;

    return GestureDetector(
      onTap: () {
        setState(() => doctor.unreadCount = 0);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatsPageDoctor(
              doctorName: doctor.name,
              chatId: doctor.userId,
              patientImageUrl: doctor.imageUrl,
              doctorRawData: doctor.rawData, // ✅ مضاف
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasUnread
                ? AppColors.blueColor.withOpacity(.28)
                : const Color(0xFFF0F2F5),
            width: hasUnread ? 1.4 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.03),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Avatar ──────────────────────────────────────────────────
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.blueColor.withOpacity(.2),
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: hasImage
                    ? Image.network(
                        doctor.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _buildInitialsAvatar(doctor.name),
                      )
                    : _buildInitialsAvatar(doctor.name),
              ),
            ),
            const SizedBox(width: 12),
            // ── Info ────────────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dr. ${doctor.name}',
                    style: TextStyle(
                      fontWeight: hasUnread
                          ? FontWeight.w800
                          : FontWeight.w600,
                      fontSize: 15,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    doctor.specialty,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.blueColor.withOpacity(.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    doctor.lastMessage.isEmpty
                        ? 'Tap to start chatting...'
                        : doctor.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: hasUnread
                          ? const Color(0xFF1F2937)
                          : Colors.grey.shade500,
                      fontWeight: hasUnread
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // ── Time + Badge ─────────────────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  doctor.lastMessageTime,
                  style: TextStyle(
                    fontSize: 11,
                    color: hasUnread
                        ? AppColors.blueColor
                        : Colors.grey.shade500,
                    fontWeight:
                        hasUnread ? FontWeight.w700 : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 6),
                if (hasUnread)
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.blueColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${doctor.unreadCount}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopCard(),
            const SizedBox(height: 12),
            Expanded(
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                          color: AppColors.blueColor))
                  : RefreshIndicator(
                      color: AppColors.blueColor,
                      onRefresh: () async {
                        setState(() => isLoading = true);
                        await loadDoctors();
                      },
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding:
                            const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSearchBox(),
                            const SizedBox(height: 18),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Messages',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: AppColors.blueColor,
                                  ),
                                ),
                                if (unreadTotal > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.blueColor,
                                      borderRadius:
                                          BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '$unreadTotal unread',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            filteredDoctors.isEmpty
                                ? Center(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 60),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.chat_bubble_outline,
                                            size: 60,
                                            color: Colors.grey.shade300,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            searchQuery.isNotEmpty
                                                ? 'No results for "$searchQuery"'
                                                : 'No doctors yet',
                                            style: TextStyle(
                                                color: Colors.grey.shade500,
                                                fontSize: 15),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : ListView.separated(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: filteredDoctors.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 10),
                                    itemBuilder: (context, index) {
                                      final doctor =
                                          filteredDoctors[index];
                                      return _buildChatTile(doctor);
                                    },
                                  ),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}