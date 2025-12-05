import 'package:app/home/home/home_controller.dart';
import 'package:app/utils/lunisolar_calendar.dart';
import 'package:app/home/event/event_detail_screen.dart';
import 'package:app/home/event/event_list_screen.dart';
import 'package:app/home/home/quick_action_management_screen.dart';
import 'package:app/home/notification/notification_screen.dart';
import 'package:app/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class HomeTabScreen extends StatelessWidget {
  HomeTabScreen({super.key});

  final HomeController controller = Get.put(HomeController());

  Widget _svg(String path, {double size = 22, Color? color}) {
    return SvgPicture.asset(
      path,
      height: size,
      width: size,
      colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    );
  }

  List<DateTime> _buildWeekDays(DateTime anchor) {
    final start = anchor.subtract(Duration(days: anchor.weekday - 1)); // Monday start
    return List.generate(7, (i) => start.add(Duration(days: i)));
  }

  void _handleAction(QuickAction action) {
    switch (action.id) {
      case 'event':
        Get.to(() => EventListScreen());
        break;
      case 'notification':
        Get.to(() => NotificationTabScreen());
        break;
      case 'note':
        ToastUtils.showToast('Ghi chú đang được mô phỏng', backgroundColor: Colors.orange);
        break;
      case 'settings':
        ToastUtils.showToast('Mở cài đặt (mock)', backgroundColor: Colors.blue);
        break;
      case 'manage':
        Get.to(() => QuickActionManagementScreen());
        break;
      default:
        ToastUtils.showToast('Tính năng đang phát triển', backgroundColor: Colors.grey.shade700);
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final lunarNow = LunisolarConverter.solarToLunar(now);
    final weekDays = _buildWeekDays(now);

    final upcoming = [
      {'title': 'Họp dự án', 'time': '09:30', 'place': 'Phòng Zoom', 'tag': 'Quan trọng', 'color': Colors.orange},
      {'title': 'Review sprint', 'time': '14:00', 'place': 'Phòng 3A', 'tag': 'Team', 'color': Colors.blue},
      {'title': 'Sinh nhật đồng nghiệp', 'time': '16:30', 'place': 'Cafe Garden', 'tag': 'Chúc mừng', 'color': Colors.pink},
    ];

    final tips = [
      'Kéo xuống để làm mới dữ liệu.',
      'Nhấn lâu vào sự kiện để xem chi tiết.',
      'Dùng lịch âm để nhắc ngày đặc biệt.',
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        toolbarHeight: 68,
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0D87F2), Color(0xFF54C6EB)],
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
              child: _svg('assets/icons/solid/home.svg', size: 18, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Trang chủ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
                Text(
                  'Hôm nay · ${now.day}/${now.month}/${now.year}',
                  style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
            tooltip: 'Tìm kiếm',
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
            tooltip: 'Tùy chọn',
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.25)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${now.day}', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                        Text('Th${now.weekday}', style: TextStyle(color: Colors.white.withOpacity(0.82), fontSize: 13)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Xin chào!', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
                        const SizedBox(height: 4),
                        const Text('Chúc bạn một ngày hiệu quả', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        Text(
                        'Hôm nay: ${now.day}/${now.month}/${now.year} · Âm: ${lunarNow.day}/${lunarNow.month}${lunarNow.isLeap ? ' (N)' : ''}',
                        style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: () => Get.to(() => const EventCreateScreen()),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Tạo sự kiện mới'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.blue.shade700,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text('Lối tắt', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.grey.shade900)),
                const Spacer(),
                TextButton(onPressed: () => Get.to(() => QuickActionManagementScreen()), child: const Text('Quản lý')),
              ],
            ),
            const SizedBox(height: 10),
            Obx(() {
              final actions = controller.visibleActions;
              if (actions.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Text('Tất cả lối tắt đã tắt. Nhấn "Quản lý" để bật lại.', style: TextStyle(color: Colors.grey.shade700)),
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: actions
                    .map(
                      (item) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Column(
                            children: [
                              InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: () => _handleAction(item),
                                child: Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                                    ],
                                  ),
                                  child: Center(child: _svg(item.icon, size: 24, color: Colors.blue.shade600)),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(item.label, style: TextStyle(fontSize: 12, color: Colors.grey.shade800)),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            }),
            const SizedBox(height: 18),
            Container(
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
                      const Text('Tuần này', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      const Spacer(),
                      Text('Hôm nay', style: TextStyle(fontSize: 12, color: Colors.blue.shade600, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: weekDays
                        .map(
                          (date) {
                            final isToday = date.day == now.day && date.month == now.month && date.year == now.year;
                            final lunar = LunisolarConverter.solarToLunar(date);
                            return Expanded(
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                                decoration: BoxDecoration(
                                  color: isToday ? Colors.blue.shade50 : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: isToday ? Colors.blue.shade300 : Colors.transparent),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      'T${date.weekday}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: isToday ? Colors.blue.shade700 : Colors.grey.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${date.day}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: isToday ? Colors.blue.shade700 : Colors.grey.shade900,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${lunar.day}',
                                      style: TextStyle(fontSize: 11, color: isToday ? Colors.blue.shade600 : Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Sự kiện sắp tới', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                TextButton(
                  onPressed: () => Get.to(() => EventListScreen()),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  child: Text('Xem tất cả', style: TextStyle(color: Colors.blue.shade600, fontWeight: FontWeight.w700, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Column(
              children: upcoming
                  .map(
                    (e) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 6)),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: (e['color'] as Color).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: _svg('assets/icons/solid/calendar-days.svg', size: 20, color: e['color'] as Color),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(e['title'] as String, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    _svg('assets/icons/outline/clock.svg', size: 14, color: Colors.grey.shade600),
                                    const SizedBox(width: 4),
                                    Text(e['time'] as String, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                                    const SizedBox(width: 10),
                                    _svg('assets/icons/outline/map-pin.svg', size: 14, color: Colors.grey.shade600),
                                    const SizedBox(width: 4),
                                    Text(e['place'] as String, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: (e['color'] as Color).withOpacity(0.14),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              e['tag'] as String,
                              style: TextStyle(fontSize: 12, color: e['color'] as Color, fontWeight: FontWeight.w700),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Mẹo nhanh', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  ...tips.map(
                    (t) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(color: Colors.blue.shade400, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Text(t, style: TextStyle(color: Colors.grey.shade800, fontSize: 13))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
