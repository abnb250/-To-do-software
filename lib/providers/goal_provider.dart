import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/goal.dart';
import '../services/storage_service.dart';
import 'todo_provider.dart'; 

final goalListProvider = StateNotifierProvider<GoalListNotifier, List<Goal>>((ref) {
  return GoalListNotifier(ref.watch(storageServiceProvider));
});

// 按状态筛选的目标
final goalsByStatusProvider = Provider.family<List<Goal>, GoalStatus>((ref, status) {
  final goals = ref.watch(goalListProvider);
  return goals.where((g) => g.status == status).toList();
});

// 按类型筛选的目标
final goalsByTypeProvider = Provider.family<List<Goal>, GoalType>((ref, type) {
  final goals = ref.watch(goalListProvider);
  return goals.where((g) => g.type == type && g.status == GoalStatus.active).toList();
});

// 目标统计
final goalStatsProvider = Provider<Map<String, int>>((ref) {
  final goals = ref.watch(goalListProvider);
  return {
    'total': goals.length,
    'active': goals.where((g) => g.status == GoalStatus.active).length,
    'completed': goals.where((g) => g.status == GoalStatus.completed).length,
    'archived': goals.where((g) => g.status == GoalStatus.archived).length,
  };
});

class GoalListNotifier extends StateNotifier<List<Goal>> {
  final StorageService _storage;

  GoalListNotifier(this._storage) : super([]) {
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    final goals = await _storage.loadGoals();
    state = goals;
  }

  Future<void> addGoal(Goal goal) async {
    await _storage.addGoal(goal);
    state = [...state, goal];
  }

  Future<void> updateGoal(Goal goal) async {
    await _storage.updateGoal(goal);
    state = [
      for (final g in state)
        if (g.id == goal.id) goal else g
    ];
  }

  Future<void> deleteGoal(String id) async {
    await _storage.deleteGoal(id);
    state = state.where((g) => g.id != id).toList();
  }

  Future<void> updateProgress(String id, int progress) async {
    final goal = state.firstWhere((g) => g.id == id);
    final updated = goal.copyWith(progress: progress.clamp(0, 100));
    await updateGoal(updated);
  }

  Future<void> completeGoal(String id) async {
    final goal = state.firstWhere((g) => g.id == id);
    final updated = goal.copyWith(
      status: GoalStatus.completed,
      completedAt: DateTime.now(),
      progress: 100,
    );
    await updateGoal(updated);
  }

  Future<void> archiveGoal(String id) async {
    final goal = state.firstWhere((g) => g.id == id);
    final updated = goal.copyWith(status: GoalStatus.archived);
    await updateGoal(updated);
  }

  Future<void> reactivateGoal(String id) async {
    final goal = state.firstWhere((g) => g.id == id);
    final updated = goal.copyWith(
      status: GoalStatus.active,
      completedAt: null,
    );
    await updateGoal(updated);
  }

  Future<void> addRelatedTodo(String goalId, String todoId) async {
    final goal = state.firstWhere((g) => g.id == goalId);
    if (!goal.relatedTodoIds.contains(todoId)) {
      final updated = goal.copyWith(
        relatedTodoIds: [...goal.relatedTodoIds, todoId],
      );
      await updateGoal(updated);
    }
  }

  Future<void> removeRelatedTodo(String goalId, String todoId) async {
    final goal = state.firstWhere((g) => g.id == goalId);
    final updated = goal.copyWith(
      relatedTodoIds: goal.relatedTodoIds.where((id) => id != todoId).toList(),
    );
    await updateGoal(updated);
  }

  Future<void> refresh() async {
    await _loadGoals();
  }
}