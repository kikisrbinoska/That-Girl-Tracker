import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/widgets/glass_card.dart';
import 'water_tracker_widget.dart';

class NutritionScreen extends ConsumerWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                  'Nutrition \u{1F957}',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ).animate().fadeIn(duration: 500.ms),

              const SizedBox(height: 24),

              // Water tracker (full version)
              const WaterTrackerWidget(compact: false)
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 100.ms)
                  .slideY(begin: 0.1, end: 0),

              const SizedBox(height: 24),

              // Meals section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Today's Meals",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.textDark,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.push('/nutrition/meals'),
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
              )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 200.ms),

              const SizedBox(height: 12),

              // Meal quick actions
              GestureDetector(
                onTap: () => context.push('/nutrition/meals'),
                child: GlassCard(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.rosePink, AppColors.lavender],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.restaurant_rounded,
                            color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Log a Meal',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.white
                                    : AppColors.textDark,
                              ),
                            ),
                            Text(
                              'Take a photo and track your meals',
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
                      Icon(Icons.chevron_right_rounded,
                          color: isDark
                              ? Colors.white30
                              : AppColors.textMuted),
                    ],
                  ),
                ),
              )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 300.ms)
                  .slideY(begin: 0.1, end: 0),

              const SizedBox(height: 24),

              // Quick recipes placeholder
              Text(
                'Quick Recipes',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.textDark,
                ),
              )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 400.ms),
              const SizedBox(height: 12),

              GlassCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          AppColors.softGradient.createShader(bounds),
                      child: const Icon(Icons.menu_book_rounded,
                          color: Colors.white, size: 40),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Coming Soon',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Healthy recipes curated for That Girl lifestyle',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w300,
                        color: isDark ? Colors.white54 : AppColors.textMuted,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 500.ms)
                  .slideY(begin: 0.1, end: 0),
            ],
          ),
        ),
      ),
    );
  }
}
