import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/daily_review.dart';
import '../../models/meal.dart';
import '../../services/daily_review_repository.dart';
import '../../services/fitness_providers.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/shimmer_loading.dart';

final dailyReviewRepositoryProvider =
    Provider<DailyReviewRepository>((ref) => DailyReviewRepository());

class EveningReviewScreen extends ConsumerStatefulWidget {
  const EveningReviewScreen({super.key});

  @override
  ConsumerState<EveningReviewScreen> createState() => _EveningReviewScreenState();
}

class _EveningReviewScreenState extends ConsumerState<EveningReviewScreen> {
  int _rating = 0;
  final _moodController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _moodController.dispose();
    super.dispose();
  }

  Future<void> _saveAndContinue() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please rate your day',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: AppColors.deepPurple,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final stepService = ref.read(stepServiceProvider);
      final nutritionRepo = ref.read(nutritionRepositoryProvider);

      final steps = await stepService.getTodaySteps();
      final water = await nutritionRepo.getTodayWaterLog();

      final today = DateTime.now();
      final dateKey =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final review = DailyReview(
        dateKey: dateKey,
        rating: _rating,
        steps: steps.stepCount,
        waterMl: water.totalMl,
        moodNotes: _moodController.text.trim(),
        date: today,
        userId: '',
      );

      final repo = ref.read(dailyReviewRepositoryProvider);
      await repo.saveDailyReview(review);

      if (mounted) {
        context.push('/routine/evening');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not save: $e',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final stepsAsync = ref.watch(todayStepsProvider);
    final waterAsync = ref.watch(todayWaterLogProvider);
    final mealsAsync = ref.watch(todayMealsProvider);

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
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                shaderCallback: (bounds) =>
                    AppColors.primaryGradient.createShader(bounds),
                child: Text(
                  'How Was Your Day? 🌙',
                  style: GoogleFonts.poppins(
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
              ).animate().fadeIn(duration: 500.ms),

              const SizedBox(height: 24),

              // Day Rating
              GlassCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      'Rate your day',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (i) {
                        final star = i + 1;
                        return GestureDetector(
                          onTap: () => setState(() => _rating = star),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Icon(
                              _rating >= star
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              size: 40,
                              color: _rating >= star
                                  ? const Color(0xFFFFD700)
                                  : (isDark
                                      ? Colors.white38
                                      : AppColors.textMuted),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 100.ms)
                  .slideY(begin: 0.1, end: 0),

              const SizedBox(height: 16),

              // Steps Summary
              stepsAsync.when(
                data: (steps) => GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        'You walked ${steps.stepCount} steps today! 🎉',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : AppColors.textDark,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: CustomPaint(
                          painter: _MiniStepRingPainter(
                            progress: steps.progress.clamp(0.0, 1.0),
                            isDark: isDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 150.ms)
                    .slideY(begin: 0.1, end: 0),
                loading: () => const ShimmerCard(height: 140, borderRadius: 20),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 16),

              // Water Summary
              waterAsync.when(
                data: (w) {
                  final ml = w?.totalMl ?? 0;
                  final goal = w?.goalMl ?? 2500;
                  final pct = goal > 0 ? (ml / goal * 100).round() : 0;
                  return GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          'You drank $ml / $goal ml',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$pct% of your daily goal',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                            color: isDark ? Colors.white54 : AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: (ml / goal).clamp(0.0, 1.0),
                            minHeight: 10,
                            backgroundColor: isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : const Color(0xFF06B6D4).withValues(alpha: 0.15),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF06B6D4)),
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 200.ms)
                      .slideY(begin: 0.1, end: 0);
                },
                loading: () => const ShimmerCard(height: 100, borderRadius: 20),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 16),

              // Meals Summary
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Today's Meals",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    mealsAsync.when(
                      data: (meals) {
                        if (meals.isEmpty) {
                          return Text(
                            'No meals logged today',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                              color: isDark ? Colors.white54 : AppColors.textMuted,
                            ),
                          );
                        }
                        return GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 1,
                          children: meals.take(4).map((m) => _MealPhotoTile(meal: m, isDark: isDark)).toList(),
                        );
                      },
                      loading: () => const ShimmerCard(height: 120),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 250.ms)
                  .slideY(begin: 0.1, end: 0),

              const SizedBox(height: 16),

              // Mood Notes
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How are you feeling?',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _moodController,
                      maxLines: 3,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: isDark ? Colors.white : AppColors.textDark,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Write a few words about your day...',
                        hintStyle: GoogleFonts.poppins(
                          color: isDark ? Colors.white38 : AppColors.textMuted,
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.white.withValues(alpha: 0.3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 300.ms)
                  .slideY(begin: 0.1, end: 0),

              const SizedBox(height: 24),

              // Save & Continue
              GestureDetector(
                onTap: _isSaving ? null : _saveAndContinue,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.rosePink.withValues(alpha: 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _isSaving
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Save & Continue',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 350.ms)
                  .slideY(begin: 0.1, end: 0),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniStepRingPainter extends CustomPainter {
  final double progress;
  final bool isDark;

  _MiniStepRingPainter({required this.progress, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    const strokeWidth = 6.0;

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
  bool shouldRepaint(covariant _MiniStepRingPainter old) => old.progress != progress;
}

class _MealPhotoTile extends StatelessWidget {
  final Meal meal;
  final bool isDark;

  const _MealPhotoTile({required this.meal, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: meal.imageUrl.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: meal.imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                color: AppColors.rosePink.withValues(alpha: 0.1),
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.rosePink),
                ),
              ),
              errorWidget: (_, __, ___) => _placeholder(),
            )
          : _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.rosePink.withValues(alpha: 0.08),
      child: Center(
        child: Icon(Icons.restaurant_rounded, size: 28, color: AppColors.textMuted),
      ),
    );
  }
}
