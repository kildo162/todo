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
          final upcoming = controller.upcomingEvents;
          final past = controller.pastEvents;

          if (controller.events.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 48,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Chưa có sự kiện',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              const Text(
                'Sắp tới',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              if (upcoming.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    'Không có sự kiện sắp tới',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                )
              else
                ...upcoming.map((e) => _EventRow(event: e)),
              const SizedBox(height: 16),
              const Text(
                'Đã qua',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              if (past.isEmpty)
                Text(
                  'Chưa có sự kiện trong quá khứ',
                  style: TextStyle(color: Colors.grey.shade600),
                )
              else
                ...past.map((e) => _EventRow(event: e)),
            ],
          );
        }),
      ),
    );
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
    final lunar = LunisolarConverter.solarToLunar(event.date);
    final badgeColor = _categoryColor(event.category);
    final badgeLabel = _categoryLabel(event.category);
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
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: _svg(
                'assets/icons/solid/calendar-days.svg',
                size: 20,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: badgeColor.withOpacity(0.35)),
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
