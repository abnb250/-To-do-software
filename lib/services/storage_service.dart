import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo.dart';
import '../models/goal.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // ========== 待办事项 ==========
  Future<void> saveTodos(List<Todo> todos) async {
    await init();
    final jsonList = todos.map((todo) => todo.toJson()).toList();
    await _prefs!.setString('todos', jsonEncode(jsonList));
  }

  Future<List<Todo>> loadTodos() async {
    await init();
    final jsonString = _prefs!.getString('todos');
    if (jsonString == null) return [];
    
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((json) => Todo.fromJson(json)).toList();
  }

  Future<void> addTodo(Todo todo) async {
    final todos = await loadTodos();
    todos.add(todo);
    await saveTodos(todos);
  }

  Future<void> updateTodo(Todo updatedTodo) async {
    final todos = await loadTodos();
    final index = todos.indexWhere((t) => t.id == updatedTodo.id);
    if (index != -1) {
      todos[index] = updatedTodo;
      await saveTodos(todos);
    }
  }

  Future<void> deleteTodo(String id) async {
    final todos = await loadTodos();
    todos.removeWhere((t) => t.id == id);
    await saveTodos(todos);
  }

  // ========== 目标 ==========
  Future<void> saveGoals(List<Goal> goals) async {
    await init();
    final jsonList = goals.map((goal) => goal.toJson()).toList();
    await _prefs!.setString('goals', jsonEncode(jsonList));
  }

  Future<List<Goal>> loadGoals() async {
    await init();
    final jsonString = _prefs!.getString('goals');
    if (jsonString == null) return [];
    
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((json) => Goal.fromJson(json)).toList();
  }

  Future<void> addGoal(Goal goal) async {
    final goals = await loadGoals();
    goals.add(goal);
    await saveGoals(goals);
  }

  Future<void> updateGoal(Goal updatedGoal) async {
    final goals = await loadGoals();
    final index = goals.indexWhere((g) => g.id == updatedGoal.id);
    if (index != -1) {
      goals[index] = updatedGoal;
      await saveGoals(goals);
    }
  }

  Future<void> deleteGoal(String id) async {
    final goals = await loadGoals();
    goals.removeWhere((g) => g.id == id);
    await saveGoals(goals);
  }

  // ========== 清除所有数据 ==========
  Future<void> clearAll() async {
    await init();
    await _prefs!.clear();
  }
}