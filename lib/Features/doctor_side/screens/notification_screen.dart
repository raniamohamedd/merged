import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/constants/colors.dart';
import 'package:flutter_application_2/Features/doctor_side/chats_doctor/view/chat_details_screen.dart' hide AppColors;
import 'package:flutter_application_2/Features/doctor_side/screens/patient_detailsdoc.dart';
import 'package:flutter_application_2/core/services/api_service.dart';

// ── Model ────────────────────────────────────────────────────────────────────
class DoctorNotificationItem {
  final String title;
  final String subtitle;
  final String time;
  final String type;
    final String id;

  bool isUnread;
  final String patientName;
  final String chatId;

  DoctorNotificationItem({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.type,
    required this.isUnread,
    required this.patientName,
    required this.chatId, required this.id,
  });

  DoctorNotificationItem copyWith({
    String? title,
    String? subtitle,
    String? time,
    String? type,
    bool? isUnread,
    String? patientName,
    String? chatId,
  }) {
    return DoctorNotificationItem(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      time: time ?? this.time,
      type: type ?? this.type,
      isUnread: isUnread ?? this.isUnread,
      patientName: patientName ?? this.patientName,
      chatId: chatId ?? this.chatId, id: this.id,
    );
  }
}

// ── Screen ───────────────────────────────────────────────────────────────────
class NotificationsPageDoctor extends StatefulWidget {
  const NotificationsPageDoctor({super.key});

  @override
  State<NotificationsPageDoctor> createState() => _NotificationsPageDoctorState();
}

