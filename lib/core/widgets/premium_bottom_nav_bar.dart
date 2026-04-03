import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class NavItem {
  final IconData icon;
  final String label;
  final bool isFill;

  NavItem({
    required this.icon,
    required this.label,
    this.isFill = false,
  });
}

class PremiumBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NavItem> items;
  final Widget? centerButton; // For Syndicate FAB in-bar style

  const PremiumBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.centerButton,
  });

  @override
  Widget build(BuildContext context) {
    // Glassmorphism background
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 85 + MediaQuery.of(context).padding.bottom,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom + 8,
            top: 12,
            left: 16,
            right: 16,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.9),
            border: Border(
              top: BorderSide(
                color: AppColors.border.withValues(alpha: 0.5),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _buildItems(context),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildItems(BuildContext context) {
    List<Widget> widgets = [];
    
    // Split items if there's a center button
    if (centerButton != null && items.length >= 4) {
      // First two items
      for (int i = 0; i < 2; i++) {
        widgets.add(_buildNavItem(i, items[i]));
      }
      
      // The center button (e.g. Syndicate Add)
      widgets.add(
        Transform.translate(
          offset: const Offset(0, -25),
          child: centerButton!,
        ),
      );
      
      // Last two items
      for (int i = 2; i < items.length; i++) {
        widgets.add(_buildNavItem(i, items[i]));
      }
    } else {
      // Standard layout
      for (int i = 0; i < items.length; i++) {
        widgets.add(_buildNavItem(i, items[i]));
      }
    }
    
    return widgets;
  }

  Widget _buildNavItem(int index, NavItem item) {
    final isSelected = currentIndex == index;
    final color = isSelected ? AppColors.primary : AppColors.onSurfaceVariant;

    return Theme(
      data: ThemeData(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: Expanded(
        child: InkWell(
          onTap: () => onTap(index),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                scale: isSelected ? 1.15 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  item.icon,
                  color: color,
                  size: 26,
                  // Since Material Symbols aren't a package here, 
                  // we use regular Icons but could simulate fill if needed
                ),
              ),
              const SizedBox(height: 6),
              Text(
                item.label.toUpperCase(),
                style: AppTextStyles.label.copyWith(
                  fontSize: 10,
                  color: color,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
