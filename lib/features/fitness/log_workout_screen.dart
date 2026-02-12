import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/workout.dart';
import '../../services/fitness_providers.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/widgets/glass_card.dart';

class LogWorkoutScreen extends ConsumerStatefulWidget {
  const LogWorkoutScreen({super.key});

  @override
  ConsumerState<LogWorkoutScreen> createState() => _LogWorkoutScreenState();
}

class _LogWorkoutScreenState extends ConsumerState<LogWorkoutScreen> {
  WorkoutType _selectedType = WorkoutType.cardio;
  double _duration = 30;
  final _caloriesController = TextEditingController();
  final _setsController = TextEditingController();
  final _repsController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _saving = false;

  bool get _isStrength =>
      _selectedType == WorkoutType.legs ||
      _selectedType == WorkoutType.upper;

  @override
  void dispose() {
    _caloriesController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final workout = Workout(
      id: const Uuid().v4(),
      type: _selectedType,
      duration: _duration.round(),
      caloriesBurned: int.tryParse(_caloriesController.text) ??
          (_duration * 7).round(),
      sets: _isStrength ? int.tryParse(_setsController.text) : null,
      reps: _isStrength ? int.tryParse(_repsController.text) : null,
      notes: _notesController.text.trim(),
      date: _selectedDate,
      userId: uid,
    );

    final repo = ref.read(fitnessRepositoryProvider);
    await repo.createWorkout(workout);
    if (mounted) {
      context.pop();
    }
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
            'Log Workout',
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
              // Workout type chips
              Text(
                'Workout Type',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.textDark,
                ),
              ).animate().fadeIn(duration: 400.ms),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: WorkoutType.values.map((type) {
                  final isSelected = _selectedType == type;
                  final color = Color(Workout.typeColors[type]!);
                  return GestureDetector(
                    onTap: () => setState(() => _selectedType = type),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color
                            : color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? color
                              : color.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        Workout.typeLabel(type),
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected ? Colors.white : color,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

              const SizedBox(height: 24),

              // Duration slider
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Duration',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : AppColors.textDark,
                          ),
                        ),
                        Text(
                          '${_duration.round()} min',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.deepPurple,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColors.deepPurple,
                        inactiveTrackColor:
                            AppColors.rosePink.withValues(alpha: 0.2),
                        thumbColor: AppColors.rosePink,
                        overlayColor:
                            AppColors.rosePink.withValues(alpha: 0.2),
                      ),
                      child: Slider(
                        value: _duration,
                        min: 5,
                        max: 180,
                        divisions: 35,
                        onChanged: (v) => setState(() => _duration = v),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

              const SizedBox(height: 16),

              // Calories
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: TextField(
                  controller: _caloriesController,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.poppins(
                    color: isDark ? Colors.white : AppColors.textDark,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Calories Burned',
                    labelStyle: GoogleFonts.poppins(
                      color: isDark ? Colors.white54 : AppColors.textMuted,
                    ),
                    hintText: 'Leave empty for estimate',
                    hintStyle: GoogleFonts.poppins(
                      color: isDark ? Colors.white30 : AppColors.textMuted,
                      fontSize: 13,
                    ),
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.local_fire_department_rounded,
                        color: AppColors.deepPurple),
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 250.ms),

              // Sets/Reps (only for strength)
              if (_isStrength) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: GlassCard(
                        padding: const EdgeInsets.all(16),
                        child: TextField(
                          controller: _setsController,
                          keyboardType: TextInputType.number,
                          style: GoogleFonts.poppins(
                            color:
                                isDark ? Colors.white : AppColors.textDark,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Sets',
                            labelStyle: GoogleFonts.poppins(
                              color: isDark
                                  ? Colors.white54
                                  : AppColors.textMuted,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GlassCard(
                        padding: const EdgeInsets.all(16),
                        child: TextField(
                          controller: _repsController,
                          keyboardType: TextInputType.number,
                          style: GoogleFonts.poppins(
                            color:
                                isDark ? Colors.white : AppColors.textDark,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Reps',
                            labelStyle: GoogleFonts.poppins(
                              color: isDark
                                  ? Colors.white54
                                  : AppColors.textMuted,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
              ],

              const SizedBox(height: 16),

              // Notes
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: TextField(
                  controller: _notesController,
                  maxLines: 3,
                  style: GoogleFonts.poppins(
                    color: isDark ? Colors.white : AppColors.textDark,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Notes',
                    labelStyle: GoogleFonts.poppins(
                      color: isDark ? Colors.white54 : AppColors.textMuted,
                    ),
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.notes_rounded,
                        color: AppColors.deepPurple),
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 350.ms),

              const SizedBox(height: 16),

              // Date/time picker
              GestureDetector(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now().subtract(
                        const Duration(days: 30)),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime:
                          TimeOfDay.fromDateTime(_selectedDate),
                    );
                    if (time != null) {
                      setState(() {
                        _selectedDate = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          time.hour,
                          time.minute,
                        );
                      });
                    }
                  }
                },
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.schedule_rounded,
                          color: AppColors.deepPurple),
                      const SizedBox(width: 12),
                      Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year} '
                        '${_selectedDate.hour.toString().padLeft(2, '0')}:'
                        '${_selectedDate.minute.toString().padLeft(2, '0')}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color:
                              isDark ? Colors.white : AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 400.ms),

              const SizedBox(height: 24),

              // Save button
              GestureDetector(
                onTap: _saving ? null : _save,
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
                    child: _saving
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Save Workout',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 450.ms),
            ],
          ),
        ),
      ),
    );
  }
}
