import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = '日历待办';
  
  // 颜色
  static const Color primaryColor = Color(0xFF6C63FF);
  static const Color secondaryColor = Color(0xFF00BFA6);
  static const Color accentColor = Color(0xFFFF6584);
  static const Color warningColor = Color(0xFFFFB800);
  
  // 存储键
  static const String todosKey = 'todos';
  static const String eventsKey = 'events';
  
  // 动画时长
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
}

// 四象限优先级：重要紧急、重要不紧急、不重要紧急、不重要不紧急
enum Priority {
  importantUrgent,      // 重要紧急 - 红色
  importantNotUrgent,   // 重要不紧急 - 绿色
  notImportantUrgent,   // 不重要紧急 - 黄色
  notImportantNotUrgent // 不重要不紧急 - 黑色/灰色
}

extension PriorityExtension on Priority {
  // 显示颜色
  Color get color {
    switch (this) {
      case Priority.importantUrgent:
        return const Color(0xFFE53935); // 红色
      case Priority.importantNotUrgent:
        return const Color(0xFF43A047); // 绿色
      case Priority.notImportantUrgent:
        return const Color(0xFFFFB300); // 黄色
      case Priority.notImportantNotUrgent:
        return const Color(0xFF757575); // 灰色
    }
  }

  // 显示名称
  String get label {
    switch (this) {
      case Priority.importantUrgent:
        return '重要紧急';
      case Priority.importantNotUrgent:
        return '重要不紧急';
      case Priority.notImportantUrgent:
        return '不重要紧急';
      case Priority.notImportantNotUrgent:
        return '不重要不紧急';
    }
  }

  // 排序权重（数值越小越靠前）
  int get sortOrder {
    switch (this) {
      case Priority.importantUrgent:
        return 1;
      case Priority.importantNotUrgent:
        return 2;
      case Priority.notImportantUrgent:
        return 3;
      case Priority.notImportantNotUrgent:
        return 4;
    }
  }
}