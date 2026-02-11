class Weather {
  final double temperature;
  final String condition;
  final String description;
  final int humidity;
  final double windSpeed;
  final double feelsLike;
  final String icon;
  final String city;
  final String country;
  final DateTime timestamp;

  const Weather({
    required this.temperature,
    required this.condition,
    required this.description,
    required this.humidity,
    required this.windSpeed,
    required this.feelsLike,
    required this.icon,
    required this.city,
    required this.country,
    required this.timestamp,
  });

  double get temperatureFahrenheit => (temperature * 9 / 5) + 32;

  factory Weather.fromJson(Map<String, dynamic> json) {
    final weather = json['weather'][0] as Map<String, dynamic>;
    final main = json['main'] as Map<String, dynamic>;
    final wind = json['wind'] as Map<String, dynamic>;
    final sys = json['sys'] as Map<String, dynamic>? ?? {};

    return Weather(
      temperature: (main['temp'] as num).toDouble(),
      condition: weather['main'] as String,
      description: weather['description'] as String,
      humidity: main['humidity'] as int,
      windSpeed: (wind['speed'] as num).toDouble(),
      feelsLike: (main['feels_like'] as num).toDouble(),
      icon: weather['icon'] as String,
      city: json['name'] as String? ?? '',
      country: sys['country'] as String? ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        (json['dt'] as int) * 1000,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weather': [
        {'main': condition, 'description': description, 'icon': icon}
      ],
      'main': {
        'temp': temperature,
        'feels_like': feelsLike,
        'humidity': humidity,
      },
      'wind': {'speed': windSpeed},
      'sys': {'country': country},
      'name': city,
      'dt': timestamp.millisecondsSinceEpoch ~/ 1000,
    };
  }
}
