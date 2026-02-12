import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../models/sleep_log.dart';
import '../../services/fitness_providers.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/widgets/glass_card.dart';

class SleepTrackerScreen extends ConsumerStatefulWidget {
  const SleepTrackerScreen({super.key});

  @override
  ConsumerState<SleepTrackerScreen> createState() =>
      _SleepTrackerScreenState();
}

class _SleepTrackerScreenState extends ConsumerState<SleepTrackerScreen> {
  TimeOfDay _bedtime = const TimeOfDay(hour: 23, minute: 0);
  TimeOfDay _wakeTime = const TimeOfDay(hour: 7, minute: 0);
  bool _saving = false;

  int get _durationMinutes {
    final bedMinutes = _bedtime.hour * 60 + _bedtime.minute;
    final wakeMinutes = _wakeTime.hour * 60 + _wakeTime.minute;
    var diff = wakeMinutes - bedMinutes;
    if (diff < 0) diff += 24 * 60;
    return diff;
  }

  String get _durationText {
    final h = _durationMinutes ~/ 60;
    final m = _durationMinutes % 60;
    return '${h}h ${m}m';
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final now = DateTime.now();
    final bedDateTime = DateTime(
        now.year, now.month, now.day, _bedtime.hour, _bedtime.minute);
    final wakeDateTime = DateTime(
        now.year, now.month, now.day, _wakeTime.hour, _wakeTime.minute);

    final log = SleepLog(
      date: now,
      bedtime: bedDateTime,
      wakeTime: wakeDateTime,
      durationMinutes: _durationMinutes,
      userId: uid,
    );

    final repo = ref.read(routineRepositoryProvider);
    await repo.saveSleepLog(log);
    ref.invalidate(todaySleepProvider);
    ref.invalidate(weeklySleepProvider);
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final todaySleep = ref.watch(todaySleepProvider);
    final weeklySleep = ref.watch(weeklySleepProvider);

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
            'Sleep Tracker',
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
              // Last night's sleep
              todaySleep.when(
                data: (sleep) {
                  if (sleep != null) {
                    return GlassCard(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Icon(
                            sleep.meetsGoal
                                ? Icons.nights_stay_rounded
                                : Icons.bedtime_rounded,
                            size: 40,
                            color: AppColors.deepPurple,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'You slept ${sleep.durationText} last night',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? Colors.white
                                  : AppColors.textDark,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: sleep.meetsGoal
                                  ? const Color(0xFF10B981)
                                      .withValues(alpha: 0.15)
                                  : const Color(0xFFF59E0B)
                                      .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              sleep.meetsGoal
                                  ? 'Goal reached! \u{2728}'
                                  : 'Below 8h goal',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: sleep.meetsGoal
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFF59E0B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 500.ms)
                        .slideY(begin: 0.1, end: 0);
                  }
                  return const SizedBox.shrink();
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 20),

              // Input bedtime / wake time
              Text(
                'Log Sleep',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.textDark,
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final t = await showTimePicker(
                          context: context,
                          initialTime: _bedtime,
                        );
                        if (t != null) setState(() => _bedtime = t);
                      },
                      child: GlassCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Icon(Icons.bedtime_rounded,
                                color: AppColors.deepPurple, size: 28),
                            const SizedBox(height: 8),
                            Text(
                              'Bedtime',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w300,
                                color: isDark
                                    ? Colors.white54
                                    : AppColors.textMuted,
                              ),
                            ),
                            Text(
                              _bedtime.format(context),
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.white
                                    : AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final t = await showTimePicker(
                          context: context,
                          initialTime: _wakeTime,
                        );
                        if (t != null) setState(() => _wakeTime = t);
                      },
                      child: GlassCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Icon(Icons.wb_sunny_rounded,
                                color: AppColors.rosePink, size: 28),
                            const SizedBox(height: 8),
                            Text(
                              'Wake Up',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w300,
                                color: isDark
                                    ? Colors.white54
                                    : AppColors.textMuted,
                              ),
                            ),
                            Text(
                              _wakeTime.format(context),
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.white
                                    : AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 400.ms, delay: 150.ms),

              const SizedBox(height: 12),

              // Duration display
              Center(
                child: Text(
                  'Duration: $_durationText',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.deepPurple,
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

              const SizedBox(height: 16),

              // Save button
              GestureDetector(
                onTap: _saving ? null : _save,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.rosePink.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _saving
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : Text(
                            'Save Sleep Log',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 250.ms),

              const SizedBox(height: 28),

              // Weekly sleep chart
              weeklySleep.when(
                data: (logs) {
                  if (logs.isEmpty) return const SizedBox.shrink();
                  return GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Weekly Sleep',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? Colors.white
                                : AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 180,
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: 12,
                              titlesData: FlTitlesData(
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, _) {
                                      final idx = value.toInt();
                                      if (idx >= 0 && idx < logs.length) {
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8),
                                          child: Text(
                                            DateFormat('E')
                                                .format(logs[idx].date),
                                            style: GoogleFonts.poppins(
                                              fontSize: 10,
                                              color: isDark
                                                  ? Colors.white54
                                                  : AppColors.textMuted,
                                            ),
                                          ),
                                        );
                                      }
                                      return const SizedBox.shrink();
                                    },
                                  ),
                                ),
                                leftTitles: const AxisTitles(
                                    sideTitles:
                                        SideTitles(showTitles: false)),
                                topTitles: const AxisTitles(
                                    sideTitles:
                                        SideTitles(showTitles: false)),
                                rightTitles: const AxisTitles(
                                    sideTitles:
                                        SideTitles(showTitles: false)),
                              ),
                              gridData: const FlGridData(show: false),
                              borderData: FlBorderData(show: false),
                              extraLinesData: ExtraLinesData(
                                horizontalLines: [
                                  HorizontalLine(
                                    y: 8,
                                    color: AppColors.deepPurple
                                        .withValues(alpha: 0.3),
                                    strokeWidth: 1,
                                    dashArray: [5, 5],
                                    label: HorizontalLineLabel(
                                      show: true,
                                      alignment: Alignment.topRight,
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        color: AppColors.deepPurple,
                                      ),
                                      labelResolver: (_) => '8h Goal',
                                    ),
                                  ),
                                ],
                              ),
                              barGroups: logs
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                final hours =
                                    entry.value.durationMinutes / 60;
                                return BarChartGroupData(
                                  x: entry.key,
                                  barRods: [
                                    BarChartRodData(
                                      toY: hours,
                                      width: 20,
                                      borderRadius:
                                          const BorderRadius.vertical(
                                              top: Radius.circular(6)),
                                      gradient: const LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: [
                                          AppColors.lavender,
                                          AppColors.deepPurple,
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 300.ms)
                      .slideY(begin: 0.1, end: 0);
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
