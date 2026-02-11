import '../models/clothing_item.dart';
import '../models/event.dart';
import '../models/weather.dart';

class OutfitRecommendation {
  final List<ClothingItem> items;
  final String reason;

  const OutfitRecommendation({required this.items, required this.reason});
}

class OutfitService {
  static OutfitRecommendation recommendOutfitForDay({
    required Weather weather,
    required List<Event> todayEvents,
    required List<ClothingItem> wardrobe,
  }) {
    if (wardrobe.isEmpty) {
      return const OutfitRecommendation(
        items: [],
        reason: 'Add clothes to your wardrobe to get recommendations!',
      );
    }

    // Determine priority event
    final priorityOrder = [
      EventType.work,
      EventType.appointment,
      EventType.gym,
      EventType.social,
      EventType.personal,
    ];

    Event? priorityEvent;
    for (final type in priorityOrder) {
      final match = todayEvents.where((e) => e.type == type).firstOrNull;
      if (match != null) {
        priorityEvent = match;
        break;
      }
    }

    // Map event type to clothing category
    ClothingCategory targetCategory;
    if (priorityEvent != null) {
      targetCategory = _eventToCategory(priorityEvent.type);
    } else {
      targetCategory = ClothingCategory.casual;
    }

    // Filter by weather-appropriate season
    var candidates = _filterBySeason(wardrobe, weather.temperature);

    // Get items matching the target category
    var categoryItems =
        candidates.where((i) => i.category == targetCategory).toList();

    // Fallback: if no matches, use all candidates
    if (categoryItems.isEmpty) {
      categoryItems = candidates;
    }

    // Rain filter: avoid light colors
    if (weather.condition.toLowerCase().contains('rain')) {
      final darkItems = categoryItems
          .where((i) =>
              !i.color.toLowerCase().contains('white') &&
              !i.color.toLowerCase().contains('cream') &&
              !i.color.toLowerCase().contains('beige'))
          .toList();
      if (darkItems.isNotEmpty) categoryItems = darkItems;
    }

    // Pick up to 3 items
    final selected = <ClothingItem>[];
    final usedCategories = <ClothingCategory>{};
    for (final item in categoryItems) {
      if (selected.length >= 3) break;
      if (!usedCategories.contains(item.category)) {
        selected.add(item);
        usedCategories.add(item.category);
      }
    }
    // Fill remaining slots
    for (final item in categoryItems) {
      if (selected.length >= 3) break;
      if (!selected.contains(item)) {
        selected.add(item);
      }
    }

    // Add outerwear if cold
    if (weather.temperature < 10) {
      final outerwear =
          candidates.where((i) => i.category == ClothingCategory.outerwear);
      if (outerwear.isNotEmpty && !selected.contains(outerwear.first)) {
        selected.add(outerwear.first);
      }
    }

    // Build reason
    final reason = _buildReason(weather, priorityEvent, targetCategory);

    return OutfitRecommendation(items: selected, reason: reason);
  }

  static ClothingCategory _eventToCategory(EventType type) {
    switch (type) {
      case EventType.work:
      case EventType.appointment:
        return ClothingCategory.formal;
      case EventType.gym:
        return ClothingCategory.sport;
      case EventType.social:
        return ClothingCategory.casual;
      case EventType.personal:
        return ClothingCategory.lounge;
    }
  }

  static List<ClothingItem> _filterBySeason(
    List<ClothingItem> wardrobe,
    double temp,
  ) {
    Season preferred;
    if (temp > 25) {
      preferred = Season.summer;
    } else if (temp > 15) {
      preferred = Season.spring;
    } else if (temp > 5) {
      preferred = Season.fall;
    } else {
      preferred = Season.winter;
    }

    final seasonal = wardrobe
        .where((i) => i.season == preferred || i.season == Season.allSeasons)
        .toList();

    return seasonal.isNotEmpty ? seasonal : wardrobe;
  }

  static String _buildReason(
    Weather weather,
    Event? priorityEvent,
    ClothingCategory category,
  ) {
    final parts = <String>[];

    if (priorityEvent != null) {
      parts.add(
          'Perfect for your ${Event.typeLabel(priorityEvent.type).toLowerCase()} event');
    } else {
      parts.add('Great for a relaxed day');
    }

    parts.add('${weather.temperature.round()}°C ${weather.description}');

    if (weather.temperature < 10) {
      parts.add("Don't forget a jacket!");
    }
    if (weather.condition.toLowerCase().contains('rain')) {
      parts.add('Grab an umbrella!');
    }

    return parts.join(' · ');
  }
}
