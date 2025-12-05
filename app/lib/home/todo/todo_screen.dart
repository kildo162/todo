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
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1F72E5), Color(0xFF42C0F0)],
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
              child: _svg('assets/icons/solid/check-circle.svg', size: 18, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Taskboard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
                Text('Tối ưu không gian & trải nghiệm', style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
            tooltip: 'Tìm kiếm nhanh (mock)',
          ),
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

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _buildSummaryCard(active: active, done: done, overdue: overdue, total: total),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _FilterHeaderDelegate(
                minHeight: 72,
                maxHeight: 72,
                child: _buildFilterBar(total: total, active: active, done: done, overdue: overdue),
              ),
            ),
            if (tasks.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyTodo(onAdd: () => _showCreateSheet(context)),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final task = tasks[index];
                      return _TodoTile(
                        task: task,
                        onToggle: () => controller.toggleTask(task.id),
                        onDelete: () => controller.deleteTask(task.id),
                        onEdit: () => _showCreateSheet(context, task: task),
                      );
                    },
                    childCount: tasks.length,
                  ),
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

  Widget _buildSummaryCard({required int active, required int done, required int overdue, required int total}) {
    final completion = total == 0 ? 0.0 : done / total;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 18, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
                child: _svg('assets/icons/outline/clipboard-document-check.svg', size: 18, color: Colors.blue.shade700),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text('Tổng quan công việc', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    const Icon(Icons.view_agenda_outlined, size: 14, color: Colors.blue),
                    const SizedBox(width: 6),
                    Text('$total task', style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w700, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _statPill('Đang làm', active, Colors.amber.shade700),
              const SizedBox(width: 8),
              _statPill('Hoàn thành', done, Colors.green.shade700),
              const SizedBox(width: 8),
              _statPill('Quá hạn', overdue, Colors.red.shade600),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: completion,
              minHeight: 10,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            total == 0 ? 'Bắt đầu thêm task để theo dõi tiến độ.' : 'Hoàn thành ${(completion * 100).round()}% · $done/$total task',
            style: TextStyle(color: Colors.grey.shade700, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _statPill(String label, int value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.18)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$value', style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 17)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color.withOpacity(0.9), fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar({required int total, required int active, required int done, required int overdue}) {
    return Container(
      color: const Color(0xFFF5F7FB),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            _filterChip(label: 'Tất cả', key: 'all', value: total, icon: Icons.apps_rounded),
            _filterChip(label: 'Đang làm', key: 'active', value: active, icon: Icons.run_circle_outlined),
            _filterChip(label: 'Hoàn thành', key: 'done', value: done, icon: Icons.verified_outlined),
            _filterChip(label: 'Quá hạn', key: 'overdue', value: overdue, icon: Icons.warning_amber_rounded),
          ],
        ),
      ),
    );
  }

  Widget _filterChip({required String label, required String key, required int value, IconData? icon}) {
    final selected = controller.filter.value == key;
    final color = selected ? Colors.blue.shade700 : Colors.grey.shade800;
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ChoiceChip(
        labelPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
            ],
            Text(label, style: TextStyle(fontWeight: FontWeight.w700, color: color)),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: selected ? Colors.white : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('$value', style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
        selected: selected,
        onSelected: (_) => controller.setFilter(key),
        selectedColor: Colors.blue.shade50,
        backgroundColor: Colors.white,
        side: BorderSide(color: selected ? Colors.blue.shade200 : Colors.grey.shade200),
        pressElevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Future<void> _showCreateSheet(BuildContext context, {TodoItem? task}) async {
    final isEditing = task != null;
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
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
                        child: _svg('assets/icons/outline/clipboard-document-check.svg', size: 18, color: Colors.blue.shade700),
                      ),
                      const SizedBox(width: 10),
                      Text(isEditing ? 'Cập nhật task' : 'Thêm task', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                      const Spacer(),
                      TextButton(onPressed: () => Navigator.of(ctx).maybePop(), child: const Text('Đóng')),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: titleCtrl,
                    decoration: InputDecoration(
                      hintText: 'Tiêu đề',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descCtrl,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Mô tả (tuỳ chọn)',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Hạn (tuỳ chọn)', style: TextStyle(fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              Text(
                                dueDate == null ? 'Chưa chọn' : '${dueDate!.day}/${dueDate!.month}/${dueDate!.year}',
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                            ],
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () async {
                            final now = DateTime.now();
                            final picked = await showDatePicker(
                              context: ctx,
                              initialDate: dueDate ?? now,
                              firstDate: DateTime(now.year - 1),
                              lastDate: DateTime(now.year + 5),
                            );
                            if (picked != null) {
                              setState(() => dueDate = picked);
                            }
                          },
                          icon: const Icon(Icons.calendar_today, size: 16),
                          label: const Text('Chọn ngày'),
                        ),
                      ],
                    ),
                  ),
                  if (dueDate != null) ...[
                    const SizedBox(height: 8),
                    TextButton(onPressed: () => setState(() => dueDate = null), child: const Text('Xoá hạn')),
                  ],
                  const SizedBox(height: 12),
                  const Text('Ưu tiên', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      ChoiceChip(
                        label: const Text('Cao'),
                        selected: priority == 'high',
                        onSelected: (_) => setState(() => priority = 'high'),
                        selectedColor: Colors.red.shade100,
                        labelStyle: TextStyle(color: priority == 'high' ? Colors.red.shade700 : Colors.grey.shade700, fontWeight: FontWeight.w700),
                      ),
                      ChoiceChip(
                        label: const Text('Thường'),
                        selected: priority == 'normal',
                        onSelected: (_) => setState(() => priority = 'normal'),
                        selectedColor: Colors.blue.shade50,
                        labelStyle: TextStyle(color: priority == 'normal' ? Colors.blue.shade700 : Colors.grey.shade700, fontWeight: FontWeight.w700),
                      ),
                      ChoiceChip(
                        label: const Text('Thấp'),
                        selected: priority == 'low',
                        onSelected: (_) => setState(() => priority = 'low'),
                        selectedColor: Colors.green.shade50,
                        labelStyle: TextStyle(color: priority == 'low' ? Colors.green.shade700 : Colors.grey.shade700, fontWeight: FontWeight.w700),
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
                      child: Text(isEditing ? 'Cập nhật' : 'Lưu task', style: const TextStyle(fontWeight: FontWeight.w700)),
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

class _FilterHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _FilterHeaderDelegate({required this.minHeight, required this.maxHeight, required this.child});

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FB),
        boxShadow: overlapsContent
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _FilterHeaderDelegate oldDelegate) {
    return minExtent != oldDelegate.minExtent || maxExtent != oldDelegate.maxExtent || oldDelegate.child != child;
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
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    final overdue = !task.completed && task.dueDate != null && task.dueDate!.isBefore(start);
    final accent = _priorityColor(task.priority);
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
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: task.completed ? Colors.grey.shade100 : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: overdue ? Colors.red.shade200 : accent.withOpacity(0.2)),
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
                shape: const CircleBorder(),
                activeColor: accent,
                visualDensity: const VisualDensity(horizontal: -3, vertical: -3),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            task.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                              decoration: task.completed ? TextDecoration.lineThrough : TextDecoration.none,
                              color: task.completed ? Colors.grey.shade600 : Colors.grey.shade900,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          color: Colors.blue.shade600,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          splashRadius: 20,
                          onPressed: onEdit,
                        ),
                      ],
                    ),
                    if ((task.description ?? '').isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        task.description!,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey.shade700, fontSize: 12.5, height: 1.35),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _priorityChip(task.priority),
                        if (task.dueDate != null) _dueChip(task, overdue: overdue),
                        _statusChip(task.completed, overdue),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _priorityChip(String priority) {
    final color = _priorityColor(priority);
    String label;
    switch (priority) {
      case 'high':
        label = 'Ưu tiên cao';
        break;
      case 'low':
        label = 'Ưu tiên thấp';
        break;
      default:
        label = 'Ưu tiên thường';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _dueChip(TodoItem task, {required bool overdue}) {
    final color = overdue ? Colors.red.shade600 : Colors.grey.shade800;
    final bg = overdue ? Colors.red.shade50 : Colors.grey.shade200;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_today, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            '${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}',
            style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(bool completed, bool overdue) {
    String label;
    Color color;
    Color bg;
    if (completed) {
      label = 'Đã xong';
      color = Colors.green.shade600;
      bg = Colors.green.shade50;
    } else if (overdue) {
      label = 'Quá hạn';
      color = Colors.red.shade600;
      bg = Colors.red.shade50;
    } else {
      label = 'Đang mở';
      color = Colors.blue.shade600;
      bg = Colors.blue.shade50;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(completed ? Icons.check_circle : Icons.timelapse, size: 14, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12)),
        ],
      ),
    );
  }

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'high':
        return Colors.red.shade500;
      case 'low':
        return Colors.green.shade500;
      default:
        return Colors.blue.shade500;
    }
  }
}

class _EmptyTodo extends StatelessWidget {
  final VoidCallback? onAdd;

  const _EmptyTodo({this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 120, left: 24, right: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
              child: Icon(Icons.inbox_outlined, size: 42, color: Colors.blue.shade600),
            ),
            const SizedBox(height: 14),
            Text('Danh sách trống', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.grey.shade800, fontSize: 16)),
            const SizedBox(height: 6),
            Text(
              'Thêm task đầu tiên để bắt đầu tối ưu không gian làm việc của bạn.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 14),
            if (onAdd != null)
              ElevatedButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                label: const Text('Thêm task ngay'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
