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
import '../../services/wardrobe_providers.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/shimmer_loading.dart';
import '../../shared/widgets/weather_card.dart';
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning, That Girl ✨';
    if (hour < 17) return 'Good Afternoon, That Girl ✨';
    return 'Good Evening, That Girl ✨';
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
    final waterLog = ref.watch(todayWaterLogProvider);
    final weatherAsync = ref.watch(weatherProvider);
    final wardrobeAsync = ref.watch(clothingItemsProvider);

    return Container(
      decoration: BoxDecoration(
        gradient: isDark
            ? AppColors.darkBackgroundGradient
            : AppColors.backgroundGradient,
      ),
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TOP SECTION: Greeting + Date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) =>
                              AppColors.primaryGradient.createShader(bounds),
                          child: Text(
                            _greeting(),
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateStr,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: isDark ? Colors.white54 : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.push('/settings'),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.white.withValues(alpha: 0.7),
                      ),
                      child: Icon(Icons.settings_rounded,
                          size: 22, color: isDark ? Colors.white70 : AppColors.textMuted),
                    ),
                  ),
                ],
              )
                  .animate()
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: 0.1, end: 0),

              const SizedBox(height: 24),

              // 1. Weather Card
              const WeatherCard()
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 100.ms)
                  .slideY(begin: 0.1, end: 0),

              const SizedBox(height: 16),

              // 2. Today's Outfit Card
              _TodayOutfitCard(
                isDark: isDark,
                weatherAsync: weatherAsync,
                todayEvents: todayEvents,
                wardrobeAsync: wardrobeAsync,
              )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 150.ms)
                  .slideY(begin: 0.1, end: 0),

              const SizedBox(height: 16),

              // 3. Step Counter Ring
              todaySteps.when(
                data: (steps) => _StepRingCard(steps: steps, isDark: isDark)
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 200.ms)
                    .slideY(begin: 0.1, end: 0),
                loading: () => const ShimmerCard(height: 200, borderRadius: 20),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 16),

              // 4. Water Tracker Card (with +250, +500)
              waterLog.when(
                data: (w) => _HomeWaterCard(
                  totalMl: w?.totalMl ?? 0,
                  goalMl: w?.goalMl ?? 2500,
                  isDark: isDark,
                  onAdd: (amt) {
                    ref.read(nutritionRepositoryProvider).addWaterEntry(amt);
                  },
                )
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 250.ms)
                    .slideY(begin: 0.1, end: 0),
                loading: () => const ShimmerCard(height: 120, borderRadius: 20),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 16),

              // 5. Today's Schedule Card
              _TodayScheduleCard(events: todayEvents, isDark: isDark)
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 300.ms)
                  .slideY(begin: 0.1, end: 0),

              const SizedBox(height: 16),

              // 6. Morning/Evening Routine Card
              _RoutineCard(
                isDark: isDark,
                morningRoutine: morningRoutine,
                eveningRoutine: eveningRoutine,
              )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 350.ms)
                  .slideY(begin: 0.1, end: 0),

              const SizedBox(height: 24),

              // Quick Actions (horizontal scrollable)
              Text(
                'Quick Actions',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.textDark,
                ),
              )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 400.ms),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _QuickActionChip(
                      icon: Icons.checkroom_rounded,
                      label: 'Outfit',
                      isDark: isDark,
                      onTap: () => context.push('/outfit/morning'),
                    ),
                    const SizedBox(width: 10),
                    _QuickActionChip(
                      icon: Icons.fitness_center_rounded,
                      label: 'Workout',
                      isDark: isDark,
                      onTap: () => context.push('/fitness/log-workout'),
                    ),
                    const SizedBox(width: 10),
                    _QuickActionChip(
                      icon: Icons.restaurant_rounded,
                      label: 'Meals',
                      isDark: isDark,
                      onTap: () => context.push('/nutrition/meals'),
                    ),
                    const SizedBox(width: 10),
                    _QuickActionChip(
                      icon: Icons.nightlight_round,
                      label: 'Routines',
                      isDark: isDark,
                      onTap: () {
                        final hour = DateTime.now().hour;
                        context.push(hour < 14 ? '/routine/morning' : '/routine/evening');
                      },
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 450.ms)
                  .slideY(begin: 0.1, end: 0),
            ],
          ),
        ),
      ),
    );
  }
}

class _TodayOutfitCard extends StatelessWidget {
  final bool isDark;
  final AsyncValue weatherAsync;
  final List<Event> todayEvents;
  final AsyncValue wardrobeAsync;

