import 'package:flutter/cupertino.dart';
import '../models/task_item.dart';
import '../services/task_db_service.dart';
import '../theme/savoria_theme.dart';

class CompletedArchiveView extends StatefulWidget {
  const CompletedArchiveView({super.key});

  @override
  State<CompletedArchiveView> createState() => _CompletedArchiveViewState();
}

class _CompletedArchiveViewState extends State<CompletedArchiveView> {
  final TaskDbService _dbService = TaskDbService();
  List<TaskItem> _completedTasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final tasks = await _dbService.getTasks(isCompleted: true);
    setState(() {
      _completedTasks = tasks;
      _isLoading = false;
    });
  }

  void _restoreTask(TaskItem task) async {
    await _dbService.toggleTaskCompletion(task.id!, true);
    _load();
  }

  void _deleteTask(TaskItem task) async {
    await _dbService.deleteTask(task.id!);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: isDark ? SavoriaTheme.darkFrosted : SavoriaTheme.lightFrosted,
        middle: const Text(
          'Accomplishments',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      child: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            // Header stats
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: SavoriaTheme.accentEmerald.withValues(alpha: 0.3), width: 1),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: SavoriaTheme.accentEmerald.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(CupertinoIcons.rosette, color: SavoriaTheme.accentEmerald, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_completedTasks.length} Completed Tasks',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: isDark ? SavoriaTheme.darkTextPrimary : SavoriaTheme.lightTextPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Every completed task represents focused momentum.',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: isDark ? SavoriaTheme.darkTextSecondary : SavoriaTheme.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            if (_isLoading)
              const SliverFillRemaining(child: Center(child: CupertinoActivityIndicator()))
            else if (_completedTasks.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(CupertinoIcons.hourglass_bottomhalf_fill, size: 48, color: SavoriaTheme.accentEmerald),
                      const SizedBox(height: 12),
                      Text(
                        'No completed tasks yet',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark ? SavoriaTheme.darkTextPrimary : SavoriaTheme.lightTextPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final task = _completedTasks[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: SavoriaTheme.frostedCardDecoration(context),
                        child: Row(
                          children: [
                            const Icon(CupertinoIcons.checkmark_seal_fill, color: SavoriaTheme.accentEmerald, size: 22),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task.title,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      decoration: TextDecoration.lineThrough,
                                      color: isDark ? SavoriaTheme.darkTextSecondary : SavoriaTheme.lightTextSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${task.category} • ${task.completedAt ?? task.dueDate}',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: isDark ? SavoriaTheme.darkTextSecondary : SavoriaTheme.lightTextSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            CupertinoButton(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              minimumSize: const Size(0, 28),
                              onPressed: () => _restoreTask(task),
                              child: const Icon(CupertinoIcons.arrow_counterclockwise, size: 18, color: SavoriaTheme.primaryIndigo),
                            ),
                            CupertinoButton(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              minimumSize: const Size(0, 28),
                              onPressed: () => _deleteTask(task),
                              child: const Icon(CupertinoIcons.trash, size: 18, color: SavoriaTheme.accentRose),
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: _completedTasks.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
