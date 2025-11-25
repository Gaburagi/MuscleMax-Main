import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../utils/app_colors.dart';
import '../utils/routes.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      image: 'assets/images/onboarding_fitness.svg',
      title1: 'Ready to start your',
      highlight: 'FITNESS',
      title2: 'journey today?',
    ),
    OnboardingPage(
      image: 'assets/images/onboarding_progress.svg',
      title1: 'Track your',
      highlight: 'PROGRESS',
      title2: 'anytime, anywhere.',
    ),
    OnboardingPage(
      image: 'assets/images/onboarding_goals.svg',
      title1: 'Reach your',
      highlight: 'GOALS',
      title2: 'easier and faster.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.go(AppRoutes.login);
    }
  }

  void _skip() {
    context.go(AppRoutes.login);
  }

  IconData _getIconForPage(String highlight) {
    switch (highlight) {
      case 'FITNESS':
        return Icons.fitness_center;
      case 'PROGRESS':
        return Icons.trending_up;
      case 'GOALS':
        return Icons.emoji_events;
      default:
        return Icons.fitness_center;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip & Pagination
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: _skip,
                      child: Text(
                        'SKIP',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.textWhite.withOpacity(0.6),
                        ),
                      ),
                    ),
                    SmoothPageIndicator(
                      controller: _pageController,
                      count: _pages.length,
                      effect: const ExpandingDotsEffect(
                        activeDotColor: AppColors.primaryRed,
                        dotColor: Colors.white24,
                        dotHeight: 8,
                        dotWidth: 8,
                        expansionFactor: 3,
                      ),
                    ),
                    TextButton(
                      onPressed: _nextPage,
                      child: Text(
                        'NEXT',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.textWhite,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // PageView
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _buildPage(_pages[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image Container with Gradient Background
          Container(
            height: 280,
            width: 280,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryRed.withOpacity(0.3),
                  AppColors.primaryRed.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: Icon(
                _getIconForPage(page.highlight),
                size: 120,
                color: AppColors.primaryRed,
              ),
            ),
          ),
          const SizedBox(height: 48),
          
          // Title
          Column(
            children: [
              Text(
                page.title1,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                page.highlight,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: AppColors.primaryRed,
                  fontSize: 36,
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                page.title2,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final String image;
  final String title1;
  final String highlight;
  final String title2;

  OnboardingPage({
    required this.image,
    required this.title1,
    required this.highlight,
    required this.title2,
  });
}
