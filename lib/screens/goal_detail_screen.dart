import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/goal.dart';
import '../models/todo.dart';
import '../providers/goal_provider.dart';
import '../providers/todo_provider.dart';
import '../utils/constants.dart';

class GoalDetailScreen extends ConsumerWidget {
  final Goal goal;

  const GoalDetailScreen({super.key, required this.goal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(todoListProvider);
    final relatedTodos = todos.where((t) => goal.relatedTodoIds.contains(t.id)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('目标详情'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // 编辑功能
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            _buildProgressSection(context, ref),
            const SizedBox(height: 24),
            _buildRelatedTodosSection(context, ref, relatedTodos),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: goal.type == GoalType.lifelong
                    ? Colors.purple.withValues(alpha: 0.15)
                    : Colors.blue.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                goal.type.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: goal.type == GoalType.lifelong
                      ? Colors.purple
                      : Colors.blue,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: goal.status.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                goal.status.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: goal.status.color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          goal.title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (goal.description != null) ...[
          const SizedBox(height: 12),
          Text(
            goal.description!,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
        ],
        if (goal.targetDate != null) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.event,
                size: 20,
                color: goal.isOverdue ? Colors.red : Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(
                '截止日期: ${goal.targetDate!.year}年${goal.targetDate!.month}月${goal.targetDate!.day}日',
                style: TextStyle(
                  fontSize: 14,
                  color: goal.isOverdue ? Colors.red : Colors.grey.shade700,
                ),
              ),
              if (goal.isOverdue) ...[
                const SizedBox(width: 8),
                const Text(
                  '(已逾期)',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildProgressSection(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '完成进度',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${goal.progress}%',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: goal.progress / 100,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  goal.status == GoalStatus.completed
                      ? Colors.green
                      : AppConstants.primaryColor,
                ),
                minHeight: 12,
              ),
            ),
            if (goal.status == GoalStatus.active) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showProgressDialog(context, ref),
                  icon: const Icon(Icons.trending_up),
                  label: const Text('更新进度'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRelatedTodosSection(BuildContext context, WidgetRef ref, List<Todo> relatedTodos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '关联待办',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () => _showAddTodoDialog(context, ref),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('添加'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (relatedTodos.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.check_box_outlined,
                      size: 48,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '暂无关联待办',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ...relatedTodos.map((todo) => _buildTodoItem(context, ref, todo)),
      ],
    );
  }

  Widget _buildTodoItem(BuildContext context, WidgetRef ref, Todo todo) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Checkbox(
          value: todo.isCompleted,
          onChanged: (value) {
            ref.read(todoListProvider.notifier).toggleTodo(todo.id);
          },
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
            color: todo.isCompleted ? Colors.grey : Colors.black87,
          ),
        ),
        subtitle: todo.dueDate != null
            ? Text(
                '${todo.dueDate!.month}月${todo.dueDate!.day}日',
                style: TextStyle(
                  fontSize: 12,
                  color: todo.isOverdue ? Colors.red : Colors.grey,
                ),
              )
            : null,
        trailing: IconButton(
          icon: const Icon(Icons.link_off, size: 20),
          onPressed: () async {
            await ref.read(goalListProvider.notifier).removeRelatedTodo(
              goal.id,
              todo.id,
            );
          },
        ),
      ),
    );
  }

  void _showProgressDialog(BuildContext context, WidgetRef ref) {
    double progress = goal.progress.toDouble();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('更新进度'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${progress.round()}%',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                Slider(
                  value: progress,
                  min: 0,
                  max: 100,
                  divisions: 20,
                  label: '${progress.round()}%',
                  onChanged: (value) {
                    setState(() {
                      progress = value;
                    });
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(goalListProvider.notifier).updateProgress(
                goal.id,
                progress.round(),
              );
              if (!context.mounted) return;  // 添加这行
              Navigator.pop(context);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showAddTodoDialog(BuildContext context, WidgetRef ref) {
    final todos = ref.read(todoListProvider);
    final availableTodos = todos.where(
      (t) => !goal.relatedTodoIds.contains(t.id) && !t.isCompleted,
    ).toList();

    if (availableTodos.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('提示'),
          content: const Text('没有可关联的待办事项'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('确定'),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择待办'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: availableTodos.length,
            itemBuilder: (context, index) {
              final todo = availableTodos[index];
              return ListTile(
                title: Text(todo.title),
                subtitle: todo.dueDate != null
                    ? Text('${todo.dueDate!.month}月${todo.dueDate!.day}日')
                    : null,
                onTap: () async {
                  await ref.read(goalListProvider.notifier).addRelatedTodo(
                    goal.id,
                    todo.id,
                  );
                  if (!context.mounted) return;  // 添加这行
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }
}