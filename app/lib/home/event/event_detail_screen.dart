import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:app/home/event/event_controller.dart';
import 'package:app/utils/lunisolar_calendar.dart';
import 'package:app/shared/widgets/swipe_back_wrapper.dart';

class EventDayDetailScreen extends StatelessWidget {
  final DateTime date;

  EventDayDetailScreen({super.key, required this.date});

  final EventController controller = Get.isRegistered<EventController>()
      ? Get.find<EventController>()
      : Get.put(EventController(), permanent: true);

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
    final lunar = LunisolarConverter.solarToLunar(date);
    final canChi = LunisolarConverter.canChi(date);
    final solarTerm = LunisolarConverter.solarTerm(date);
    final bool isHoangDao = LunisolarConverter.isHoangDaoDay(date);
    final String hoangDaoLabel = isHoangDao ? 'Hoàng đạo' : 'Hắc đạo';
    final events = controller.eventsForDate(date)
      ..sort((a, b) => a.date.compareTo(b.date));

    return SwipeBackWrapper(
      child: Scaffold(
        appBar: AppBar(
          leading: const BackButton(),
          title: const Text('Chi tiết ngày'),
          backgroundColor: Colors.white,
          elevation: 0.5,
          iconTheme: const IconThemeData(color: Colors.black),
          titleTextStyle: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () =>
                  Get.to(() => EventCreateScreen(initialDate: date)),
              tooltip: 'Tạo sự kiện',
            ),
          ],
        ),
        backgroundColor: const Color(0xFFF6F8FB),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
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
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${date.day}',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            'T${date.month}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          Text(
                            'T${date.weekday}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dương: ${date.day}/${date.month}/${date.year}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Âm: ${lunar.day}/${lunar.month}${lunar.isLeap ? " (N)" : ""}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Ngày ${_weekdayLabel(date.weekday)} · ${events.length} sự kiện',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Can Chi',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _Tag(
                          label: '${canChi.dayCan} ${canChi.dayChi}',
                          caption: 'Ngày',
                        ),
                        const SizedBox(width: 8),
                        _Tag(
                          label: '${canChi.monthCan} ${canChi.monthChi}',
                          caption: 'Tháng',
                        ),
                        const SizedBox(width: 8),
                        _Tag(
                          label: '${canChi.yearCan} ${canChi.yearChi}',
                          caption: 'Năm',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tiết khí & Hoàng đạo',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _Tag(label: solarTerm, caption: 'Tiết khí'),
                        const SizedBox(width: 8),
                        _Tag(label: hoangDaoLabel, caption: 'Ngày'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Sự kiện trong ngày',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  TextButton.icon(
                    onPressed: () =>
                        Get.to(() => EventCreateScreen(initialDate: date)),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Thêm'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (events.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 46,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Chưa có sự kiện',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Thêm sự kiện để không bỏ lỡ ngày này.',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Column(
                  children: events
                      .map(
                        (event) => Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
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
                                    _CategoryBadge(category: event.category),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${_formatTime(event.startTime)} - ${_formatTime(event.endTime)}',
                                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      event.description,
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontSize: 12,
                                      ),
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
                                      ],
                                    ),
                                    if (event.locationName != null &&
                                        event.locationName!.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.place_outlined, size: 14, color: Colors.redAccent),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              event.locationName!,
                                              style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                    if (event.guests.isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 4,
                                        children: event.guests
                                            .map(
                                              (guest) => Chip(
                                                label: Text(
                                                  guest,
                                                  style: const TextStyle(fontSize: 11),
                                                ),
                                                backgroundColor: Colors.blue.shade50,
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    ],
                                    if (event.attachments.isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: event.attachments
                                            .map(
                                              (att) => Text(
                                                '• $att',
                                                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    ],
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 4,
                                      children: [
                                        TextButton.icon(
                                          onPressed: () => Get.to(() => EventCreateScreen(initialDate: event.date, event: event)),
                                          icon: const Icon(Icons.edit_outlined, size: 16),
                                          label: const Text('Chỉnh sửa'),
                                        ),
                                        TextButton.icon(
                                          onPressed: () async {
                                            await controller.deleteEvent(event.id);
                                            Get.snackbar(
                                              'Đã xoá',
                                              'Sự kiện đã bị xoá',
                                              snackPosition: SnackPosition.BOTTOM,
                                              mainButton: TextButton(
                                                onPressed: () => controller.undoDelete(),
                                                child: const Text('Hoàn tác'),
                                              ),
                                            );
                                          },
                                          icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                                          label: const Text('Xoá', style: TextStyle(color: Colors.red)),
                                        ),
                                        TextButton.icon(
                                          onPressed: () => controller.snoozeEvent(event.id, const Duration(minutes: 5)),
                                          icon: const Icon(Icons.snooze, size: 16),
                                          label: const Text('Snooze 5p'),
                                        ),
                                        if (event.recurrence != 'none')
                                          TextButton(
                                            onPressed: () => controller.skipOccurrence(event.id, date),
                                            child: const Text('Bỏ qua lần này'),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _weekdayLabel(int weekday) {
    const labels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    return labels[(weekday - 1) % 7];
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final String caption;

  const _Tag({required this.label, required this.caption});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              caption,
              style: TextStyle(
                color: Colors.blue.shade600,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final String category;

  const _CategoryBadge({required this.category});

  Color _color() {
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

  String _label() {
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

  @override
  Widget build(BuildContext context) {
    final color = _color();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(
        _label(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class EventCreateScreen extends StatefulWidget {
  final DateTime? initialDate;
  final Event? event;

  const EventCreateScreen({super.key, this.initialDate, this.event});

  @override
  State<EventCreateScreen> createState() => _EventCreateScreenState();
}

class _EventCreateScreenState extends State<EventCreateScreen> {
  final EventController controller = Get.isRegistered<EventController>()
      ? Get.find<EventController>()
      : Get.put(EventController(), permanent: true);

  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _mapCtrl = TextEditingController();
  final _attachmentsCtrl = TextEditingController();
  final _guestsCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _customRecurrenceCtrl = TextEditingController();
  late DateTime _selectedDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  String _category = 'personal';
  String _priority = 'normal';
  String _recurrence = 'none';
  DateTime? _recurrenceEnd;
  List<int> _selectedReminders = [30];
  final List<Map<String, dynamic>> _categoryOptions = const [
    {'key': 'personal', 'label': 'Cá nhân', 'color': Color(0xFF2563EB)},
    {'key': 'work', 'label': 'Công việc', 'color': Color(0xFF16A34A)},
    {'key': 'health', 'label': 'Sức khỏe', 'color': Color(0xFF0EA5E9)},
    {'key': 'holiday', 'label': 'Lịch lễ', 'color': Color(0xFFF97316)},
    {'key': 'other', 'label': 'Khác', 'color': Color(0xFF6B7280)},
  ];
  final List<Map<String, dynamic>> _priorityOptions = const [
    {'key': 'high', 'label': 'Cao', 'color': Color(0xFFDC2626)},
    {'key': 'normal', 'label': 'Trung bình', 'color': Color(0xFF2563EB)},
    {'key': 'low', 'label': 'Thấp', 'color': Color(0xFF6B7280)},
  ];
  final List<Map<String, String>> _recurrenceOptions = const [
    {'key': 'none', 'label': 'Không lặp'},
    {'key': 'daily', 'label': 'Hằng ngày'},
    {'key': 'weekly', 'label': 'Hằng tuần'},
    {'key': 'monthly', 'label': 'Hằng tháng'},
    {'key': 'custom', 'label': 'Tuỳ chỉnh'},
  ];
  final List<int> _reminderPresets = [5, 15, 30, 60, 120];
  bool get _isEditing => widget.event != null;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final existing = widget.event;
    _selectedDate = existing?.date ?? widget.initialDate ?? now;
    _startTime = existing != null ? TimeOfDay.fromDateTime(existing.startTime) : TimeOfDay(hour: now.hour, minute: now.minute);
    _endTime = existing != null
        ? TimeOfDay.fromDateTime(existing.endTime)
        : TimeOfDay(hour: (now.hour + 1) % 24, minute: now.minute);
    _titleCtrl.text = existing?.title ?? '';
    _descCtrl.text = existing?.description ?? '';
    _locationCtrl.text = existing?.locationName ?? '';
    _mapCtrl.text = existing?.mapUrl ?? '';
    _attachmentsCtrl.text = existing?.attachments.join('\n') ?? '';
    _guestsCtrl.text = existing?.guests.join(', ') ?? '';
    _notesCtrl.text = existing?.notes ?? '';
    _customRecurrenceCtrl.text = existing?.customRecurrenceRule ?? '';
    _category = existing?.category ?? 'personal';
    _priority = existing?.priority ?? 'normal';
    _recurrence = existing?.recurrence ?? 'none';
    _recurrenceEnd = existing?.recurrenceEnd;
    _selectedReminders = List<int>.from(existing?.reminders ?? const [30]);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    _mapCtrl.dispose();
    _attachmentsCtrl.dispose();
    _guestsCtrl.dispose();
    _notesCtrl.dispose();
    _customRecurrenceCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(context: context, initialTime: _startTime);
    if (picked != null) {
      setState(() => _startTime = picked);
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(context: context, initialTime: _endTime);
    if (picked != null) {
      setState(() => _endTime = picked);
    }
  }

  Future<void> _pickRecurrenceEnd() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _recurrenceEnd ?? _selectedDate,
      firstDate: _selectedDate,
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _recurrenceEnd = picked);
    }
  }

  void _save() {
    if (_formKey.currentState?.validate() != true) return;
    final start = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _startTime.hour,
      _startTime.minute,
    );
    final tentativeEnd = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _endTime.hour,
      _endTime.minute,
    );
    final end = tentativeEnd.isAfter(start) ? tentativeEnd : start.add(const Duration(hours: 1));
    final attachments = _attachmentsCtrl.text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final guests = _guestsCtrl.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final event = Event(
      id: widget.event?.id,
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      date: _selectedDate,
      startTime: start,
      endTime: end,
      category: _category,
      priority: _priority,
      reminders: _selectedReminders,
      recurrence: _recurrence,
      recurrenceEnd: _recurrenceEnd,
      customRecurrenceRule: _recurrence == 'custom' ? _customRecurrenceCtrl.text.trim() : null,
      locationName: _locationCtrl.text.trim().isEmpty ? null : _locationCtrl.text.trim(),
      mapUrl: _mapCtrl.text.trim().isEmpty ? null : _mapCtrl.text.trim(),
      attachments: attachments,
      guests: guests,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );
    if (_isEditing) {
      controller.updateEvent(widget.event!.id, event);
    } else {
      controller.addEvent(event);
    }
    Get.back();
    Get.snackbar(
      _isEditing ? 'Đã cập nhật' : 'Đã tạo',
      _isEditing ? 'Sự kiện đã được cập nhật' : 'Sự kiện mới đã được thêm',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    final lunar = LunisolarConverter.solarToLunar(_selectedDate);
    return SwipeBackWrapper(
      child: Scaffold(
        appBar: AppBar(
          leading: const BackButton(),
          title: const Text('Tạo sự kiện'),
          backgroundColor: Colors.white,
          elevation: 0.5,
          iconTheme: const IconThemeData(color: Colors.black),
          titleTextStyle: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: const Color(0xFFF6F8FB),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tiêu đề',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _titleCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Nhập tiêu đề sự kiện',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Vui lòng nhập tiêu đề'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Mô tả',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _descCtrl,
                        minLines: 3,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          hintText: 'Chi tiết sự kiện',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ngày',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Dương: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}\nÂm: ${lunar.day}/${lunar.month}${lunar.isLeap ? " (N)" : ""}',
                              style: TextStyle(
                                color: Colors.grey.shade800,
                                height: 1.3,
                              ),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _pickDate,
                            icon: const Icon(Icons.calendar_today, size: 18),
                            label: const Text('Chọn ngày'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _pickStartTime,
                              child: Text('Bắt đầu: ${_startTime.format(context)}'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _pickEndTime,
                              child: Text('Kết thúc: ${_endTime.format(context)}'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Timezone: ${DateTime.now().timeZoneName}',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Phân loại',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _categoryOptions.map((c) {
                          final selected = _category == c['key'];
                          return ChoiceChip(
                            label: Text(
                              c['label'] as String,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: selected ? Colors.white : Colors.black87,
                              ),
                            ),
                            selected: selected,
                            onSelected: (_) =>
                                setState(() => _category = c['key'] as String),
                            selectedColor: c['color'] as Color,
                            backgroundColor: Colors.grey.shade100,
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
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
                      const Text('Mức ưu tiên', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 10,
                        children: _priorityOptions.map((item) {
                          final selected = _priority == item['key'];
                          return ChoiceChip(
                            label: Text(item['label'] as String, style: TextStyle(color: selected ? Colors.white : Colors.black87, fontWeight: FontWeight.w700)),
                            selected: selected,
                            onSelected: (_) => setState(() => _priority = item['key'] as String),
                            selectedColor: item['color'] as Color,
                            backgroundColor: Colors.grey.shade100,
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
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
                      const Text('Nhắc trước', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _reminderPresets
                            .map(
                              (value) => FilterChip(
                                label: Text('$value phút'),
                                selected: _selectedReminders.contains(value),
                                onSelected: (_) {
                                  setState(() {
                                    if (_selectedReminders.contains(value)) {
                                      _selectedReminders.remove(value);
                                    } else {
                                      _selectedReminders.add(value);
                                    }
                                  });
                                },
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 8),
                      Text('Nhắc sẽ được mô phỏng qua log trong app.', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
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
                      const Text('Lặp lại', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _recurrence,
                        items: _recurrenceOptions
                            .map(
                              (item) => DropdownMenuItem<String>(
                                value: item['key'],
                                child: Text(item['label']!),
                              ),
                            )
                            .toList(),
                        onChanged: (value) => setState(() => _recurrence = value ?? 'none'),
                        decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                      ),
                      if (_recurrence == 'custom') ...[
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _customRecurrenceCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Quy tắc tuỳ chỉnh',
                            hintText: 'VD: Thứ 2,4 hàng tuần',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _recurrenceEnd == null ? 'Không giới hạn' : 'Kết thúc: ${_recurrenceEnd!.day}/${_recurrenceEnd!.month}/${_recurrenceEnd!.year}',
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                          ),
                          TextButton(
                            onPressed: _pickRecurrenceEnd,
                            child: const Text('Chọn ngày kết thúc'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
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
                      const Text('Địa điểm & Liên kết', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _locationCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Địa điểm',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _mapCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Link bản đồ / họp trực tuyến',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
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
                      const Text('Khách mời & Tài liệu', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _guestsCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Khách mời (phân cách bằng dấu phẩy)',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _attachmentsCtrl,
                        minLines: 2,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Tài liệu/đường dẫn (mỗi dòng 1 mục)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _notesCtrl,
                        minLines: 2,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Ghi chú bổ sung',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      _isEditing ? 'Cập nhật sự kiện' : 'Lưu sự kiện',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
