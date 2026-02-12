import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/event.dart';
import '../../models/step_data.dart';
import '../../services/event_providers.dart';
import '../../services/fitness_providers.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/weather_card.dart';
import '../nutrition/water_tracker_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, MMMM d').format(now);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final todayEvents = ref.watch(todayEventsProvider);
    final todaySteps = ref.watch(todayStepsProvider);
    final morningRoutine = ref.watch(morningRoutineProvider);
    final eveningRoutine = ref.watch(eveningRoutineProvider);

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
              // Greeting
              Text(
                '${_greeting()},',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  color: isDark ? Colors.white70 : AppColors.textMuted,
                ),
              ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.1, end: 0),
              const SizedBox(height: 4),
              ShaderMask(
                shaderCallback: (bounds) =>
                    AppColors.primaryGradient.createShader(bounds),
                child: Text(
                  'That Girl \u{2728}',
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 100.ms)
                  .slideX(begin: -0.1, end: 0),
              const SizedBox(height: 20),

              // Weather card
              const WeatherCard()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 150.ms)
                  .slideY(begin: 0.1, end: 0),

              const SizedBox(height: 20),

              // Step progress ring (small) + Today's date
              Row(
                children: [
                  // Mini step ring
                  todaySteps.when(
                    data: (steps) =>
                        _MiniStepRing(steps: steps, isDark: isDark),
                    loading: () => const SizedBox(width: 120, height: 120),
                    error: (_, __) =>
                        const SizedBox(width: 120, height: 120),
                  ),
                  const SizedBox(width: 16),
                  // Date card
                  Expanded(
                    child: GlassCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Today',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                              color: isDark
                                  ? Colors.white70
                                  : AppColors.textMuted,
                            ),
                          ),
                          Text(
                            dateStr,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color:
                                  isDark ? Colors.white : AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 200.ms)
                  .slideY(begin: 0.1, end: 0),

              const SizedBox(height: 20),

              // Water tracker card (compact)
              const WaterTrackerWidget(compact: true)
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 250.ms)
                  .slideY(begin: 0.1, end: 0),

              const SizedBox(height: 20),

              // Routine quick access cards
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => context.push('/routine/morning'),
                      child: GlassCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFF59E0B),
                                        Color(0xFFFFD700),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.wb_sunny_rounded,
                                      color: Colors.white, size: 16),
                                ),
                                const Spacer(),
                                Icon(Icons.chevron_right_rounded,
                                    size: 18,
                                    color: isDark
                                        ? Colors.white30
                                        : AppColors.textMuted),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Morning',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.white
                                    : AppColors.textDark,
                              ),
                            ),
                            morningRoutine.when(
                              data: (r) {
                                if (r == null) {
                                  return Text(
                                    'Start routine',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w300,
                                      color: isDark
                                          ? Colors.white54
                                          : AppColors.textMuted,
                                    ),
                                  );
                                }
                                return Text(
                                  '${r.completedCount}/${r.tasks.length} tasks done',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w300,
                                    color: isDark
                                        ? Colors.white54
                                        : AppColors.textMuted,
                                  ),
                                );
                              },
                              loading: () => const SizedBox.shrink(),
                              error: (_, __) => const SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => context.push('/routine/evening'),
                      child: GlassCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        AppColors.lavender,
                                        AppColors.deepPurple,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                      Icons.nights_stay_rounded,
                                      color: Colors.white,
                                      size: 16),
                                ),
                                const Spacer(),
                                Icon(Icons.chevron_right_rounded,
                                    size: 18,
                                    color: isDark
                                        ? Colors.white30
                                        : AppColors.textMuted),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Evening',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.white
                                    : AppColors.textDark,
                              ),
                            ),
                            eveningRoutine.when(
                              data: (r) {
                                if (r == null) {
                                  return Text(
                                    'Ready to wind down?',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w300,
                                      color: isDark
                                          ? Colors.white54
                                          : AppColors.textMuted,
                                    ),
                                  );
                                }
                                return Text(
                                  r.completedCount > 0
                                      ? '${r.completedCount}/${r.tasks.length} tasks done'
                                      : 'Ready to wind down?',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w300,
                                    color: isDark
                                        ? Colors.white54
                                        : AppColors.textMuted,
                                  ),
                                );
                              },
                              loading: () => const SizedBox.shrink(),
                              error: (_, __) => const SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 300.ms)
                  .slideY(begin: 0.1, end: 0),

              const SizedBox(height: 20),

              // Daily motivation card
              GlassCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) =>
                              AppColors.primaryGradient.createShader(bounds),
                          child: const Icon(
                            Icons.auto_awesome_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Daily Affirmation',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color:
                                isDark ? Colors.white : AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '"What, like it\'s hard?" \u{2014} You\'re capable of everything you set your mind to today.',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w300,
                        color: isDark ? Colors.white70 : AppColors.textDark,
                        height: 1.6,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 350.ms)
                  .slideY(begin: 0.1, end: 0),

              const SizedBox(height: 20),

              // Today's Schedule
              _TodaySchedule(events: todayEvents, isDark: isDark)
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 400.ms)
                  .slideY(begin: 0.1, end: 0),

              const SizedBox(height: 20),

              // Quick actions
              Text(
                'Quick Actions',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.textDark,
                ),
              )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 500.ms),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.checkroom_rounded,
                      label: 'Outfit',
                      gradient: const LinearGradient(
                        colors: [AppColors.rosePink, Color(0xFFE88FA8)],
                      ),
                      isDark: isDark,
                      onTap: () => context.push('/outfit/morning'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.fitness_center_rounded,
                      label: 'Workout',
                      gradient: const LinearGradient(
                        colors: [AppColors.lavender, Color(0xFFB494D6)],
                      ),
                      isDark: isDark,
                      onTap: () => context.push('/fitness/log-workout'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.self_improvement_rounded,
                      label: 'Routines',
                      gradient: const LinearGradient(
                        colors: [AppColors.deepPurple, Color(0xFF9F67FF)],
                      ),
                      isDark: isDark,
                      onTap: () => context.push('/routine/morning'),
                    ),
                  ),
                ],
              )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 600.ms)
                  .slideY(begin: 0.1, end: 0),
            ],
          ),
        ),
      ),
    );
  }
}

