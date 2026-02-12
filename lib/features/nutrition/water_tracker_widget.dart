import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/water_log.dart';
import '../../services/fitness_providers.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/widgets/glass_card.dart';

class WaterTrackerWidget extends ConsumerWidget {
  final bool compact;

  const WaterTrackerWidget({super.key, this.compact = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final waterAsync = ref.watch(todayWaterLogProvider);

    return waterAsync.when(
      data: (log) {
        final waterLog = log ??
            WaterLog(date: DateTime.now(), userId: '');
        final totalMl = waterLog.totalMl;
        final goalMl = waterLog.goalMl;
        final progress = waterLog.progress;

        if (compact) {
          return _CompactWaterCard(
            totalMl: totalMl,
            goalMl: goalMl,
            progress: progress,
            isDark: isDark,
            onAdd: (amount) => _addWater(ref, amount),
          );
        }

        return _FullWaterCard(
          waterLog: waterLog,
          totalMl: totalMl,
          goalMl: goalMl,
          progress: progress,
          isDark: isDark,
          onAdd: (amount) => _addWater(ref, amount),
        );
      },
      loading: () => const SizedBox(
        height: 80,
        child: Center(
          child: CircularProgressIndicator(
              strokeWidth: 2, color: AppColors.rosePink),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  void _addWater(WidgetRef ref, int amount) {
    final repo = ref.read(nutritionRepositoryProvider);
    repo.addWaterEntry(amount);
  }
}

class _CompactWaterCard extends StatelessWidget {
  final int totalMl;
  final int goalMl;
  final double progress;
  final bool isDark;
  final void Function(int) onAdd;

  const _CompactWaterCard({
    required this.totalMl,
    required this.goalMl,
    required this.progress,
    required this.isDark,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.water_drop_rounded,
                  color: const Color(0xFF06B6D4), size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Water',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.textDark,
                  ),
                ),
              ),
              Text(
                '$totalMl / $goalMl ml',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF06B6D4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : const Color(0xFF06B6D4).withValues(alpha: 0.12),
              valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF06B6D4)),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _QuickAddButton(label: '+250ml', onTap: () => onAdd(250)),
              _QuickAddButton(label: '+500ml', onTap: () => onAdd(500)),
              _QuickAddButton(label: '+1L', onTap: () => onAdd(1000)),
            ],
          ),
        ],
      ),
    );
  }
}

class _FullWaterCard extends StatelessWidget {
  final WaterLog waterLog;
  final int totalMl;
  final int goalMl;
  final double progress;
  final bool isDark;
  final void Function(int) onAdd;

  const _FullWaterCard({
    required this.waterLog,
    required this.totalMl,
    required this.goalMl,
    required this.progress,
    required this.isDark,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Water bottle icon with fill
              SizedBox(
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.water_drop_rounded,
                      size: 80,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : const Color(0xFF06B6D4).withValues(alpha: 0.15),
                    ),
                    ShaderMask(
                      shaderCallback: (bounds) {
                        return LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            const Color(0xFF06B6D4),
                            const Color(0xFF3B82F6),
                          ],
                          stops: [progress, progress],
                        ).createShader(bounds);
                      },
                      blendMode: BlendMode.srcIn,
                      child: const Icon(
                        Icons.water_drop_rounded,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$totalMl / $goalMl ml',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${(progress * 100).round()}% of daily goal',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w300,
                  color: isDark ? Colors.white54 : AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : const Color(0xFF06B6D4).withValues(alpha: 0.12),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF06B6D4)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _QuickAddButton(
                      label: '+250ml', onTap: () => onAdd(250)),
                  _QuickAddButton(
                      label: '+500ml', onTap: () => onAdd(500)),
                  _QuickAddButton(
                      label: '+1L', onTap: () => onAdd(1000)),
                ],
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(duration: 500.ms)
            .slideY(begin: 0.1, end: 0),

        // Timeline of entries
        if (waterLog.entries.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            "Today's Log",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          ...waterLog.entries.reversed.take(10).map((entry) {
            final timeStr =
                '${entry.time.hour.toString().padLeft(2, '0')}:${entry.time.minute.toString().padLeft(2, '0')}';
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: GlassCard(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    const Icon(Icons.water_drop_rounded,
                        color: Color(0xFF06B6D4), size: 16),
                    const SizedBox(width: 10),
                    Text(
                      '${entry.amountMl} ml',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color:
                            isDark ? Colors.white : AppColors.textDark,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      timeStr,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                        color: isDark
                            ? Colors.white54
                            : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ],
    );
  }
}

class _QuickAddButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickAddButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
