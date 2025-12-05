import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'event_controller.dart';
import '../../utils/lunisolar_calendar.dart';

class EventTabScreen extends StatelessWidget {
  EventTabScreen({super.key});
  final EventController controller = Get.put(EventController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text('Events', style: TextStyle(color: Colors.black)),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      Text(
                        'Tháng ${DateTime.now().month} - ${DateTime.now().year}',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      // Calendar header with days of week
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text('Mon', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('Tue', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('Wed', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('Thu', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('Fri', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('Sat', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('Sun', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade300)),
                        ],
                      ),
                      SizedBox(height: 10),
                      // Calendar grid
                      Builder(
                        builder: (context) {
                          DateTime now = DateTime.now();
                          int year = now.year;
                          int month = now.month;
                          DateTime firstDayOfMonth = DateTime(year, month, 1);
                          int weekdayOfFirstDay = firstDayOfMonth.weekday; // 1 = Mon, 7 = Sun
                          int daysInMonth = DateTime(year, month + 1, 0).day;
                          int daysInPrevMonth = DateTime(year, month, 0).day;
                          int startDayPrev = daysInPrevMonth - weekdayOfFirstDay + 2;
                          int totalCells = 35; // 5 weeks * 7 days
                          List<Map<String, dynamic>> calendarDays = [];

                          // Previous month days
                          for (int i = 0; i < weekdayOfFirstDay - 1; i++) {
                            final date = DateTime(year, month - 1, startDayPrev + i);
                            calendarDays.add({
                              'day': date,
                              'isCurrentMonth': false,
                              'isToday': false,
                            });
                          }

                          // Current month days
                          for (int day = 1; day <= daysInMonth; day++) {
                            bool isToday = day == now.day && month == now.month && year == now.year;
                            final date = DateTime(year, month, day);
                            calendarDays.add({
                              'day': date,
                              'isCurrentMonth': true,
                              'isToday': isToday,
                            });
                          }

                          // Next month days
                          int remainingCells = totalCells - calendarDays.length;
                          for (int i = 1; i <= remainingCells; i++) {
                            final date = DateTime(year, month + 1, i);
                            calendarDays.add({
                              'day': date,
                              'isCurrentMonth': false,
                              'isToday': false,
                            });
                          }

                          return GridView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 7,
                              childAspectRatio: 1.2,
                            ),
                            itemCount: calendarDays.length,
                            itemBuilder: (context, index) {
                              var dayData = calendarDays[index];
                              DateTime date = dayData['day'];
                              final lunar = LunisolarConverter.solarToLunar(date);
                              bool isCurrentMonth = dayData['isCurrentMonth'];
                              bool isToday = dayData['isToday'];
                              final textColor = isCurrentMonth
                                  ? (isToday
                                      ? Colors.white
                                      : (index % 7 == 6 ? Colors.red.shade300 : Colors.black))
                                  : Colors.grey;

                              return Container(
                                alignment: Alignment.center,
                                margin: EdgeInsets.all(1),
                                decoration: BoxDecoration(
                                  color: isToday ? Colors.blue : Colors.transparent,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${date.day}',
                                      style: TextStyle(
                                        color: textColor,
                                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                    Text(
                                      '${lunar.day}${lunar.day == 1 ? '/${lunar.month}' : ''}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isToday ? Colors.white : Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            sliver: Obx(() {
              if (controller.events.isEmpty) {
                return SliverToBoxAdapter(
                  child: Center(child: Text('Không có sự kiện sắp tới')),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final event = controller.events[index];
                    return Card(
                      child: ListTile(
                        title: Text(event.title),
                        subtitle: Text('${event.date.day}/${event.date.month}/${event.date.year} - ${event.description}'),
                      ),
                    );
                  },
                  childCount: controller.events.length,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
