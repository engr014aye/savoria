import 'package:flutter/cupertino.dart';
import 'services/task_db_service.dart';
import 'theme/savoria_theme.dart';
import 'views/categories_view.dart';
import 'views/completed_archive_view.dart';
import 'views/settings_view.dart';
import 'views/today_tasks_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Silently initialize SQLite offline storage in the background
  final dbService = TaskDbService();
  await dbService.database;

  runApp(const SavoriaApp());
}

class SavoriaApp extends StatefulWidget {
  const SavoriaApp({super.key});

  @override
  State<SavoriaApp> createState() => _SavoriaAppState();
}

class _SavoriaAppState extends State<SavoriaApp> {
  // Requirement: Default settings screen theme is Light Mode, switchable to Dark Mode
  Brightness _brightness = Brightness.light;

  void _updateTheme(Brightness brightness) {
    setState(() {
      _brightness = brightness;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Savoria',
      debugShowCheckedModeBanner: false,
      theme: SavoriaTheme.getTheme(_brightness),
      home: SavoriaHome(
        currentBrightness: _brightness,
        onThemeChanged: _updateTheme,
      ),
    );
  }
}

class SavoriaHome extends StatefulWidget {
  final Brightness currentBrightness;
  final ValueChanged<Brightness> onThemeChanged;

  const SavoriaHome({
    super.key,
    required this.currentBrightness,
    required this.onThemeChanged,
  });

  @override
  State<SavoriaHome> createState() => _SavoriaHomeState();
}

class _SavoriaHomeState extends State<SavoriaHome> {
  @override
  Widget build(BuildContext context) {
    final isDark = widget.currentBrightness == Brightness.dark;

    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        backgroundColor: isDark ? SavoriaTheme.darkFrosted : SavoriaTheme.lightFrosted,
        activeColor: SavoriaTheme.primaryIndigo,
        inactiveColor: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0x28FFFFFF) : const Color(0x18000000),
            width: 0.5,
          ),
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.checkmark_circle),
            activeIcon: Icon(CupertinoIcons.checkmark_circle_fill),
            label: 'Today',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.square_grid_2x2),
            activeIcon: Icon(CupertinoIcons.square_grid_2x2_fill),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.rosette),
            activeIcon: Icon(CupertinoIcons.rosette),
            label: 'Accomplished',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.gear_alt),
            activeIcon: Icon(CupertinoIcons.gear_alt_fill),
            label: 'Settings',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return CupertinoTabView(
              builder: (context) => const TodayTasksView(),
            );
          case 1:
            return CupertinoTabView(
              builder: (context) => const CategoriesView(),
            );
          case 2:
            return CupertinoTabView(
              builder: (context) => const CompletedArchiveView(),
            );
          case 3:
            return CupertinoTabView(
              builder: (context) => SettingsView(
                currentBrightness: widget.currentBrightness,
                onThemeChanged: widget.onThemeChanged,
              ),
            );
          default:
            return CupertinoTabView(
              builder: (context) => const TodayTasksView(),
            );
        }
      },
    );
  }
}
