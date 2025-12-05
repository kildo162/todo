import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuickAction {
  final String id;
  final String label;
  final String icon;
  final bool enabled;

  const QuickAction({
    required this.id,
    required this.label,
    required this.icon,
    required this.enabled,
  });

  QuickAction copyWith({bool? enabled}) {
    return QuickAction(
      id: id,
      label: label,
      icon: icon,
      enabled: enabled ?? this.enabled,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'icon': icon,
        'enabled': enabled,
      };

  factory QuickAction.fromJson(Map<String, dynamic> json) {
    return QuickAction(
      id: json['id'] as String,
      label: json['label'] as String,
      icon: json['icon'] as String,
      enabled: json['enabled'] as bool,
    );
  }
}

class HomeController extends GetxController {
  static const String _storageKey = 'home_quick_actions';
  var quickActions = <QuickAction>[].obs;

  @override
  void onInit() {
    super.onInit();
    quickActions.assignAll(_defaultActions());
    _loadActions();
  }

  List<QuickAction> get visibleActions => quickActions.where((e) => e.enabled).toList();

  Future<void> toggleAction(String id, bool enabled) async {
    final idx = quickActions.indexWhere((e) => e.id == id);
    if (idx == -1) return;
    quickActions[idx] = quickActions[idx].copyWith(enabled: enabled);
    quickActions.refresh();
    await _saveActions();
  }

  Future<void> reorderActions(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex -= 1;
    final item = quickActions.removeAt(oldIndex);
    quickActions.insert(newIndex, item);
    quickActions.refresh();
    await _saveActions();
  }

  Future<void> resetActions() async {
    quickActions.assignAll(_defaultActions());
    await _saveActions();
  }

  Future<void> _loadActions() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null && raw.isNotEmpty) {
      final decoded = jsonDecode(raw) as List<dynamic>;
      quickActions.assignAll(decoded.map((e) => QuickAction.fromJson(e as Map<String, dynamic>)).toList());
    } else {
      quickActions.assignAll(_defaultActions());
    }
  }

  Future<void> _saveActions() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(quickActions.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, data);
  }

  List<QuickAction> _defaultActions() {
    return const [
      QuickAction(id: 'event', label: 'Sự kiện', icon: 'assets/icons/solid/calendar.svg', enabled: true),
      QuickAction(id: 'notification', label: 'Thông báo', icon: 'assets/icons/solid/bell.svg', enabled: true),
      QuickAction(id: 'note', label: 'Ghi chú', icon: 'assets/icons/solid/check-circle.svg', enabled: true),
      QuickAction(id: 'settings', label: 'Cài đặt', icon: 'assets/icons/solid/cog-6-tooth.svg', enabled: true),
      QuickAction(id: 'manage', label: 'Quản lý lối tắt', icon: 'assets/icons/solid/squares-2x2.svg', enabled: true),
    ];
  }
}
