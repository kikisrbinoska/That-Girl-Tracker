import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../models/clothing_item.dart';
import '../../models/outfit.dart';
import '../../services/wardrobe_providers.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/widgets/glass_card.dart';

class SavedOutfitsScreen extends ConsumerWidget {
  const SavedOutfitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final outfitsAsync = ref.watch(outfitsProvider);
    final clothingAsync = ref.watch(clothingItemsProvider);

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
            'My Outfits',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.textDark,
            ),
          ),
        ),
        body: outfitsAsync.when(
          data: (outfits) {
            if (outfits.isEmpty) return _buildEmpty(isDark);
            return clothingAsync.when(
              data: (allClothing) => ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                itemCount: outfits.length,
                itemBuilder: (context, index) {
                  final outfit = outfits[index];
                  final outfitItems = allClothing
                      .where((c) => outfit.items.contains(c.id))
                      .toList();
                  return _OutfitCard(
                    outfit: outfit,
                    items: outfitItems,
                    isDark: isDark,
                    onWear: () {
                      ref.read(wardrobeRepositoryProvider).updateOutfit(
                            outfit.copyWith(lastWorn: DateTime.now()),
                          );
                    },
                    onDelete: () async {
                      await ref
                          .read(wardrobeRepositoryProvider)
                          .deleteOutfit(outfit.id);
                    },
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: (80 * index).ms)
                      .slideY(begin: 0.1, end: 0);
                },
              ),
              loading: () => const Center(
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.rosePink),
              ),
              error: (_, __) => const SizedBox.shrink(),
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(
                strokeWidth: 2, color: AppColors.rosePink),
          ),
          error: (_, __) => _buildEmpty(isDark),
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
            child: const Icon(Icons.style_rounded,
                size: 48, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            'No saved outfits yet',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w300,
              color: isDark ? Colors.white54 : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _OutfitCard extends StatelessWidget {
  final Outfit outfit;
  final List<ClothingItem> items;
  final bool isDark;
  final VoidCallback onWear;
  final VoidCallback onDelete;

  const _OutfitCard({
    required this.outfit,
    required this.items,
    required this.isDark,
    required this.onWear,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    outfit.name,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.textDark,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onDelete,
                  child: const Icon(Icons.close_rounded,
                      size: 18, color: AppColors.textMuted),
                ),
              ],
            ),
            if (outfit.lastWorn != null) ...[
              const SizedBox(height: 4),
              Text(
                'Last worn: ${DateFormat('MMM d').format(outfit.lastWorn!)}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                  color: isDark ? Colors.white54 : AppColors.textMuted,
                ),
              ),
            ],
            const SizedBox(height: 12),
            // Item thumbnails
            SizedBox(
              height: 60,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final item = items[i];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 60,
                      height: 60,
                      child: item.imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: item.imageUrl,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => _thumb(),
                            )
                          : _thumb(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            // Wear today button
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                onPressed: onWear,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'Wear Today',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _thumb() {
    return Container(
      color: isDark
          ? Colors.white.withValues(alpha: 0.05)
          : AppColors.rosePink.withValues(alpha: 0.08),
      child: const Center(
        child: Icon(Icons.checkroom_rounded, size: 20, color: AppColors.textMuted),
      ),
    );
  }
}
