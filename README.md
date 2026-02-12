# That Girl Tracker ✨

A premium lifestyle planner app inspired by Elle Woods. Track your calendar, outfits, fitness, nutrition, and daily routines — all in one beautiful glassmorphic UI.

## 🌸 Features

- **Smart Calendar** — Events with reminders, recurring events, color-coded categories
- **Outfit AI** — Smart outfit recommendations based on weather + calendar events
- **Digital Wardrobe** — Upload clothes, save favorite outfits, shopping wishlist
- **Fitness Tracker** — Real-time step counter, workout logger, weekly training plans
- **Water & Nutrition** — 2.5L daily goal, hourly reminders, meal logger with photos
- **Daily Routines** — Morning & evening checklists, sleep tracker, day ratings
- **Weather Integration** — Real-time forecasts with animated icons
- **Beautiful Dashboard** — Weather, steps, water, schedule, and routines at a glance

## 🛠️ Tech Stack

**Frontend:** Flutter 3.35.7, Riverpod, go_router, glassmorphic design  
**Backend:** Firebase (Auth, Firestore, Storage, Cloud Messaging)  
**APIs:** OpenWeatherMap for weather data  
**UI/UX:** Custom glassmorphic cards, pink/purple gradients, Poppins font, dark mode support

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.35.7+
- Firebase account
- OpenWeatherMap API key (free tier)

### Installation

1. **Clone & Install**
```bash
git clone https://github.com/yourusername/that_girl_tracker.git
cd that_girl_tracker
flutter pub get
```

2. **Firebase Setup**
```bash
npm install -g firebase-tools
firebase login
dart pub global activate flutterfire_cli
flutterfire configure
```

3. **Enable Firebase Services**
- Go to [Firebase Console](https://console.firebase.google.com)
- Enable: Authentication (Email + Google), Firestore, Storage, Cloud Messaging

4. **Add Weather API Key**
- Sign up at [openweathermap.org](https://openweathermap.org)
- Add your key to `services/weather_service.dart`

5. **Run**
```bash
flutter run -d chrome        # Web
flutter run                  # Android/iOS
```

## 📱 Platform Support

- ✅ Web (pedometer uses mock data)
- ✅ Android (full support)
- ✅ iOS (full support)

## 📁 Project Structure
```
lib/
├── features/        # auth, home, calendar, outfit, fitness, nutrition, routine, profile
├── models/          # event, clothing_item, workout, meal, user_profile
├── services/        # weather, notifications, outfit AI, step counter
└── shared/          # glass_card widget, colors, constants
```

## 🔐 Security

Firestore rules protect all user data — only authenticated users can access their own documents.

---
