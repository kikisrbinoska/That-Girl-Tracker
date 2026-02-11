import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/auth_screen.dart';
import '../features/calendar/add_event_screen.dart';
import '../features/calendar/calendar_screen.dart';
import '../features/calendar/event_detail_screen.dart';
import '../features/home/home_screen.dart';
import '../features/outfit/add_clothing_screen.dart';
import '../features/outfit/morning_outfit_screen.dart';
import '../features/outfit/saved_outfits_screen.dart';
import '../features/outfit/wardrobe_screen.dart';
import '../features/outfit/wishlist_screen.dart';
import '../models/clothing_item.dart';
import '../models/event.dart';
import '../shared/widgets/app_shell.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/auth',
    routes: [
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
            pageBuilder: (context, state) => NoTransitionPage(
              child: _placeholder('Fitness'),
            ),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => NoTransitionPage(
              child: _placeholder('Profile'),
            ),
          ),
        ],
      ),
    ],
  );

  static Widget _placeholder(String title) {
    return Scaffold(
      body: Center(
        child: Text(
          title,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
