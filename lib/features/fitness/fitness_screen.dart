import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../models/step_data.dart';
import '../../models/workout.dart';
import '../../services/fitness_providers.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/widgets/glass_card.dart';

class FitnessScreen extends ConsumerWidget {
  const FitnessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final todaySteps = ref.watch(todayStepsProvider);
    final weeklySteps = ref.watch(weeklyStepsProvider);
    final todayWorkouts = ref.watch(todayWorkoutsProvider);

    return Container(
      decoration: BoxDecoration(
        gradient: isDark
            ? AppColors.darkBackgroundGradient
            : AppColors.backgroundGradient,
      ),
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                shaderCallback: (bounds) =>
                    AppColors.primaryGradient.createShader(bounds),
                child: Text(
                  'Fitness \u{1F4AA}',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ).animate().fadeIn(duration: 500.ms),

              const SizedBox(height: 24),

              // Step counter ring
              todaySteps.when(
                data: (steps) => _StepRing(steps: steps, isDark: isDark)
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 100.ms)
                    .slideY(begin: 0.1, end: 0),
                loading: () => const SizedBox(
                  height: 220,
                  child: Center(
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.rosePink),
                  ),
                ),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 20),

              // Today's Activity card
              todaySteps.when(
                data: (steps) => _ActivityCard(steps: steps, isDark: isDark)
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 200.ms)
                    .slideY(begin: 0.1, end: 0),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 20),

              // Weekly steps chart
              weeklySteps.when(
                data: (data) => _WeeklyStepsChart(data: data, isDark: isDark)
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 300.ms)
                    .slideY(begin: 0.1, end: 0),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 20),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: _GradientButton(
                      label: 'Log Workout',
                      icon: Icons.add_rounded,
                      onTap: () => context.push('/fitness/log-workout'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _GradientButton(
                      label: 'Training Plan',
                      icon: Icons.calendar_month_rounded,
                      onTap: () => context.push('/fitness/training-plan'),
                    ),
                  ),
                ],
              )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 400.ms)
                  .slideY(begin: 0.1, end: 0),

              const SizedBox(height: 8),

              SizedBox(
                width: double.infinity,
                child: _GradientButton(
                  label: 'Sleep Tracker',
                  icon: Icons.bedtime_rounded,
                  onTap: () => context.push('/fitness/sleep'),
                ),
              )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 450.ms)
                  .slideY(begin: 0.1, end: 0),

              const SizedBox(height: 24),

              // Today's workouts
              Text(
                "Today's Workouts",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.textDark,
                ),
              )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 500.ms),

              const SizedBox(height: 12),

              todayWorkouts.when(
                data: (workouts) {
                  if (workouts.isEmpty) {
                    return GlassCard(
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) =>
                                AppColors.softGradient.createShader(bounds),
                            child: const Icon(Icons.fitness_center_rounded,
                                color: Colors.white, size: 28),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              'No workouts yet today. Let\'s get moving!',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: isDark
                                    ? Colors.white70
                                    : AppColors.textDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 500.ms, delay: 550.ms);
                  }
                  return Column(
                    children: workouts
                        .map((w) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _WorkoutCard(
                                  workout: w, isDark: isDark),
                            ))
                        .toList(),
                  )
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 550.ms);
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

class _StepRing extends StatefulWidget {
  final StepData steps;
  final bool isDark;

  const _StepRing({required this.steps, required this.isDark});

  @override
  State<_StepRing> createState() => _StepRingState();
}

class _StepRingState extends State<_StepRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = Tween<double>(begin: 0, end: widget.steps.progress)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return SizedBox(
            width: 200,
            height: 200,
            child: CustomPaint(
              painter: _StepRingPainter(
                progress: _animation.value,
                isDark: widget.isDark,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(widget.steps.stepCount * _animation.value / widget.steps.progress).round()}',
                      style: GoogleFonts.poppins(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: widget.isDark
                            ? Colors.white
                            : AppColors.textDark,
                      ),
                    ),
                    Text(
                      '/ ${widget.steps.goal}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                        color: widget.isDark
                            ? Colors.white54
                            : AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(_animation.value * 100).round()}%',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.deepPurple,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StepRingPainter extends CustomPainter {
  final double progress;
  final bool isDark;

  _StepRingPainter({required this.progress, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;
    const strokeWidth = 12.0;

    // Background ring
    final bgPaint = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.1)
          : AppColors.rosePink.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Gradient ring
    if (progress > 0) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      final gradientPaint = Paint()
        ..shader = const SweepGradient(
          startAngle: -pi / 2,
          endAngle: 3 * pi / 2,
          colors: [AppColors.rosePink, AppColors.deepPurple],
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        rect.inflate(-strokeWidth / 2 + strokeWidth / 2),
        -pi / 2,
        2 * pi * progress,
        false,
        gradientPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StepRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _ActivityCard extends StatelessWidget {
  final StepData steps;
  final bool isDark;

  const _ActivityCard({required this.steps, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShaderMask(
                shaderCallback: (bounds) =>
                    AppColors.primaryGradient.createShader(bounds),
                child: const Icon(Icons.local_fire_department_rounded,
                    color: Colors.white, size: 22),
              ),
              const SizedBox(width: 8),
              Text(
                "Today's Activity",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatItem(
                icon: Icons.directions_walk_rounded,
                label: 'Steps',
                value: '${steps.stepCount}',
                isDark: isDark,
              ),
              _StatItem(
                icon: Icons.straighten_rounded,
                label: 'Distance',
                value: '${steps.distanceKm.toStringAsFixed(1)} km',
                isDark: isDark,
              ),
              _StatItem(
                icon: Icons.local_fire_department_rounded,
                label: 'Calories',
                value: '${steps.caloriesBurned}',
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: AppColors.deepPurple),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.textDark,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w300,
              color: isDark ? Colors.white54 : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyStepsChart extends StatelessWidget {
  final List<StepData> data;
  final bool isDark;

  const _WeeklyStepsChart({required this.data, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Steps',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 15000,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => AppColors.deepPurple,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${rod.toY.round()}',
                        GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx >= 0 && idx < data.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              DateFormat('E').format(data[idx].date),
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w400,
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
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: 10000,
                      color: AppColors.deepPurple.withValues(alpha: 0.3),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                      label: HorizontalLineLabel(
                        show: true,
                        alignment: Alignment.topRight,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: AppColors.deepPurple,
                        ),
                        labelResolver: (_) => 'Goal',
                      ),
                    ),
                  ],
                ),
                barGroups: data.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.stepCount.toDouble(),
                        width: 20,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6)),
                        gradient: const LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [AppColors.rosePink, AppColors.deepPurple],
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
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  final Workout workout;
  final bool isDark;

  const _WorkoutCard({required this.workout, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final typeColor = Color(Workout.typeColors[workout.type]!);

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 44,
            decoration: BoxDecoration(
              color: typeColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Workout.typeLabel(workout.type),
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.textDark,
                  ),
                ),
                Text(
                  '${workout.duration} min · ${workout.caloriesBurned} cal',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w300,
                    color: isDark ? Colors.white54 : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              Workout.typeLabel(workout.type),
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: typeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _GradientButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
