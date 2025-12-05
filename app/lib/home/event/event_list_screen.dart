import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:app/home/event/event_controller.dart';
import 'package:app/home/event/event_detail_screen.dart';
import 'package:app/utils/lunisolar_calendar.dart';
import 'package:app/shared/widgets/swipe_back_wrapper.dart';

class EventListScreen extends StatelessWidget {
  EventListScreen({super.key});

  final EventController controller = Get.isRegistered<EventController>()
      ? Get.find<EventController>()
      : Get.put(EventController(), permanent: true);

  @override
  Widget build(BuildContext context) {
    return SwipeBackWrapper(
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8FB),
        appBar: AppBar(
          leading: const BackButton(),
          title: const Text('Tất cả sự kiện'),
          backgroundColor: Colors.white,
          elevation: 0.5,
          iconTheme: const IconThemeData(color: Colors.black),
          titleTextStyle: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        body: Obx(() {
          final events = controller.filteredEvents;
          final selectedCategories = controller.selectedCategories;
          final categoryOptions = const [
            {'key': 'personal', 'label': 'Cá nhân'},
            {'key': 'work', 'label': 'Công việc'},
            {'key': 'health', 'label': 'Sức khỏe'},
            {'key': 'holiday', 'label': 'Lịch lễ'},
            {'key': 'other', 'label': 'Khác'},
          ];

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              TextField(
                onChanged: controller.setSearch,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm sự kiện...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categoryOptions
                    .map(
                      (item) => FilterChip(
                        label: Text(item['label']!),
                        selected: selectedCategories.contains(item['key']),
                        onSelected: (_) =>
                            controller.toggleCategoryFilter(item['key']!),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: controller.sortMode.value,
                decoration: const InputDecoration(
                  labelText: 'Sắp xếp',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'time_asc',
                    child: Text('Thời gian ↑'),
                  ),
                  DropdownMenuItem(
                    value: 'time_desc',
                    child: Text('Thời gian ↓'),
                  ),
                  DropdownMenuItem(value: 'priority', child: Text('Ưu tiên')),
                ],
                onChanged: (value) {
                  if (value != null) controller.setSortMode(value);
                },
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final path = await controller.exportToICS();
                        Get.snackbar(
                          'Đã xuất ICS',
                          'Lưu tại $path',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                      child: const Text('Xuất ICS'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _showImportDialog(context),
                      child: const Text('Nhập ICS'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (events.isEmpty)
                Column(
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 48,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Không tìm thấy sự kiện phù hợp',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                )
              else
                ...events.map((e) => _EventRow(event: e)),
              const SizedBox(height: 80),
            ],
          );
        }),
      ),
    );
  }

  Future<void> _showImportDialog(BuildContext context) async {
    final textCtrl = TextEditingController();
    final raw = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nhập ICS'),
        content: TextField(
          controller: textCtrl,
          maxLines: 8,
          decoration: const InputDecoration(hintText: 'Dán nội dung file .ics'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Huỷ'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(textCtrl.text),
            child: const Text('Nhập'),
          ),
        ],
      ),
    );
    if (raw != null && raw.trim().isNotEmpty) {
      await controller.importFromICS(raw.trim());
      Get.snackbar(
        'Nhập ICS',
        'Đã thêm sự kiện từ nội dung ICS',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}

class _EventRow extends StatelessWidget {
  final Event event;

  const _EventRow({required this.event});

  Widget _svg(String path, {double size = 20, Color? color}) {
    return SvgPicture.asset(
      path,
      height: size,
      width: size,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<EventController>()
        ? Get.find<EventController>()
        : Get.put(EventController(), permanent: true);
    final lunar = LunisolarConverter.solarToLunar(event.date);
    final badgeColor = _categoryColor(event.category);
    final badgeLabel = _categoryLabel(event.category);
    final priorityColor = _priorityColor(event.priority);
    return InkWell(
      onTap: () => Get.to(() => EventDayDetailScreen(date: event.date)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: priorityColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _svg(
                'assets/icons/solid/calendar-days.svg',
                size: 20,
                color: priorityColor,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          event.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, size: 18),
                        onSelected: (value) async {
                          if (value == 'edit') {
                            Get.to(
                              () => EventCreateScreen(
                                initialDate: event.date,
                                event: event,
                              ),
                            );
                          } else if (value == 'delete') {
                            await controller.deleteEvent(event.id);
                            Get.snackbar(
                              'Đã xoá sự kiện',
                              'Bạn có thể hoàn tác trong giây lát',
                              snackPosition: SnackPosition.BOTTOM,
                              mainButton: TextButton(
                                onPressed: controller.undoDelete,
                                child: const Text('Hoàn tác'),
                              ),
                            );
                          } else if (value == 'snooze') {
                            controller.snoozeEvent(
                              event.id,
                              const Duration(minutes: 5),
                            );
                          } else if (value == 'skip') {
                            controller.skipOccurrence(event.id, event.date);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Chỉnh sửa'),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Xoá'),
                          ),
                          const PopupMenuItem(
                            value: 'snooze',
                            child: Text('Snooze 5p'),
                          ),
                          if (event.recurrence != 'none')
                            const PopupMenuItem(
                              value: 'skip',
                              child: Text('Bỏ qua lần này'),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: badgeColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: badgeColor.withOpacity(0.35),
                          ),
                        ),
                        child: Text(
                          badgeLabel,
                          style: TextStyle(
                            color: badgeColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: priorityColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          event.priority == 'high'
                              ? 'Ưu tiên cao'
                              : (event.priority == 'low'
                                    ? 'Ưu tiên thấp'
                                    : 'Ưu tiên TB'),
                          style: TextStyle(
                            color: priorityColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_formatTime(event.startTime)} - ${_formatTime(event.endTime)}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.description,
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _svg(
                        'assets/icons/outline/calendar-date-range.svg',
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${event.date.day}/${event.date.month}/${event.date.year}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(width: 10),
                      _svg(
                        'assets/icons/outline/moon.svg',
                        size: 14,
                        color: Colors.orange.shade300,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${lunar.day}/${lunar.month}${lunar.isLeap ? ' (N)' : ''}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  if (event.locationName != null &&
                      event.locationName!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.place_outlined,
                          size: 14,
                          color: Colors.redAccent,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.locationName!,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Color _categoryColor(String category) {
  switch (category) {
    case 'personal':
      return const Color(0xFF2563EB);
    case 'work':
      return const Color(0xFF16A34A);
    case 'health':
      return const Color(0xFF0EA5E9);
    case 'holiday':
      return const Color(0xFFF97316);
    default:
      return const Color(0xFF6B7280);
  }
}

String _categoryLabel(String category) {
  switch (category) {
    case 'personal':
      return 'Cá nhân';
    case 'work':
      return 'Công việc';
    case 'health':
      return 'Sức khỏe';
    case 'holiday':
      return 'Lịch lễ';
    default:
      return 'Khác';
  }
}

Color _priorityColor(String priority) {
  switch (priority) {
    case 'high':
      return const Color(0xFFDC2626);
    case 'low':
      return const Color(0xFF6B7280);
    default:
      return const Color(0xFF2563EB);
  }
}

String _formatTime(DateTime dt) =>
    '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
