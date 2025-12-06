import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:app/sutra/sutra_controller.dart';
import 'package:app/sutra/sutra_models.dart';
import 'package:app/sutra/sutra_detail_screen.dart';
import 'package:app/sutra/sutra_history_screen.dart';
import 'package:app/sutra/sutra_reading_screen.dart';
import 'package:app/utils/toast_utils.dart';

class SutraScreen extends StatelessWidget {
  SutraScreen({super.key});

  final SutraController controller = Get.isRegistered<SutraController>()
      ? Get.find<SutraController>()
      : Get.put(SutraController(), permanent: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0D87F2), Color(0xFF34AADC)],
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
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.menu_book_outlined, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sutra',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                Text(
                  'Tụng kinh · Kinh kệ · Phật pháp',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => controller.resetChantCounts(),
            tooltip: 'Đặt lại số biến tụng',
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Obx(() {
        final totalChants = controller.totalChantCount;
        final completedLessons = controller.completedLessons;
        final favorites = controller.favoriteItems.length;
        final filtered = controller.filteredItems;
        final isCompact = controller.compactMode.value;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StatHeader(
                totalChants: totalChants,
                completedLessons: completedLessons,
                favorites: favorites,
              ),
              const SizedBox(height: 16),
              _QuickPractice(
                onTap: () {
                  if (filtered.isEmpty) return;
                  final target = filtered.firstWhere(
                    (e) => e.category == SutraCategory.chant,
                    orElse: () => filtered.first,
                  );
                  controller.incrementChant(target.id);
                  ToastUtils.showToast(
                    'Đã ghi nhận 1 biến tụng cho "${target.title}"',
                    backgroundColor: Colors.blue,
                  );
                },
                onOpenFavorites: favorites > 0
                    ? () => Get.to(
                        () => SutraDetailScreen(
                          item: controller.favoriteItems.first,
                        ),
                      )
                    : null,
                onOpenHistory: () => Get.to(() => SutraHistoryScreen()),
              ),
              const SizedBox(height: 14),
              _FilterBar(controller: controller),
              const SizedBox(height: 18),
              if (filtered.isEmpty)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    'Không tìm thấy bài phù hợp, hãy đổi bộ lọc hoặc tìm kiếm khác.',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                )
              else
                Column(
                  children: filtered
                      .map(
                        (item) => isCompact
                            ? _CompactItemTile(
                                item: item,
                                controller: controller,
                              )
                            : _buildCardByCategory(item, controller),
                      )
                      .toList(),
                ),
              const SizedBox(height: 18),
              _SectionTitle(
                title: 'Nhật ký gần đây',
                subtitle: 'Theo dõi lần tụng/đọc mới nhất',
                color: Colors.grey.shade800,
              ),
              const SizedBox(height: 10),
              Obx(() {
                final history = controller.recentHistory;
                if (history.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      'Chưa có lịch sử, hãy bắt đầu tụng hoặc đọc một bài.',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  );
                }
                return Column(
                  children: history.take(5).map((h) {
                    final item = controller.findById(h.itemId);
                    final color = h.type.color;
                    final dateStr =
                        '${h.time.day}/${h.time.month} ${h.time.hour.toString().padLeft(2, '0')}:${h.time.minute.toString().padLeft(2, '0')}';
                    final subtitle = h.type == SutraActionType.chant
                        ? 'Tụng +${h.count}'
                        : h.type == SutraActionType.read
                        ? 'Đọc${h.durationMinutes != null ? ' ~${h.durationMinutes}p' : ''}'
                        : 'Hoàn thành';
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
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
                              h.type == SutraActionType.chant
                                  ? Icons.self_improvement
                                  : h.type == SutraActionType.read
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
                                  item?.title ?? 'Không tìm thấy bài',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  subtitle,
                                  style: TextStyle(color: Colors.grey.shade700),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  dateStr,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: item != null
                                ? () => Get.to(
                                    () => SutraDetailScreen(item: item),
                                  )
                                : null,
                            child: const Text('Xem'),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              }),
              const SizedBox(height: 24),
            ],
          ),
        );
      }),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final SutraController controller;

  const _FilterBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          onChanged: (value) => controller.searchQuery.value = value,
          decoration: InputDecoration(
            hintText: 'Tìm kiếm kinh, chú, bài học...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: Obx(() {
              if (controller.searchQuery.value.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => controller.searchQuery.value = '',
                );
              }
              return const SizedBox.shrink();
            }),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _filterChip(
              label: 'Tụng kinh',
              category: SutraCategory.chant,
              controller: controller,
            ),
            _filterChip(
              label: 'Kinh kệ',
              category: SutraCategory.scripture,
              controller: controller,
            ),
            _filterChip(
              label: 'Bài học',
              category: SutraCategory.lesson,
              controller: controller,
            ),
            Obx(() {
              final fav = controller.favoritesOnly.value;
              return FilterChip(
                label: const Text('Ưa thích'),
                selected: fav,
                onSelected: (v) => controller.favoritesOnly.value = v,
                selectedColor: Colors.orange.shade100,
                checkmarkColor: Colors.orange.shade700,
              );
            }),
            Obx(() {
              final done = controller.completedOnly.value;
              return FilterChip(
                label: const Text('Đã hoàn thành'),
                selected: done,
                onSelected: (v) => controller.completedOnly.value = v,
                selectedColor: Colors.green.shade100,
                checkmarkColor: Colors.green.shade700,
              );
            }),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Obx(() {
                return DropdownButtonFormField<String>(
                  value: controller.sortKey.value,
                  decoration: InputDecoration(
                    labelText: 'Sắp xếp',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'default', child: Text('Mặc định')),
                    DropdownMenuItem(value: 'recent', child: Text('Gần đây')),
                    DropdownMenuItem(
                      value: 'duration',
                      child: Text('Thời lượng tăng'),
                    ),
                    DropdownMenuItem(value: 'title', child: Text('Tên A-Z')),
                  ],
                  onChanged: (value) {
                    if (value != null) controller.sortKey.value = value;
                  },
                );
              }),
            ),
            const SizedBox(width: 12),
            Obx(() {
              final compact = controller.compactMode.value;
              return OutlinedButton.icon(
                onPressed: () => controller.compactMode.value = !compact,
                icon: Icon(
                  compact
                      ? Icons.view_agenda_outlined
                      : Icons.view_comfy_alt_outlined,
                ),
                label: Text(compact ? 'Chi tiết' : 'Gọn'),
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _filterChip({
    required String label,
    required SutraCategory category,
    required SutraController controller,
  }) {
    return Obx(() {
      final selected = controller.activeCategories.contains(category);
      return FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (v) {
          if (v) {
            controller.activeCategories.add(category);
          } else {
            controller.activeCategories.remove(category);
          }
          controller.activeCategories.refresh();
        },
        selectedColor: category.color.withOpacity(0.15),
        checkmarkColor: category.color,
      );
    });
  }
}

class _StatHeader extends StatelessWidget {
  final int totalChants;
  final int completedLessons;
  final int favorites;

  const _StatHeader({
    required this.totalChants,
    required this.completedLessons,
    required this.favorites,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF0D87F2), Color(0xFF34AADC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade100,
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
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
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: const Icon(Icons.spa_rounded, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hành trì hôm nay',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      'Ghi nhận tụng niệm và học pháp để nuôi dưỡng chánh niệm.',
                      style: TextStyle(color: Colors.white.withOpacity(0.9)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _statTile(
                'Biến tụng',
                '$totalChants',
                Icons.favorite,
                Colors.white,
              ),
              const SizedBox(width: 10),
              _statTile(
                'Bài học',
                '$completedLessons',
                Icons.school,
                Colors.white,
              ),
              const SizedBox(width: 10),
              _statTile('Ưa thích', '$favorites', Icons.star, Colors.white),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statTile(String label, String value, IconData icon, Color textColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: textColor),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(color: textColor.withOpacity(0.9))),
          ],
        ),
      ),
    );
  }
}

