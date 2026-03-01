import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/goal.dart';
import '../providers/goal_provider.dart';
import '../utils/constants.dart';

class AddGoalScreen extends ConsumerStatefulWidget {
  const AddGoalScreen({super.key});

  @override
  ConsumerState<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends ConsumerState<AddGoalScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  GoalType _selectedType = GoalType.monthly;
  DateTime? _targetDate;

  final List<GoalType> _goalTypes = [
    GoalType.daily,
    GoalType.weekly,
    GoalType.monthly,
    GoalType.yearly,
    GoalType.lifelong,
  ];

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
        title: const Text('新建目标'),
        actions: [
          TextButton(
            onPressed: _saveGoal,
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
                hintText: '目标名称',
                prefixIcon: Icon(Icons.flag),
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
                hintText: '目标描述（可选）',
                prefixIcon: Icon(Icons.notes),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('目标类型'),
            const SizedBox(height: 8),
            _buildTypeSelector(),
            const SizedBox(height: 24),
            _buildSectionTitle('截止日期（可选）'),
            const SizedBox(height: 8),
            _buildDateSelector(),
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

  Widget _buildTypeSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _goalTypes.map((type) {
        final isSelected = _selectedType == type;
        final colors = _getTypeColors(type);
        
        return ChoiceChip(
          label: Text(type.label),
          selected: isSelected,
          onSelected: (selected) {
            setState(() => _selectedType = type);
          },
          selectedColor: colors['bg'],
          labelStyle: TextStyle(
            color: isSelected ? colors['text'] : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: isSelected ? colors['text']! : Colors.transparent,
            ),
          ),
        );
      }).toList(),
    );
  }

  Map<String, Color> _getTypeColors(GoalType type) {
    switch (type) {
      case GoalType.daily:
        return {'bg': Colors.orange.withValues(alpha: 0.15), 'text': Colors.orange};
      case GoalType.weekly:
        return {'bg': Colors.blue.withValues(alpha: 0.15), 'text': Colors.blue};
      case GoalType.monthly:
        return {'bg': Colors.green.withValues(alpha: 0.15), 'text': Colors.green};
      case GoalType.yearly:
        return {'bg': Colors.purple.withValues(alpha: 0.15), 'text': Colors.purple};
      case GoalType.lifelong:
        return {'bg': Colors.red.withValues(alpha: 0.15), 'text': Colors.red};
    }
  }

  Widget _buildDateSelector() {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _targetDate ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2100),
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
          setState(() => _targetDate = date);
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
            const Icon(Icons.event, color: AppConstants.primaryColor),
            const SizedBox(width: 12),
            Text(
              _targetDate != null
                  ? DateFormat('yyyy年MM月dd日').format(_targetDate!)
                  : '选择截止日期',
              style: TextStyle(
                fontSize: 16,
                color: _targetDate != null ? Colors.black87 : Colors.grey,
              ),
            ),
            if (_targetDate != null) ...[
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () => setState(() => _targetDate = null),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _saveGoal() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入目标名称')),
      );
      return;
    }

    final goal = Goal(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      type: _selectedType,
      targetDate: _targetDate,
    );

    ref.read(goalListProvider.notifier).addGoal(goal);
    Navigator.pop(context);
  }
}