import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/todo.dart';
import '../providers/todo_provider.dart';
import '../utils/constants.dart';

class AddTodoScreen extends ConsumerStatefulWidget {
  final DateTime? initialDate;
  
  const AddTodoScreen({super.key, this.initialDate});

  @override
  ConsumerState<AddTodoScreen> createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends ConsumerState<AddTodoScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  Priority _selectedPriority = Priority.notImportantNotUrgent;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('新建待办'),
        actions: [
          TextButton(
            onPressed: _saveTodo,
            child: const Text(
              '保存',
              style: TextStyle(
                color: AppConstants.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: '待办事项标题',
                prefixIcon: Icon(Icons.title),
              ),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                hintText: '添加备注（可选）',
                prefixIcon: Icon(Icons.notes),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('截止日期'),
            const SizedBox(height: 8),
            _buildDateSelector(),
            const SizedBox(height: 24),
            if (_selectedDate != null) ...[
              _buildSectionTitle('截止时间'),
              const SizedBox(height: 8),
              _buildTimeSelector(),
              const SizedBox(height: 24),
            ],
            _buildSectionTitle('优先级'),
            const SizedBox(height: 8),
            _buildPrioritySelector(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildDateSelector() {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2030),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: AppConstants.primaryColor,
                ),
              ),
              child: child!,
            );
          },
        );
        if (date != null) {
          setState(() => _selectedDate = date);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: AppConstants.primaryColor),
            const SizedBox(width: 12),
            Text(
              _selectedDate != null
                  ? DateFormat('yyyy年MM月dd日').format(_selectedDate!)
                  : '选择日期',
              style: TextStyle(
                fontSize: 16,
                color: _selectedDate != null ? Colors.black87 : Colors.grey,
              ),
            ),
            if (_selectedDate != null) ...[
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () => setState(() => _selectedDate = null),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector() {
    return InkWell(
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: _selectedTime ?? TimeOfDay.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: AppConstants.primaryColor,
                ),
              ),
              child: child!,
            );
          },
        );
        if (time != null) {
          setState(() => _selectedTime = time);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time, color: AppConstants.primaryColor),
            const SizedBox(width: 12),
            Text(
              _selectedTime != null
                  ? _selectedTime!.format(context)
                  : '选择时间（可选）',
              style: TextStyle(
                fontSize: 16,
                color: _selectedTime != null ? Colors.black87 : Colors.grey,
              ),
            ),
            if (_selectedTime != null) ...[
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () => setState(() => _selectedTime = null),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPrioritySelector() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildPriorityItem(
                Priority.importantUrgent,
                '重要紧急',
                '立即做',
                Icons.priority_high,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildPriorityItem(
                Priority.importantNotUrgent,
                '重要不紧急',
                '计划做',
                Icons.event_note,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildPriorityItem(
                Priority.notImportantUrgent,
                '不重要紧急',
                '委托做',
                Icons.alarm,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildPriorityItem(
                Priority.notImportantNotUrgent,
                '不重要不紧急',
                '少做',
                Icons.coffee,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriorityItem(
    Priority priority,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final isSelected = _selectedPriority == priority;
    
    return InkWell(
      onTap: () => setState(() => _selectedPriority = priority),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? priority.color.withValues(alpha: 0.15) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: priority.color, width: 2)
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: priority.color,
              size: 28,
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? priority.color : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? priority.color.withValues(alpha: 0.8) : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveTodo() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入待办事项标题')),
      );
      return;
    }

    DateTime? dueTime;
    if (_selectedDate != null && _selectedTime != null) {
      dueTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
    }

    final todo = Todo(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      dueDate: _selectedDate,
      dueTime: dueTime,
      priority: _selectedPriority,
    );

    ref.read(todoListProvider.notifier).addTodo(todo);
    Navigator.pop(context);
  }
}