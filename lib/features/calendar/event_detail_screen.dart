import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/event.dart';
import '../../services/event_providers.dart';
import '../../services/notification_service.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/widgets/glass_card.dart';

class EventDetailScreen extends ConsumerWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final eventsAsync = ref.watch(eventsStreamProvider);

    return eventsAsync.when(
      data: (events) {
        final event = events.where((e) => e.id == eventId).firstOrNull;
        if (event == null) {
          return Scaffold(
            body: Center(
              child: Text(
                'Event not found',
                style: GoogleFonts.poppins(
                  color: isDark ? Colors.white : AppColors.textDark,
                ),
              ),
            ),
          );
        }
        return _buildContent(context, ref, event, isDark);
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.deepPurple)),
      ),
      error: (_, __) => Scaffold(
        body: Center(
          child: Text(
            'Something went wrong',
            style: GoogleFonts.poppins(
              color: isDark ? Colors.white : AppColors.textDark,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    Event event,
    bool isDark,
  ) {
    final typeColor = Color(Event.typeColors[event.type]!);
    final isPast = event.dateTime.isBefore(DateTime.now());
    final dateStr = DateFormat('EEEE, MMMM d, y').format(event.dateTime);
    final timeStr = DateFormat('h:mm a').format(event.dateTime);

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
          actions: [
            IconButton(
              icon: ShaderMask(
                shaderCallback: (bounds) =>
                    AppColors.softGradient.createShader(bounds),
                child: const Icon(
                  Icons.edit_rounded,
                  color: Colors.white,
                ),
              ),
              onPressed: () => context.push(
                '/calendar/edit/${event.id}',
                extra: event,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  color: Colors.redAccent),
              onPressed: () => _confirmDelete(context, ref, event),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title + badge
              Row(
                children: [
                  Expanded(
                    child: Text(
                      event.title,
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppColors.textDark,
                      ),
                    ),
                  ),
                  if (isPast)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Completed ✓',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                    ),
                ],
              ).animate().fadeIn(duration: 400.ms),

              const SizedBox(height: 6),

              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  Event.typeLabel(event.type),
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: typeColor,
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

              const SizedBox(height: 24),

              // Date & Time
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _DetailRow(
                      icon: Icons.calendar_today_rounded,
                      label: 'Date',
                      value: dateStr,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),
                    _DetailRow(
                      icon: Icons.access_time_rounded,
                      label: 'Time',
                      value: timeStr,
                      isDark: isDark,
                    ),
                    if (event.isRecurring) ...[
                      const SizedBox(height: 16),
                      _DetailRow(
                        icon: Icons.repeat_rounded,
                        label: 'Repeats',
                        value: event.recurringType == RecurringType.daily
                            ? 'Daily'
                            : 'Weekly',
                        isDark: isDark,
                      ),
                    ],
                    if (event.notificationEnabled) ...[
                      const SizedBox(height: 16),
                      _DetailRow(
                        icon: Icons.notifications_active_rounded,
                        label: 'Reminder',
                        value: '1 hour before',
                        isDark: isDark,
                      ),
                    ],
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 200.ms)
                  .slideY(begin: 0.1, end: 0),

              if (event.notes.isNotEmpty) ...[
                const SizedBox(height: 16),
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) =>
                                AppColors.softGradient.createShader(bounds),
                            child: const Icon(
                              Icons.notes_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Notes',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        event.notes,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                          color: isDark ? Colors.white70 : AppColors.textDark,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 300.ms)
                    .slideY(begin: 0.1, end: 0),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Event event,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete Event',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to delete "${event.title}"?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w300),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    if (event.notificationId != null) {
      await NotificationService().cancelNotification(event.notificationId!);
    }
    await ref.read(eventRepositoryProvider).deleteEvent(event.id);

    if (context.mounted) context.pop();
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ShaderMask(
          shaderCallback: (bounds) =>
              AppColors.softGradient.createShader(bounds),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white54 : AppColors.textMuted,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : AppColors.textDark,
            ),
          ),
        ),
      ],
    );
  }
}
