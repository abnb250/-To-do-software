import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/goal.dart';
import '../providers/goal_provider.dart';
import 'add_goal_screen.dart';
import 'goal_detail_screen.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {


    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('目标管理'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '进行中'),
              Tab(text: '已完成'),
              Tab(text: '已归档'),
            ],
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
          ),
        ),
        body: TabBarView(
          children: [
            _buildGoalList(context, ref, GoalStatus.active),
            _buildGoalList(context, ref, GoalStatus.completed),
            _buildGoalList(context, ref, GoalStatus.archived),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddGoalScreen(),
              ),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('新建目标'),
        ),
      ),
    );
  }

  Widget _buildGoalList(BuildContext context, WidgetRef ref, GoalStatus status) {
    final goals = ref.watch(goalsByStatusProvider(status));

    if (goals.isEmpty) {
      return _buildEmptyState(status);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: goals.length,
      itemBuilder: (context, index) {
        final goal = goals[index];
        return _buildGoalCard(context, ref, goal);
      },
    );
  }

  Widget _buildGoalCard(BuildContext context, WidgetRef ref, Goal goal) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GoalDetailScreen(goal: goal),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: goal.type == GoalType.lifelong
                          ? Colors.purple.withValues(alpha: 0.15)
                          : Colors.blue.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      goal.type.label,
                      style: TextStyle(
                        fontSize: 12,
                        color: goal.type == GoalType.lifelong
                            ? Colors.purple
                            : Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (goal.isOverdue && goal.status == GoalStatus.active)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '已逾期',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                goal.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (goal.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  goal.description!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '进度 ${goal.progress}%',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: goal.progress / 100,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              goal.status == GoalStatus.completed
                                  ? Colors.green
                                  : Theme.of(context).primaryColor,
                            ),
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  _buildPopupMenu(context, ref, goal),
                ],
              ),
              if (goal.targetDate != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.event,
                      size: 16,
                      color: goal.isOverdue ? Colors.red : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '截止日期: ${_formatDate(goal.targetDate!)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: goal.isOverdue ? Colors.red : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopupMenu(BuildContext context, WidgetRef ref, Goal goal) {
    return PopupMenuButton<String>(
      itemBuilder: (context) {
        final items = <PopupMenuEntry<String>>[];

        if (goal.status == GoalStatus.active) {
          items.addAll([
            const PopupMenuItem(
              value: 'progress',
              child: Row(
                children: [
                  Icon(Icons.trending_up, size: 20),
                  SizedBox(width: 8),
                  Text('更新进度'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'complete',
              child: Row(
                children: [
                  Icon(Icons.check_circle, size: 20, color: Colors.green),
                  SizedBox(width: 8),
                  Text('标记完成'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'archive',
              child: Row(
                children: [
                  Icon(Icons.archive, size: 20, color: Colors.grey),
                  SizedBox(width: 8),
                  Text('归档'),
                ],
              ),
            ),
          ]);
        } else if (goal.status == GoalStatus.completed) {
          items.addAll([
            const PopupMenuItem(
              value: 'reactivate',
              child: Row(
                children: [
                  Icon(Icons.refresh, size: 20),
                  SizedBox(width: 8),
                  Text('重新激活'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'archive',
              child: Row(
                children: [
                  Icon(Icons.archive, size: 20, color: Colors.grey),
                  SizedBox(width: 8),
                  Text('归档'),
                ],
              ),
            ),
          ]);
        } else {
          items.addAll([
            const PopupMenuItem(
              value: 'reactivate',
              child: Row(
                children: [
                  Icon(Icons.refresh, size: 20),
                  SizedBox(width: 8),
                  Text('重新激活'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('删除', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ]);
        }

        return items;
      },
      onSelected: (value) async {
        switch (value) {
          case 'progress':
            _showProgressDialog(context, ref, goal);
            break;
          case 'complete':
            await ref.read(goalListProvider.notifier).completeGoal(goal.id);
            break;
          case 'archive':
            await ref.read(goalListProvider.notifier).archiveGoal(goal.id);
            break;
          case 'reactivate':
            await ref.read(goalListProvider.notifier).reactivateGoal(goal.id);
            break;
          case 'delete':
            _showDeleteConfirm(context, ref, goal);
            break;
        }
      },
    );
  }

  void _showProgressDialog(BuildContext context, WidgetRef ref, Goal goal) {
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
                Text('${progress.round()}%'),
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
              );if (!context.mounted) return;
              Navigator.pop(context);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, WidgetRef ref, Goal goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('删除后无法恢复，是否继续？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(goalListProvider.notifier).deleteGoal(goal.id);if (!context.mounted) return;
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(GoalStatus status) {
    String message;
    IconData icon;

    switch (status) {
      case GoalStatus.active:
        message = '没有进行中的目标';
        icon = Icons.track_changes;
        break;
      case GoalStatus.completed:
        message = '还没有完成的目标';
        icon = Icons.check_circle_outline;
        break;
      case GoalStatus.archived:
        message = '没有已归档的目标';
        icon = Icons.archive_outlined;
        break;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey.shade300),
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

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }
}