  const _TodayOutfitCard({
    required this.isDark,
    required this.weatherAsync,
    required this.todayEvents,
    required this.wardrobeAsync,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = weatherAsync.when(
      data: (w) {
        var s = '${w.temperature.round()}°C · ${w.description}';
        if (todayEvents.isNotEmpty) s += ' · ${todayEvents.first.title}';
        return s;
      },
      loading: () => 'Loading...',
      error: (_, __) => 'Tap to see picks',
    );

    return GestureDetector(
      onTap: () => context.push('/outfit/morning'),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.rosePink.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.checkroom_rounded, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Today's Outfit",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                gradient: AppColors.softGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.rosePink.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                'View Full Outfit',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepRingCard extends StatefulWidget {
  final StepData steps;
  final bool isDark;

  const _StepRingCard({required this.steps, required this.isDark});

  @override
  State<_StepRingCard> createState() => _StepRingCardState();
}

class _StepRingCardState extends State<_StepRingCard>
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
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          SizedBox(
            width: 140,
            height: 140,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, _) {
                return CustomPaint(
                  painter: _StepRingPainter(
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
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: widget.isDark ? Colors.white : AppColors.textDark,
                          ),
                        ),
                        Text(
                          '/ ${widget.steps.goal}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                            color: widget.isDark ? Colors.white54 : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatPill(
                icon: Icons.straighten_rounded,
                value: '${widget.steps.distanceKm.toStringAsFixed(1)} km',
                label: 'Distance',
                isDark: widget.isDark,
              ),
              _StatPill(
                icon: Icons.local_fire_department_rounded,
                value: '${widget.steps.caloriesBurned}',
                label: 'Calories',
                isDark: widget.isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final bool isDark;

  const _StatPill({
    required this.icon,
    required this.value,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: AppColors.deepPurple),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.textDark,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w300,
                color: isDark ? Colors.white38 : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ],
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
    final radius = size.width / 2 - 8;
    const strokeWidth = 10.0;

    final bgPaint = Paint()
      ..color = isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.rosePink.withValues(alpha: 0.15)
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
      canvas.drawArc(rect, -pi / 2, 2 * pi * progress, false, gradientPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _StepRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _HomeWaterCard extends StatelessWidget {
  final int totalMl;
  final int goalMl;
  final bool isDark;
  final void Function(int) onAdd;

  const _HomeWaterCard({
    required this.totalMl,
    required this.goalMl,
    required this.isDark,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (totalMl / goalMl).clamp(0.0, 1.0);

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
                ).createShader(bounds),
                child: const Icon(Icons.water_drop_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 10),
              Text(
                'Water',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.textDark,
                ),
              ),
              const Spacer(),
              Text(
                '$totalMl / $goalMl ml',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF06B6D4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : const Color(0xFF06B6D4).withValues(alpha: 0.15),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF06B6D4)),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _WaterAddButton(label: '+250ml', onTap: () => onAdd(250)),
              const SizedBox(width: 10),
              _WaterAddButton(label: '+500ml', onTap: () => onAdd(500)),
            ],
          ),
        ],
      ),
    );
  }
}

class _WaterAddButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _WaterAddButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF06B6D4).withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _TodayScheduleCard extends StatelessWidget {
  final List<Event> events;
  final bool isDark;

  const _TodayScheduleCard({required this.events, required this.isDark});

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
            GestureDetector(
              onTap: () => context.go('/calendar'),
              child: Text(
                'View Calendar',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.deepPurple,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (events.isEmpty)
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                ShaderMask(
                  shaderCallback: (bounds) =>
                      AppColors.softGradient.createShader(bounds),
                  child: const Icon(Icons.celebration_rounded, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'No events yet! Tap + to add your first event ✨',
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
                  onTap: () => context.push('/calendar/event/${event.id}'),
                  child: GlassCard(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 40,
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
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : AppColors.textDark,
                                ),
                              ),
                              Text(
                                DateFormat('h:mm a').format(event.dateTime),
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
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

class _RoutineCard extends StatelessWidget {
  final bool isDark;
  final AsyncValue morningRoutine;
  final AsyncValue eveningRoutine;

  const _RoutineCard({
    required this.isDark,
    required this.morningRoutine,
    required this.eveningRoutine,
  });

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final isMorning = hour < 14;

    return GestureDetector(
      onTap: () => context.push(isMorning ? '/routine/morning' : '/routine/evening'),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: isMorning
                    ? const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFFFD700)])
                    : const LinearGradient(colors: [AppColors.lavender, AppColors.deepPurple]),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: (isMorning ? const Color(0xFFF59E0B) : AppColors.deepPurple)
                        .withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                isMorning ? Icons.wb_sunny_rounded : Icons.nights_stay_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isMorning ? 'Morning Routine' : 'Evening Routine',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.textDark,
                    ),
                  ),
                  isMorning
                      ? morningRoutine.when(
                          data: (r) => Text(
                            r == null ? 'Start your day' : '${r.completedCount}/${r.tasks.length} tasks done',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w300,
                              color: isDark ? Colors.white54 : AppColors.textMuted,
                            ),
                          ),
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                        )
                      : eveningRoutine.when(
                          data: (r) => Text(
                            r == null ? 'Ready to wind down?' : '${r.completedCount}/${r.tasks.length} tasks done',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w300,
                              color: isDark ? Colors.white54 : AppColors.textMuted,
                            ),
                          ),
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: isDark ? Colors.white30 : AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final VoidCallback onTap;

  const _QuickActionChip({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.white.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : AppColors.rosePink.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ShaderMask(
              shaderCallback: (bounds) =>
                  AppColors.primaryGradient.createShader(bounds),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
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
