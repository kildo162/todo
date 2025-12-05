import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'todo_model.dart';

class TodoController extends GetxController {
  static const _storageKey = 'todo_items_storage';

  final tasks = <TodoItem>[].obs;
  final filter = 'all'.obs; // all | active | done | overdue

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  List<TodoItem> get visibleTasks {
    List<TodoItem> list;
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    switch (filter.value) {
      case 'active':
        list = tasks.where((t) => !t.completed).toList();
        break;
      case 'done':
        list = tasks.where((t) => t.completed).toList();
        break;
      case 'overdue':
        list = tasks.where((t) => !t.completed && t.dueDate != null && t.dueDate!.isBefore(start)).toList();
        break;
      default:
        list = tasks;
    }
    list.sort(_sortComparator(start));
    return list;
  }

  void setFilter(String value) {
    filter.value = value;
  }

  Future<void> addTask(String title, {String? description, DateTime? dueDate, String priority = 'normal'}) async {
    final newTask = TodoItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      dueDate: dueDate,
      priority: priority,
    );
    tasks.insert(0, newTask);
    await _save();
  }

  Future<void> toggleTask(String id) async {
    final idx = tasks.indexWhere((t) => t.id == id);
    if (idx == -1) return;
    final task = tasks[idx];
    tasks[idx] = task.copyWith(completed: !task.completed);
    await _save();
  }

  Future<void> updateTask(String id, {String? title, String? description, DateTime? dueDate, String? priority}) async {
    final idx = tasks.indexWhere((t) => t.id == id);
    if (idx == -1) return;
    final task = tasks[idx].copyWith(
      title: title,
      description: description,
      dueDate: dueDate,
      priority: priority,
    );
    tasks[idx] = task;
    await _save();
  }

  Future<void> deleteTask(String id) async {
    tasks.removeWhere((t) => t.id == id);
    await _save();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      final decoded = jsonDecode(raw) as List<dynamic>;
      tasks.assignAll(decoded.map((e) => TodoItem.fromJson(e as Map<String, dynamic>)));
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(tasks.map((t) => t.toJson()).toList());
    await prefs.setString(_storageKey, data);
  }

  int Function(TodoItem, TodoItem) _sortComparator(DateTime todayStart) {
    return (a, b) {
      int priorityScore(String p) {
        switch (p) {
          case 'high':
            return 2;
          case 'low':
            return 0;
          default:
            return 1;
        }
      }

      bool overdue(TodoItem t) => !t.completed && t.dueDate != null && t.dueDate!.isBefore(todayStart);

      final oa = overdue(a);
      final ob = overdue(b);
      if (oa != ob) return oa ? -1 : 1;

      final pa = priorityScore(a.priority);
      final pb = priorityScore(b.priority);
      if (pa != pb) return pb.compareTo(pa); // high first

      if (a.dueDate != null && b.dueDate != null) {
        if (a.dueDate != b.dueDate) return a.dueDate!.compareTo(b.dueDate!);
      } else if (a.dueDate != null) {
        return -1;
      } else if (b.dueDate != null) {
        return 1;
      }

      return b.createdAt.compareTo(a.createdAt);
    };
  }
}
