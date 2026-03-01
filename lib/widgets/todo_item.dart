import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/todo.dart';
import '../providers/todo_provider.dart';
import '../utils/constants.dart';
import '../screens/edit_todo_screen.dart';
import 'animations/slide_animation.dart';

class TodoItem extends ConsumerWidget {
  final Todo todo;
  final VoidCallback? onTap;
  final bool showDate;

  const TodoItem({
    super.key,
    required this.todo,
    this.onTap,
    this.showDate = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SlideAnimation(
      child: Dismissible(
        key: Key(todo.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: Colors.red.shade400,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.delete,
            color: Colors.white,
            size: 28,
          ),
        ),
        onDismissed: (_) {
          ref.read(todoListProvider.notifier).deleteTodo(todo.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('已删除'),
              action: SnackBarAction(
                label: '撤销',
                onPressed: () {
                  ref.read(todoListProvider.notifier).addTodo(todo);
                },
              ),
            ),
          );
        },
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: InkWell(
            onTap: onTap ?? () => _openEdit(context),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _buildCheckbox(context, ref),
                  const SizedBox(width: 12),
                  _buildPriorityIndicator(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          todo.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            decoration: todo.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            color: todo.isCompleted
                                ? Colors.grey
                                : Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (todo.description != null && todo.description!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            todo.description!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        if (showDate && todo.dueDate != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildDateChip(),
                              _buildPriorityChip(),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert, size: 20),
                    onPressed: () => _showOptions(context, ref),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => ref.read(todoListProvider.notifier).toggleTodo(todo.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: todo.isCompleted ? AppConstants.secondaryColor : Colors.transparent,
          border: Border.all(
            color: todo.isCompleted
                ? AppConstants.secondaryColor
                : Colors.grey.shade400,
            width: 2,
          ),
        ),
        child: todo.isCompleted
            ? const Icon(
                Icons.check,
                size: 16,
                color: Colors.white,
              )
            : null,
      ),
    );
  }

  Widget _buildPriorityIndicator() {
    return Container(
      width: 4,
      height: 50,
      decoration: BoxDecoration(
        color: todo.priority.color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildDateChip() {
    final isOverdue = todo.isOverdue;
    final isToday = todo.isDueToday;

    Color chipColor;
    String dateText;

    if (isOverdue) {
      chipColor = AppConstants.accentColor;
      dateText = '已逾期';
    } else if (isToday) {
      chipColor = AppConstants.warningColor;
      dateText = '今天';
    } else {
      chipColor = Colors.grey.shade600;
      dateText = DateFormat('MM月dd日').format(todo.dueDate!);
    }

    if (todo.dueTime != null) {
      dateText += ' ${DateFormat('HH:mm').format(todo.dueTime!)}';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        dateText,
        style: TextStyle(
          fontSize: 12,
          color: chipColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildPriorityChip() {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: todo.priority.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        todo.priority.label,
        style: TextStyle(
          fontSize: 10,
          color: todo.priority.color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _openEdit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTodoScreen(todo: todo),
      ),
    );
  }

  void _showOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: AppConstants.primaryColor),
              title: const Text('编辑'),
              onTap: () {
                Navigator.pop(context);
                _openEdit(context);
              },
            ),
            ListTile(
              leading: Icon(
                todo.isCompleted ? Icons.refresh : Icons.check_circle,
                color: AppConstants.secondaryColor,
              ),
              title: Text(todo.isCompleted ? '标记为未完成' : '标记为完成'),
              onTap: () {
                ref.read(todoListProvider.notifier).toggleTodo(todo.id);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('删除', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                ref.read(todoListProvider.notifier).deleteTodo(todo.id);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}