import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/clothing_item.dart';
import '../models/outfit.dart';
import '../models/weather.dart';
import '../models/wishlist_item.dart';
import 'wardrobe_repository.dart';
import 'weather_service.dart';

final wardrobeRepositoryProvider = Provider<WardrobeRepository>((ref) {
  return WardrobeRepository();
});

final weatherServiceProvider = Provider<WeatherService>((ref) {
  return WeatherService();
});

final weatherProvider = FutureProvider<Weather>((ref) async {
  final service = ref.watch(weatherServiceProvider);
  return service.fetchCurrentWeather();
});

final forecastProvider = FutureProvider<List<Weather>>((ref) async {
  final service = ref.watch(weatherServiceProvider);
  return service.fetchForecast();
});

final clothingItemsProvider = StreamProvider<List<ClothingItem>>((ref) {
  final repo = ref.watch(wardrobeRepositoryProvider);
  return repo.getClothingItems();
});

final clothingCategoryFilterProvider =
    StateProvider<ClothingCategory?>((ref) => null);

final filteredClothingProvider = Provider<List<ClothingItem>>((ref) {
  final itemsAsync = ref.watch(clothingItemsProvider);
  final filter = ref.watch(clothingCategoryFilterProvider);

  return itemsAsync.when(
    data: (items) {
      if (filter == null) return items;
      return items.where((i) => i.category == filter).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

final outfitsProvider = StreamProvider<List<Outfit>>((ref) {
  final repo = ref.watch(wardrobeRepositoryProvider);
  return repo.getOutfits();
});

final wishlistProvider = StreamProvider<List<WishlistItem>>((ref) {
  final repo = ref.watch(wardrobeRepositoryProvider);
  return repo.getWishlistItems();
});
