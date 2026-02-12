import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/clothing_item.dart';
import '../../models/event.dart';
import '../../services/event_providers.dart';
import '../../services/fitness_providers.dart';
import '../../services/outfit_service.dart';
import '../../services/wardrobe_providers.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/widgets/glass_card.dart';

class MorningOutfitScreen extends ConsumerWidget {
  const MorningOutfitScreen({super.key});

  static const _affirmations = [
    '"What, like it\'s hard?" — You\'ve got this.',
    '"Dress like you\'re going somewhere better later."',
    '"Confidence is the best outfit. Rock it!"',
    '"Look good, feel good, do good."',
    '"Your style is your statement."',
  ];

  String _dailyAffirmation() {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
    return _affirmations[dayOfYear % _affirmations.length];
  }

  bool _hasGymToday(List<Event> events) {
    return events.any((e) => e.type == EventType.gym);
  }

  List<ClothingItem> _getGymOutfit(List<ClothingItem> wardrobe) {
    return wardrobe
        .where((item) => item.category == ClothingCategory.sport)
        .take(3)
        .toList();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final weatherAsync = ref.watch(weatherProvider);
    final todayEvents = ref.watch(todayEventsProvider);
    final wardrobeAsync = ref.watch(clothingItemsProvider);
    final trainingPlanAsync = ref.watch(trainingPlanProvider);

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
              // Title
              ShaderMask(
                shaderCallback: (bounds) =>
                    AppColors.primaryGradient.createShader(bounds),
                child: Text(
                  'What to Wear\nToday? ✨',
                  style: GoogleFonts.poppins(
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
              ).animate().fadeIn(duration: 500.ms),

              const SizedBox(height: 20),

              // Weather summary
              weatherAsync.when(
                data: (weather) => GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        _weatherIcon(weather.condition),
                        size: 32,
                        color: AppColors.deepPurple,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${weather.temperature.round()}°C · ${weather.description}',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color:
                                  isDark ? Colors.white : AppColors.textDark,
                            ),
                          ),
                          Text(
                            'Feels like ${weather.feelsLike.round()}°C',
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
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 100.ms)
                    .slideY(begin: 0.1, end: 0),
                loading: () => const SizedBox(
                  height: 60,
                  child: Center(
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.rosePink),
                  ),
                ),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 16),

