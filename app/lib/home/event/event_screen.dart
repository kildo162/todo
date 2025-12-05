import 'package:flutter/material.dart';
import 'package:app/utils/lunisolar_calendar.dart';
import 'package:get/get.dart';
import 'event_controller.dart';
import 'event_detail_screen.dart';
import 'event_list_screen.dart';

class EventTabScreen extends StatelessWidget {
  EventTabScreen({super.key});

  final controller = Get.put(EventController(), permanent: true);

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  List<DateTime> _buildCalendarDays(DateTime month) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final weekdayOfFirstDay = firstDayOfMonth.weekday; // 1 = Mon, 7 = Sun
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final daysInPrevMonth = DateTime(month.year, month.month, 0).day;
    final leadingEmpty = weekdayOfFirstDay - 1;

    final totalNeeded = leadingEmpty + daysInMonth;
    final totalCells = ((totalNeeded / 7).ceil()) * 7; // make full weeks (35 or 42)
    final List<DateTime> calendarDays = [];

    for (int i = 0; i < leadingEmpty; i++) {
      calendarDays.add(DateTime(month.year, month.month - 1, daysInPrevMonth - leadingEmpty + 1 + i));
    }
    for (int day = 1; day <= daysInMonth; day++) {
      calendarDays.add(DateTime(month.year, month.month, day));
    }
    final trailing = totalCells - calendarDays.length;
    for (int i = 1; i <= trailing; i++) {
      calendarDays.add(DateTime(month.year, month.month + 1, i));
    }
    return calendarDays;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final lunarNow = LunisolarConverter.solarToLunar(now);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        toolbarHeight: 68,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0D47A1), Color(0xFF42A5F5)],
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
              child: const Icon(Icons.event_note, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Lịch & Sự kiện', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
                Text(
                  'Theo dõi lịch dương/âm',
                  style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.today, color: Colors.white),
            onPressed: controller.goToCurrentMonth,
            tooltip: 'Về hôm nay',
          ),
          IconButton(
            icon: const Icon(Icons.list_alt_outlined, color: Colors.white),
            onPressed: () => Get.to(() => EventListScreen()),
            tooltip: 'Danh sách sự kiện',
          ),
          IconButton(
            icon: const Icon(Icons.filter_alt_outlined, color: Colors.white),
            onPressed: () {},
            tooltip: 'Lọc',
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0D87F2), Color(0xFF54C6EB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.blue.shade100, blurRadius: 12, offset: const Offset(0, 6)),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${now.day}', style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                          Text('Th${now.weekday}', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hôm nay · ${now.day}/${now.month}/${now.year}',
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Âm lịch: ${lunarNow.day}/${lunarNow.month}${lunarNow.isLeap ? ' (N)' : ''}',
                            style: TextStyle(color: Colors.white.withOpacity(0.86), fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Kéo qua lại để xem tháng và các sự kiện nổi bật.',
                            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: GetX<EventController>(
                builder: (ctrl) {
                  final events = ctrl.events;
                  final focusedMonth = ctrl.focusedMonth.value;
                  final calendarDays = _buildCalendarDays(focusedMonth);
                  final weekdayLabels = const ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

                  return Card(
                    elevation: 2,
                    shadowColor: Colors.black12,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                onPressed: () => ctrl.changeMonth(-1),
                                icon: const Icon(Icons.chevron_left),
                                splashRadius: 20,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Tháng ${focusedMonth.month}',
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '${focusedMonth.year}',
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () => ctrl.changeMonth(1),
                                icon: const Icon(Icons.chevron_right),
                                splashRadius: 20,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: weekdayLabels
                                .map(
                                  (label) => Expanded(
                                    child: Center(
                                      child: Text(
                                        label,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: label == 'CN' ? Colors.red.shade400 : Colors.grey.shade700,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                          const SizedBox(height: 8),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final rows = (calendarDays.length / 7).ceil();
                            const spacing = 6.0;
                            final tileWidth = (constraints.maxWidth - spacing * 6) / 7;
                            final tileHeight = tileWidth * 1.05;
                            final totalHeight = rows * tileHeight + (rows - 1) * spacing;

                            return SizedBox(
                              height: totalHeight,
                              child: GridView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.zero,
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 7,
                                  childAspectRatio: 1.05,
                                  crossAxisSpacing: spacing,
                                  mainAxisSpacing: spacing,
                                ),
                                itemCount: calendarDays.length,
                                itemBuilder: (context, index) {
                                  final date = calendarDays[index];
                                  final lunar = LunisolarConverter.solarToLunar(date);
                                  final isCurrentMonth = date.month == focusedMonth.month;
                                  final isToday = _isSameDate(date, now);
                                  final hasEvent = events.any((event) => _isSameDate(event.date, date));
                                  final isWeekend = date.weekday == DateTime.sunday;

                                  final Color baseText = isCurrentMonth ? Colors.grey.shade900 : Colors.grey.shade500;
                                  final Color dayColor = isToday ? Colors.white : (isWeekend ? Colors.red.shade400 : baseText);
                                  final Color lunarColor = isToday ? Colors.white70 : Colors.grey.shade600;

                                  final bool isLunarHighlight = lunar.day == 1 || lunar.day == 15;
                                  final Color bgColor = isToday
                                      ? Colors.blue.shade600
                                      : !isCurrentMonth
                                          ? Colors.grey.shade200
                                          : hasEvent
                                              ? Colors.blue.shade50
                                              : Colors.white;

                                  return GestureDetector(
                                    onTap: () => Get.to(() => EventDayDetailScreen(date: date)),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 180),
                                      decoration: BoxDecoration(
                                        color: bgColor,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: isToday
                                              ? Colors.blue.shade600
                                              : !isCurrentMonth
                                                  ? Colors.grey.shade300
                                                  : hasEvent
                                                      ? Colors.blue.shade200
                                                      : Colors.grey.shade200,
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '${date.day}',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: dayColor,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${lunar.day}${lunar.day == 1 ? '/${lunar.month}' : ''}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: isLunarHighlight && !isToday ? Colors.red.shade500 : lunarColor,
                                              fontWeight: isLunarHighlight ? FontWeight.w700 : FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          if (hasEvent)
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: BoxDecoration(
                                                color: isToday ? Colors.white : Colors.blue.shade400,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _LegendDot(color: Colors.blue.shade400, label: 'Có sự kiện'),
                              const SizedBox(width: 12),
                              _LegendDot(color: Colors.red.shade400, label: 'Chủ nhật'),
                              const Spacer(),
                              Text(
                                'Âm lịch hiển thị bên dưới ngày',
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            sliver: GetX<EventController>(
              builder: (ctrl) {
                final upcoming = ctrl.upcomingEvents;
                if (upcoming.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 36),
                      child: _EmptyEventState(),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final event = upcoming[index];
                      final lunar = LunisolarConverter.solarToLunar(event.date);
                      return InkWell(
                        onTap: () => Get.to(() => EventDayDetailScreen(date: event.date)),
                        child: _EventCard(event: event, lunar: lunar),
                      );
                    },
                    childCount: upcoming.length,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
      ],
    );
  }
}

class _EventCard extends StatelessWidget {
  final Event event;
  final LunarDate lunar;

  const _EventCard({required this.event, required this.lunar});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 58,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${event.date.day}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black)),
                  Text('T${event.date.month}', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.description,
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 13, height: 1.3),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, size: 14, color: Colors.blue.shade400),
                      const SizedBox(width: 4),
                      Text(
                        '${event.date.day}/${event.date.month}/${event.date.year}',
                        style: TextStyle(color: Colors.grey.shade800, fontSize: 12),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.bedtime_rounded, size: 14, color: Colors.orange.shade300),
                      const SizedBox(width: 4),
                      Text(
                        '${lunar.day}/${lunar.month}${lunar.isLeap ? ' (N)' : ''}',
                        style: TextStyle(color: Colors.grey.shade800, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _EmptyEventState extends StatelessWidget {
  const _EmptyEventState();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade500),
        const SizedBox(height: 12),
        Text('Không có sự kiện sắp tới', style: TextStyle(color: Colors.grey.shade700, fontSize: 15)),
        const SizedBox(height: 6),
        Text(
          'Hãy thêm sự kiện mới để không bỏ lỡ những ngày quan trọng.',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
