import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/calendar')) return 1;
    if (location.startsWith('/wardrobe')) return 2;
    if (location.startsWith('/fitness')) return 3;
    if (location.startsWith('/nutrition')) return 4;
    if (location.startsWith('/profile')) return 5;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
      case 1:
        context.go('/calendar');
      case 2:
        context.go('/wardrobe');
      case 3:
        context.go('/fitness');
      case 4:
        context.go('/nutrition');
      case 5:
        context.go('/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedIndex = _currentIndex(context);

    return Scaffold(
      body: child,
      extendBody: true,
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkBackground.withValues(alpha: 0.85)
                  : Colors.white.withValues(alpha: 0.85),
              border: Border(
                top: BorderSide(
                  color: isDark
                      ? AppColors.glassBorderDark
                      : AppColors.rosePink.withValues(alpha: 0.2),
                  width: 0.5,
                ),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NavItem(
                      icon: Icons.home_rounded,
                      label: 'Home',
                      isSelected: selectedIndex == 0,
                      onTap: () => _onTap(context, 0),
                    ),
                    _NavItem(
                      icon: Icons.calendar_month_rounded,
                      label: 'Calendar',
                      isSelected: selectedIndex == 1,
                      onTap: () => _onTap(context, 1),
                    ),
                    _NavItem(
                      icon: Icons.checkroom_rounded,
                      label: 'Wardrobe',
                      isSelected: selectedIndex == 2,
                      onTap: () => _onTap(context, 2),
                    ),
                    _NavItem(
                      icon: Icons.fitness_center_rounded,
                      label: 'Fitness',
                      isSelected: selectedIndex == 3,
                      onTap: () => _onTap(context, 3),
                    ),
                    _NavItem(
                      icon: Icons.restaurant_rounded,
                      label: 'Nutrition',
                      isSelected: selectedIndex == 4,
                      onTap: () => _onTap(context, 4),
                    ),
                    _NavItem(
                      icon: Icons.person_rounded,
                      label: 'Profile',
                      isSelected: selectedIndex == 5,
                      onTap: () => _onTap(context, 5),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: isSelected ? AppColors.softGradient : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.rosePink.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? Colors.white : AppColors.textMuted,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? Colors.white : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
