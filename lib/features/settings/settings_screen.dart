import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/widgets/glass_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _calendarReminders = true;
  bool _waterReminders = true;
  bool _dailySummary = true;
  int _stepGoal = 10000;
  int _waterGoal = 2500;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _calendarReminders = prefs.getBool('calendar_reminders') ?? true;
      _waterReminders = prefs.getBool('water_reminders') ?? true;
      _dailySummary = prefs.getBool('daily_summary') ?? true;
      _stepGoal = prefs.getInt('step_goal') ?? 10000;
      _waterGoal = prefs.getInt('water_goal') ?? 2500;
    });
  }

  Future<void> _saveToggle(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _saveInt(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = FirebaseAuth.instance.currentUser;

    return Container(
      decoration: BoxDecoration(
        gradient: isDark
            ? AppColors.darkBackgroundGradient
            : AppColors.backgroundGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded,
                color: isDark ? Colors.white : AppColors.textDark),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Settings',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.textDark,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile card
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.softGradient,
                      ),
                      child: Center(
                        child: Text(
                          (user?.displayName ?? user?.email ?? 'T')
                              .substring(0, 1)
                              .toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.displayName ?? 'That Girl',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : AppColors.textDark,
                            ),
                          ),
                          Text(
                            user?.email ?? '',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w300,
                              color: isDark
                                  ? Colors.white54
                                  : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: 0.1, end: 0),

              const SizedBox(height: 24),

              // Notifications section
              _sectionTitle('Notifications', isDark),
              const SizedBox(height: 12),
              GlassCard(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  children: [
                    _ToggleTile(
                      icon: Icons.calendar_month_rounded,
                      title: 'Calendar Reminders',
                      subtitle: 'Event reminders',
                      value: _calendarReminders,
                      isDark: isDark,
                      onChanged: (v) {
                        setState(() => _calendarReminders = v);
                        _saveToggle('calendar_reminders', v);
                      },
                    ),
                    Divider(
                      height: 1,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : AppColors.rosePink.withValues(alpha: 0.1),
                    ),
                    _ToggleTile(
                      icon: Icons.water_drop_rounded,
                      title: 'Water Reminders',
                      subtitle: 'Hourly reminders 9 AM – 9 PM',
                      value: _waterReminders,
                      isDark: isDark,
                      onChanged: (v) {
                        setState(() => _waterReminders = v);
                        _saveToggle('water_reminders', v);
                      },
                    ),
                    Divider(
                      height: 1,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : AppColors.rosePink.withValues(alpha: 0.1),
                    ),
                    _ToggleTile(
                      icon: Icons.notifications_rounded,
                      title: 'Daily Summary (7 AM)',
                      subtitle: 'Good morning with weather & schedule',
                      value: _dailySummary,
                      isDark: isDark,
                      onChanged: (v) {
                        setState(() => _dailySummary = v);
                        _saveToggle('daily_summary', v);
                      },
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 100.ms)
                  .slideY(begin: 0.1, end: 0),

              const SizedBox(height: 24),

              // Goals section
              _sectionTitle('Goals', isDark),
              const SizedBox(height: 12),
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _GoalSlider(
                      icon: Icons.directions_walk_rounded,
                      title: 'Daily Steps',
                      value: _stepGoal,
                      min: 2000,
                      max: 20000,
                      divisions: 18,
                      labelBuilder: (v) =>
                          '${(v / 1000).toStringAsFixed(0)}K steps',
                      isDark: isDark,
                      onChanged: (v) {
                        setState(() => _stepGoal = v.round());
                        _saveInt('step_goal', v.round());
                      },
                    ),
                    const SizedBox(height: 16),
                    _GoalSlider(
                      icon: Icons.water_drop_rounded,
                      title: 'Daily Water',
                      value: _waterGoal,
                      min: 1000,
                      max: 4000,
                      divisions: 12,
                      labelBuilder: (v) =>
                          '${(v / 1000).toStringAsFixed(1)}L',
                      isDark: isDark,
                      onChanged: (v) {
                        setState(() => _waterGoal = v.round());
                        _saveInt('water_goal', v.round());
                      },
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 200.ms)
                  .slideY(begin: 0.1, end: 0),

              const SizedBox(height: 24),

              // About section
              _sectionTitle('About', isDark),
              const SizedBox(height: 12),
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _InfoTile(
                      icon: Icons.info_outline_rounded,
                      title: 'Version',
                      trailing: '1.0.0',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    _InfoTile(
                      icon: Icons.favorite_rounded,
                      title: 'Made with love',
                      trailing: 'That Girl Energy',
                      isDark: isDark,
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 300.ms)
                  .slideY(begin: 0.1, end: 0),

              const SizedBox(height: 24),

              // Sign out
              GestureDetector(
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text('Sign Out',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600)),
                      content: Text('Are you sure you want to sign out?',
                          style: GoogleFonts.poppins()),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: Text('Sign Out',
                              style: TextStyle(color: Colors.red.shade400)),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true && context.mounted) {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) context.go('/auth');
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.red.shade300.withValues(alpha: 0.5)),
                  ),
                  child: Center(
                    child: Text(
                      'Sign Out',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.red.shade400,
                      ),
                    ),
                  ),
                ),
              )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 400.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white : AppColors.textDark,
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final bool isDark;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          ShaderMask(
            shaderCallback: (bounds) =>
                AppColors.softGradient.createShader(bounds),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : AppColors.textDark,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                    color: isDark ? Colors.white54 : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.deepPurple,
            activeTrackColor: AppColors.lavender.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }
}

class _GoalSlider extends StatelessWidget {
  final IconData icon;
  final String title;
  final int value;
  final double min;
  final double max;
  final int divisions;
  final String Function(double) labelBuilder;
  final bool isDark;
  final ValueChanged<double> onChanged;

  const _GoalSlider({
    required this.icon,
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.labelBuilder,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            ShaderMask(
              shaderCallback: (bounds) =>
                  AppColors.softGradient.createShader(bounds),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : AppColors.textDark,
              ),
            ),
            const Spacer(),
            Text(
              labelBuilder(value.toDouble()),
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.deepPurple,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: AppColors.deepPurple,
            inactiveTrackColor:
                AppColors.lavender.withValues(alpha: 0.3),
            thumbColor: AppColors.deepPurple,
            overlayColor: AppColors.deepPurple.withValues(alpha: 0.1),
          ),
          child: Slider(
            value: value.toDouble(),
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String trailing;
  final bool isDark;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.trailing,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ShaderMask(
          shaderCallback: (bounds) =>
              AppColors.softGradient.createShader(bounds),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: isDark ? Colors.white : AppColors.textDark,
          ),
        ),
        const Spacer(),
        Text(
          trailing,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w300,
            color: isDark ? Colors.white54 : AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}
