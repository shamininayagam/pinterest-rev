import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../ui/ui.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 0.5,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavBarItem(
                  icon: Icons.home_filled,
                  inactiveIcon: Icons.home_outlined,
                  isSelected: navigationShell.currentIndex == 0,
                  onTap: () => navigationShell.goBranch(0),
                ),
                _NavBarItem(
                  icon: Icons.search,
                  inactiveIcon: Icons.search_outlined,
                  isSelected: navigationShell.currentIndex == 1,
                  onTap: () => navigationShell.goBranch(1),
                ),
                _NavBarItem(
                  icon: Icons.add,
                  inactiveIcon: Icons.add,
                  isSelected: navigationShell.currentIndex == 2,
                  isAction: true,
                  onTap: () => navigationShell.goBranch(2),
                ),
                _NavBarItem(
                  icon: Icons.person,
                  inactiveIcon: Icons.person_outline,
                  isSelected: navigationShell.currentIndex == 3,
                  onTap: () => navigationShell.goBranch(3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.icon,
    required this.inactiveIcon,
    required this.isSelected,
    required this.onTap,
    this.isAction = false,
  });

  final IconData icon;
  final IconData inactiveIcon;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (isAction) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 26,
            color: isSelected ? AppColors.white : (isDark ? AppColors.darkText : AppColors.lightText),
          ),
        ),
      );
    }

    return IconButton(
      icon: Icon(
        isSelected ? icon : inactiveIcon,
        size: 28,
        color: isSelected
            ? (isDark ? AppColors.darkText : AppColors.lightText)
            : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
      ),
      onPressed: onTap,
    );
  }
}