              // Today's Schedule Overview
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Today's Schedule Overview",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (todayEvents.isEmpty)
                      Text(
                        'No events today — your day is wide open! ✨',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                          color: isDark ? Colors.white54 : AppColors.textMuted,
                        ),
                      )
                    else
                      ...todayEvents.take(3).map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Color(Event.typeColors[e.type]!),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        e.title,
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? Colors.white : AppColors.textDark,
                                        ),
                                      ),
                                      Text(
                                        DateFormat('h:mm a').format(e.dateTime),
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
                                    color: Color(Event.typeColors[e.type]!).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    Event.typeLabel(e.type),
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Color(Event.typeColors[e.type]!),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 200.ms)
                  .slideY(begin: 0.1, end: 0),

              const SizedBox(height: 16),

              // Gym outfit suggestion
              wardrobeAsync.when(
                data: (wardrobe) {
                  final hasGym = _hasGymToday(todayEvents);
                  final hasGymPlan = trainingPlanAsync.when(
                    data: (plans) => plans.any(
                        (p) => p.dayOfWeek == DateTime.now().weekday && !p.isRestDay),
                    loading: () => false,
                    error: (_, __) => false,
                  );

                  if (!hasGym && !hasGymPlan) {
                    return const SizedBox.shrink();
                  }

                  final gymItems = _getGymOutfit(wardrobe);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GlassCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                ShaderMask(
                                  shaderCallback: (bounds) =>
                                      AppColors.softGradient.createShader(bounds),
                                  child: const Icon(
                                      Icons.fitness_center_rounded,
                                      color: Colors.white,
                                      size: 22),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "Gym Day! Here's your workout fit \u{1F4AA}",
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? Colors.white
                                          : AppColors.textDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (gymItems.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 100,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: gymItems.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(width: 10),
                                  itemBuilder: (_, i) {
                                    final item = gymItems[i];
                                    return GlassCard(
                                      padding: EdgeInsets.zero,
                                      child: SizedBox(
                                        width: 80,
                                        child: Column(
                                          children: [
                                            Expanded(
                                              child: ClipRRect(
                                                borderRadius:
                                                    const BorderRadius.vertical(
                                                        top: Radius.circular(
                                                            20)),
                                                child: item.imageUrl
                                                        .isNotEmpty
                                                    ? CachedNetworkImage(
                                                        imageUrl:
                                                            item.imageUrl,
                                                        fit: BoxFit.cover,
                                                        width: 80,
                                                      )
                                                    : Container(
                                                        color: AppColors
                                                            .rosePink
                                                            .withValues(
                                                                alpha: 0.08),
                                                        child: const Center(
                                                          child: Icon(
                                                              Icons
                                                                  .checkroom_rounded,
                                                              size: 20,
                                                              color: AppColors
                                                                  .textMuted),
                                                        ),
                                                      ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(4),
                                              child: Text(
                                                item.name,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w500,
                                                  color: isDark
                                                      ? Colors.white
                                                      : AppColors.textDark,
                                                ),
                                                maxLines: 1,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ] else
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  'Add sport items to your wardrobe for gym outfit suggestions!',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w300,
                                    color: isDark
                                        ? Colors.white54
                                        : AppColors.textMuted,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 500.ms, delay: 250.ms)
                          .slideY(begin: 0.1, end: 0),
                      const SizedBox(height: 16),
                    ],
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              // Outfit Recommendation
              weatherAsync.when(
                data: (weather) => wardrobeAsync.when(
                  data: (wardrobe) {
                    final recommendation = OutfitService.recommendOutfitForDay(
                      weather: weather,
                      todayEvents: todayEvents,
                      wardrobe: wardrobe,
                    );
                    return _RecommendationCard(
                      recommendation: recommendation,
                      isDark: isDark,
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Add items to your wardrobe to get outfit suggestions!',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      color: isDark ? Colors.white70 : AppColors.textDark,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Browse wardrobe button
              Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: AppColors.rosePink),
                ),
                child: OutlinedButton.icon(
                  onPressed: () => context.go('/wardrobe'),
                  icon: const Icon(Icons.checkroom_rounded, size: 20),
                  label: Text(
                    'Browse Wardrobe',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.deepPurple,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 400.ms),

              const SizedBox(height: 24),

              // Motivational quote
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          AppColors.primaryGradient.createShader(bounds),
                      child: const Icon(Icons.auto_awesome_rounded,
                          color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        _dailyAffirmation(),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.italic,
                          color: isDark ? Colors.white70 : AppColors.textDark,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 450.ms)
                  .slideY(begin: 0.1, end: 0),
            ],
          ),
        ),
      ),
    );
  }

  IconData _weatherIcon(String condition) {
    final c = condition.toLowerCase();
    if (c.contains('rain')) return Icons.water_drop_rounded;
    if (c.contains('cloud')) return Icons.cloud_rounded;
    if (c.contains('snow')) return Icons.ac_unit_rounded;
    return Icons.wb_sunny_rounded;
  }
}

class _RecommendationCard extends StatelessWidget {
  final OutfitRecommendation recommendation;
  final bool isDark;

  const _RecommendationCard({
    required this.recommendation,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recommended Outfit',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        if (recommendation.items.isEmpty)
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Text(
              recommendation.reason,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w300,
                color: isDark ? Colors.white70 : AppColors.textDark,
              ),
            ),
          )
        else ...[
          // Items row
          SizedBox(
            height: 130,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: recommendation.items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                final item = recommendation.items[i];
                return GlassCard(
                  padding: EdgeInsets.zero,
                  child: SizedBox(
                    width: 100,
                    child: Column(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(20)),
                            child: item.imageUrl.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: item.imageUrl,
                                    fit: BoxFit.cover,
                                    width: 100,
                                    errorWidget: (_, __, ___) => _placeholder(),
                                  )
                                : _placeholder(),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(6),
                          child: Text(
                            item.name,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color:
                                  isDark ? Colors.white : AppColors.textDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
              .animate()
              .fadeIn(duration: 500.ms, delay: 300.ms)
              .slideX(begin: 0.1, end: 0),

          const SizedBox(height: 12),

          // Reason
          GlassCard(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                ShaderMask(
                  shaderCallback: (bounds) =>
                      AppColors.softGradient.createShader(bounds),
                  child: const Icon(Icons.auto_awesome_rounded,
                      color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    recommendation.reason,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w300,
                      color: isDark ? Colors.white70 : AppColors.textDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 300.ms)
        .slideY(begin: 0.1, end: 0);
  }

  Widget _placeholder() {
    return Container(
      color: isDark
          ? Colors.white.withValues(alpha: 0.05)
          : AppColors.rosePink.withValues(alpha: 0.08),
      child: const Center(
        child: Icon(Icons.checkroom_rounded, size: 24, color: AppColors.textMuted),
      ),
    );
  }
}
