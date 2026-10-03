import 'package:flutter/cupertino.dart';
import '../models/task_item.dart';
import '../services/task_db_service.dart';
import '../theme/savoria_theme.dart';
import 'task_editor_sheet.dart';

class CategoriesView extends StatefulWidget {
  const CategoriesView({super.key});

  @override
  State<CategoriesView> createState() => _CategoriesViewState();
}

class _CategoriesViewState extends State<CategoriesView> {
  final TaskDbService _dbService = TaskDbService();
  List<TaskItem> _allTasks = [];
  bool _isLoading = true;

  final List<Map<String, dynamic>> _categoryMeta = [
    {
      'title': 'Today',
      'icon': CupertinoIcons.sun_max_fill,
      'color': SavoriaTheme.accentAmber,
      'desc': 'Daily priorities and immediate action items',
    },
    {
      'title': 'Work & Executive',
      'icon': CupertinoIcons.briefcase_fill,
      'color': SavoriaTheme.primaryIndigo,
      'desc': 'Strategic roadmaps, meetings, and business deliverables',
    },
    {
      'title': 'Personal & Wellness',
      'icon': CupertinoIcons.heart_fill,
      'color': SavoriaTheme.accentEmerald,
      'desc': 'Health, nutrition, mindfulness, and personal habits',
    },
    {
      'title': 'Focus & Urgent',
      'icon': CupertinoIcons.flame_fill,
      'color': SavoriaTheme.accentRose,
      'desc': 'High-impact deliverables requiring immediate attention',
    },
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final tasks = await _dbService.getTasks();
    setState(() {
      _allTasks = tasks;
      _isLoading = false;
    });
  }

  void _openCategoryDetail(String categoryName, Color categoryColor, IconData icon) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => _CategoryDetailScreen(
          categoryName: categoryName,
          categoryColor: categoryColor,
          icon: icon,
          onRefreshParent: _load,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: isDark ? SavoriaTheme.darkFrosted : SavoriaTheme.lightFrosted,
        middle: const Text(
          'Task Categories',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      child: SafeArea(
        child: _isLoading
            ? const Center(child: CupertinoActivityIndicator())
            : ListView.builder(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                padding: const EdgeInsets.all(20),
                itemCount: _categoryMeta.length,
                itemBuilder: (context, index) {
                  final cat = _categoryMeta[index];
                  final name = cat['title'] as String;
                  final color = cat['color'] as Color;
                  final icon = cat['icon'] as IconData;
                  final desc = cat['desc'] as String;

                  final catTasks = _allTasks.where((t) => t.category == name).toList();
                  final pendingCount = catTasks.where((t) => !t.isCompleted).length;
                  final completedCount = catTasks.where((t) => t.isCompleted).length;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: SavoriaTheme.frostedCardDecoration(context),
                    clipBehavior: Clip.antiAlias,
                    child: CupertinoButton(
                      padding: const EdgeInsets.all(20),
                      onPressed: () => _openCategoryDetail(name, color, icon),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(icon, color: color, size: 24),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: isDark ? SavoriaTheme.darkTextPrimary : SavoriaTheme.lightTextPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '$pendingCount pending • $completedCount completed',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                        color: color,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(CupertinoIcons.chevron_forward, color: CupertinoColors.systemGrey3, size: 20),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            desc,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? SavoriaTheme.darkTextSecondary : SavoriaTheme.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _CategoryDetailScreen extends StatefulWidget {
  final String categoryName;
  final Color categoryColor;
  final IconData icon;
  final VoidCallback onRefreshParent;

  const _CategoryDetailScreen({
    required this.categoryName,
    required this.categoryColor,
    required this.icon,
    required this.onRefreshParent,
  });

  @override
  State<_CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<_CategoryDetailScreen> {
  final TaskDbService _dbService = TaskDbService();
  List<TaskItem> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategoryTasks();
  }

  Future<void> _loadCategoryTasks() async {
    setState(() => _isLoading = true);
    final list = await _dbService.getTasks(category: widget.categoryName);
    setState(() {
      _tasks = list;
      _isLoading = false;
    });
    widget.onRefreshParent();
  }

  void _openEditor([TaskItem? existing]) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => TaskEditorSheet(
        existingTask: existing,
        onSaved: _loadCategoryTasks,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: isDark ? SavoriaTheme.darkFrosted : SavoriaTheme.lightFrosted,
        middle: Text(
          widget.categoryName,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => _openEditor(),
          child: const Icon(CupertinoIcons.add_circled, color: SavoriaTheme.primaryIndigo, size: 26),
        ),
      ),
      child: SafeArea(
        child: _isLoading
            ? const Center(child: CupertinoActivityIndicator())
            : _tasks.isEmpty
                ? Center(
                    child: Text(
                      'No tasks in ${widget.categoryName}',
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? SavoriaTheme.darkTextSecondary : SavoriaTheme.lightTextSecondary,
                      ),
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                    padding: const EdgeInsets.all(20),
                    itemCount: _tasks.length,
                    itemBuilder: (context, index) {
                      final task = _tasks[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: SavoriaTheme.frostedCardDecoration(context),
                        child: Row(
                          children: [
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(28, 28),
                              onPressed: () async {
                                await _dbService.toggleTaskCompletion(task.id!, task.isCompleted);
                                _loadCategoryTasks();
                              },
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: task.isCompleted ? SavoriaTheme.accentEmerald : CupertinoColors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: task.isCompleted ? SavoriaTheme.accentEmerald : widget.categoryColor,
                                    width: 2,
                                  ),
                                ),
                                child: task.isCompleted
                                    ? const Icon(CupertinoIcons.checkmark, size: 16, color: CupertinoColors.white)
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task.title,
                                    style: TextStyle(
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w700,
                                      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                                      color: task.isCompleted
                                          ? (isDark ? SavoriaTheme.darkTextSecondary : SavoriaTheme.lightTextSecondary)
                                          : (isDark ? SavoriaTheme.darkTextPrimary : SavoriaTheme.lightTextPrimary),
                                    ),
                                  ),
                                  if (task.notes.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      task.notes,
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        color: isDark ? SavoriaTheme.darkTextSecondary : SavoriaTheme.lightTextSecondary,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
