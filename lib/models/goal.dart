import 'package:uuid/uuid.dart';
import 'dart:ui';
import 'package:flutter/material.dart';

enum GoalStatus {
  active,      // 进行中
  completed,   // 已完成
  archived,    // 已归档
}

enum GoalType {
  daily,       // 日常目标
  weekly,      // 周目标
  monthly,     // 月目标
  yearly,      // 年目标
  lifelong,    // 人生目标
}

extension GoalTypeExtension on GoalType {
  String get label {
    switch (this) {
      case GoalType.daily:
        return '日常';
      case GoalType.weekly:
        return '周目标';
      case GoalType.monthly:
        return '月目标';
      case GoalType.yearly:
        return '年目标';
      case GoalType.lifelong:
        return '人生目标';
    }
  }
}

extension GoalStatusExtension on GoalStatus {
  String get label {
    switch (this) {
      case GoalStatus.active:
        return '进行中';
      case GoalStatus.completed:
        return '已完成';
      case GoalStatus.archived:
        return '已归档';
    }
  }

  Color get color {
    switch (this) {
      case GoalStatus.active:
        return const Color(0xFF4CAF50);
      case GoalStatus.completed:
        return const Color(0xFF2196F3);
      case GoalStatus.archived:
        return const Color(0xFF9E9E9E);
    }
  }
}

class Goal {
  final String id;
  final String title;
  final String? description;
  final GoalType type;
  final GoalStatus status;
  final DateTime createdAt;
  final DateTime? targetDate;
  final DateTime? completedAt;
  final List<String> relatedTodoIds; // 关联的待办事项ID
  final int progress; // 0-100

  Goal({
    String? id,
    required this.title,
    this.description,
    this.type = GoalType.monthly,
    this.status = GoalStatus.active,
    DateTime? createdAt,
    this.targetDate,
    this.completedAt,
    this.relatedTodoIds = const [],
    this.progress = 0,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Goal copyWith({
    String? title,
    String? description,
    GoalType? type,
    GoalStatus? status,
    DateTime? targetDate,
    DateTime? completedAt,
    List<String>? relatedTodoIds,
    int? progress,
  }) {
    return Goal(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      createdAt: createdAt,
      targetDate: targetDate ?? this.targetDate,
      completedAt: completedAt ?? this.completedAt,
      relatedTodoIds: relatedTodoIds ?? this.relatedTodoIds,
      progress: progress ?? this.progress,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'targetDate': targetDate?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'relatedTodoIds': relatedTodoIds,
      'progress': progress,
    };
  }

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: GoalType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => GoalType.monthly,
      ),
      status: GoalStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => GoalStatus.active,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      targetDate: json['targetDate'] != null ? DateTime.parse(json['targetDate']) : null,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      relatedTodoIds: List<String>.from(json['relatedTodoIds'] ?? []),
      progress: json['progress'] ?? 0,
    );
  }

  bool get isOverdue {
    if (targetDate == null || status != GoalStatus.active) return false;
    return DateTime.now().isAfter(targetDate!);
  }
}