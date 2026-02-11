import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../models/event.dart';
import '../../services/event_providers.dart';
import '../../services/notification_service.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/widgets/glass_card.dart';

class AddEventScreen extends ConsumerStatefulWidget {
  final Event? existingEvent;

  const AddEventScreen({super.key, this.existingEvent});

  @override
  ConsumerState<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends ConsumerState<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();

  late EventType _selectedType;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late bool _isRecurring;
  late RecurringType _recurringType;
  late bool _notificationEnabled;

  bool get _isEditing => widget.existingEvent != null;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final event = widget.existingEvent;
    if (event != null) {
      _titleController.text = event.title;
      _notesController.text = event.notes;
      _selectedType = event.type;
      _selectedDate = event.dateTime;
      _selectedTime = TimeOfDay.fromDateTime(event.dateTime);
      _isRecurring = event.isRecurring;
      _recurringType = event.recurringType;
      _notificationEnabled = event.notificationEnabled;
    } else {
      _selectedType = EventType.personal;
      _selectedDate = DateTime.now();
      _selectedTime = TimeOfDay.now();
      _isRecurring = false;
      _recurringType = RecurringType.none;
      _notificationEnabled = true;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: AppColors.deepPurple,
              ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: AppColors.deepPurple,
              ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      if (mounted) context.pop();
      return;
    }

    final dateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final repo = ref.read(eventRepositoryProvider);

    if (_isEditing) {
      final updated = widget.existingEvent!.copyWith(
        title: _titleController.text.trim(),
        type: _selectedType,
        dateTime: dateTime,
        notes: _notesController.text.trim(),
        isRecurring: _isRecurring,
        recurringType: _isRecurring ? _recurringType : RecurringType.none,
        notificationEnabled: _notificationEnabled,
      );

      await repo.updateEvent(updated);

      if (_notificationEnabled) {
        final notifId =
            await NotificationService().scheduleEventNotification(updated);
        await repo
            .updateEvent(updated.copyWith(notificationId: notifId));
      }
    } else {
      final event = Event(
        id: const Uuid().v4(),
        title: _titleController.text.trim(),
        type: _selectedType,
        dateTime: dateTime,
        notes: _notesController.text.trim(),
        isRecurring: _isRecurring,
        recurringType: _isRecurring ? _recurringType : RecurringType.none,
        notificationEnabled: _notificationEnabled,
        userId: userId,
        createdAt: DateTime.now(),
      );

      if (_isRecurring && _recurringType != RecurringType.none) {
        await repo.createRecurringEvents(event);
      } else {
        await repo.createEvent(event);
      }

      if (_notificationEnabled) {
        final notifId =
            await NotificationService().scheduleEventNotification(event);
        await repo.updateEvent(event.copyWith(notificationId: notifId));
      }
    }

    if (mounted) context.pop();
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete Event',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to delete this event?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w300),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final event = widget.existingEvent!;
    final repo = ref.read(eventRepositoryProvider);

    if (event.notificationId != null) {
      await NotificationService().cancelNotification(event.notificationId!);
    }
    await repo.deleteEvent(event.id);

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
            icon: Icon(
              Icons.arrow_back_rounded,
              color: isDark ? Colors.white : AppColors.textDark,
            ),
            onPressed: () => context.pop(),
          ),
          title: Text(
            _isEditing ? 'Edit Event' : 'New Event',
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
                // Title
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: TextFormField(
                    controller: _titleController,
                    style: GoogleFonts.poppins(
                      color: isDark ? Colors.white : AppColors.textDark,
                      fontWeight: FontWeight.w400,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Event title',
                      hintStyle: GoogleFonts.poppins(
                        color: isDark ? Colors.white38 : AppColors.textMuted,
                        fontWeight: FontWeight.w300,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Enter a title' : null,
                  ),
                ),

                const SizedBox(height: 16),

                // Event Type
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Event Type',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white70 : AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: EventType.values.map((type) {
                          final isSelected = _selectedType == type;
                          final typeColor = Color(Event.typeColors[type]!);
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedType = type),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? typeColor
                                    : typeColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? typeColor
                                      : typeColor.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                Event.typeLabel(type),
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : typeColor,
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

                // Date & Time
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _pickDate,
                        child: GlassCard(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              ShaderMask(
                                shaderCallback: (bounds) =>
                                    AppColors.softGradient
                                        .createShader(bounds),
                                child: const Icon(
                                  Icons.calendar_today_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                DateFormat('MMM d, y').format(_selectedDate),
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: _pickTime,
                        child: GlassCard(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              ShaderMask(
                                shaderCallback: (bounds) =>
                                    AppColors.softGradient
                                        .createShader(bounds),
                                child: const Icon(
                                  Icons.access_time_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                _selectedTime.format(context),
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Notes
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: TextFormField(
                    controller: _notesController,
                    maxLines: 4,
                    style: GoogleFonts.poppins(
                      color: isDark ? Colors.white : AppColors.textDark,
                      fontWeight: FontWeight.w300,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Notes (optional)',
                      hintStyle: GoogleFonts.poppins(
                        color: isDark ? Colors.white38 : AppColors.textMuted,
                        fontWeight: FontWeight.w300,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Toggles
                GlassCard(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 8),
                  child: Column(
                    children: [
                      _buildToggle(
                        icon: Icons.repeat_rounded,
                        label: 'Recurring',
                        value: _isRecurring,
                        onChanged: (v) =>
                            setState(() => _isRecurring = v),
                        isDark: isDark,
                      ),
                      if (_isRecurring) ...[
                        const Divider(height: 1),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            children: [
                              _RecurringOption(
                                label: 'Daily',
                                isSelected:
                                    _recurringType == RecurringType.daily,
                                onTap: () => setState(
                                    () => _recurringType = RecurringType.daily),
                                isDark: isDark,
                              ),
                              const SizedBox(width: 10),
                              _RecurringOption(
                                label: 'Weekly',
                                isSelected:
                                    _recurringType == RecurringType.weekly,
                                onTap: () => setState(() =>
                                    _recurringType = RecurringType.weekly),
                                isDark: isDark,
                              ),
                            ],
                          ),
                        ),
                      ],
                      const Divider(height: 1),
                      _buildToggle(
                        icon: Icons.notifications_active_rounded,
                        label: 'Notification (1hr before)',
                        value: _notificationEnabled,
                        onChanged: (v) =>
                            setState(() => _notificationEnabled = v),
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // Save button
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
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            _isEditing ? 'Update Event' : 'Save Event',
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

  Widget _buildToggle({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          ShaderMask(
            shaderCallback: (bounds) =>
                AppColors.softGradient.createShader(bounds),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: isDark ? Colors.white : AppColors.textDark,
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.deepPurple,
            activeTrackColor: AppColors.lavender.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }
}

class _RecurringOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _RecurringOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.softGradient : null,
          color: isSelected
              ? null
              : (isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : AppColors.rosePink.withValues(alpha: 0.3),
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
    );
  }
}