class _NotificationsPageDoctorState extends State<NotificationsPageDoctor>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<DoctorNotificationItem> notifications = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRequests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRequests() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });
    try {
      final data = await ApiService.getDoctorRequests();
      setState(() {
        notifications = data.cast<DoctorNotificationItem>();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  // ── Getters ─────────────────────────────────────────────────────────────
  List<DoctorNotificationItem> get requestNotifications =>
      notifications.where((e) => e.type == 'request').toList();

  List<DoctorNotificationItem> get otherNotifications =>
      notifications.where((e) => e.type != 'request').toList();

  int get unreadCount => notifications.where((e) => e.isUnread).length;

  // ── Actions ─────────────────────────────────────────────────────────────
  void _markAllAsRead() {
    setState(() {
      for (var n in notifications) {
        n.isUnread = false;
      }
    });
    _showSnack('All notifications marked as read', Colors.green);
  }

  void _markOneAsRead(DoctorNotificationItem item) {
    setState(() {
      item.isUnread = false;
    });
  }

  void _removeNotification(DoctorNotificationItem item) {
    setState(() => notifications.remove(item));
  }

  Future<void> _acceptRequest(DoctorNotificationItem item) async {
    try {
      await ApiService.acceptRequest(item.id);
      _removeNotification(item);
      _showSnack('✅ Connection accepted from ${item.patientName}', AppColors.blueColor);
    } catch (_) {
      _showSnack('Failed to accept request', Colors.red);
    }
  }

  Future<void> _rejectRequest(DoctorNotificationItem item) async {
    try {
      await ApiService.rejectRequest(item.chatId);
      _removeNotification(item);
      _showSnack('Request from ${item.patientName} declined', Colors.redAccent);
    } catch (_) {
      _showSnack('Failed to reject request', Colors.red);
    }
  }

  void _openPatientDetails(DoctorNotificationItem item) {
    _markOneAsRead(item);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PatientDetailsPage(patientId: item.chatId),
      ),
    );
  }

  void _openChat(DoctorNotificationItem item) {
    _markOneAsRead(item);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatsPageDoctor(
          doctorName: item.patientName,
          chatId: item.chatId,
        ),
      ),
    );
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  // ── Helpers ──────────────────────────────────────────────────────────────
  String _initials(String name) {
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'request': return const Color(0xFF1976D2);
      case 'emergency': return Colors.red;
      case 'message': return Colors.indigo;
      case 'medication': return Colors.orange;
      case 'symptom': return Colors.purple;
      case 'success': return Colors.green;
      default: return Colors.grey;
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'request': return Icons.person_add_alt_1_rounded;
      case 'emergency': return Icons.warning_amber_rounded;
      case 'message': return Icons.chat_bubble_outline_rounded;
      case 'medication': return Icons.medication_outlined;
      case 'symptom': return Icons.monitor_heart_outlined;
      case 'success': return Icons.check_circle_outline_rounded;
      default: return Icons.notifications_none_rounded;
    }
  }

  // ── Request Card ─────────────────────────────────────────────────────────
  Widget _buildRequestCard(DoctorNotificationItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: item.isUnread
              ? AppColors.blueColor.withOpacity(.3)
              : const Color(0xFFF0F2F5),
          width: item.isUnread ? 1.4 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.03),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header row
            Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: AppColors.blueColor.withOpacity(.12),
                      child: Text(
                        _initials(item.patientName),
                        style: TextStyle(
                          color: AppColors.blueColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    if (item.isUnread)
                      Positioned(
                        top: 0, right: 0,
                        child: Container(
                          width: 12, height: 12,
                          decoration: BoxDecoration(
                            color: AppColors.blueColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.patientName,
                        style: TextStyle(
                          fontWeight: item.isUnread ? FontWeight.w800 : FontWeight.w700,
                          fontSize: 15,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.subtitle,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded,
                            size: 11, color: Colors.grey.shade400),
                        const SizedBox(width: 3),
                        Text(
                          item.time,
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.blueColor.withOpacity(.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'New Request',
                        style: TextStyle(
                          color: AppColors.blueColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFF0F2F5)),
            const SizedBox(height: 12),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey.shade700,
                      side: BorderSide(color: Colors.grey.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => _rejectRequest(item),
                    icon: const Icon(Icons.close_rounded, size: 16),
                    label: const Text('Decline',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blueColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => _acceptRequest(item),
                    icon: const Icon(Icons.check_rounded, size: 16),
                    label: const Text('Accept',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 8),
                // View patient
                InkWell(
                  onTap: () => _openPatientDetails(item),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.blueColor.withOpacity(.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.person_outline,
                      color: AppColors.blueColor,
                      size: 20,
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

  // ── General Notification Card ─────────────────────────────────────────────
  Widget _buildGeneralCard(DoctorNotificationItem item) {
    final color = _typeColor(item.type);

    return GestureDetector(
      onTap: () {
        _markOneAsRead(item);
        if (item.type == 'message') _openChat(item);
        else if (item.type != 'request') _openPatientDetails(item);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: item.isUnread ? color.withOpacity(.25) : const Color(0xFFF0F2F5),
            width: item.isUnread ? 1.2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.03),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(_typeIcon(item.type), color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: item.isUnread ? FontWeight.w800 : FontWeight.w700,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                      ),
                      if (item.isUnread)
                        Container(
                          width: 8, height: 8,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item.subtitle,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded,
                          size: 12, color: Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Text(
                        item.time,
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: color.withOpacity(.1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          item.type[0].toUpperCase() + item.type.substring(1),
                          style: TextStyle(
                            color: color, fontSize: 11, fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty State ──────────────────────────────────────────────────────────
  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Column(
          children: [
            CircleAvatar(
              radius: 38,
              backgroundColor: AppColors.blueColor.withOpacity(.08),
              child: Icon(
                Icons.notifications_none_rounded,
                color: AppColors.blueColor.withOpacity(.4),
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Tab Views ────────────────────────────────────────────────────────────
  Widget _buildRequestsTab() {
    if (requestNotifications.isEmpty) {
      return _buildEmptyState('No pending requests');
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: requestNotifications.length,
      itemBuilder: (_, i) => _buildRequestCard(requestNotifications[i]),
    );
  }

  Widget _buildOtherTab() {
    if (otherNotifications.isEmpty) {
      return _buildEmptyState('No notifications yet');
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: otherNotifications.length,
      itemBuilder: (_, i) => _buildGeneralCard(otherNotifications[i]),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Column(
                children: [
                  // Top card
                  Container(
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
                         // 🔙 Back Button
    IconButton(
      onPressed: () => Navigator.pop(context),
      icon: const Icon(
        Icons.arrow_back_ios_new_rounded,
        color: Colors.white,
        size: 20,
      ),
    ),

                       
                       
                        Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.18),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              const Icon(
                                Icons.notifications_active_outlined,
                                color: Colors.white,
                                size: 26,
                              ),
                              if (unreadCount > 0)
                                Positioned(
                                  top: 8, right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: const BoxDecoration(
                                      color: Colors.redAccent,
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 10, minHeight: 10,
                                    ),
                                    child: Text(
                                      '$unreadCount',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Notifications',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                unreadCount > 0
                                    ? '$unreadCount unread notification${unreadCount > 1 ? 's' : ''}'
                                    : 'All caught up ✓',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            // if (unreadCount > 0)
                            //   TextButton(
                            //     onPressed: _markAllAsRead,
                            //     child: const Text(
                            //       'Mark all',
                            //       style: TextStyle(
                            //         color: Colors.white70,
                            //         fontWeight: FontWeight.w600,
                            //         fontSize: 12,
                            //       ),
                            //     ),
                            //   ),
                            IconButton(
                              onPressed: _loadRequests,
                              icon: const Icon(Icons.refresh_rounded, color: Colors.white70, size: 22),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Tab bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFF0F2F5)),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      labelColor: AppColors.blueColor,
                      unselectedLabelColor: Colors.grey.shade500,
                      indicatorColor: AppColors.blueColor,
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                      tabs: [
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Requests'),
                              if (requestNotifications.isNotEmpty) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.blueColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${requestNotifications.length}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Other'),
                              if (otherNotifications.any((e) => e.isUnread)) ...[
                                const SizedBox(width: 6),
                                Container(
                                  width: 8, height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.redAccent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 4),

            // Content
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : hasError
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline,
                                  size: 48, color: Colors.red.shade300),
                              const SizedBox(height: 12),
                              Text(
                                'Failed to load notifications',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _loadRequests,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Retry'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.blueColor,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        )
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            _buildRequestsTab(),
                            _buildOtherTab(),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }
}