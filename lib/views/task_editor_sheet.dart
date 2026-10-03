import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../models/task_item.dart';
import '../services/task_db_service.dart';
import '../theme/savoria_theme.dart';

class TaskEditorSheet extends StatefulWidget {
  final TaskItem? existingTask;
  final VoidCallback onSaved;

  const TaskEditorSheet({
    super.key,
    this.existingTask,
    required this.onSaved,
  });

  @override
  State<TaskEditorSheet> createState() => _TaskEditorSheetState();
}

class _TaskEditorSheetState extends State<TaskEditorSheet> {
  final TaskDbService _dbService = TaskDbService();

  late TextEditingController _titleController;
  late TextEditingController _notesController;
  late String _selectedCategory;
  late String _selectedPriority;
  late DateTime _selectedDueDate;
  late String _dueTimeString;

  final List<String> _categories = [
    'Today',
    'Work & Executive',
    'Personal & Wellness',
    'Focus & Urgent',
  ];

  final List<String> _priorities = [
    'Normal',
    'Medium',
    'High',
    'Urgent',
  ];

  @override
  void initState() {
    super.initState();
    final task = widget.existingTask;
    _titleController = TextEditingController(text: task?.title ?? '');
    _notesController = TextEditingController(text: task?.notes ?? '');
    _selectedCategory = task?.category ?? 'Today';
    _selectedPriority = task?.priority ?? 'Medium';
    _selectedDueDate = task != null ? DateTime.tryParse(task.dueDate) ?? DateTime.now() : DateTime.now();
    _dueTimeString = task?.dueTime ?? DateFormat('hh:mm a').format(DateTime.now().add(const Duration(hours: 1)));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveTask() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final nowStr = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDueDate);

    if (widget.existingTask != null) {
      final updated = widget.existingTask!.copyWith(
        title: title,
        notes: _notesController.text.trim(),
        category: _selectedCategory,
        priority: _selectedPriority,
        dueDate: dateStr,
        dueTime: _dueTimeString,
      );
      await _dbService.updateTask(updated);
    } else {
      final newTask = TaskItem(
        title: title,
        notes: _notesController.text.trim(),
        category: _selectedCategory,
        priority: _selectedPriority,
        dueDate: dateStr,
        dueTime: _dueTimeString,
        isCompleted: false,
        createdAt: nowStr,
      );
      await _dbService.insertTask(newTask);
    }

    widget.onSaved();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _pickTime() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 240,
          color: CupertinoTheme.of(context).scaffoldBackgroundColor,
          child: SafeArea(
            top: false,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.time,
              initialDateTime: DateTime.now(),
              use24hFormat: false,
              onDateTimeChanged: (DateTime newDateTime) {
                setState(() {
                  _dueTimeString = DateFormat('hh:mm a').format(newDateTime);
                });
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.86,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : CupertinoColors.systemBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Top Navigation Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  Text(
                    widget.existingTask != null ? 'Edit Task' : 'New Task',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: _saveTask,
                    child: const Text(
                      'Save',
                      style: TextStyle(fontWeight: FontWeight.w700, color: SavoriaTheme.primaryIndigo),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  const SizedBox(height: 10),
                  _buildSectionHeader('TASK TITLE', isDark),
                  CupertinoTextField(
                    controller: _titleController,
                    placeholder: 'What needs to be accomplished?',
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? SavoriaTheme.darkTextPrimary : SavoriaTheme.lightTextPrimary,
                    ),
                  ),

                  const SizedBox(height: 18),
                  _buildSectionHeader('NOTES & SUBTASKS (OPTIONAL)', isDark),
                  CupertinoTextField(
                    controller: _notesController,
                    placeholder: 'Add details, bullet points, or checklist steps...',
                    maxLines: 3,
                    padding: const EdgeInsets.all(14),
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? SavoriaTheme.darkTextPrimary : SavoriaTheme.lightTextPrimary,
                    ),
                  ),

                  const SizedBox(height: 18),
                  _buildSectionHeader('CATEGORY', isDark),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _categories.map((cat) {
                      final isSelected = cat == _selectedCategory;
                      return CupertinoButton(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        color: isSelected
                            ? SavoriaTheme.primaryIndigo
                            : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(16),
                        minimumSize: const Size(0, 34),
                        onPressed: () => setState(() => _selectedCategory = cat),
                        child: Text(
                          cat,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected
                                ? CupertinoColors.white
                                : (isDark ? SavoriaTheme.darkTextPrimary : SavoriaTheme.lightTextPrimary),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 18),
                  _buildSectionHeader('PRIORITY LEVEL', isDark),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _priorities.map((prio) {
                      final isSelected = prio == _selectedPriority;
                      final col = SavoriaTheme.priorityColor(prio);
                      return CupertinoButton(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        color: isSelected
                            ? col
                            : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(16),
                        minimumSize: const Size(0, 34),
                        onPressed: () => setState(() => _selectedPriority = prio),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              CupertinoIcons.circle_fill,
                              size: 8,
                              color: isSelected ? CupertinoColors.white : col,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              prio,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected
                                    ? CupertinoColors.white
                                    : (isDark ? SavoriaTheme.darkTextPrimary : SavoriaTheme.lightTextPrimary),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 18),
                  _buildSectionHeader('DUE SCHEDULE', isDark),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(CupertinoIcons.clock, size: 18, color: SavoriaTheme.primaryIndigo),
                            const SizedBox(width: 10),
                            Text(
                              'Target Time: $_dueTimeString',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                                color: isDark ? SavoriaTheme.darkTextPrimary : SavoriaTheme.lightTextPrimary,
                              ),
                            ),
                          ],
                        ),
                        CupertinoButton(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          color: SavoriaTheme.primaryIndigo.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          minimumSize: const Size(0, 28),
                          onPressed: _pickTime,
                          child: const Text(
                            'Change',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: SavoriaTheme.primaryIndigo),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String label, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: isDark ? SavoriaTheme.darkTextSecondary : SavoriaTheme.lightTextSecondary,
        ),
      ),
    );
  }
}
