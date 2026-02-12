import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart' show ImagePicker, ImageSource;
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/meal.dart';
import '../../services/fitness_providers.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/widgets/glass_card.dart';

class MealLoggerScreen extends ConsumerWidget {
  const MealLoggerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mealsAsync = ref.watch(todayMealsProvider);

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
            "Today's Meals",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.textDark,
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddMealSheet(context, ref, isDark),
          backgroundColor: AppColors.deepPurple,
          child: const Icon(Icons.add_rounded, color: Colors.white),
        ),
        body: mealsAsync.when(
          data: (meals) {
            if (meals.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          AppColors.softGradient.createShader(bounds),
                      child: const Icon(Icons.restaurant_rounded,
                          color: Colors.white, size: 64),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No meals logged yet today',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: isDark ? Colors.white70 : AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap + to add your first meal',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w300,
                        color: isDark ? Colors.white54 : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 500.ms);
            }

            return GridView.builder(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: meals.length,
              itemBuilder: (context, index) {
                final meal = meals[index];
                return _MealCard(meal: meal, isDark: isDark)
                    .animate()
                    .fadeIn(
                        duration: 400.ms,
                        delay: Duration(milliseconds: 50 * index))
                    .slideY(begin: 0.1, end: 0);
              },
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(
                strokeWidth: 2, color: AppColors.rosePink),
          ),
          error: (_, __) => Center(
            child: Text(
              'Failed to load meals',
              style: GoogleFonts.poppins(
                  color: isDark ? Colors.white70 : AppColors.textMuted),
            ),
          ),
        ),
      ),
    );
  }

  void _showAddMealSheet(
      BuildContext context, WidgetRef ref, bool isDark) {
    final nameController = TextEditingController();
    final notesController = TextEditingController();
    MealType selectedType = MealType.breakfast;
    Uint8List? imageBytes;
    TimeOfDay selectedTime = TimeOfDay.now();
    bool saving = false;

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
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Meal',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 16),

                // Image picker
                GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final source = await showDialog<ImageSource>(
                      context: ctx,
                      builder: (dCtx) => AlertDialog(
                        title: Text('Choose source',
                            style: GoogleFonts.poppins()),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(dCtx, ImageSource.camera),
                            child: const Text('Camera'),
                          ),
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(dCtx, ImageSource.gallery),
                            child: const Text('Gallery'),
                          ),
                        ],
                      ),
                    );
                    if (source != null) {
                      final img = await picker.pickImage(
                        source: source,
                        maxWidth: 800,
                        imageQuality: 80,
                      );
                      if (img != null) {
                        final bytes = await img.readAsBytes();
                        setModalState(() {
                          imageBytes = bytes;
                        });
                      }
                    }
                  },
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : AppColors.rosePink.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.rosePink.withValues(alpha: 0.3),
                      ),
                    ),
                    child: imageBytes != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.memory(
                              imageBytes!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 120,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt_rounded,
                                  color: AppColors.rosePink, size: 32),
                              const SizedBox(height: 8),
                              Text(
                                'Add Photo',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: AppColors.rosePink,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // Name
                TextField(
                  controller: nameController,
                  style: GoogleFonts.poppins(
                      color: isDark ? Colors.white : AppColors.textDark),
                  decoration: InputDecoration(
                    labelText: 'Meal Name',
                    labelStyle: GoogleFonts.poppins(
                        color:
                            isDark ? Colors.white54 : AppColors.textMuted),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Meal type chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: MealType.values.map((type) {
                    final isSelected = selectedType == type;
                    final color = Color(Meal.typeColors[type]!);
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
                          Meal.typeLabel(type),
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
                const SizedBox(height: 12),

                // Time picker
                GestureDetector(
                  onTap: () async {
                    final t = await showTimePicker(
                      context: ctx,
                      initialTime: selectedTime,
                    );
                    if (t != null) {
                      setModalState(() => selectedTime = t);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.rosePink.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.schedule_rounded,
                            color: AppColors.deepPurple, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          selectedTime.format(ctx),
                          style: GoogleFonts.poppins(
                            color: isDark
                                ? Colors.white
                                : AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Notes
                TextField(
                  controller: notesController,
                  maxLines: 2,
                  style: GoogleFonts.poppins(
                      color: isDark ? Colors.white : AppColors.textDark),
                  decoration: InputDecoration(
                    labelText: 'Notes (optional)',
                    labelStyle: GoogleFonts.poppins(
                        color:
                            isDark ? Colors.white54 : AppColors.textMuted),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Save button
                GestureDetector(
                  onTap: saving
                      ? null
                      : () async {
                          if (nameController.text.trim().isEmpty) return;
                          setModalState(() => saving = true);

                          final uid =
                              FirebaseAuth.instance.currentUser?.uid ??
                                  '';
                          final mealId = const Uuid().v4();
                          final repo =
                              ref.read(nutritionRepositoryProvider);

                          String imageUrl = '';
                          if (imageBytes != null) {
                            imageUrl = await repo.uploadMealImageBytes(
                                mealId, imageBytes!);
                          }

                          final now = DateTime.now();
                          final meal = Meal(
                            id: mealId,
                            name: nameController.text.trim(),
                            mealType: selectedType,
                            imageUrl: imageUrl,
                            time: DateTime(
                              now.year,
                              now.month,
                              now.day,
                              selectedTime.hour,
                              selectedTime.minute,
                            ),
                            notes: notesController.text.trim(),
                            userId: uid,
                          );

                          await repo.createMeal(meal);
                          if (ctx.mounted) Navigator.pop(ctx);
                        },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: saving
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : Text(
                              'Save Meal',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  final Meal meal;
  final bool isDark;

  const _MealCard({required this.meal, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final typeColor = Color(Meal.typeColors[meal.mealType]!);

    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              child: meal.imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: meal.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorWidget: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.name,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.textDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    Meal.typeLabel(meal.mealType),
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: typeColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: isDark
          ? Colors.white.withValues(alpha: 0.05)
          : AppColors.rosePink.withValues(alpha: 0.08),
      child: const Center(
        child: Icon(Icons.restaurant_rounded,
            size: 32, color: AppColors.textMuted),
      ),
    );
  }
}