class _QuickPractice extends StatelessWidget {
  final VoidCallback onTap;
  final VoidCallback? onOpenFavorites;
  final VoidCallback? onOpenHistory;

  const _QuickPractice({
    required this.onTap,
    this.onOpenFavorites,
    this.onOpenHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.play_circle_outline, color: Colors.blue.shade700),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bắt đầu tụng nhanh',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  'Ghi nhận thêm 1 biến tụng vào mục đầu tiên trong danh sách.',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Ghi nhận'),
          ),
          const SizedBox(width: 8),
          if (onOpenFavorites != null)
            OutlinedButton(
              onPressed: onOpenFavorites,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.blue.shade200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Ưa thích'),
            ),
          const SizedBox(width: 8),
          if (onOpenHistory != null)
            OutlinedButton(
              onPressed: onOpenHistory,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.blue.shade200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Lịch sử'),
            ),
        ],
      ),
    );
  }
}

class _ChantCard extends StatelessWidget {
  final SutraItem item;
  final SutraController controller;

  const _ChantCard({required this.item, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
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
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.self_improvement,
                  color: Colors.blue.shade700,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  controller.isFavorite(item.id)
                      ? Icons.star
                      : Icons.star_border,
                  color: controller.isFavorite(item.id)
                      ? Colors.orange
                      : Colors.grey.shade500,
                ),
                onPressed: () => controller.toggleFavorite(item.id),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              if (item.targetCount != null)
                _chip(
                  icon: Icons.flag,
                  text: 'Mục tiêu: ${item.targetCount} biến',
                  color: Colors.blue.shade100,
                  textColor: Colors.blue.shade800,
                ),
              if (item.durationMinutes != null)
                _chip(
                  icon: Icons.timer,
                  text: '${item.durationMinutes} phút',
                  color: Colors.indigo.shade50,
                  textColor: Colors.indigo.shade700,
                ),
              ...item.tags.map(
                (tag) => _chip(
                  icon: Icons.tag,
                  text: tag,
                  color: Colors.grey.shade200,
                  textColor: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Obx(() {
            final count = controller.chantCountFor(item.id);
            final progress = controller.chantProgress(item.id);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Đã tụng: $count',
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (item.targetCount != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        '· Mục tiêu ${item.targetCount}',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress == 0 ? 0.02 : progress,
                    backgroundColor: Colors.grey.shade200,
                    minHeight: 8,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.blue.shade600,
                    ),
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 10),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () => controller.incrementChant(item.id),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Tụng +1'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: () => Get.to(() => SutraDetailScreen(item: item)),
                icon: const Icon(Icons.menu_book_outlined, size: 18),
                label: const Text('Xem chi tiết'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.blue.shade200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompactItemTile extends StatelessWidget {
  final SutraItem item;
  final SutraController controller;

  const _CompactItemTile({required this.item, required this.controller});

  @override
  Widget build(BuildContext context) {
    final color = item.category.color;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
              item.category == SutraCategory.chant
                  ? Icons.self_improvement
                  : item.category == SutraCategory.scripture
                  ? Icons.menu_book_outlined
                  : Icons.psychology_alt,
              color: color,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    if (item.durationMinutes != null)
                      _chip(
                        icon: Icons.timer,
                        text: '${item.durationMinutes}p',
                        color: color.withOpacity(0.15),
                        textColor: color,
                      ),
                    if (item.targetCount != null)
                      _chip(
                        icon: Icons.flag,
                        text: '${item.targetCount} biến',
                        color: color.withOpacity(0.15),
                        textColor: color,
                      ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                icon: Icon(
                  controller.isFavorite(item.id)
                      ? Icons.star
                      : Icons.star_border,
                  color: controller.isFavorite(item.id)
                      ? Colors.orange
                      : Colors.grey.shade500,
                ),
                onPressed: () => controller.toggleFavorite(item.id),
              ),
              TextButton(
                onPressed: () => Get.to(() => SutraDetailScreen(item: item)),
                child: const Text('Xem'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _buildCardByCategory(SutraItem item, SutraController controller) {
  switch (item.category) {
    case SutraCategory.chant:
      return _ChantCard(item: item, controller: controller);
    case SutraCategory.scripture:
      return _ScriptureCard(item: item, controller: controller);
    case SutraCategory.lesson:
      return _LessonCard(item: item, controller: controller);
  }
}

class _ScriptureCard extends StatelessWidget {
  final SutraItem item;
  final SutraController controller;

  const _ScriptureCard({required this.item, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
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
                  color: Colors.deepPurple.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.menu_book_rounded,
                  color: Colors.deepPurple.shade600,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  controller.isFavorite(item.id)
                      ? Icons.star
                      : Icons.star_border,
                  color: controller.isFavorite(item.id)
                      ? Colors.orange
                      : Colors.grey.shade500,
                ),
                onPressed: () => controller.toggleFavorite(item.id),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              if (item.durationMinutes != null)
                _chip(
                  icon: Icons.timer,
                  text: '${item.durationMinutes} phút',
                  color: Colors.deepPurple.shade50,
                  textColor: Colors.deepPurple.shade700,
                ),
              ...item.tags.map(
                (tag) => _chip(
                  icon: Icons.label,
                  text: tag,
                  color: Colors.grey.shade200,
                  textColor: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => Get.to(() => SutraReadingScreen(item: item)),
              icon: const Icon(Icons.chrome_reader_mode_outlined, size: 18),
              label: const Text('Đọc'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.deepPurple.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  final SutraItem item;
  final SutraController controller;

  const _LessonCard({required this.item, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
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
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.psychology_alt, color: Colors.green.shade700),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
              Obx(() {
                final done = controller.isCompleted(item.id);
                return Switch(
                  value: done,
                  onChanged: (_) => controller.toggleCompleted(item.id),
                  activeColor: Colors.white,
                  activeTrackColor: Colors.green.shade600,
                );
              }),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _chip(
                icon: Icons.layers,
                text: item.level,
                color: Colors.green.shade50,
                textColor: Colors.green.shade700,
              ),
              ...item.tags.map(
                (tag) => _chip(
                  icon: Icons.label,
                  text: tag,
                  color: Colors.grey.shade200,
                  textColor: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () => controller.toggleCompleted(item.id),
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: const Text('Đánh dấu xong'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              TextButton.icon(
                onPressed: () => Get.to(() => SutraDetailScreen(item: item)),
                icon: const Icon(Icons.menu_book_outlined, size: 18),
                label: const Text('Xem nội dung'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.green.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;

  const _SectionTitle({
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 28,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
          ],
        ),
      ],
    );
  }
}

Widget _chip({
  required IconData icon,
  required String text,
  required Color color,
  required Color textColor,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: textColor, size: 16),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}
