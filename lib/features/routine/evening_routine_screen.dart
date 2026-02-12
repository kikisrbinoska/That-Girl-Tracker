import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/routine.dart';
import '../../services/fitness_providers.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/widgets/glass_card.dart';

class EveningRoutineScreen extends ConsumerStatefulWidget {
  const EveningRoutineScreen({super.key});

  @override
  ConsumerState<EveningRoutineScreen> createState() =>
      _EveningRoutineScreenState();
}

class _EveningRoutineScreenState
    extends ConsumerState<EveningRoutineScreen> {
  bool _initialized = false;
  int _rating = 0;

  @override
  void initState() {
    super.initState();
    _initRoutine();
  }

  Future<void> _initRoutine() async {
    final repo = ref.read(routineRepositoryProvider);
    final routine = await repo.getRoutine('evening');
    if (mounted) {
      setState(() {
        _initialized = true;
        _rating = routine.dayRating ?? 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final routineAsync = ref.watch(eveningRoutineProvider);

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
                  'Evening\nWind Down \u{1F319}',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
              ).animate().fadeIn(duration: 500.ms),

              const SizedBox(height: 24),

              if (!_initialized)
                const Center(
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.rosePink),
                )
              else
                routineAsync.when(
                  data: (routine) {
                    if (routine == null) return const SizedBox.shrink();
                    return Column(
                      children: [
                        // Checklist
                        _EveningChecklist(
                          routine: routine,
                          isDark: isDark,
                          onToggle: (taskId, done) {
                            final repo =
                                ref.read(routineRepositoryProvider);
                            repo.toggleTask('evening', taskId, done);
                          },
                        ),

                        const SizedBox(height: 20),

                        // Day rating
                        _DayRatingWidget(
                          rating: _rating,
                          isDark: isDark,
                          onRate: (r) {
                            setState(() => _rating = r);
                            final repo =
                                ref.read(routineRepositoryProvider);
                            repo.saveDayRating(r);
                          },
                        )
                            .animate()
                            .fadeIn(duration: 500.ms, delay: 400.ms)
                            .slideY(begin: 0.1, end: 0),

                        const SizedBox(height: 16),

                        // Progress
                        GlassCard(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${routine.completedCount}/${routine.tasks.length} completed',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? Colors.white
                                          : AppColors.textDark,
                                    ),
                                  ),
                                  Text(
                                    '${(routine.progress * 100).round()}%',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.deepPurple,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: routine.progress,
                                  minHeight: 8,
                                  backgroundColor: isDark
                                      ? Colors.white.withValues(alpha: 0.1)
                                      : AppColors.rosePink
                                          .withValues(alpha: 0.15),
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                          AppColors.deepPurple),
                                ),
                              ),
                            ],
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 500.ms, delay: 500.ms),
                      ],
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.rosePink),
                  ),
                  error: (_, __) => const SizedBox.shrink(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EveningChecklist extends StatelessWidget {
  final Routine routine;
  final bool isDark;
  final void Function(String taskId, bool done) onToggle;

  const _EveningChecklist({
    required this.routine,
    required this.isDark,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: routine.tasks.asMap().entries.map((entry) {
          final task = entry.value;
          final index = entry.key;
          return Padding(
            padding: EdgeInsets.only(
                bottom: index < routine.tasks.length - 1 ? 12 : 0),
            child: GestureDetector(
              onTap: () => onToggle(task.id, !task.done),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      gradient: task.done ? AppColors.softGradient : null,
                      border: task.done
                          ? null
                          : Border.all(
                              color: isDark
                                  ? Colors.white30
                                  : AppColors.textMuted,
                              width: 2,
                            ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: task.done
                          ? [
                              BoxShadow(
                                color: AppColors.rosePink
                                    .withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: task.done
                        ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 18)
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      task.text,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: task.done
                            ? (isDark
                                ? Colors.white38
                                : AppColors.textMuted)
                            : (isDark
                                ? Colors.white
                                : AppColors.textDark),
                        decoration:
                            task.done ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(
                    duration: 400.ms,
                    delay: Duration(milliseconds: 50 * index))
                .slideX(begin: 0.05, end: 0),
          );
        }).toList(),
      ),
    );
  }
}

class _DayRatingWidget extends StatelessWidget {
  final int rating;
  final bool isDark;
  final void Function(int) onRate;

  const _DayRatingWidget({
    required this.rating,
    required this.isDark,
    required this.onRate,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            'Rate Your Day',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final starIndex = i + 1;
              final isSelected = starIndex <= rating;
              return GestureDetector(
                onTap: () => onRate(starIndex),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: AnimatedScale(
                    scale: isSelected ? 1.2 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      isSelected
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 36,
                      color: isSelected
                          ? const Color(0xFFF59E0B)
                          : (isDark ? Colors.white30 : AppColors.textMuted),
                    ),
                  ),
                ),
              );
            }),
          ),
          if (rating > 0) ...[
            const SizedBox(height: 8),
            Text(
              _ratingText(rating),
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: isDark ? Colors.white54 : AppColors.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _ratingText(int rating) {
    switch (rating) {
      case 1:
        return 'Rough day, but tomorrow is a new start';
      case 2:
        return 'Could have been better, keep going';
      case 3:
        return 'A decent day, nice work!';
      case 4:
        return 'Great day! You crushed it';
      case 5:
        return 'Amazing day! You\'re unstoppable';
      default:
        return '';
    }
  }
}
