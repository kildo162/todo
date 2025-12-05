import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum EventFilter { all, upcoming, past, thisMonth }

class Event {
  final String title;
  final DateTime date;
  final String description;

  Event({required this.title, required this.date, required this.description});

  Map<String, dynamic> toJson() => {
        'title': title,
        'date': date.toIso8601String(),
        'description': description,
      };

  factory Event.fromJson(Map<String, dynamic> json) => Event(
        title: json['title'] as String,
        date: DateTime.parse(json['date'] as String),
        description: json['description'] as String,
      );
}

class EventController extends GetxController {
  static const String _storageKey = 'events_storage';
  var events = <Event>[].obs;
  final focusedMonth = DateTime.now().obs;
  final filter = EventFilter.upcoming.obs;

  @override
  void onInit() {
    super.onInit();
    _loadFromStorage();
  }

  void changeMonth(int delta) {
    final current = focusedMonth.value;
    focusedMonth.value = DateTime(current.year, current.month + delta);
  }

  void goToCurrentMonth() {
    final now = DateTime.now();
    focusedMonth.value = DateTime(now.year, now.month);
  }

  void setFilter(EventFilter value) {
    filter.value = value;
  }

  List<Event> get upcomingEvents {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    final list = events.where((e) => !e.date.isBefore(start)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  List<Event> get pastEvents {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    final list = events.where((e) => e.date.isBefore(start)).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  List<Event> get filteredEvents {
    final sorted = [...events]..sort((a, b) => a.date.compareTo(b.date));
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);

    switch (filter.value) {
      case EventFilter.all:
        return sorted;
      case EventFilter.upcoming:
        return sorted.where((e) => !e.date.isBefore(start)).toList();
      case EventFilter.past:
        final past = sorted.where((e) => e.date.isBefore(start)).toList();
        return past.reversed.toList();
      case EventFilter.thisMonth:
        final current = focusedMonth.value;
        return sorted.where((e) => e.date.year == current.year && e.date.month == current.month).toList();
    }
  }

  Future<void> addEvent(Event event) async {
    events.add(event);
    events.sort((a, b) => a.date.compareTo(b.date));
    events.refresh();
    await _saveToStorage();
  }

  List<Event> eventsForDate(DateTime date) {
    return events.where((e) => e.date.year == date.year && e.date.month == date.month && e.date.day == date.day).toList();
  }

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null && raw.isNotEmpty) {
      final decoded = jsonDecode(raw) as List<dynamic>;
      final loaded = decoded.map((e) => Event.fromJson(e as Map<String, dynamic>)).toList();
      events.assignAll(loaded);
    } else {
      _seedDefaultEvents();
      await _saveToStorage();
    }
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(events.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, data);
  }

  void _seedDefaultEvents() {
    events.addAll([
      Event(title: 'Tết Dương lịch', date: DateTime(2025, 1, 1), description: 'Ngày đầu năm mới theo lịch Dương'),
      Event(title: 'Giỗ Tổ Hùng Vương', date: DateTime(2025, 4, 30), description: 'Ngày tưởng nhớ Tổ tiên dân tộc'),
      Event(title: 'Ngày Quốc tế Lao động', date: DateTime(2025, 5, 1), description: 'Ngày tôn vinh người lao động'),
      Event(title: 'Quốc khánh Việt Nam', date: DateTime(2025, 9, 2), description: 'Ngày Quốc khánh nước Cộng hòa Xã hội Chủ nghĩa Việt Nam'),
      Event(title: 'Ngày Phụ nữ Việt Nam', date: DateTime(2025, 10, 20), description: 'Ngày tôn vinh phụ nữ Việt Nam'),
      Event(title: 'Ngày Nhà giáo Việt Nam', date: DateTime(2025, 11, 20), description: 'Ngày tôn vinh thầy cô giáo'),
      Event(title: 'Lễ Giáng Sinh', date: DateTime(2025, 12, 24), description: 'Lễ mừng ngày Chúa Giáng Sinh'),
      Event(title: 'Lễ Giáng Sinh', date: DateTime(2025, 12, 25), description: 'Lễ mừng ngày Chúa Giáng Sinh'),
      Event(title: 'Tết Nguyên Đán - Ngày 1', date: DateTime(2025, 1, 29), description: 'Ngày đầu tiên của năm mới âm lịch'),
      Event(title: 'Tết Nguyên Đán - Ngày 2', date: DateTime(2025, 1, 30), description: 'Ngày thứ hai của Tết Nguyên Đán'),
      Event(title: 'Tết Nguyên Đán - Ngày 3', date: DateTime(2025, 1, 31), description: 'Ngày thứ ba của Tết Nguyên Đán'),
      Event(title: 'Tết Nguyên Đán - Ngày 4', date: DateTime(2025, 2, 1), description: 'Ngày thứ tư của Tết Nguyên Đán'),
      Event(title: 'Tết Nguyên Đán - Ngày 5', date: DateTime(2025, 2, 2), description: 'Ngày thứ năm của Tết Nguyên Đán'),
      Event(title: 'Tết Trung Thu', date: DateTime(2025, 10, 6), description: 'Lễ hội Trung Thu, ngày rằm tháng 8 âm lịch'),
    ]);
  }
}
