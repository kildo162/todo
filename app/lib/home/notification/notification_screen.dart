import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'notification_controller.dart';
import 'notification_model.dart';

class NotificationTabScreen extends StatelessWidget {
  NotificationTabScreen({super.key});

  final NotificationController controller =
      Get.isRegistered<NotificationController>() ? Get.find<NotificationController>() : Get.put(NotificationController());

  Widget _svg(String path, {double size = 20, Color? color}) {
    return SvgPicture.asset(
      path,
      height: size,
      width: size,
      colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 66,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
          ),
        ),
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), shape: BoxShape.circle),
              child: _svg('assets/icons/outline/bell.svg', size: 18, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Thông báo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
                Text('Cập nhật mới nhất', style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: SvgPicture.asset('assets/icons/outline/check.svg', height: 22, colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
            onPressed: controller.markAllAsRead,
            tooltip: 'Đánh dấu đã đọc',
          ),
          IconButton(
            icon: _svg('assets/icons/outline/cog-6-tooth.svg', size: 20, color: Colors.white),
            onPressed: () {},
            tooltip: 'Cài đặt',
          ),
          const SizedBox(width: 6),
        ],
      ),
      backgroundColor: const Color(0xFFF6F8FB),
      body: Obx(() {
        final notifications = controller.notifications;
        final unreadCount = notifications.where((n) => !n.read).length;

        return RefreshIndicator(
          onRefresh: controller.fetchNotifications,
          child: notifications.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 160),
                    _EmptyNotificationState(),
                  ],
                )
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: notifications.length + 2, // summary + notifications + bottom gap
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _NotificationSummary(unreadCount: unreadCount, totalCount: notifications.length);
                    }
                    if (index == notifications.length + 1) {
                      return const SizedBox(height: 60);
                    }
                    final item = notifications[index - 1];
                    return _NotificationTile(item: item);
                  },
                ),
        );
      }),
    );
  }
}

String formatTime(DateTime time) {
  final now = DateTime.now();
  final diff = now.difference(time);
  if (diff.inMinutes < 1) return 'Vừa xong';
  if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
  if (diff.inHours < 24) return '${diff.inHours} giờ trước';
  return '${diff.inDays} ngày trước';
}

class _NotificationSummary extends StatelessWidget {
  final int unreadCount;
  final int totalCount;

  const _NotificationSummary({required this.unreadCount, required this.totalCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF0D87F2), Color(0xFF54C6EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: Colors.blue.shade100, blurRadius: 10, offset: const Offset(0, 6)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.28)),
            ),
            child: const Icon(Icons.notifications_active, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thông báo',
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  '$totalCount tổng · $unreadCount chưa đọc',
                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  'Kéo xuống để làm mới danh sách.',
                  style: TextStyle(color: Colors.white.withOpacity(0.78), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel item;

  const _NotificationTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final isRead = item.read;
    final timeString = formatTime(item.time);
    Widget svg(String path, {double size = 20, Color? color}) {
      return SvgPicture.asset(
        path,
        height: size,
        width: size,
        colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isRead ? Colors.grey.shade200 : Colors.blue.shade100),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isRead ? Colors.grey.shade200 : Colors.blue.shade50,
              ),
              child: Center(
                child: svg('assets/icons/solid/bell.svg', size: 20, color: isRead ? Colors.grey.shade600 : Colors.blue.shade500),
              ),
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
                          fontSize: 15,
                          fontWeight: isRead ? FontWeight.w600 : FontWeight.w800,
                          color: Colors.grey.shade900,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isRead ? Colors.grey.shade100 : Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        timeString,
                        style: TextStyle(fontSize: 11, color: isRead ? Colors.grey.shade600 : Colors.blue.shade600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.body,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.3),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    svg(
                      isRead ? 'assets/icons/outline/check-circle.svg' : 'assets/icons/solid/check-circle.svg',
                      size: 14,
                      color: isRead ? Colors.grey.shade400 : Colors.blue.shade400,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isRead ? 'Đã đọc' : 'Chưa đọc',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isRead ? Colors.grey.shade500 : Colors.blue.shade600),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyNotificationState extends StatelessWidget {
  const _EmptyNotificationState();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade500),
        const SizedBox(height: 12),
        Text('Chưa có thông báo', style: TextStyle(color: Colors.grey.shade700, fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text(
          'Khi có cập nhật mới, thông báo sẽ hiển thị tại đây.',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
