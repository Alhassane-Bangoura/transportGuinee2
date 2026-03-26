import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'pages/onboarding_page1.dart';
import 'pages/onboarding_page2.dart';
import 'pages/onboarding_page3.dart';
import '../auth/role_selection_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  final int _totalPages = 3;

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finish();
    }
  }

  void _skip() {
    _finish();
  }

  void _finish() {
    // Naviguer vers le choix du rôle (à créer)
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const RoleSelectionPage()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          // PageView
          PageView(
            controller: _controller,
            onPageChanged: (i) => setState(() => _currentPage = i),
            children: [
              OnboardingPage1(
                onNext: _nextPage,
                onSkip: _skip,
                currentPage: _currentPage,
                totalPages: _totalPages,
              ),
              OnboardingPage2(
                onNext: _nextPage,
                onSkip: _skip,
                currentPage: _currentPage,
                totalPages: _totalPages,
              ),
              OnboardingPage3(
                onNext: _nextPage,
                onSkip: _skip,
                currentPage: _currentPage,
                totalPages: _totalPages,
              ),
            ],
          ),
          
          // Pagination Dots & Button are handled inside each page for better layout control
          // as per the new premium design screenshots
        ],
      ),
    );
  }
}

/// Widget des points de pagination réutilisable
class OnboardingDots extends StatelessWidget {
  const OnboardingDots({
    super.key,
    required this.currentPage,
    required this.totalPages,
  });

  final int currentPage;
  final int totalPages;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalPages,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: index == currentPage ? 24 : 8,
          decoration: BoxDecoration(
            color: index == currentPage ? AppColors.primary : AppColors.border,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

/// Bouton principal vert réutilisable
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.showArrow = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: AppTextStyles.buttonText),
            if (showArrow) ...[
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_rounded, size: 20),
            ],
          ],
        ),
      ),
    );
  }
}
