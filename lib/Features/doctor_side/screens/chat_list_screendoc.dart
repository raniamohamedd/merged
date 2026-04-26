import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/Features/doctor_side/chats_doctor/view/chat_details_screen.dart'
    hide AppColors;
import 'package:flutter_application_2/core/constants/colors.dart';
import 'package:flutter_application_2/core/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

// ─── Model ─────────────────────────────────────────────────────────────────
class PatientChatItem {
  final String userId;           // user _id → للـ socket
  final String patientProfileId;
  final String name;
  final String? imageUrl;        // صورة Cloudinary الحقيقية
  String lastMessage;
  String lastMessageTime;
  int unreadCount;

  PatientChatItem({
    required this.userId,
    required this.patientProfileId,
    required this.name,
    this.imageUrl,
    this.lastMessage = '',
    this.lastMessageTime = '',
    this.unreadCount = 0,
  });
}

// ─── Screen ────────────────────────────────────────────────────────────────
class ChatsListScreenDoctor extends StatefulWidget {
  const ChatsListScreenDoctor({super.key});

  @override
  State<ChatsListScreenDoctor> createState() => _ChatsListScreenDoctorState();
}

class _ChatsListScreenDoctorState extends State<ChatsListScreenDoctor> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';
  List<PatientChatItem> patients = [];
  bool isLoading = true;
  IO.Socket? _previewSocket;

  List<PatientChatItem> get filteredPatients => patients
      .where((p) => p.name.toLowerCase().contains(searchQuery.toLowerCase()))
      .toList();

  int get unreadTotal => patients.fold(0, (s, p) => s + p.unreadCount);

  // ─── تحميل المرضى من API ─────────────────────────────────────────────────
  Future<void> loadPatients() async {
    try {
      final response = await ApiService.getPatients();
      final List data = response['data'] ?? [];

      final List<PatientChatItem> loaded = data.map<PatientChatItem>((e) {
        final user = e['userId'] ?? {};

        // ── استخرج صورة المريض الحقيقية ──
        String? imageUrl;
        final imgField = user['image'];
        if (imgField is Map) {
          // {"secure_url": "...", "public_id": "..."}
          imageUrl = imgField['secure_url']?.toString();
        } else if (imgField is String && imgField.isNotEmpty) {
          imageUrl = imgField;
        }

        return PatientChatItem(
          userId: user['_id']?.toString() ?? '',
          patientProfileId: e['_id']?.toString() ?? '',
          name: user['fullName']?.toString() ?? 'Unknown',
          imageUrl: imageUrl,
        );
      }).toList();

      setState(() {
        patients = loaded;
        isLoading = false;
      });

      _fetchLastMessages(loaded);
    } catch (e) {
      debugPrint('LOAD ERROR: $e');
      setState(() => isLoading = false);
    }
  }

  // ─── جلب آخر رسالة عبر Socket ────────────────────────────────────────────
  Future<void> _fetchLastMessages(List<PatientChatItem> items) async {
    if (items.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';

    _previewSocket = IO.io(
      'https://medpal-production-e325.up.railway.app/chat',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setExtraHeaders({'authorization': 'System $token'})
          .disableAutoConnect()
          .build(),
    );

    _previewSocket!.connect();

    _previewSocket!.onConnect((_) {
      for (final p in items) {
        if (p.userId.isNotEmpty) {
          _previewSocket!.emit('getHistory', {
            'withUserId': p.userId,
            'page': 1,
            'limit': 1,
          });
        }
      }
    });

    // آخر رسالة من تاريخ المحادثة
    _previewSocket!.on('chatHistory', (data) {
      if (!mounted) return;
      final msgs = (data['messages'] as List?) ?? [];
      if (msgs.isEmpty) return;

      final lastMsg = msgs.first;
      final senderId = lastMsg['senderId']?.toString() ?? '';
      final receiverId = lastMsg['receiverId']?.toString() ?? '';
      final text = lastMsg['message']?.toString() ?? '';
      final createdAt = lastMsg['createdAt']?.toString() ?? '';

      final idx = patients.indexWhere(
        (p) => p.userId == senderId || p.userId == receiverId,
      );

      if (idx != -1 && mounted) {
        setState(() {
          patients[idx].lastMessage = text.isEmpty ? '📎 Media' : text;
          patients[idx].lastMessageTime = _formatTime(createdAt);
        });
      }
    });

    // رسائل جديدة real-time
    _previewSocket!.on('newMessage', (data) {
      if (!mounted) return;
      final senderId = data['senderId']?.toString() ?? '';
      final text = data['message']?.toString() ?? '';

      final idx = patients.indexWhere((p) => p.userId == senderId);
      if (idx != -1) {
        setState(() {
          patients[idx].lastMessage = text.isEmpty ? '📎 Media' : text;
          patients[idx].lastMessageTime = _formatTime(null);
          patients[idx].unreadCount += 1;
          final item = patients.removeAt(idx);
          patients.insert(0, item);
        });
      }
    });
  }

  String _formatTime(String? iso) {
    if (iso == null || iso.isEmpty) {
      final n = TimeOfDay.now();
      return '${n.hour.toString().padLeft(2, '0')}:${n.minute.toString().padLeft(2, '0')}';
    }
    try {
      final dt = DateTime.parse(iso).toLocal();
      final now = DateTime.now();
      if (dt.day == now.day && dt.month == now.month && dt.year == now.year) {
        return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      } else if (now.difference(dt).inDays == 1) {
        return 'Yesterday';
      } else {
        return '${dt.day}/${dt.month}';
      }
    } catch (_) {
      return '';
    }
  }

  @override
  void initState() {
    super.initState();
    loadPatients();
  }

  @override
  void dispose() {
    _previewSocket?.disconnect();
    _searchController.dispose();
    super.dispose();
  }

  // ─── Avatar: صورة حقيقية أو initials ─────────────────────────────────────
  Widget _buildAvatar(PatientChatItem patient) {
    final hasImage =
        patient.imageUrl != null && patient.imageUrl!.isNotEmpty;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.blueColor.withOpacity(.12),
          backgroundImage:
              hasImage ? NetworkImage(patient.imageUrl!) : null,
          onBackgroundImageError: hasImage ? (_, __) {} : null,
          child: !hasImage
              ? Text(
                  _getInitials(patient.name),
                  style: TextStyle(
                    color: AppColors.blueColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                )
              : null,
        ),
        Positioned(
          bottom: -1,
          right: -1,
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  String _getInitials(String name) {
    final parts =
        name.trim().split(' ').where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  // ─── Chat Tile ────────────────────────────────────────────────────────────
  Widget _buildChatTile(PatientChatItem patient) {
    final hasUnread = patient.unreadCount > 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () {
            setState(() => patient.unreadCount = 0);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatsPageDoctor(
                  doctorName: patient.name,
                  chatId: patient.userId,
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
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
                _buildAvatar(patient),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient.name,
                        style: TextStyle(
                          fontWeight: hasUnread
                              ? FontWeight.w800
                              : FontWeight.w600,
                          fontSize: 15,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        patient.lastMessage.isEmpty
                            ? 'Tap to start chatting...'
                            : patient.lastMessage,
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      patient.lastMessageTime,
                      style: TextStyle(
                        fontSize: 11,
                        color: hasUnread
                            ? AppColors.blueColor
                            : Colors.grey.shade500,
                        fontWeight: hasUnread
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (hasUnread)
                      Container(
                        constraints: const BoxConstraints(
                            minWidth: 22, minHeight: 22),
                        alignment: Alignment.center,
                        padding:
                            const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          color: AppColors.blueColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${patient.unreadCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else
                      const SizedBox(height: 22),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────────────
  Widget _buildTopCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.blueColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.blueColor.withOpacity(.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.18),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.chat_bubble_outline_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Chats',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  unreadTotal > 0
                      ? '$unreadTotal unread message${unreadTotal > 1 ? 's' : ''}'
                      : '${patients.length} conversations',
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() => isLoading = true);
              loadPatients();
            },
            icon: const Icon(Icons.refresh_rounded,
                color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBox() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF0F2F5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.03),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => searchQuery = v),
        decoration: InputDecoration(
          hintText: 'Search patients...',
          hintStyle: TextStyle(color: Colors.grey.shade500),
          prefixIcon:
              Icon(CupertinoIcons.search, color: AppColors.blueColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 40, 16, 0),
              child: _buildTopCard(),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSearchBox(),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Text(
                                'Messages',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: AppColors.blueColor,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.blueColor.withOpacity(.12),
                                  borderRadius:
                                      BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${filteredPatients.length}',
                                  style: TextStyle(
                                    color: AppColors.blueColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (filteredPatients.isEmpty)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 50),
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      radius: 38,
                                      backgroundColor: AppColors.blueColor
                                          .withOpacity(.08),
                                      child: Icon(
                                        Icons.chat_bubble_outline_rounded,
                                        color: AppColors.blueColor
                                            .withOpacity(.4),
                                        size: 38,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      searchQuery.isEmpty
                                          ? 'No patients yet'
                                          : 'No results for "$searchQuery"',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            ListView.builder(
                              itemCount: filteredPatients.length,
                              shrinkWrap: true,
                              physics:
                                  const NeverScrollableScrollPhysics(),
                              itemBuilder: (_, i) =>
                                  _buildChatTile(filteredPatients[i]),
                            ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}