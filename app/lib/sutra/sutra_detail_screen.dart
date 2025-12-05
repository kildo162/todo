import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:app/sutra/sutra_controller.dart';
import 'package:app/sutra/sutra_models.dart';
import 'package:app/sutra/sutra_reading_screen.dart';

class SutraDetailScreen extends StatelessWidget {
  final SutraItem item;

  SutraDetailScreen({super.key, required this.item});

  final SutraController controller =
      Get.isRegistered<SutraController>() ? Get.find<SutraController>() : Get.put(SutraController(), permanent: true);

  @override
  Widget build(BuildContext context) {
    final themeColor = item.category.color;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        backgroundColor: themeColor,
        elevation: 0,
        title: Text(item.title),
        actions: [
          Obx(() {
            final isFav = controller.isFavorite(item.id);
            return IconButton(
              icon: Icon(isFav ? Icons.star : Icons.star_border),
              onPressed: () => controller.toggleFavorite(item.id),
              color: isFav ? Colors.amber : Colors.white,
            );
          }),
        ],
      ),
      body: Obx(() {
        final chantCount = controller.chantCountFor(item.id);
        final completed = controller.isCompleted(item.id);

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: themeColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            item.category == SutraCategory.chant
                                ? Icons.self_improvement
                                : item.category == SutraCategory.scripture
                                    ? Icons.menu_book_outlined
                                    : Icons.psychology_alt,
                            color: themeColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                              const SizedBox(height: 6),
                              Text(item.description, style: TextStyle(color: Colors.grey.shade700)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _chip(text: item.category.label, icon: Icons.category, color: themeColor),
                        if (item.targetCount != null)
                          _chip(text: 'Mục tiêu ${item.targetCount} biến', icon: Icons.flag, color: Colors.blue.shade600),
                        if (item.durationMinutes != null)
                          _chip(text: '${item.durationMinutes} phút', icon: Icons.timer, color: Colors.deepPurple.shade600),
                        ...item.tags.map((tag) => _chip(text: tag, icon: Icons.label, color: Colors.grey.shade700)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Nội dung tóm lược', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 10),
                    Text(
                      item.content,
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade800, height: 1.5),
                    ),
                    const SizedBox(height: 14),
                    Align(
                      alignment: Alignment.centerRight,
                      child: OutlinedButton.icon(
                        onPressed: () => Get.to(() => SutraReadingScreen(item: item)),
                        icon: const Icon(Icons.chrome_reader_mode_outlined, size: 18),
                        label: const Text('Chế độ đọc'),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: themeColor.withOpacity(0.5)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (item.category == SutraCategory.chant)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Ghi nhận tụng niệm', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Text('Hiện tại: $chantCount biến', style: TextStyle(color: Colors.blue.shade900)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => controller.incrementChant(item.id),
                            icon: const Icon(Icons.add),
                            label: const Text('Thêm 1 biến'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade600,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          OutlinedButton(
                            onPressed: () => controller.resetChantCounts(),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.blue.shade300),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Đặt lại tất cả'),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.psychology_alt, color: Colors.green.shade700),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Đánh dấu hoàn thành', style: TextStyle(fontWeight: FontWeight.w700)),
                            Text(
                              'Giữ thói quen học pháp và ôn lại định kỳ.',
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: completed,
                        onChanged: (_) => controller.toggleCompleted(item.id),
                        activeColor: Colors.white,
                        activeTrackColor: Colors.green.shade600,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _chip({required String text, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
