import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/utils/lunisolar_calendar.dart';

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
      await _mergeDefaultEvents(prefs);
    } else {
      _seedDefaultEvents();
      await _saveToStorage(prefs);
    }
  }

  Future<void> _saveToStorage([SharedPreferences? cachedPrefs]) async {
    final prefs = cachedPrefs ?? await SharedPreferences.getInstance();
    final data = jsonEncode(events.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, data);
  }

  void _seedDefaultEvents() {
    events.assignAll(_defaultEvents());
    events.sort((a, b) => a.date.compareTo(b.date));
    events.refresh();
  }

  Future<void> _mergeDefaultEvents(SharedPreferences prefs) async {
    final defaults = _defaultEvents();
    final defaultKeys = defaults.map(_eventKey).toSet();
    final defaultTitles = defaults.map((e) => e.title).toSet();

    final retainedCustomAndValidDefaults = events.where((e) {
      if (!defaultTitles.contains(e.title)) return true;
      return defaultKeys.contains(_eventKey(e));
    }).toList();

    final existingKeys = retainedCustomAndValidDefaults.map(_eventKey).toSet();
    final additions = defaults.where((e) => !existingKeys.contains(_eventKey(e))).toList();

    if (additions.isEmpty && retainedCustomAndValidDefaults.length == events.length) return;

    events
      ..assignAll([...retainedCustomAndValidDefaults, ...additions])
      ..sort((a, b) => a.date.compareTo(b.date));
    events.refresh();
    await _saveToStorage(prefs);
  }

  List<Event> _defaultEvents() {
    final currentYear = DateTime.now().year;
    final years = {currentYear, currentYear + 1};
    final defaults = years.expand(_buildVietnamHolidaysForSolarYear).toList();
    defaults.sort((a, b) => a.date.compareTo(b.date));
    return defaults;
  }

  List<Event> _buildVietnamHolidaysForSolarYear(int solarYear) {
    final List<Event> result = [
      Event(title: 'Tết Dương lịch', date: DateTime(solarYear, 1, 1), description: 'Ngày đầu năm mới theo lịch Dương'),
      Event(title: 'Ngày Quốc tế Phụ nữ', date: DateTime(solarYear, 3, 8), description: 'Tôn vinh phụ nữ trên toàn thế giới'),
      Event(title: 'Ngày Giải phóng miền Nam', date: DateTime(solarYear, 4, 30), description: 'Kỷ niệm thống nhất đất nước 30/4'),
      Event(title: 'Ngày Quốc tế Lao động', date: DateTime(solarYear, 5, 1), description: 'Ngày tôn vinh người lao động'),
      Event(title: 'Ngày Quốc tế Thiếu nhi', date: DateTime(solarYear, 6, 1), description: 'Ngày lễ của trẻ em'),
      Event(title: 'Ngày Gia đình Việt Nam', date: DateTime(solarYear, 6, 28), description: 'Tôn vinh giá trị gia đình Việt'),
      Event(title: 'Ngày Thương binh Liệt sĩ', date: DateTime(solarYear, 7, 27), description: 'Tri ân những người có công với Tổ quốc'),
      Event(title: 'Quốc khánh Việt Nam', date: DateTime(solarYear, 9, 2), description: 'Ngày Quốc khánh nước Cộng hòa Xã hội Chủ nghĩa Việt Nam'),
      Event(title: 'Ngày Phụ nữ Việt Nam', date: DateTime(solarYear, 10, 20), description: 'Tôn vinh phụ nữ Việt Nam'),
      Event(title: 'Ngày Nhà giáo Việt Nam', date: DateTime(solarYear, 11, 20), description: 'Tôn vinh thầy cô giáo'),
      Event(title: 'Đêm Giáng Sinh', date: DateTime(solarYear, 12, 24), description: 'Đêm vọng Giáng Sinh'),
      Event(title: 'Lễ Giáng Sinh', date: DateTime(solarYear, 12, 25), description: 'Lễ mừng ngày Chúa Giáng Sinh'),
    ];

    final addedKeys = result.map(_eventKey).toSet();
    final lunarYearsToCheck = {solarYear, solarYear - 1};
    final lunarHolidays = <_LunarHoliday>[
      const _LunarHoliday(month: 1, day: 15, title: 'Rằm tháng Giêng', description: 'Tết Nguyên Tiêu (15/1 âm lịch)'),
      const _LunarHoliday(month: 3, day: 3, title: 'Tết Hàn Thực', description: 'Mùng 3 tháng 3 âm lịch'),
      const _LunarHoliday(month: 3, day: 10, title: 'Giỗ Tổ Hùng Vương', description: 'Mùng 10 tháng 3 âm lịch tưởng nhớ các Vua Hùng'),
      const _LunarHoliday(month: 4, day: 15, title: 'Lễ Phật Đản', description: 'Rằm tháng 4 âm lịch'),
      const _LunarHoliday(month: 5, day: 5, title: 'Tết Đoan Ngọ', description: 'Mùng 5 tháng 5 âm lịch (Tết diệt sâu bọ)'),
      const _LunarHoliday(month: 7, day: 15, title: 'Lễ Vu Lan', description: 'Rằm tháng 7 âm lịch - báo hiếu, xá tội vong nhân'),
      const _LunarHoliday(month: 8, day: 15, title: 'Tết Trung Thu', description: 'Rằm tháng 8 âm lịch'),
      const _LunarHoliday(month: 12, day: 23, title: 'Lễ Ông Công Ông Táo', description: '23 tháng Chạp tiễn Táo quân về trời'),
    ];

    for (final lunarYear in lunarYearsToCheck) {
      final lunarNewYear = LunisolarConverter.lunarToSolar(LunarDate(day: 1, month: 1, year: lunarYear));
      for (int offset = 0; offset < 5; offset++) {
        final date = lunarNewYear.add(Duration(days: offset));
        if (date.year == solarYear) {
          final event = Event(
            title: 'Tết Nguyên Đán - Ngày ${offset + 1}',
            date: date,
            description: 'Kỳ nghỉ Tết cổ truyền (mùng ${offset + 1})',
          );
          final key = _eventKey(event);
          if (addedKeys.add(key)) {
            result.add(event);
          }
        }
      }

      for (final holiday in lunarHolidays) {
        final date = LunisolarConverter.lunarToSolar(LunarDate(day: holiday.day, month: holiday.month, year: lunarYear));
        if (date.year == solarYear) {
          final event = Event(title: holiday.title, date: date, description: holiday.description);
          final key = _eventKey(event);
          if (addedKeys.add(key)) {
            result.add(event);
          }
        }
      }
    }

    result.sort((a, b) => a.date.compareTo(b.date));
    return result;
  }

  String _eventKey(Event event) => '${event.title}-${event.date.toIso8601String()}';
}

class _LunarHoliday {
  final int month;
  final int day;
  final String title;
  final String description;

  const _LunarHoliday({
    required this.month,
    required this.day,
    required this.title,
    required this.description,
  });
}
