import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:app/home/event/event_controller.dart';
import 'package:app/utils/lunisolar_calendar.dart';
import 'package:app/shared/widgets/swipe_back_wrapper.dart';

class EventDayDetailScreen extends StatelessWidget {
  final DateTime date;

  EventDayDetailScreen({super.key, required this.date});

  final EventController controller =
      Get.isRegistered<EventController>() ? Get.find<EventController>() : Get.put(EventController(), permanent: true);

  Widget _svg(String path, {double size = 20, Color? color}) {
    return SvgPicture.asset(
      path,
      height: size,
      width: size,
      colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final lunar = LunisolarConverter.solarToLunar(date);
    final canChi = LunisolarConverter.canChi(date);
    final events = controller.eventsForDate(date)..sort((a, b) => a.date.compareTo(b.date));

    return SwipeBackWrapper(
      child: Scaffold(
        appBar: AppBar(
          leading: const BackButton(),
          title: const Text('Chi tiết ngày'),
          backgroundColor: Colors.white,
          elevation: 0.5,
          iconTheme: const IconThemeData(color: Colors.black),
          titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w700),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => Get.to(() => EventCreateScreen(initialDate: date)),
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
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
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
                          Text('${date.day}', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.black)),
                          Text('T${date.month}', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                          Text('T${date.weekday}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
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
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Âm: ${lunar.day}/${lunar.month}${lunar.isLeap ? " (N)" : ""}',
                            style: const TextStyle(fontSize: 14, color: Colors.blue),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Ngày ${_weekdayLabel(date.weekday)} · ${events.length} sự kiện',
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
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
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Can Chi', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _Tag(label: '${canChi.dayCan} ${canChi.dayChi}', caption: 'Ngày'),
                        const SizedBox(width: 8),
                        _Tag(label: '${canChi.monthCan} ${canChi.monthChi}', caption: 'Tháng'),
                        const SizedBox(width: 8),
                        _Tag(label: '${canChi.yearCan} ${canChi.yearChi}', caption: 'Năm'),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Sự kiện trong ngày', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  TextButton.icon(
                    onPressed: () => Get.to(() => EventCreateScreen(initialDate: date)),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Thêm'),
                    style: TextButton.styleFrom(foregroundColor: Colors.blue.shade700),
                  )
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
                      BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.inbox_outlined, size: 46, color: Colors.grey.shade500),
                      const SizedBox(height: 8),
                      Text('Chưa có sự kiện', style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text('Thêm sự kiện để không bỏ lỡ ngày này.', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
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
                              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
                                child: _svg('assets/icons/solid/calendar-days.svg', size: 20, color: Colors.blue),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(event.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                                    const SizedBox(height: 4),
                                    Text(event.description, style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        _svg('assets/icons/outline/calendar-date-range.svg', size: 14, color: Colors.grey.shade600),
                                        const SizedBox(width: 4),
                                        Text('${event.date.day}/${event.date.month}/${event.date.year}',
                                            style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
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
            Text(caption, style: TextStyle(color: Colors.blue.shade600, fontSize: 12, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class EventCreateScreen extends StatefulWidget {
  final DateTime? initialDate;

  const EventCreateScreen({super.key, this.initialDate});

  @override
  State<EventCreateScreen> createState() => _EventCreateScreenState();
}

class _EventCreateScreenState extends State<EventCreateScreen> {
  final EventController controller =
      Get.isRegistered<EventController>() ? Get.find<EventController>() : Get.put(EventController(), permanent: true);

  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
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

  void _save() {
    if (_formKey.currentState?.validate() != true) return;
    controller.addEvent(Event(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      date: _selectedDate,
    ));
    Get.back();
    Get.snackbar('Đã tạo', 'Sự kiện mới đã được thêm', snackPosition: SnackPosition.BOTTOM);
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
          titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w700),
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
                      BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tiêu đề', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _titleCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Nhập tiêu đề sự kiện',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập tiêu đề' : null,
                      ),
                      const SizedBox(height: 12),
                      const Text('Mô tả', style: TextStyle(fontWeight: FontWeight.w700)),
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
                      BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Ngày', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Dương: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}\nÂm: ${lunar.day}/${lunar.month}${lunar.isLeap ? " (N)" : ""}',
                              style: TextStyle(color: Colors.grey.shade800, height: 1.3),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _pickDate,
                            icon: const Icon(Icons.calendar_today, size: 18),
                            label: const Text('Chọn ngày'),
                            style: TextButton.styleFrom(foregroundColor: Colors.blue.shade700),
                          ),
                        ],
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Lưu sự kiện', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
