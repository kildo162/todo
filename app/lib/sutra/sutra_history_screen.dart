import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:app/sutra/sutra_controller.dart';
import 'package:app/sutra/sutra_models.dart';

class SutraHistoryScreen extends StatelessWidget {
  SutraHistoryScreen({super.key});

  final SutraController controller = Get.isRegistered<SutraController>()
      ? Get.find<SutraController>()
      : Get.put(SutraController(), permanent: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D87F2),
        elevation: 0,
        title: const Text('Nhật ký tụng/đọc'),
      ),
      body: Obx(() {
        final entries = controller.recentHistory;
        if (entries.isEmpty) {
          return Center(
            child: Text(
              'Chưa có lịch sử, hãy bắt đầu tụng hoặc đọc một bài.',
              style: TextStyle(color: Colors.grey.shade700),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          itemCount: entries.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final entry = entries[index];
            final item = controller.findById(entry.itemId);
            return _HistoryTile(entry: entry, item: item);
          },
        );
      }),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final SutraHistoryEntry entry;
  final SutraItem? item;

  const _HistoryTile({required this.entry, required this.item});

  @override
  Widget build(BuildContext context) {
    final color = entry.type.color;
    final title = item?.title ?? 'Không tìm thấy bài';
    final dateStr = _formatDate(entry.time);
    final subtitle = _buildSubtitle(entry);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              entry.type == SutraActionType.chant
                  ? Icons.self_improvement
                  : entry.type == SutraActionType.read
                  ? Icons.menu_book
                  : Icons.check_circle,
              color: color,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: Colors.grey.shade700)),
                const SizedBox(height: 4),
                Text(
                  dateStr,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              entry.type.label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '${time.day}/${time.month}/${time.year} · $h:$m';
  }

  String _buildSubtitle(SutraHistoryEntry entry) {
    switch (entry.type) {
      case SutraActionType.chant:
        return 'Tụng thêm ${entry.count} biến';
      case SutraActionType.read:
        return 'Đánh dấu đã đọc${entry.durationMinutes != null ? ' ~${entry.durationMinutes} phút' : ''}';
      case SutraActionType.complete:
        return 'Đánh dấu hoàn thành';
    }
  }
}
