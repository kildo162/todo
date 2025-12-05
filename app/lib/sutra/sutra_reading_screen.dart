import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:app/sutra/sutra_controller.dart';
import 'package:app/sutra/sutra_models.dart';
import 'package:app/utils/toast_utils.dart';

class SutraReadingScreen extends StatefulWidget {
  final SutraItem item;

  const SutraReadingScreen({super.key, required this.item});

  @override
  State<SutraReadingScreen> createState() => _SutraReadingScreenState();
}

class _SutraReadingScreenState extends State<SutraReadingScreen> {
  final SutraController controller =
      Get.isRegistered<SutraController>() ? Get.find<SutraController>() : Get.put(SutraController(), permanent: true);
  double fontSize = 16;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final color = item.category.color;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        backgroundColor: color,
        elevation: 0,
        title: Text(item.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.text_increase),
            onPressed: () => setState(() => fontSize = (fontSize + 1).clamp(14, 26)),
            tooltip: 'Tăng cỡ chữ',
          ),
          IconButton(
            icon: const Icon(Icons.text_decrease),
            onPressed: () => setState(() => fontSize = (fontSize - 1).clamp(14, 26)),
            tooltip: 'Giảm cỡ chữ',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                border: Border(
                  bottom: BorderSide(color: color.withOpacity(0.25)),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.menu_book, color: color),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Chế độ đọc • ${item.category.label}',
                      style: TextStyle(color: color, fontWeight: FontWeight.w700),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await controller.logReading(item.id);
                      ToastUtils.showToast('Đã ghi nhận một lần đọc', backgroundColor: color);
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Đánh dấu đã đọc'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(fontSize: fontSize + 4, fontWeight: FontWeight.w800, color: color),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.description,
                      style: TextStyle(fontSize: fontSize - 1, color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      item.content,
                      style: TextStyle(fontSize: fontSize, height: 1.6, color: Colors.grey.shade900),
                    ),
                    const SizedBox(height: 24),
                    if (item.durationMinutes != null)
                      Text(
                        'Gợi ý: ${item.durationMinutes} phút • ${item.level}',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    if (item.tags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: item.tags
                            .map((tag) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    tag,
                                    style: TextStyle(color: color, fontWeight: FontWeight.w600),
                                  ),
                                ))
                            .toList(),
                      ),
                    ],
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
