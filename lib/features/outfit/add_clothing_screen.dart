import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../models/clothing_item.dart';
import '../../services/wardrobe_providers.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/widgets/glass_card.dart';

class AddClothingScreen extends ConsumerStatefulWidget {
  final ClothingItem? existingItem;

  const AddClothingScreen({super.key, this.existingItem});

  @override
  ConsumerState<AddClothingScreen> createState() => _AddClothingScreenState();
}

class _AddClothingScreenState extends ConsumerState<AddClothingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _tagsController = TextEditingController();

  late ClothingCategory _category;
  late Season _season;
  String _selectedColor = 'Black';
  Uint8List? _imageBytes;
  String _existingImageUrl = '';
  bool _isSaving = false;

  bool get _isEditing => widget.existingItem != null;

  static const _colorOptions = [
    'Black', 'White', 'Gray', 'Navy', 'Blue', 'Red', 'Pink',
    'Purple', 'Green', 'Yellow', 'Orange', 'Brown', 'Beige', 'Cream',
  ];

  static const Map<String, int> _colorValues = {
    'Black': 0xFF1F2937, 'White': 0xFFFFFFFF, 'Gray': 0xFF9CA3AF,
    'Navy': 0xFF1E3A5F, 'Blue': 0xFF3B82F6, 'Red': 0xFFEF4444,
    'Pink': 0xFFF4A7B9, 'Purple': 0xFF8B5CF6, 'Green': 0xFF10B981,
    'Yellow': 0xFFF59E0B, 'Orange': 0xFFF97316, 'Brown': 0xFF92400E,
    'Beige': 0xFFD2B48C, 'Cream': 0xFFFFFDD0,
  };

  @override
  void initState() {
    super.initState();
    final item = widget.existingItem;
    if (item != null) {
      _nameController.text = item.name;
      _tagsController.text = item.tags.join(', ');
      _category = item.category;
      _season = item.season;
      _selectedColor = item.color.isNotEmpty ? item.color : 'Black';
      _existingImageUrl = item.imageUrl;
    } else {
      _category = ClothingCategory.casual;
      _season = Season.allSeasons;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded,
                    color: AppColors.deepPurple),
                title: Text('Camera', style: GoogleFonts.poppins()),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded,
                    color: AppColors.deepPurple),
                title: Text('Gallery', style: GoogleFonts.poppins()),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;
    final picked = await picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 75,
    );
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() => _imageBytes = bytes);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      if (mounted) context.pop();
      return;
    }

    final repo = ref.read(wardrobeRepositoryProvider);
    final tags = _tagsController.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    String imageUrl = _existingImageUrl;

    if (_imageBytes != null) {
      final itemId =
          _isEditing ? widget.existingItem!.id : const Uuid().v4();
      imageUrl = await repo.uploadImage(itemId, _imageBytes!);
    }

    if (_isEditing) {
      final updated = widget.existingItem!.copyWith(
        name: _nameController.text.trim(),
        category: _category,
        color: _selectedColor,
        season: _season,
        imageUrl: imageUrl,
        tags: tags,
      );
      await repo.updateClothingItem(updated);
    } else {
      final item = ClothingItem(
        id: const Uuid().v4(),
        name: _nameController.text.trim(),
        category: _category,
        color: _selectedColor,
        season: _season,
        imageUrl: imageUrl,
        tags: tags,
        userId: userId,
        createdAt: DateTime.now(),
      );
      await repo.createClothingItem(item);
    }

    if (mounted) context.pop();
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Item',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text('Remove this from your wardrobe?',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w300)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: GoogleFonts.poppins(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete',
                style: GoogleFonts.poppins(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref
        .read(wardrobeRepositoryProvider)
        .deleteClothingItem(widget.existingItem!.id);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
            _isEditing ? 'Edit Item' : 'Add to Wardrobe',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.textDark,
            ),
          ),
          actions: _isEditing
              ? [
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded,
                        color: Colors.redAccent),
                    onPressed: _delete,
                  ),
                ]
              : null,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image picker
                GestureDetector(
                  onTap: _pickImage,
                  child: GlassCard(
                    padding: EdgeInsets.zero,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: SizedBox(
                        height: 200,
                        child: _imageBytes != null
                            ? Image.memory(_imageBytes!, fit: BoxFit.cover)
                            : _existingImageUrl.isNotEmpty
                                ? Image.network(_existingImageUrl,
                                    fit: BoxFit.cover)
                                : Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_a_photo_rounded,
                                          size: 40,
                                          color: isDark
                                              ? Colors.white38
                                              : AppColors.textMuted,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Add Photo',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: isDark
                                                ? Colors.white38
                                                : AppColors.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Name
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: TextFormField(
                    controller: _nameController,
                    style: GoogleFonts.poppins(
                      color: isDark ? Colors.white : AppColors.textDark,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Item name',
                      hintStyle: GoogleFonts.poppins(
                        color: isDark ? Colors.white38 : AppColors.textMuted,
                        fontWeight: FontWeight.w300,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Enter a name' : null,
                  ),
                ),

                const SizedBox(height: 16),

                // Category
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Category',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color:
                                isDark ? Colors.white70 : AppColors.textMuted,
                          )),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: ClothingCategory.values.map((cat) {
                          final isSelected = _category == cat;
                          final catColor =
                              Color(ClothingItem.categoryColors[cat]!);
                          return GestureDetector(
                            onTap: () => setState(() => _category = cat),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? catColor
                                    : catColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                ClothingItem.categoryLabel(cat),
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      isSelected ? Colors.white : catColor,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Color
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Color',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color:
                                isDark ? Colors.white70 : AppColors.textMuted,
                          )),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 44,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _colorOptions.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 10),
                          itemBuilder: (_, i) {
                            final name = _colorOptions[i];
                            final isSelected = _selectedColor == name;
                            final colorVal = Color(_colorValues[name]!);
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedColor = name),
                              child: Column(
                                children: [
                                  AnimatedContainer(
                                    duration:
                                        const Duration(milliseconds: 200),
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: colorVal,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.deepPurple
                                            : Colors.grey.withValues(alpha: 0.3),
                                        width: isSelected ? 3 : 1,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    name,
                                    style: GoogleFonts.poppins(
                                      fontSize: 9,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w300,
                                      color: isDark
                                          ? Colors.white70
                                          : AppColors.textDark,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Season
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Season',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color:
                                isDark ? Colors.white70 : AppColors.textMuted,
                          )),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: Season.values.map((s) {
                          final isSelected = _season == s;
                          return GestureDetector(
                            onTap: () => setState(() => _season = s),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                gradient:
                                    isSelected ? AppColors.softGradient : null,
                                color: isSelected
                                    ? null
                                    : (isDark
                                        ? Colors.white.withValues(alpha: 0.08)
                                        : Colors.white.withValues(alpha: 0.5)),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.transparent
                                      : AppColors.rosePink
                                          .withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                ClothingItem.seasonLabel(s),
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark
                                          ? Colors.white70
                                          : AppColors.textDark),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Tags
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: TextFormField(
                    controller: _tagsController,
                    style: GoogleFonts.poppins(
                      color: isDark ? Colors.white : AppColors.textDark,
                      fontWeight: FontWeight.w300,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Tags (comma separated: casual, date, office)',
                      hintStyle: GoogleFonts.poppins(
                        color: isDark ? Colors.white38 : AppColors.textMuted,
                        fontWeight: FontWeight.w300,
                        fontSize: 13,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Save
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: const LinearGradient(
                      colors: [AppColors.deepPurple, Color(0xFF9F67FF)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.deepPurple.withValues(alpha: 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.white))
                        : Text(
                            _isEditing ? 'Update Item' : 'Add to Wardrobe',
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
        ),
      ),
    );
  }
}
