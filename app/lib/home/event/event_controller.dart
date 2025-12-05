import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/utils/lunisolar_calendar.dart';

enum EventFilter { all, upcoming, past, thisMonth }

class Event {
  final String id;
  final String title;
  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;
  final String description;
  final String category; // holiday | personal | work | health | other
  final String priority; // low | normal | high
  final String timezone;
  final List<int> reminders; // minutes before
  final String recurrence; // none | daily | weekly | monthly | custom
  final DateTime? recurrenceEnd;
  final String? customRecurrenceRule;
  final List<String> skippedOccurrences;
  final String? locationName;
  final String? mapUrl;
  final List<String> attachments;
  final List<String> guests;
  final String? notes;

  Event({
    String? id,
    required this.title,
    DateTime? date,
    DateTime? startTime,
    DateTime? endTime,
    required this.description,
    this.category = 'personal',
    this.priority = 'normal',
    String? timezone,
    List<int>? reminders,
    this.recurrence = 'none',
    this.recurrenceEnd,
    this.customRecurrenceRule,
    List<String>? skippedOccurrences,
    this.locationName,
    this.mapUrl,
    List<String>? attachments,
    List<String>? guests,
    this.notes,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        startTime = startTime ?? date ?? DateTime.now(),
        endTime = endTime ??
            (startTime ?? date ?? DateTime.now()).add(
              const Duration(hours: 1),
            ),
        date = DateTime(
          (startTime ?? date ?? DateTime.now()).year,
          (startTime ?? date ?? DateTime.now()).month,
          (startTime ?? date ?? DateTime.now()).day,
        ),
        timezone = timezone ?? DateTime.now().timeZoneName,
        reminders = reminders?.toList() ?? const [30],
        skippedOccurrences = skippedOccurrences?.toList() ?? const [],
        attachments = attachments?.toList() ?? const [],
        guests = guests?.toList() ?? const [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'date': date.toIso8601String(),
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'description': description,
        'category': category,
        'priority': priority,
        'timezone': timezone,
        'reminders': reminders,
        'recurrence': recurrence,
        'recurrenceEnd': recurrenceEnd?.toIso8601String(),
        'customRecurrenceRule': customRecurrenceRule,
        'skippedOccurrences': skippedOccurrences,
        'locationName': locationName,
        'mapUrl': mapUrl,
        'attachments': attachments,
        'guests': guests,
        'notes': notes,
      };

  factory Event.fromJson(Map<String, dynamic> json) => Event(
        id: json['id'] as String? ?? '${json['title']}-${json['date']}',
        title: json['title'] as String,
        date: DateTime.parse(json['date'] as String),
        startTime: json['startTime'] != null ? DateTime.parse(json['startTime'] as String) : null,
        endTime: json['endTime'] != null ? DateTime.parse(json['endTime'] as String) : null,
        description: json['description'] as String,
        category: json['category'] as String? ?? 'personal',
        priority: json['priority'] as String? ?? 'normal',
        timezone: json['timezone'] as String?,
        reminders: (json['reminders'] as List<dynamic>?)?.map((e) => e as int).toList(),
        recurrence: json['recurrence'] as String? ?? 'none',
        recurrenceEnd: json['recurrenceEnd'] != null ? DateTime.parse(json['recurrenceEnd'] as String) : null,
        customRecurrenceRule: json['customRecurrenceRule'] as String?,
        skippedOccurrences: (json['skippedOccurrences'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
        locationName: json['locationName'] as String?,
        mapUrl: json['mapUrl'] as String?,
        attachments: (json['attachments'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
        guests: (json['guests'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
        notes: json['notes'] as String?,
      );

  Event copyWith({
    String? id,
    String? title,
    DateTime? date,
    DateTime? startTime,
    DateTime? endTime,
    String? description,
    String? category,
    String? priority,
    String? timezone,
    List<int>? reminders,
    String? recurrence,
    DateTime? recurrenceEnd,
    String? customRecurrenceRule,
    List<String>? skippedOccurrences,
    String? locationName,
    String? mapUrl,
    List<String>? attachments,
    List<String>? guests,
    String? notes,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      timezone: timezone ?? this.timezone,
      reminders: reminders ?? this.reminders,
      recurrence: recurrence ?? this.recurrence,
      recurrenceEnd: recurrenceEnd ?? this.recurrenceEnd,
      customRecurrenceRule: customRecurrenceRule ?? this.customRecurrenceRule,
      skippedOccurrences: skippedOccurrences ?? this.skippedOccurrences,
      locationName: locationName ?? this.locationName,
      mapUrl: mapUrl ?? this.mapUrl,
      attachments: attachments ?? this.attachments,
      guests: guests ?? this.guests,
      notes: notes ?? this.notes,
    );
  }
}

class EventController extends GetxController {
  static const String _storageKey = 'events_storage';
  var events = <Event>[].obs;
  final focusedMonth = DateTime.now().obs;
  final filter = EventFilter.upcoming.obs;
  final searchQuery = ''.obs;
  final selectedCategories = <String>{}.obs;
  final sortMode = 'time_asc'.obs;
  final reminderLog = <String>[].obs;
  Event? _lastRemoved;

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

  void setSearch(String value) {
    searchQuery.value = value;
  }

  void toggleCategoryFilter(String category) {
    final current = selectedCategories.toSet();
    if (current.contains(category)) {
      current.remove(category);
    } else {
      current.add(category);
    }
    selectedCategories
      ..clear()
      ..addAll(current);
  }

  void setSortMode(String mode) {
    sortMode.value = mode;
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
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    Iterable<Event> list = events;

    switch (filter.value) {
      case EventFilter.upcoming:
        list = list.where((e) => !e.startTime.isBefore(start));
        break;
      case EventFilter.past:
        list = list.where((e) => e.startTime.isBefore(start));
        break;
      case EventFilter.thisMonth:
        final current = focusedMonth.value;
        list = list.where((e) => e.startTime.year == current.year && e.startTime.month == current.month);
        break;
      case EventFilter.all:
        break;
    }

    if (searchQuery.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      list = list.where((e) =>
          e.title.toLowerCase().contains(q) ||
          e.description.toLowerCase().contains(q) ||
          (e.notes ?? '').toLowerCase().contains(q) ||
          e.locationName?.toLowerCase().contains(q) == true ||
          e.guests.any((g) => g.toLowerCase().contains(q)));
    }

    if (selectedCategories.isNotEmpty) {
      list = list.where((e) => selectedCategories.contains(e.category));
    }

    final result = list.toList();
    switch (sortMode.value) {
      case 'time_desc':
        result.sort((a, b) => b.startTime.compareTo(a.startTime));
        break;
      case 'priority':
        result.sort((a, b) => _priorityScore(b.priority).compareTo(_priorityScore(a.priority)));
        break;
      default:
        result.sort((a, b) => a.startTime.compareTo(b.startTime));
    }
    return result;
  }

  Future<void> addEvent(Event event) async {
    events.add(event);
    events.sort((a, b) => a.startTime.compareTo(b.startTime));
    events.refresh();
    _scheduleReminders(event);
    await _saveToStorage();
  }

  Future<void> updateEvent(String id, Event event) async {
    final idx = events.indexWhere((e) => e.id == id);
    if (idx == -1) return;
    events[idx] = event;
    events.sort((a, b) => a.startTime.compareTo(b.startTime));
    events.refresh();
    _scheduleReminders(event);
    await _saveToStorage();
  }

  Future<void> deleteEvent(String id) async {
    final idx = events.indexWhere((e) => e.id == id);
    if (idx == -1) return;
    _lastRemoved = events[idx];
    events.removeAt(idx);
    events.refresh();
    await _saveToStorage();
  }

  Future<void> undoDelete() async {
    if (_lastRemoved == null) return;
    events.add(_lastRemoved!);
    events.sort((a, b) => a.startTime.compareTo(b.startTime));
    events.refresh();
    await _saveToStorage();
    _lastRemoved = null;
  }

  void snoozeEvent(String id, Duration duration) {
    final idx = events.indexWhere((e) => e.id == id);
    if (idx == -1) return;
    final event = events[idx];
    final snoozedTime = DateTime.now().add(duration);
    reminderLog.add('[${DateTime.now().toIso8601String()}] Snooze "${event.title}" đến ${snoozedTime.toIso8601String()}');
  }

  List<Event> eventsForDate(DateTime date) {
    final key = _dayKey(date);
    return events
        .where(
          (e) =>
              e.date.year == date.year &&
              e.date.month == date.month &&
              e.date.day == date.day &&
              !e.skippedOccurrences.contains(key),
        )
        .toList();
  }

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null && raw.isNotEmpty) {
      final decoded = jsonDecode(raw) as List<dynamic>;
      final loaded = decoded
          .map((e) => Event.fromJson(e as Map<String, dynamic>))
          .toList();
      _applyCategoryDefaults(loaded);
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
    final additions = defaults
        .where((e) => !existingKeys.contains(_eventKey(e)))
        .toList();

    if (additions.isEmpty &&
        retainedCustomAndValidDefaults.length == events.length)
      return;

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

  int get eventsThisWeek {
    final now = DateTime.now();
    final start =
        DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    final end = start.add(const Duration(days: 7));
    return events
        .where((e) => e.startTime.isAfter(start) && e.startTime.isBefore(end))
        .length;
  }

  int get eventsThisMonth {
    final now = DateTime.now();
    return events
        .where((e) => e.startTime.year == now.year && e.startTime.month == now.month)
        .length;
  }

  Map<String, int> get categoryBreakdown {
    final map = <String, int>{};
    for (final event in events) {
      map[event.category] = (map[event.category] ?? 0) + 1;
    }
    return map;
  }

  Future<String> exportToICS() async {
    final buffer = StringBuffer()
      ..writeln('BEGIN:VCALENDAR')
      ..writeln('VERSION:2.0')
      ..writeln('PRODID:-//TodoHealth//EN');
    for (final event in events) {
      buffer
        ..writeln('BEGIN:VEVENT')
        ..writeln('UID:${event.id}@todo-health')
        ..writeln('SUMMARY:${event.title}')
        ..writeln('DESCRIPTION:${event.description}')
        ..writeln('DTSTART:${_formatAsIcs(event.startTime)}')
        ..writeln('DTEND:${_formatAsIcs(event.endTime)}')
        ..writeln('CATEGORIES:${event.category}')
        ..writeln('LOCATION:${event.locationName ?? ''}')
        ..writeln('END:VEVENT');
    }
    buffer.writeln('END:VCALENDAR');
    final dir = Directory('build');
    if (!dir.existsSync()) dir.createSync(recursive: true);
    final path = '${dir.path}/events_export.ics';
    await File(path).writeAsString(buffer.toString());
    return path;
  }

  Future<void> importFromICS(String raw) async {
    final lines = raw.split(RegExp(r'\r?\n'));
    Event? current;
    final imported = <Event>[];
    for (final rawLine in lines) {
      final line = rawLine.trim();
      if (line == 'BEGIN:VEVENT') {
        current = Event(title: 'Chưa đặt tên', description: '', date: DateTime.now());
      } else if (line == 'END:VEVENT') {
        if (current != null) imported.add(current);
        current = null;
      } else if (current != null) {
        if (line.startsWith('SUMMARY:')) {
          current = current.copyWith(title: line.substring(8));
        } else if (line.startsWith('DESCRIPTION:')) {
          current = current.copyWith(description: line.substring(12));
        } else if (line.startsWith('DTSTART')) {
          final dt = _parseIcsDate(line.split(':').last);
          current = current.copyWith(startTime: dt, date: dt);
        } else if (line.startsWith('DTEND')) {
          final dt = _parseIcsDate(line.split(':').last);
          current = current.copyWith(endTime: dt);
        } else if (line.startsWith('CATEGORIES:')) {
          current = current.copyWith(category: line.substring(11));
        } else if (line.startsWith('LOCATION:')) {
          current = current.copyWith(locationName: line.substring(9));
        }
      }
    }
    if (imported.isEmpty) return;
    events.addAll(imported);
    events.sort((a, b) => a.startTime.compareTo(b.startTime));
    events.refresh();
    await _saveToStorage();
  }

  Future<void> skipOccurrence(String id, DateTime date) async {
    final idx = events.indexWhere((e) => e.id == id);
    if (idx == -1) return;
    final key = _dayKey(date);
    final updated = events[idx]
        .copyWith(skippedOccurrences: [...events[idx].skippedOccurrences, key]);
    await updateEvent(id, updated);
  }

  void _applyCategoryDefaults(List<Event> list) {
    final defaults = _defaultEvents();
    final defaultMap = {for (final e in defaults) _eventKey(e): e.category};
    for (var i = 0; i < list.length; i++) {
      final e = list[i];
      final key = _eventKey(e);
      final normalized =
          defaultMap[key] ?? (e.category.isNotEmpty ? e.category : 'personal');
      if (normalized != e.category) {
        list[i] = e.copyWith(category: normalized);
      }
    }
  }

  List<Event> _buildVietnamHolidaysForSolarYear(int solarYear) {
    final List<Event> result = [
      Event(
        title: 'Tết Dương lịch',
        date: DateTime(solarYear, 1, 1),
        description: 'Ngày đầu năm mới theo lịch Dương',
        category: 'holiday',
      ),
      Event(
        title: 'Ngày Quốc tế Phụ nữ',
        date: DateTime(solarYear, 3, 8),
        description: 'Tôn vinh phụ nữ trên toàn thế giới',
        category: 'holiday',
      ),
      Event(
        title: 'Ngày Giải phóng miền Nam',
        date: DateTime(solarYear, 4, 30),
        description: 'Kỷ niệm thống nhất đất nước 30/4',
        category: 'holiday',
      ),
      Event(
        title: 'Ngày Quốc tế Lao động',
        date: DateTime(solarYear, 5, 1),
        description: 'Ngày tôn vinh người lao động',
        category: 'holiday',
      ),
      Event(
        title: 'Ngày Quốc tế Thiếu nhi',
        date: DateTime(solarYear, 6, 1),
        description: 'Ngày lễ của trẻ em',
        category: 'holiday',
      ),
      Event(
        title: 'Ngày Gia đình Việt Nam',
        date: DateTime(solarYear, 6, 28),
        description: 'Tôn vinh giá trị gia đình Việt',
        category: 'holiday',
      ),
      Event(
        title: 'Ngày Thương binh Liệt sĩ',
        date: DateTime(solarYear, 7, 27),
        description: 'Tri ân những người có công với Tổ quốc',
        category: 'holiday',
      ),
      Event(
        title: 'Quốc khánh Việt Nam',
        date: DateTime(solarYear, 9, 2),
        description: 'Ngày Quốc khánh nước Cộng hòa Xã hội Chủ nghĩa Việt Nam',
        category: 'holiday',
      ),
      Event(
        title: 'Ngày Phụ nữ Việt Nam',
        date: DateTime(solarYear, 10, 20),
        description: 'Tôn vinh phụ nữ Việt Nam',
        category: 'holiday',
      ),
      Event(
        title: 'Ngày Nhà giáo Việt Nam',
        date: DateTime(solarYear, 11, 20),
        description: 'Tôn vinh thầy cô giáo',
        category: 'holiday',
      ),
      Event(
        title: 'Đêm Giáng Sinh',
        date: DateTime(solarYear, 12, 24),
        description: 'Đêm vọng Giáng Sinh',
        category: 'holiday',
      ),
      Event(
        title: 'Lễ Giáng Sinh',
        date: DateTime(solarYear, 12, 25),
        description: 'Lễ mừng ngày Chúa Giáng Sinh',
        category: 'holiday',
      ),
    ];

    final addedKeys = result.map(_eventKey).toSet();
    final lunarYearsToCheck = {solarYear, solarYear - 1};
    final lunarHolidays = <_LunarHoliday>[
      const _LunarHoliday(
        month: 1,
        day: 15,
        title: 'Rằm tháng Giêng',
        description: 'Tết Nguyên Tiêu (15/1 âm lịch)',
      ),
      const _LunarHoliday(
        month: 3,
        day: 3,
        title: 'Tết Hàn Thực',
        description: 'Mùng 3 tháng 3 âm lịch',
      ),
      const _LunarHoliday(
        month: 3,
        day: 10,
        title: 'Giỗ Tổ Hùng Vương',
        description: 'Mùng 10 tháng 3 âm lịch tưởng nhớ các Vua Hùng',
      ),
      const _LunarHoliday(
        month: 4,
        day: 15,
        title: 'Lễ Phật Đản',
        description: 'Rằm tháng 4 âm lịch',
      ),
      const _LunarHoliday(
        month: 5,
        day: 5,
        title: 'Tết Đoan Ngọ',
        description: 'Mùng 5 tháng 5 âm lịch (Tết diệt sâu bọ)',
      ),
      const _LunarHoliday(
        month: 7,
        day: 15,
        title: 'Lễ Vu Lan',
        description: 'Rằm tháng 7 âm lịch - báo hiếu, xá tội vong nhân',
      ),
      const _LunarHoliday(
        month: 8,
        day: 15,
        title: 'Tết Trung Thu',
        description: 'Rằm tháng 8 âm lịch',
      ),
      const _LunarHoliday(
        month: 12,
        day: 23,
        title: 'Lễ Ông Công Ông Táo',
        description: '23 tháng Chạp tiễn Táo quân về trời',
      ),
    ];

    for (final lunarYear in lunarYearsToCheck) {
      final lunarNewYear = LunisolarConverter.lunarToSolar(
        LunarDate(day: 1, month: 1, year: lunarYear),
      );
      for (int offset = 0; offset < 5; offset++) {
        final date = lunarNewYear.add(Duration(days: offset));
        if (date.year == solarYear) {
          final event = Event(
            title: 'Tết Nguyên Đán - Ngày ${offset + 1}',
            date: date,
            description: 'Kỳ nghỉ Tết cổ truyền (mùng ${offset + 1})',
            category: 'holiday',
          );
          final key = _eventKey(event);
          if (addedKeys.add(key)) {
            result.add(event);
          }
        }
      }

      for (final holiday in lunarHolidays) {
        final date = LunisolarConverter.lunarToSolar(
          LunarDate(day: holiday.day, month: holiday.month, year: lunarYear),
        );
        if (date.year == solarYear) {
          final event = Event(
            title: holiday.title,
            date: date,
            description: holiday.description,
            category: 'holiday',
          );
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

  String _eventKey(Event event) =>
      '${event.title}-${event.date.toIso8601String()}';

  void _scheduleReminders(Event event) {
    for (final minutes in event.reminders) {
      final reminderTime = event.startTime.subtract(Duration(minutes: minutes));
      reminderLog.add(
        '[${DateTime.now().toIso8601String()}] Nhắc "${event.title}" lúc ${reminderTime.toLocal()}',
      );
    }
  }

  String _formatAsIcs(DateTime dt) {
    final utc = dt.toUtc();
    return utc.toIso8601String().replaceAll('-', '').replaceAll(':', '');
  }

  DateTime _parseIcsDate(String raw) {
    if (raw.endsWith('Z')) {
      return DateTime.parse(raw.replaceAll('Z', ''));
    }
    if (raw.length >= 15) {
      final year = int.parse(raw.substring(0, 4));
      final month = int.parse(raw.substring(4, 6));
      final day = int.parse(raw.substring(6, 8));
      final hour = int.parse(raw.substring(9, 11));
      final minute = int.parse(raw.substring(11, 13));
      return DateTime(year, month, day, hour, minute);
    }
    final year = int.parse(raw.substring(0, 4));
    final month = int.parse(raw.substring(4, 6));
    final day = int.parse(raw.substring(6, 8));
    return DateTime(year, month, day);
  }

  int _priorityScore(String priority) {
    switch (priority) {
      case 'high':
        return 2;
      case 'low':
        return 0;
      default:
        return 1;
    }
  }

  String _dayKey(DateTime date) =>
      DateTime(date.year, date.month, date.day).toIso8601String();
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
