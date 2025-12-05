import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'todo_controller.dart';
import 'todo_model.dart';

class TodoScreen extends StatelessWidget {
  TodoScreen({super.key});

  final TodoController controller =
      Get.isRegistered<TodoController>() ? Get.find<TodoController>() : Get.put(TodoController(), permanent: true);

  Widget _svg(String path, {double size = 20, Color? color}) {
    return SvgPicture.asset(path, height: size, width: size, colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        toolbarHeight: 66,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E88E5), Color(0xFF64B5F6)],
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
              child: _svg('assets/icons/outline/clipboard-document-check.svg', size: 18, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Task', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
                Text('Quản lý công việc', style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: _svg('assets/icons/outline/adjustments-horizontal.svg', size: 20, color: Colors.white),
            onPressed: () {},
            tooltip: 'Tùy chọn',
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Obx(() {
        final tasks = controller.visibleTasks;
        final total = controller.tasks.length;
        final done = controller.tasks.where((t) => t.completed).length;
        final active = total - done;
        final overdue = controller.tasks
            .where((t) => !t.completed && t.dueDate != null && t.dueDate!.isBefore(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)))
            .length;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: Row(
                children: [
                  _summaryChip(label: 'Tất cả', value: total, selected: controller.filter.value == 'all', onTap: () => controller.setFilter('all')),
                  const SizedBox(width: 8),
                  _summaryChip(label: 'Đang làm', value: active, selected: controller.filter.value == 'active', onTap: () => controller.setFilter('active')),
                  const SizedBox(width: 8),
                  _summaryChip(label: 'Hoàn thành', value: done, selected: controller.filter.value == 'done', onTap: () => controller.setFilter('done')),
                  const SizedBox(width: 8),
                  _summaryChip(label: 'Quá hạn', value: overdue, selected: controller.filter.value == 'overdue', onTap: () => controller.setFilter('overdue')),
                ],
              ),
            ),
            Expanded(
              child: tasks.isEmpty
                  ? const _EmptyTodo()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return _TodoTile(
                          task: task,
                          onToggle: () => controller.toggleTask(task.id),
                          onDelete: () => controller.deleteTask(task.id),
                          onEdit: () => _showCreateSheet(context, task: task),
                        );
                      },
                    ),
            ),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateSheet(context),
        backgroundColor: Colors.blue.shade600,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Thêm task', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _summaryChip({required String label, required int value, required bool selected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.blue.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? Colors.blue.shade200 : Colors.grey.shade200),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 3)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: TextStyle(fontWeight: FontWeight.w700, color: selected ? Colors.blue.shade700 : Colors.grey.shade800)),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: selected ? Colors.blue.shade100 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('$value', style: TextStyle(fontSize: 12, color: selected ? Colors.blue.shade700 : Colors.grey.shade800)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCreateSheet(BuildContext context, {TodoItem? task}) async {
    final titleCtrl = TextEditingController(text: task?.title ?? '');
    final descCtrl = TextEditingController(text: task?.description ?? '');
    DateTime? dueDate = task?.dueDate;
    String priority = task?.priority ?? 'normal';

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: StatefulBuilder(builder: (ctx, setState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _svg('assets/icons/outline/clipboard-document-check.svg', size: 18, color: Colors.blue.shade600),
                      const SizedBox(width: 8),
                      const Text('Thêm task', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Tiêu đề',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Mô tả (tuỳ chọn)',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Hạn (tuỳ chọn)', style: TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            Text(
                              dueDate == null ? 'Chưa chọn' : '${dueDate!.day}/${dueDate!.month}/${dueDate!.year}',
                              style: TextStyle(color: Colors.grey.shade800),
                            ),
                          ],
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          final now = DateTime.now();
                          final picked = await showDatePicker(
                            context: ctx,
                            initialDate: dueDate ?? now,
                            firstDate: DateTime(now.year - 1),
                            lastDate: DateTime(now.year + 5),
                          );
                          if (picked != null) {
                            setState(() {
                              dueDate = picked;
                            });
                          }
                        },
                        icon: const Icon(Icons.calendar_today, size: 16),
                        label: const Text('Chọn ngày'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Ưu tiên', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(width: 12),
                      ChoiceChip(
                        label: const Text('Cao'),
                        selected: priority == 'high',
                        onSelected: (_) => setState(() => priority = 'high'),
                        selectedColor: Colors.red.shade100,
                        labelStyle: TextStyle(color: priority == 'high' ? Colors.red.shade700 : Colors.grey.shade700),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Thường'),
                        selected: priority == 'normal',
                        onSelected: (_) => setState(() => priority = 'normal'),
                        selectedColor: Colors.blue.shade50,
                        labelStyle: TextStyle(color: priority == 'normal' ? Colors.blue.shade700 : Colors.grey.shade700),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Thấp'),
                        selected: priority == 'low',
                        onSelected: (_) => setState(() => priority = 'low'),
                        selectedColor: Colors.green.shade50,
                        labelStyle: TextStyle(color: priority == 'low' ? Colors.green.shade700 : Colors.grey.shade700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final title = titleCtrl.text.trim();
                        if (title.isEmpty) return;
                        final desc = descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim();
                        if (task == null) {
                          controller.addTask(title, description: desc, dueDate: dueDate, priority: priority);
                          Get.snackbar('Đã thêm', 'Task mới đã được lưu', snackPosition: SnackPosition.BOTTOM);
                        } else {
                          controller.updateTask(task.id, title: title, description: desc, dueDate: dueDate, priority: priority);
                          Get.snackbar('Đã cập nhật', 'Task đã được lưu', snackPosition: SnackPosition.BOTTOM);
                        }
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(task == null ? 'Lưu task' : 'Cập nhật', style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
  }
}

class _TodoTile extends StatelessWidget {
  final TodoItem task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _TodoTile({required this.task, required this.onToggle, required this.onDelete, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(14)),
        child: Icon(Icons.delete, color: Colors.red.shade700),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: task.completed,
              onChanged: (_) => onToggle(),
              activeColor: Colors.blue.shade600,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      decoration: task.completed ? TextDecoration.lineThrough : TextDecoration.none,
                      color: task.completed ? Colors.grey.shade600 : Colors.black,
                    ),
                  ),
                  if ((task.description ?? '').isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      task.description!,
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 12, height: 1.3),
                    ),
                  ],
                  if (task.dueDate != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 12, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          '${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _priorityChip(task.priority),
                      if (task.dueDate != null) ...[
                        const SizedBox(width: 8),
                        _dueChip(task),
                      ],
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.edit, size: 16, color: Colors.blue),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: onEdit,
                        splashRadius: 18,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _priorityChip(String priority) {
    Color color;
    String label;
    switch (priority) {
      case 'high':
        color = Colors.red.shade400;
        label = 'Ưu tiên cao';
        break;
      case 'low':
        color = Colors.green.shade400;
        label = 'Ưu tiên thấp';
        break;
      default:
        color = Colors.blue.shade400;
        label = 'Ưu tiên thường';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
      child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w700)),
    );
  }

  Widget _dueChip(TodoItem task) {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    final overdue = !task.completed && task.dueDate!.isBefore(start);
    final color = overdue ? Colors.red.shade500 : Colors.grey.shade700;
    final bg = overdue ? Colors.red.shade50 : Colors.grey.shade200;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_today, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            '${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}',
            style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _EmptyTodo extends StatelessWidget {
  const _EmptyTodo();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 120),
        child: Column(
          children: [
            Icon(Icons.task_alt, size: 60, color: Colors.grey.shade500),
            const SizedBox(height: 10),
            Text('Chưa có task nào', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.grey.shade700)),
            const SizedBox(height: 4),
            Text('Thêm task để bắt đầu quản lý công việc.', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
