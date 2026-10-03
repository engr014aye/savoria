import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../models/task_item.dart';
import '../services/task_db_service.dart';
import '../theme/savoria_theme.dart';
import 'task_editor_sheet.dart';

class TodayTasksView extends StatefulWidget {
  const TodayTasksView({super.key});

  @override
  State<TodayTasksView> createState() => _TodayTasksViewState();
}

class _TodayTasksViewState extends State<TodayTasksView> {
  final TaskDbService _dbService = TaskDbService();
  List<TaskItem> _tasks = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isLoading = true;

  final List<String> _categories = [
    'All',
    'Today',
    'Work & Executive',
    'Personal & Wellness',
    'Focus & Urgent',
  ];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    final tasks = await _dbService.getTasks(
      category: _selectedCategory == 'All' ? null : _selectedCategory,
    );
    setState(() {
      _tasks = tasks;
      _isLoading = false;
    });
  }

  void _openTaskEditor([TaskItem? existing]) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => TaskEditorSheet(
        existingTask: existing,
        onSaved: _loadTasks,
      ),
    );
  }

  void _toggleTask(TaskItem task) async {
    HapticFeedback.lightImpact();
    await _dbService.toggleTaskCompletion(task.id!, task.isCompleted);
    _loadTasks();
  }

  void _deleteTask(TaskItem task) async {
    HapticFeedback.mediumImpact();
    await _dbService.deleteTask(task.id!);
    _loadTasks();
  }

  List<TaskItem> get _filteredTasks {
    if (_searchQuery.isEmpty) return _tasks;
    final q = _searchQuery.toLowerCase();
    return _tasks.where((t) =>
      t.title.toLowerCase().contains(q) ||
      t.notes.toLowerCase().contains(q) ||
      t.category.toLowerCase().contains(q)
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    final filtered = _filteredTasks;
    final completedCount = _tasks.where((t) => t.isCompleted).length;
    final totalCount = _tasks.length;
    final progressPercent = totalCount == 0 ? 0.0 : (completedCount / totalCount);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: isDark ? SavoriaTheme.darkFrosted : SavoriaTheme.lightFrosted,
        middle: const Text(
          'S A V O R I A',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.5,
            color: SavoriaTheme.primaryIndigo,
          ),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => _openTaskEditor(),
          child: const Icon(CupertinoIcons.add_circled_solid, color: SavoriaTheme.primaryIndigo, size: 28),
        ),
      ),
      child: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            // Header: Date & Productivity Metrics Banner
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DAILY PRODUCTIVITY',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: isDark ? SavoriaTheme.darkTextSecondary : SavoriaTheme.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Today\'s Agenda',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.0,
                        color: isDark ? SavoriaTheme.darkTextPrimary : SavoriaTheme.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Executive Progress Card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: SavoriaTheme.frostedCardDecoration(context),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Daily Focus Completion',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? SavoriaTheme.darkTextPrimary : SavoriaTheme.lightTextPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '$completedCount of $totalCount tasks finalized',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: isDark ? SavoriaTheme.darkTextSecondary : SavoriaTheme.lightTextSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: SavoriaTheme.primaryIndigo.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${(progressPercent * 100).toInt()}%',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: SavoriaTheme.primaryIndigo,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Custom iOS Progress Bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: SizedBox(
                              height: 8,
                              child: Stack(
                                children: [
                                  Container(
                                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                                  ),
                                  FractionallySizedBox(
                                    widthFactor: progressPercent.clamp(0.0, 1.0),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [SavoriaTheme.primaryIndigo, SavoriaTheme.accentEmerald],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: CupertinoSearchTextField(
                  placeholder: 'Search tasks, subtasks, or categories...',
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),
            ),

            // Category Filter Pills
            SliverToBoxAdapter(
              child: Container(
                height: 40,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected = cat == _selectedCategory;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: CupertinoButton(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        color: isSelected
                            ? SavoriaTheme.primaryIndigo
                            : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(18),
                        minimumSize: const Size(0, 32),
                        onPressed: () {
                          setState(() => _selectedCategory = cat);
                          _loadTasks();
                        },
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
                      ),
                    );
                  },
                ),
              ),
            ),

            // Tasks List
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(child: CupertinoActivityIndicator(radius: 14)),
              )
            else if (filtered.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(CupertinoIcons.checkmark_seal_fill, size: 52, color: SavoriaTheme.primaryIndigo),
                      const SizedBox(height: 12),
                      Text(
                        'All caught up!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isDark ? SavoriaTheme.darkTextPrimary : SavoriaTheme.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Tap the + icon above to schedule a new task.',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? SavoriaTheme.darkTextSecondary : SavoriaTheme.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final task = filtered[index];
                      return _buildTaskCard(task, isDark);
                    },
                    childCount: filtered.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(TaskItem task, bool isDark) {
    final prioColor = SavoriaTheme.priorityColor(task.priority);

    // Dismissible with iOS spring animations
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: Key('task_${task.id}'),
        direction: DismissDirection.horizontal,
        background: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: SavoriaTheme.accentEmerald,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Row(
            children: [
              Icon(CupertinoIcons.checkmark_circle_fill, color: CupertinoColors.white, size: 24),
              SizedBox(width: 8),
              Text(
                'Complete',
                style: TextStyle(color: CupertinoColors.white, fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ],
          ),
        ),
        secondaryBackground: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: SavoriaTheme.accentRose,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Delete',
                style: TextStyle(color: CupertinoColors.white, fontWeight: FontWeight.w700, fontSize: 14),
              ),
              SizedBox(width: 8),
              Icon(CupertinoIcons.trash_fill, color: CupertinoColors.white, size: 24),
            ],
          ),
        ),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            // Swipe right: toggle complete
            _toggleTask(task);
            return false;
          } else {
            // Swipe left: delete
            _deleteTask(task);
            return true;
          }
        },
        child: Container(
          decoration: SavoriaTheme.frostedCardDecoration(context),
          clipBehavior: Clip.antiAlias,
          child: CupertinoButton(
            padding: const EdgeInsets.all(16),
            onPressed: () => _openTaskEditor(task),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Spring animated Checkbox
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(28, 28),
                  onPressed: () => _toggleTask(task),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutBack,
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: task.isCompleted ? SavoriaTheme.accentEmerald : CupertinoColors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: task.isCompleted ? SavoriaTheme.accentEmerald : prioColor,
                        width: 2,
                      ),
                    ),
                    child: task.isCompleted
                        ? const Icon(CupertinoIcons.checkmark, size: 16, color: CupertinoColors.white)
                        : null,
                  ),
                ),
                const SizedBox(width: 14),

                // Task Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                          color: task.isCompleted
                              ? (isDark ? SavoriaTheme.darkTextSecondary : SavoriaTheme.lightTextSecondary)
                              : (isDark ? SavoriaTheme.darkTextPrimary : SavoriaTheme.lightTextPrimary),
                        ),
                      ),
                      if (task.notes.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          task.notes,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? SavoriaTheme.darkTextSecondary : SavoriaTheme.lightTextSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          // Category tag
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              task.category,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isDark ? SavoriaTheme.darkTextSecondary : SavoriaTheme.lightTextSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Time tag
                          Row(
                            children: [
                              Icon(CupertinoIcons.clock, size: 12, color: prioColor),
                              const SizedBox(width: 4),
                              Text(
                                task.dueTime,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: prioColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Icon(CupertinoIcons.chevron_forward, size: 16, color: CupertinoColors.systemGrey3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
