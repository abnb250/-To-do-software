import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/calendar_provider.dart' as my;
import '../providers/todo_provider.dart';
import '../widgets/calendar_widget.dart';
import '../widgets/todo_item.dart';
import '../utils/constants.dart';
import 'add_todo_screen.dart';
import 'edit_todo_screen.dart';
import 'goals_screen.dart';  // 添加这行导入
import '../models/todo.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;  // 添加这行：当前选中的导航项

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(my.selectedDateProvider);
    final filteredTodos = ref.watch(filteredTodosProvider(selectedDate));
    final stats = ref.watch(todoStatsProvider);

    return Scaffold(
      body: _currentIndex == 0  // 根据索引显示不同页面
          ? _buildCalendarView(context, ref, selectedDate, filteredTodos, stats)
          : const GoalsScreen(),  // 目标页面
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () => _showAddTodo(context, selectedDate),
              icon: const Icon(Icons.add),
              label: const Text('新建'),
            )
          : null,  // 目标页面有自己的添加按钮
      bottomNavigationBar: BottomNavigationBar(  // 添加底部导航栏
        currentIndex: _currentIndex,
        selectedItemColor: AppConstants.primaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: '日历',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flag),
            label: '目标',
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;  // 切换页面
          });
        },
      ),
    );
  }

  // 把原来的 body 内容提取到这个函数
  Widget _buildCalendarView(
    BuildContext context,
    WidgetRef ref,
    DateTime selectedDate,
    List<Todo> filteredTodos,
    Map<String, int> stats,
  ) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _buildHeader(context, stats),
        ),
        const SliverToBoxAdapter(
          child: CalendarWidget(),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _getDateTitle(selectedDate),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${filteredTodos.length} 项待办',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
        filteredTodos.isEmpty
            ? SliverFillRemaining(
                hasScrollBody: false,
                child: _buildEmptyState(context),
              )
            : SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final todo = filteredTodos[index];
                    return TodoItem(
                      todo: todo,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditTodoScreen(todo: todo),
                          ),
                        );
                      },
                    );
                  },
                  childCount: filteredTodos.length,
                ),
              ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 80),
        ),
      ],
    );
  }

  // 其他方法保持不变...
  Widget _buildHeader(BuildContext context, Map<String, int> stats) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '种一棵树，最好的时间是十年前，其次是现在',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '日历待办',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${stats['pending']}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.primaryColor,
                        ),
                      ),
                      const Text(
                        '待完成',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatChip(Icons.check_circle, '${stats['completed']}', '已完成', Colors.green),
                const SizedBox(width: 12),
                _buildStatChip(Icons.warning, '${stats['overdue']}', '已逾期', Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            '$value $label',
            style: TextStyle(
              fontSize: 13,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            '今天没有待办事项',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => _showAddTodo(context, DateTime.now()),
            child: const Text('添加一个'),
          ),
        ],
      ),
    );
  }

  String _getDateTitle(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(date.year, date.month, date.day);
    
    if (selected == today) {
      return '今天';
    } else if (selected == today.add(const Duration(days: 1))) {
      return '明天';
    } else if (selected == today.subtract(const Duration(days: 1))) {
      return '昨天';
    } else {
      return DateFormat('MM月dd日').format(date);
    }
  }

  void _showAddTodo(BuildContext context, DateTime? initialDate) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: AddTodoScreen(initialDate: initialDate),
      ),
    );
  }
}