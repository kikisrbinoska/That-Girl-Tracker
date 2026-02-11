import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../../models/wishlist_item.dart';
import '../../services/wardrobe_providers.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/widgets/glass_card.dart';

class WishlistScreen extends ConsumerStatefulWidget {
  const WishlistScreen({super.key});

  @override
  ConsumerState<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends ConsumerState<WishlistScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final wishlistAsync = ref.watch(wishlistProvider);

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
            'Wishlist',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.textDark,
            ),
          ),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.deepPurple,
            indicatorWeight: 3,
            labelColor: isDark ? Colors.white : AppColors.textDark,
            unselectedLabelColor: AppColors.textMuted,
            labelStyle: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            tabs: const [
              Tab(text: 'Wishlist'),
              Tab(text: 'Purchased'),
            ],
          ),
        ),
        body: wishlistAsync.when(
          data: (items) {
            final wishlist = items.where((i) => !i.isPurchased).toList();
            final purchased = items.where((i) => i.isPurchased).toList();
            return TabBarView(
              controller: _tabController,
              children: [
                _buildList(wishlist, isDark, isPurchasedTab: false),
                _buildList(purchased, isDark, isPurchasedTab: true),
              ],
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(
                strokeWidth: 2, color: AppColors.rosePink),
          ),
          error: (_, __) => const SizedBox.shrink(),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 0),
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
              onPressed: () => _showAddDialog(context, isDark),
              backgroundColor: Colors.transparent,
              elevation: 0,
              hoverElevation: 0,
              focusElevation: 0,
              highlightElevation: 0,
              child: const Icon(Icons.add_rounded,
                  color: Colors.white, size: 28),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildList(
    List<WishlistItem> items,
    bool isDark, {
    required bool isPurchasedTab,
  }) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ShaderMask(
              shaderCallback: (bounds) =>
                  AppColors.softGradient.createShader(bounds),
              child: Icon(
                isPurchasedTab
                    ? Icons.shopping_bag_rounded
                    : Icons.favorite_border_rounded,
                size: 48,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isPurchasedTab ? 'No purchases yet' : 'Your wishlist is empty',
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

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: item.imageUrl.isNotEmpty
                        ? Image.network(item.imageUrl, fit: BoxFit.cover)
                        : Container(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.05)
                                : AppColors.rosePink.withValues(alpha: 0.08),
                            child: const Icon(Icons.shopping_bag_outlined,
                                color: AppColors.textMuted),
                          ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : AppColors.textDark,
                        ),
                      ),
                      if (item.brand.isNotEmpty)
                        Text(
                          item.brand,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w300,
                            color:
                                isDark ? Colors.white54 : AppColors.textMuted,
                          ),
                        ),
                      if (item.price != null)
                        Text(
                          '\$${item.price!.toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.deepPurple,
                          ),
                        ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        ref.read(wardrobeRepositoryProvider).updateWishlistItem(
                              item.copyWith(isPurchased: !item.isPurchased),
                            );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: item.isPurchased
                              ? const Color(0xFF10B981).withValues(alpha: 0.15)
                              : AppColors.deepPurple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          item.isPurchased
                              ? Icons.check_circle_rounded
                              : Icons.shopping_cart_outlined,
                          size: 20,
                          color: item.isPurchased
                              ? const Color(0xFF10B981)
                              : AppColors.deepPurple,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () => ref
                          .read(wardrobeRepositoryProvider)
                          .deleteWishlistItem(item.id),
                      child: const Icon(Icons.close_rounded,
                          size: 16, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ],
            ),
          ),
        )
            .animate()
            .fadeIn(duration: 400.ms, delay: (80 * index).ms)
            .slideY(begin: 0.1, end: 0);
      },
    );
  }

  void _showAddDialog(BuildContext context, bool isDark) {
    final nameController = TextEditingController();
    final brandController = TextEditingController();
    final priceController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Add to Wishlist',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.textDark,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              style: GoogleFonts.poppins(
                  color: isDark ? Colors.white : AppColors.textDark),
              decoration: InputDecoration(
                hintText: 'Item name *',
                hintStyle:
                    GoogleFonts.poppins(color: AppColors.textMuted),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: brandController,
              style: GoogleFonts.poppins(
                  color: isDark ? Colors.white : AppColors.textDark),
              decoration: InputDecoration(
                hintText: 'Brand (optional)',
                hintStyle:
                    GoogleFonts.poppins(color: AppColors.textMuted),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              style: GoogleFonts.poppins(
                  color: isDark ? Colors.white : AppColors.textDark),
              decoration: InputDecoration(
                hintText: 'Price (optional)',
                hintStyle:
                    GoogleFonts.poppins(color: AppColors.textMuted),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: const LinearGradient(
                  colors: [AppColors.deepPurple, Color(0xFF9F67FF)],
                ),
              ),
              child: ElevatedButton(
                onPressed: () {
                  if (nameController.text.trim().isEmpty) return;
                  final userId = FirebaseAuth.instance.currentUser?.uid;
                  if (userId == null) return;

                  final item = WishlistItem(
                    id: const Uuid().v4(),
                    name: nameController.text.trim(),
                    brand: brandController.text.trim(),
                    price: double.tryParse(priceController.text),
                    userId: userId,
                    createdAt: DateTime.now(),
                  );
                  ref
                      .read(wardrobeRepositoryProvider)
                      .createWishlistItem(item);
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Add Item',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
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
}
