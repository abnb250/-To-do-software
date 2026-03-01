import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo.dart';
import '../utils/constants.dart';
import '../services/storage_service.dart';

// 存储服务Provider
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

// 待办事项列表Provider
final todoListProvider = StateNotifierProvider<TodoListNotifier, List<Todo>>((ref) {
  return TodoListNotifier(ref.watch(storageServiceProvider));
});

// 筛选后的待办Provider（按日期）
final filteredTodosProvider = Provider.family<List<Todo>, DateTime>((ref, date) {
  final todos = ref.watch(todoListProvider);
  final filtered = todos.where((todo) {
    if (todo.dueDate == null) return false;
    return todo.dueDate!.year == date.year &&
        todo.dueDate!.month == date.month &&
        todo.dueDate!.day == date.day;
  }).toList();
  
  // 按四象限+时间排序
  filtered.sort((a, b) {
    final priorityCompare = a.priority.sortOrder.compareTo(b.priority.sortOrder);
    if (priorityCompare != 0) return priorityCompare;
    
    if (a.dueTime != null && b.dueTime != null) {
      return a.dueTime!.compareTo(b.dueTime!);
    } else if (a.dueTime != null) {
      return -1;
    } else if (b.dueTime != null) {
      return 1;
    }
    
    return 0;
  });
  
  return filtered;
});

// 今日待办Provider
final todayTodosProvider = Provider<List<Todo>>((ref) {
  final todos = ref.watch(todoListProvider);
  final now = DateTime.now();
  
  final todayTodos = todos.where((todo) {
    if (todo.dueDate == null) return false;
    return todo.dueDate!.year == now.year &&
        todo.dueDate!.month == now.month &&
        todo.dueDate!.day == now.day;
  }).toList();
  
  // 按四象限+时间排序
  todayTodos.sort((a, b) {
    final priorityCompare = a.priority.sortOrder.compareTo(b.priority.sortOrder);
    if (priorityCompare != 0) return priorityCompare;
    
    if (a.dueTime != null && b.dueTime != null) {
      return a.dueTime!.compareTo(b.dueTime!);
    } else if (a.dueTime != null) {
      return -1;
    } else if (b.dueTime != null) {
      return 1;
    }
    
    return 0;
  });
  
  return todayTodos;
});

// 待办统计Provider
final todoStatsProvider = Provider<Map<String, int>>((ref) {
  final todos = ref.watch(todoListProvider);
  return {
    'total': todos.length,
    'completed': todos.where((t) => t.isCompleted).length,
    'pending': todos.where((t) => !t.isCompleted).length,
    'overdue': todos.where((t) => t.isOverdue).length,
  };
});

class TodoListNotifier extends StateNotifier<List<Todo>> {
  final StorageService _storage;

  TodoListNotifier(this._storage) : super([]) {
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    final todos = await _storage.loadTodos();
    state = todos;
  }

  Future<void> addTodo(Todo todo) async {
    await _storage.addTodo(todo);
    state = [...state, todo];
  }

  Future<void> updateTodo(Todo todo) async {
    await _storage.updateTodo(todo);
    state = [
      for (final t in state)
        if (t.id == todo.id) todo else t
    ];
  }

  Future<void> deleteTodo(String id) async {
    await _storage.deleteTodo(id);
    state = state.where((t) => t.id != id).toList();
  }

  Future<void> toggleTodo(String id) async {
    final todo = state.firstWhere((t) => t.id == id);
    final updated = todo.copyWith(isCompleted: !todo.isCompleted);
    await updateTodo(updated);
  }

  Future<void> refresh() async {
    await _loadTodos();
  }
}