// Mini step ring for home screen
class _MiniStepRing extends StatefulWidget {
  final StepData steps;
  final bool isDark;

  const _MiniStepRing({required this.steps, required this.isDark});

  @override
  State<_MiniStepRing> createState() => _MiniStepRingState();
}

class _MiniStepRingState extends State<_MiniStepRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
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
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          width: 120,
          height: 120,
          child: CustomPaint(
            painter: _MiniRingPainter(
              progress: _animation.value,
              isDark: widget.isDark,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${widget.steps.stepCount}',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: widget.isDark
                          ? Colors.white
                          : AppColors.textDark,
                    ),
                  ),
                  Text(
                    'steps',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w300,
                      color: widget.isDark
                          ? Colors.white54
                          : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MiniRingPainter extends CustomPainter {
  final double progress;
  final bool isDark;

  _MiniRingPainter({required this.progress, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    const strokeWidth = 8.0;

    final bgPaint = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.1)
          : AppColors.rosePink.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

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
          rect, -pi / 2, 2 * pi * progress, false, gradientPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _MiniRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _TodaySchedule extends StatelessWidget {
  final List<Event> events;
  final bool isDark;

  const _TodaySchedule({required this.events, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Today's Schedule",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.textDark,
              ),
            ),
            if (events.isNotEmpty)
              GestureDetector(
                onTap: () => context.go('/calendar'),
                child: Text(
                  'See all',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.deepPurple,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (events.isEmpty)
          GlassCard(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                ShaderMask(
                  shaderCallback: (bounds) =>
                      AppColors.softGradient.createShader(bounds),
                  child: const Icon(
                    Icons.celebration_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Your day is wide open! \u{2728}',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: isDark ? Colors.white70 : AppColors.textDark,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          ...events.take(3).map((event) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GestureDetector(
                  onTap: () =>
                      context.push('/calendar/event/${event.id}'),
                  child: GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Color(Event.typeColors[event.type]!),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event.title,
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                DateFormat('h:mm a')
                                    .format(event.dateTime),
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
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Color(Event.typeColors[event.type]!)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            Event.typeLabel(event.type),
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(Event.typeColors[event.type]!),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final LinearGradient gradient;
  final bool isDark;
  final VoidCallback? onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.isDark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: gradient.colors.first.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
