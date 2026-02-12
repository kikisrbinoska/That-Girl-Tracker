import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/routine.dart';
import '../../services/fitness_providers.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/widgets/glass_card.dart';

class MorningRoutineScreen extends ConsumerStatefulWidget {
  const MorningRoutineScreen({super.key});

  @override
  ConsumerState<MorningRoutineScreen> createState() =>
      _MorningRoutineScreenState();
}

class _MorningRoutineScreenState
    extends ConsumerState<MorningRoutineScreen> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initRoutine();
  }

  Future<void> _initRoutine() async {
    final repo = ref.read(routineRepositoryProvider);
    await repo.getRoutine('morning');
    if (mounted) setState(() => _initialized = true);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final routineAsync = ref.watch(morningRoutineProvider);

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
                  'Good Morning\nRoutine \u{2600}\u{FE0F}',
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
                    return _RoutineChecklist(
                      routine: routine,
                      isDark: isDark,
                      onToggle: (taskId, done) {
                        final repo =
                            ref.read(routineRepositoryProvider);
                        repo.toggleTask('morning', taskId, done);
                      },
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

class _RoutineChecklist extends StatelessWidget {
  final Routine routine;
  final bool isDark;
  final void Function(String taskId, bool done) onToggle;

  const _RoutineChecklist({
    required this.routine,
    required this.isDark,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GlassCard(
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
                          gradient: task.done
                              ? AppColors.softGradient
                              : null,
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
                            decoration: task.done
                                ? TextDecoration.lineThrough
                                : null,
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
        ),

        const SizedBox(height: 16),

        // Progress bar
        GlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${routine.completedCount}/${routine.tasks.length} completed',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : AppColors.textDark,
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
                      : AppColors.rosePink.withValues(alpha: 0.15),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.deepPurple),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 500.ms, delay: 300.ms),

        const SizedBox(height: 16),

        // Start Your Day button
        if (routine.allDone)
          GestureDetector(
            onTap: () => context.go('/home'),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.rosePink.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'Start Your Day \u{2728}',
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
              .fadeIn(duration: 500.ms)
              .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),
      ],
    );
  }
}
