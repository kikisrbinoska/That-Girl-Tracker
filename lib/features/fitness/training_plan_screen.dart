import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/training_plan.dart';
import '../../models/workout.dart';
import '../../services/fitness_providers.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/widgets/glass_card.dart';

class TrainingPlanScreen extends ConsumerWidget {
  const TrainingPlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final planAsync = ref.watch(trainingPlanProvider);
    final todayWeekday = DateTime.now().weekday;

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
            'Training Plan',
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
              Text(
                'Your Weekly Plan',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  color: isDark ? Colors.white70 : AppColors.textMuted,
                ),
              ).animate().fadeIn(duration: 400.ms),
              const SizedBox(height: 16),
              planAsync.when(
                data: (plans) {
                  return Column(
                    children: List.generate(7, (i) {
                      final day = i + 1;
                      final plan =
                          plans.where((p) => p.dayOfWeek == day).firstOrNull;
                      final isToday = day == todayWeekday;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: GestureDetector(
                          onTap: () => _showEditDialog(
                            context,
                            ref,
                            day,
                            plan,
                            isDark,
                          ),
                          child: _DayCard(
                            day: day,
                            plan: plan,
                            isToday: isToday,
                            isDark: isDark,
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(
                              duration: 400.ms,
                              delay: Duration(milliseconds: 50 * i))
                          .slideX(begin: 0.05, end: 0);
                    }),
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.rosePink),
                ),
                error: (_, __) => Text(
                  'Failed to load training plan',
                  style: GoogleFonts.poppins(
                      color: isDark ? Colors.white70 : AppColors.textMuted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    int day,
    TrainingPlan? existing,
    bool isDark,
  ) {
    WorkoutType selectedType = existing?.workoutType ?? WorkoutType.cardio;
    double duration = existing?.duration.toDouble() ?? 45;
    final notesController =
        TextEditingController(text: existing?.notes ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: EdgeInsets.fromLTRB(
              24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkBackground : Colors.white,
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    TrainingPlan.dayName(day),
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.textDark,
                    ),
                  ),
                  if (existing != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded,
                          color: Colors.redAccent),
                      onPressed: () async {
                        final repo = ref.read(fitnessRepositoryProvider);
                        await repo.deleteTrainingPlan(day);
                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Workout Type',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white70 : AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: WorkoutType.values.map((type) {
                  final isSelected = selectedType == type;
                  final color = Color(Workout.typeColors[type]!);
                  return GestureDetector(
                    onTap: () =>
                        setModalState(() => selectedType = type),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color
                            : color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        Workout.typeLabel(type),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isSelected ? Colors.white : color,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Duration',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white70 : AppColors.textMuted,
                    ),
                  ),
                  Text(
                    '${duration.round()} min',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.deepPurple,
                    ),
                  ),
                ],
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.deepPurple,
                  inactiveTrackColor:
                      AppColors.rosePink.withValues(alpha: 0.2),
                  thumbColor: AppColors.rosePink,
                ),
                child: Slider(
                  value: duration,
                  min: 0,
                  max: 180,
                  divisions: 36,
                  onChanged: (v) =>
                      setModalState(() => duration = v),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: notesController,
                style: GoogleFonts.poppins(
                    color: isDark ? Colors.white : AppColors.textDark),
                decoration: InputDecoration(
                  hintText: 'Notes (optional)',
                  hintStyle: GoogleFonts.poppins(
                      color: isDark ? Colors.white30 : AppColors.textMuted),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: AppColors.rosePink.withValues(alpha: 0.3)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.rosePink),
                        ),
                        child: Center(
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.rosePink,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final uid =
                            FirebaseAuth.instance.currentUser?.uid ?? '';
                        final plan = TrainingPlan(
                          dayOfWeek: day,
                          workoutType: selectedType,
                          duration: duration.round(),
                          notes: notesController.text.trim(),
                          userId: uid,
                        );
                        final repo =
                            ref.read(fitnessRepositoryProvider);
                        await repo.saveTrainingPlan(plan);
                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            'Save',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  final int day;
  final TrainingPlan? plan;
  final bool isToday;
  final bool isDark;

  const _DayCard({
    required this.day,
    this.plan,
    required this.isToday,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final isRest = plan == null || plan!.isRestDay;
    final typeColor =
        plan != null ? Color(Workout.typeColors[plan!.workoutType]!) : null;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: isToday ? AppColors.softGradient : null,
              color: isToday ? null : (isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : AppColors.rosePink.withValues(alpha: 0.08)),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                TrainingPlan.dayShort(day),
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isToday
                      ? Colors.white
                      : (isDark ? Colors.white70 : AppColors.textDark),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isRest
                      ? 'Rest Day'
                      : Workout.typeLabel(plan!.workoutType),
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.textDark,
                  ),
                ),
                if (!isRest)
                  Text(
                    '${plan!.duration} min${plan!.notes.isNotEmpty ? ' · ${plan!.notes}' : ''}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                      color: isDark ? Colors.white54 : AppColors.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          if (!isRest && typeColor != null)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                Workout.typeLabel(plan!.workoutType),
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: typeColor,
                ),
              ),
            )
          else
            Icon(
              Icons.spa_rounded,
              size: 20,
              color: isDark ? Colors.white30 : AppColors.textMuted,
            ),
          const SizedBox(width: 4),
          Icon(
            Icons.chevron_right_rounded,
            color: isDark ? Colors.white30 : AppColors.textMuted,
            size: 20,
          ),
        ],
      ),
    );
  }
}
