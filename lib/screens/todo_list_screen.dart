import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/todo_provider.dart';
import '../utils/constants.dart';
import '../widgets/todo_item.dart';

class TodoListScreen extends ConsumerWidget {
  const TodoListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(todoListProvider);
    
    // 排序：先按四象限优先级，再按提醒时间升序
    final pendingTodos = todos.where((t) => !t.isCompleted).toList()
      ..sort((a, b) {
        // 第一优先级：四象限等级
        final priorityCompare = a.priority.sortOrder.compareTo(b.priority.sortOrder);
        if (priorityCompare != 0) return priorityCompare;
        
        // 第二优先级：提醒时间（升序，越早越靠前）
        if (a.dueTime != null && b.dueTime != null) {
          return a.dueTime!.compareTo(b.dueTime!);
        } else if (a.dueTime != null) {
          return -1;
        } else if (b.dueTime != null) {
          return 1;
        }
        
        // 第三优先级：截止日期
        if (a.dueDate != null && b.dueDate != null) {
          return a.dueDate!.compareTo(b.dueDate!);
        }
        
        return 0;
      });
    
    final completedTodos = todos.where((t) => t.isCompleted).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('所有待办'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '进行中'),
              Tab(text: '已完成'),
            ],
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
          ),
        ),
        body: TabBarView(
          children: [
            pendingTodos.isEmpty
                ? _buildEmptyState('没有进行中的待办')
                : ListView.builder(
                    itemCount: pendingTodos.length,
                    itemBuilder: (context, index) => TodoItem(
                      todo: pendingTodos[index],
                      showDate: true,
                    ),
                  ),
            completedTodos.isEmpty
                ? _buildEmptyState('没有已完成的待办')
                : ListView.builder(
                    itemCount: completedTodos.length,
                    itemBuilder: (context, index) => TodoItem(
                      todo: completedTodos[index],
                      showDate: true,
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}