import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather.dart';

class WeatherService {
  static const _apiKey = '5904a6bbc1e155baf849c50be2a6621c';
  static const _baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const _cacheKey = 'weather_cache';
  static const _cacheTimeKey = 'weather_cache_time';
  static const _cacheDuration = Duration(minutes: 30);

  // Skopje, Macedonia
  static const _defaultLat = 41.9973;
  static const _defaultLon = 21.4280;

  Future<Weather> fetchCurrentWeather({
    double lat = _defaultLat,
    double lon = _defaultLon,
  }) async {
    final cached = await _getCached();
    if (cached != null) return cached;

    final uri = Uri.parse(
      '$_baseUrl/weather?lat=$lat&lon=$lon&appid=$_apiKey&units=metric',
    );
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final weather = Weather.fromJson(json);
      await _saveCache(json);
      return weather;
    } else {
      throw Exception('Failed to fetch weather: ${response.statusCode}');
    }
  }

  Future<List<Weather>> fetchForecast({
    double lat = _defaultLat,
    double lon = _defaultLon,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/forecast?lat=$lat&lon=$lon&appid=$_apiKey&units=metric',
    );
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final list = json['list'] as List;

      // Get one forecast per day (noon entries)
      final daily = <Weather>[];
      String? lastDate;
      for (final item in list) {
        final dt = DateTime.fromMillisecondsSinceEpoch(
          (item['dt'] as int) * 1000,
        );
        final dateKey = '${dt.year}-${dt.month}-${dt.day}';
        if (dateKey != lastDate && dt.hour >= 11 && dt.hour <= 14) {
          daily.add(Weather.fromJson({
            ...item as Map<String, dynamic>,
            'name': json['city']?['name'] ?? '',
            'sys': {'country': json['city']?['country'] ?? ''},
          }));
          lastDate = dateKey;
        }
      }
      return daily.take(5).toList();
    } else {
      throw Exception('Failed to fetch forecast: ${response.statusCode}');
    }
  }

  Future<Weather?> _getCached() async {
    final prefs = await SharedPreferences.getInstance();
    final cacheTime = prefs.getInt(_cacheTimeKey);
    if (cacheTime == null) return null;

    final cachedAt = DateTime.fromMillisecondsSinceEpoch(cacheTime);
    if (DateTime.now().difference(cachedAt) > _cacheDuration) return null;

    final cached = prefs.getString(_cacheKey);
    if (cached == null) return null;

    return Weather.fromJson(jsonDecode(cached) as Map<String, dynamic>);
  }

  Future<void> _saveCache(Map<String, dynamic> json) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, jsonEncode(json));
    await prefs.setInt(
      _cacheTimeKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }
}
