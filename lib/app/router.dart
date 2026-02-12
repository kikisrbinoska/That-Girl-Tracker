import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/auth/auth_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/calendar/add_event_screen.dart';
import '../features/calendar/calendar_screen.dart';
import '../features/calendar/event_detail_screen.dart';
import '../features/fitness/fitness_screen.dart';
import '../features/fitness/log_workout_screen.dart';
import '../features/fitness/training_plan_screen.dart';
import '../features/fitness/sleep_tracker_screen.dart';
import '../features/home/home_screen.dart';
import '../features/nutrition/nutrition_screen.dart';
import '../features/nutrition/meal_logger_screen.dart';
import '../features/outfit/add_clothing_screen.dart';
import '../features/outfit/morning_outfit_screen.dart';
import '../features/outfit/saved_outfits_screen.dart';
import '../features/outfit/wardrobe_screen.dart';
import '../features/outfit/wishlist_screen.dart';
import '../features/routine/morning_routine_screen.dart';
import '../features/routine/evening_routine_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/routine/evening_review_screen.dart';
import '../features/settings/settings_screen.dart';
import '../models/clothing_item.dart';
import '../models/event.dart';
import '../shared/widgets/app_shell.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/onboarding',
    redirect: _redirect,
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),
      // Calendar full-screen routes
      GoRoute(
        path: '/calendar/add',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AddEventScreen(),
      ),
      GoRoute(
        path: '/calendar/edit/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final event = state.extra as Event?;
          return AddEventScreen(existingEvent: event);
        },
      ),
      GoRoute(
        path: '/calendar/event/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return EventDetailScreen(eventId: id);
        },
      ),
      // Wardrobe full-screen routes
      GoRoute(
        path: '/wardrobe/add',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AddClothingScreen(),
      ),
      GoRoute(
        path: '/wardrobe/edit/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final item = state.extra as ClothingItem?;
          return AddClothingScreen(existingItem: item);
        },
      ),
      GoRoute(
        path: '/wardrobe/outfits',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SavedOutfitsScreen(),
      ),
      GoRoute(
        path: '/wardrobe/wishlist',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const WishlistScreen(),
      ),
      GoRoute(
        path: '/outfit/morning',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const MorningOutfitScreen(),
      ),
      // Fitness full-screen routes
      GoRoute(
        path: '/fitness/log-workout',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LogWorkoutScreen(),
      ),
      GoRoute(
        path: '/fitness/training-plan',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const TrainingPlanScreen(),
      ),
      GoRoute(
        path: '/fitness/sleep',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SleepTrackerScreen(),
      ),
      // Nutrition full-screen routes
      GoRoute(
        path: '/nutrition/meals',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const MealLoggerScreen(),
      ),
      // Routine full-screen routes
      GoRoute(
        path: '/routine/morning',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const MorningRoutineScreen(),
      ),
      GoRoute(
        path: '/routine/evening',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const EveningRoutineScreen(),
      ),
      GoRoute(
        path: '/review',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const EveningReviewScreen(),
      ),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),
      // Shell routes (with bottom nav)
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/calendar',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CalendarScreen(),
            ),
          ),
          GoRoute(
            path: '/wardrobe',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: WardrobeScreen(),
            ),
          ),
          GoRoute(
            path: '/fitness',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: FitnessScreen(),
            ),
          ),
          GoRoute(
            path: '/nutrition',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: NutritionScreen(),
            ),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
        ],
      ),
    ],
  );

  static Future<String?> _redirect(BuildContext context, GoRouterState state) async {
    final path = state.uri.path;
    final prefs = await SharedPreferences.getInstance();
    final onboardingCompleted =
        prefs.getBool('onboarding_completed') ?? false;
    final user = FirebaseAuth.instance.currentUser;

    if (!onboardingCompleted) {
      return path == '/onboarding' ? null : '/onboarding';
    }
    if (path == '/onboarding') return '/auth';
    if (user == null) {
      return path == '/auth' ? null : '/auth';
    }
    if (path == '/auth') return '/home';
    return null;
  }
}
