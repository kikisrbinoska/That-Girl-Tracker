import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/event.dart';
import '../../services/event_providers.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/widgets/glass_card.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedDate = ref.watch(selectedDateProvider);
    final selectedEvents = ref.watch(selectedDateEventsProvider);
    final eventsAsync = ref.watch(eventsStreamProvider);
    final activeFilter = ref.watch(eventTypeFilterProvider);

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
                      'Calendar',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppColors.textDark,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => ref.read(selectedDateProvider.notifier).state =
                          DateTime(
                        DateTime.now().year,
                        DateTime.now().month,
                        DateTime.now().day,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: AppColors.softGradient,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Today',
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
              ).animate().fadeIn(duration: 400.ms),

              const SizedBox(height: 8),

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
                          .read(eventTypeFilterProvider.notifier)
                          .state = null,
                      isDark: isDark,
                    ),
                    ...EventType.values.map((type) => _FilterChip(
                          label: Event.typeLabel(type),
                          isSelected: activeFilter == type,
                          color: Color(Event.typeColors[type]!),
                          onTap: () => ref
                              .read(eventTypeFilterProvider.notifier)
                              .state = type,
                          isDark: isDark,
                        )),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

              const SizedBox(height: 8),

              // Calendar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: GlassCard(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
                  child: eventsAsync.when(
                    data: (allEvents) => _buildCalendar(
                      context,
                      ref,
                      selectedDate,
                      allEvents,
                      isDark,
                    ),
                    loading: () => _buildCalendar(
                      context,
                      ref,
                      selectedDate,
                      [],
                      isDark,
                    ),
                    error: (_, __) => _buildCalendar(
                      context,
                      ref,
                      selectedDate,
                      [],
                      isDark,
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: 500.ms, delay: 200.ms),

              const SizedBox(height: 12),

              // Events list
              Expanded(
                child: selectedEvents.isEmpty
                    ? _buildEmptyState(isDark)
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                        itemCount: selectedEvents.length,
                        itemBuilder: (context, index) {
                          return _EventCard(
                            event: selectedEvents[index],
                            isDark: isDark,
                          )
                              .animate()
                              .fadeIn(
                                duration: 400.ms,
                                delay: (100 * index).ms,
                              )
                              .slideY(begin: 0.15, end: 0);
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
              onPressed: () => context.push('/calendar/add'),
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
                delay: 500.ms,
                curve: Curves.elasticOut,
              ),
        ),
      ),
    );
  }

  Widget _buildCalendar(
    BuildContext context,
    WidgetRef ref,
    DateTime selectedDate,
    List<Event> allEvents,
    bool isDark,
  ) {
    final textColor = isDark ? Colors.white : AppColors.textDark;
    final mutedColor = isDark ? Colors.white38 : AppColors.textMuted;

    return TableCalendar<Event>(
      firstDay: DateTime.utc(2024, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: selectedDate,
      selectedDayPredicate: (day) => isSameDay(selectedDate, day),
      onDaySelected: (selected, focused) {
        ref.read(selectedDateProvider.notifier).state = DateTime(
          selected.year,
          selected.month,
          selected.day,
        );
      },
      eventLoader: (day) {
        return allEvents.where((e) {
          return e.dateTime.year == day.year &&
              e.dateTime.month == day.month &&
              e.dateTime.day == day.day;
        }).toList();
      },
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        todayDecoration: BoxDecoration(
          color: AppColors.rosePink.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
        todayTextStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          color: AppColors.rosePink,
        ),
        selectedDecoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
          shape: BoxShape.circle,
        ),
        selectedTextStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        defaultTextStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w400,
          color: textColor,
        ),
        weekendTextStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w400,
          color: textColor,
        ),
        markerDecoration: const BoxDecoration(
          color: AppColors.deepPurple,
          shape: BoxShape.circle,
        ),
        markersMaxCount: 3,
        markerSize: 5,
        markerMargin: const EdgeInsets.symmetric(horizontal: 1),
      ),
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        leftChevronIcon: Icon(
          Icons.chevron_left_rounded,
          color: textColor,
        ),
        rightChevronIcon: Icon(
          Icons.chevron_right_rounded,
          color: textColor,
        ),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: mutedColor,
        ),
        weekendStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: mutedColor,
        ),
      ),
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, day, events) {
          if (events.isEmpty) return null;
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: events.take(3).map((event) {
              return Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  color: Color(Event.typeColors[event.type]!),
                  shape: BoxShape.circle,
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ShaderMask(
            shaderCallback: (bounds) =>
                AppColors.softGradient.createShader(bounds),
            child: const Icon(
              Icons.event_available_rounded,
              size: 48,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'No events for this day',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w300,
              color: isDark ? Colors.white54 : AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap + to add one ✨',
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

class _EventCard extends StatelessWidget {
  final Event event;
  final bool isDark;

  const _EventCard({
    required this.event,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('h:mm a').format(event.dateTime);
    final typeColor = Color(Event.typeColors[event.type]!);
    final isPast = event.dateTime.isBefore(DateTime.now());

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => context.push('/calendar/event/${event.id}'),
        child: GlassCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 50,
                decoration: BoxDecoration(
                  color: typeColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: isDark ? Colors.white54 : AppColors.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          timeStr,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w300,
                            color:
                                isDark ? Colors.white54 : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      Event.typeLabel(event.type),
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: typeColor,
                      ),
                    ),
                  ),
                  if (isPast) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Completed ✓',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
