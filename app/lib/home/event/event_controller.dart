import 'package:get/get.dart';

class Event {
  final String title;
  final DateTime date;
  final String description;

  Event({required this.title, required this.date, required this.description});
}

class EventController extends GetxController {
  var events = <Event>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Mock events based on Vietnamese holidays (Gregorian and Lunar calendar for 2025)
    events.addAll([
      // Lịch Dương
      Event(title: 'Tết Dương lịch', date: DateTime(2025, 1, 1), description: 'Ngày đầu năm mới theo lịch Dương'),
      Event(title: 'Giỗ Tổ Hùng Vương', date: DateTime(2025, 4, 30), description: 'Ngày tưởng nhớ Tổ tiên dân tộc'),
      Event(title: 'Ngày Quốc tế Lao động', date: DateTime(2025, 5, 1), description: 'Ngày tôn vinh người lao động'),
      Event(title: 'Quốc khánh Việt Nam', date: DateTime(2025, 9, 2), description: 'Ngày Quốc khánh nước Cộng hòa Xã hội Chủ nghĩa Việt Nam'),
      Event(title: 'Ngày Phụ nữ Việt Nam', date: DateTime(2025, 10, 20), description: 'Ngày tôn vinh phụ nữ Việt Nam'),
      Event(title: 'Ngày Nhà giáo Việt Nam', date: DateTime(2025, 11, 20), description: 'Ngày tôn vinh thầy cô giáo'),
      Event(title: 'Lễ Giáng Sinh', date: DateTime(2025, 12, 24), description: 'Lễ mừng ngày Chúa Giáng Sinh'),
      Event(title: 'Lễ Giáng Sinh', date: DateTime(2025, 12, 25), description: 'Lễ mừng ngày Chúa Giáng Sinh'),

      // Lịch Âm (dựa trên năm 2025)
      Event(title: 'Tết Nguyên Đán - Ngày 1', date: DateTime(2025, 1, 29), description: 'Ngày đầu tiên của năm mới âm lịch'),
      Event(title: 'Tết Nguyên Đán - Ngày 2', date: DateTime(2025, 1, 30), description: 'Ngày thứ hai của Tết Nguyên Đán'),
      Event(title: 'Tết Nguyên Đán - Ngày 3', date: DateTime(2025, 1, 31), description: 'Ngày thứ ba của Tết Nguyên Đán'),
      Event(title: 'Tết Nguyên Đán - Ngày 4', date: DateTime(2025, 2, 1), description: 'Ngày thứ tư của Tết Nguyên Đán'),
      Event(title: 'Tết Nguyên Đán - Ngày 5', date: DateTime(2025, 2, 2), description: 'Ngày thứ năm của Tết Nguyên Đán'),
      Event(title: 'Tết Trung Thu', date: DateTime(2025, 10, 6), description: 'Lễ hội Trung Thu, ngày rằm tháng 8 âm lịch'),
    ]);
  }
}
