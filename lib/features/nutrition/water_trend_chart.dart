import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/water_log.dart';
import '../../services/fitness_providers.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/shimmer_loading.dart';

class WaterTrendChart extends ConsumerWidget {
  const WaterTrendChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final weeklyWater = ref.watch(weeklyWaterProvider);

    return weeklyWater.when(
      data: (logs) => _buildChart(logs, isDark),
      loading: () => const ShimmerCard(height: 200),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  static const _cyanToBlueGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
  );

  Widget _buildChart(List<WaterLog> logs, bool isDark) {
    if (logs.isEmpty) return const SizedBox.shrink();

    const maxY = 3000.0; // Y-axis 0-3000 ml

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShaderMask(
                shaderCallback: (bounds) =>
                    AppColors.softGradient.createShader(bounds),
                child: const Icon(Icons.water_drop_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 8),
              Text(
                '7-Day Water Trend',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 500,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : AppColors.rosePink.withValues(alpha: 0.1),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      interval: 500,
                      getTitlesWidget: (value, _) => Text(
                        '${(value / 1000).toStringAsFixed(1)}L',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: isDark ? Colors.white38 : AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= logs.length) return const SizedBox.shrink();
                        return Text(
                          DateFormat('E').format(logs[idx].date).substring(0, 2),
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color:
                                isDark ? Colors.white38 : AppColors.textMuted,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minY: 0,
                maxY: maxY,
                lineBarsData: [
                  // Goal line
                  LineChartBarData(
                    spots: List.generate(
                        logs.length, (i) => FlSpot(i.toDouble(), 2500)),
                    isCurved: false,
                    color: AppColors.textMuted.withValues(alpha: 0.3),
                    dotData: const FlDotData(show: false),
                    barWidth: 1,
                    dashArray: [5, 5],
                  ),
                  // Actual water line (cyan to blue gradient)
                  LineChartBarData(
                    spots: logs
                        .asMap()
                        .entries
                        .map((e) =>
                            FlSpot(e.key.toDouble(), e.value.totalMl.toDouble()))
                        .toList(),
                    isCurved: true,
                    gradient: _cyanToBlueGradient,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) =>
                          FlDotCirclePainter(
                        radius: 4,
                        color: const Color(0xFF3B82F6),
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF06B6D4).withValues(alpha: 0.3),
                          const Color(0xFF06B6D4).withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
