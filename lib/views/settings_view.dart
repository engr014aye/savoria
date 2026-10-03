import 'package:flutter/cupertino.dart';
import '../theme/savoria_theme.dart';

class SettingsView extends StatefulWidget {
  final Brightness currentBrightness;
  final ValueChanged<Brightness> onThemeChanged;

  const SettingsView({
    super.key,
    required this.currentBrightness,
    required this.onThemeChanged,
  });

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool _soundEffects = true;
  bool _springHaptics = true;
  bool _autoArchive = false;
  bool _confirmDelete = true;
  bool _showBadges = true;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.currentBrightness == Brightness.dark;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: isDark ? SavoriaTheme.darkFrosted : SavoriaTheme.lightFrosted,
        middle: const Text(
          'Settings & Aesthetics',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      child: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          padding: const EdgeInsets.all(20),
          children: [
            // App Identity Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: SavoriaTheme.frostedCardDecoration(context),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [SavoriaTheme.primaryIndigo, SavoriaTheme.primaryIndigoDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: SavoriaTheme.primaryIndigo.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(CupertinoIcons.checkmark_alt, color: CupertinoColors.white, size: 30),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Savoria Executive',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: isDark ? SavoriaTheme.darkTextPrimary : SavoriaTheme.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Premium Daily Task Manager',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: SavoriaTheme.primaryIndigo,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '100% Offline • Zero Distractions',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: isDark ? SavoriaTheme.darkTextSecondary : SavoriaTheme.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // THEME APPEARANCE: Default Light Mode, switchable to Dark Mode
            _buildSectionHeader('APPEARANCE THEME', isDark),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: SavoriaTheme.frostedCardDecoration(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Interface Theme',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: isDark ? SavoriaTheme.darkTextPrimary : SavoriaTheme.lightTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isDark ? 'Dark Mode (Active)' : 'Light Mode (Default)',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: isDark ? SavoriaTheme.darkTextSecondary : SavoriaTheme.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        isDark ? CupertinoIcons.moon_fill : CupertinoIcons.sun_max_fill,
                        color: SavoriaTheme.primaryIndigo,
                        size: 22,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoSlidingSegmentedControl<Brightness>(
                      groupValue: widget.currentBrightness,
                      children: const {
                        Brightness.light: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(CupertinoIcons.sun_max, size: 16),
                              SizedBox(width: 6),
                              Text('Light Mode (Default)'),
                            ],
                          ),
                        ),
                        Brightness.dark: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(CupertinoIcons.moon, size: 16),
                              SizedBox(width: 6),
                              Text('Dark Mode'),
                            ],
                          ),
                        ),
                      },
                      onValueChanged: (val) {
                        if (val != null) {
                          widget.onThemeChanged(val);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // SOUND & INTERACTION
            _buildSectionHeader('SOUND & HAPTICS', isDark),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: SavoriaTheme.frostedCardDecoration(context),
              child: Column(
                children: [
                  _buildToggleRow(
                    title: 'Task Completion Chime',
                    subtitle: 'Play acoustic high-fidelity bell upon completion',
                    value: _soundEffects,
                    onChanged: (val) => setState(() => _soundEffects = val),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 14),
                  _buildToggleRow(
                    title: 'iOS Spring Haptics',
                    subtitle: 'Physical vibration feedback on swipe and toggle',
                    value: _springHaptics,
                    onChanged: (val) => setState(() => _springHaptics = val),
                    isDark: isDark,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // TASK PREFERENCES
            _buildSectionHeader('TASK WORKFLOW', isDark),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: SavoriaTheme.frostedCardDecoration(context),
              child: Column(
                children: [
                  _buildToggleRow(
                    title: 'Show Priority Badges',
                    subtitle: 'Display color tags for urgency levels on task cards',
                    value: _showBadges,
                    onChanged: (val) => setState(() => _showBadges = val),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 14),
                  _buildToggleRow(
                    title: 'Confirm Before Deleting',
                    subtitle: 'Prevent accidental task removals',
                    value: _confirmDelete,
                    onChanged: (val) => setState(() => _confirmDelete = val),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 14),
                  _buildToggleRow(
                    title: 'Auto-Move to Archive',
                    subtitle: 'Instantly transfer completed tasks to accomplishments',
                    value: _autoArchive,
                    onChanged: (val) => setState(() => _autoArchive = val),
                    isDark: isDark,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // TYPOGRAPHY & DESIGN
            _buildSectionHeader('DESIGN & TYPOGRAPHY', isDark),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: SavoriaTheme.frostedCardDecoration(context),
              child: Column(
                children: [
                  _buildInfoRow('UI Framework', '100% Cupertino Native', isDark),
                  const SizedBox(height: 8),
                  _buildInfoRow('Scroll Dynamics', 'iOS Bouncing Physics', isDark),
                  const SizedBox(height: 8),
                  _buildInfoRow('Typography', 'Inter / SF Pro High-Definition', isDark),
                  const SizedBox(height: 8),
                  _buildInfoRow('Visual Surface', 'Frosted Glass Backdrop Filters', isDark),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ABOUT
            _buildSectionHeader('ABOUT SAVORIA', isDark),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: SavoriaTheme.frostedCardDecoration(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Savoria is a premium daily to-do and task management suite created by VIP FOOD COMPANY ( PRIVATE ) LIMITED. Built to deliver pure focus, fluid iOS spring animations, and zero-clutter productivity.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      color: isDark ? SavoriaTheme.darkTextSecondary : SavoriaTheme.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Version 1.0.0 (Build 1)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? SavoriaTheme.darkTextSecondary : SavoriaTheme.lightTextSecondary,
                        ),
                      ),
                      const Text(
                        'VIP FOOD COMPANY',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: SavoriaTheme.primaryIndigo,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 0, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: isDark ? SavoriaTheme.darkTextSecondary : SavoriaTheme.lightTextSecondary,
        ),
      ),
    );
  }

  Widget _buildToggleRow({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDark,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: isDark ? SavoriaTheme.darkTextPrimary : SavoriaTheme.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? SavoriaTheme.darkTextSecondary : SavoriaTheme.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),
        CupertinoSwitch(
          value: value,
          activeTrackColor: SavoriaTheme.primaryIndigo,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.5,
            color: isDark ? SavoriaTheme.darkTextSecondary : SavoriaTheme.lightTextSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: isDark ? SavoriaTheme.darkTextPrimary : SavoriaTheme.lightTextPrimary,
          ),
        ),
      ],
    );
  }
}
