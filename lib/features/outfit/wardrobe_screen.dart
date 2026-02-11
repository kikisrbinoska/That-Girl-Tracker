import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/clothing_item.dart';
import '../../services/wardrobe_providers.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/widgets/glass_card.dart';

class WardrobeScreen extends ConsumerWidget {
  const WardrobeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filteredItems = ref.watch(filteredClothingProvider);
    final activeFilter = ref.watch(clothingCategoryFilterProvider);

    return Container(
      decoration: BoxDecoration(
        gradient: isDark
            ? AppColors.darkBackgroundGradient
            : AppColors.backgroundGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Wardrobe',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppColors.textDark,
                      ),
                    ),
                    Row(
                      children: [
                        _HeaderButton(
                          icon: Icons.style_rounded,
                          label: 'Outfits',
                          onTap: () => context.push('/wardrobe/outfits'),
                          isDark: isDark,
                        ),
                        const SizedBox(width: 8),
                        _HeaderButton(
                          icon: Icons.favorite_border_rounded,
                          label: 'Wishlist',
                          onTap: () => context.push('/wardrobe/wishlist'),
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms),

              const SizedBox(height: 12),

              // Filter chips
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _FilterChip(
                      label: 'All',
                      isSelected: activeFilter == null,
                      onTap: () => ref
                          .read(clothingCategoryFilterProvider.notifier)
                          .state = null,
                      isDark: isDark,
                    ),
                    ...ClothingCategory.values.map((cat) => _FilterChip(
                          label: ClothingItem.categoryLabel(cat),
                          isSelected: activeFilter == cat,
                          color: Color(ClothingItem.categoryColors[cat]!),
                          onTap: () => ref
                              .read(clothingCategoryFilterProvider.notifier)
                              .state = cat,
                          isDark: isDark,
                        )),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

              const SizedBox(height: 12),

              // Grid
              Expanded(
                child: filteredItems.isEmpty
                    ? _buildEmpty(isDark)
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          return _ClothingCard(
                            item: filteredItems[index],
                            isDark: isDark,
                            onTap: () => context.push(
                              '/wardrobe/edit/${filteredItems[index].id}',
                              extra: filteredItems[index],
                            ),
                            onFavorite: () {
                              final item = filteredItems[index];
                              ref
                                  .read(wardrobeRepositoryProvider)
                                  .updateClothingItem(
                                    item.copyWith(
                                        isFavorite: !item.isFavorite),
                                  );
                            },
                          )
                              .animate()
                              .fadeIn(
                                duration: 400.ms,
                                delay: (80 * index).ms,
                              )
                              .slideY(begin: 0.1, end: 0);
                        },
                      ),
              ),
            ],
          ),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 60),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.deepPurple.withValues(alpha: 0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: FloatingActionButton(
              onPressed: () => context.push('/wardrobe/add'),
              backgroundColor: Colors.transparent,
              elevation: 0,
              hoverElevation: 0,
              focusElevation: 0,
              highlightElevation: 0,
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
            ),
          )
              .animate()
              .scale(
                begin: const Offset(0, 0),
                end: const Offset(1, 1),
                duration: 400.ms,
                delay: 400.ms,
                curve: Curves.elasticOut,
              ),
        ),
      ),
    );
  }

  Widget _buildEmpty(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ShaderMask(
            shaderCallback: (bounds) =>
                AppColors.softGradient.createShader(bounds),
            child: const Icon(Icons.checkroom_rounded, size: 48,
                color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            'Your wardrobe is empty',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w300,
              color: isDark ? Colors.white54 : AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap + to add your first item ✨',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w300,
              color: isDark ? Colors.white38 : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDark;

  const _HeaderButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.white.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.rosePink.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.deepPurple),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
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

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? color;
  final VoidCallback onTap;
  final bool isDark;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    this.color,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: isSelected
                ? (color != null
                    ? LinearGradient(colors: [
                        color!,
                        color!.withValues(alpha: 0.7),
                      ])
                    : AppColors.softGradient)
                : null,
            color: isSelected
                ? null
                : (isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.white.withValues(alpha: 0.5)),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.15)
                      : AppColors.rosePink.withValues(alpha: 0.3)),
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.white70 : AppColors.textDark),
            ),
          ),
        ),
      ),
    );
  }
}

class _ClothingCard extends StatelessWidget {
  final ClothingItem item;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onFavorite;

  const _ClothingCard({
    required this.item,
    required this.isDark,
    required this.onTap,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final catColor = Color(ClothingItem.categoryColors[item.category]!);

    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: item.imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: item.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : AppColors.rosePink.withValues(alpha: 0.1),
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.rosePink,
                            ),
                          ),
                        ),
                        errorWidget: (_, __, ___) => _placeholder(),
                      )
                    : _placeholder(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : AppColors.textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: catColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            ClothingItem.categoryLabel(item.category),
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: catColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: onFavorite,
                    child: Icon(
                      item.isFavorite
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: item.isFavorite
                          ? AppColors.rosePink
                          : AppColors.textMuted,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: isDark
          ? Colors.white.withValues(alpha: 0.05)
          : AppColors.rosePink.withValues(alpha: 0.08),
      child: Center(
        child: Icon(
          Icons.checkroom_rounded,
          size: 36,
          color: isDark ? Colors.white24 : AppColors.textMuted.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}
