import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/app_colors.dart';
import '../utils/routes.dart';
import '../widgets/bottom_navigation.dart';

class TrainingHubScreen extends StatelessWidget {
  const TrainingHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundCard,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go(AppRoutes.home),
        ),
        title: const Text(
          'TRAINING HUB',
          style: TextStyle(
            fontFamily: 'Bebas Neue',
            fontSize: 24,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Training & AI Features',
              style: TextStyle(
                color: AppColors.textGray,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            _TrainingCard(
              title: 'Quick Workout Generator',
              subtitle: 'Create a fast AI-powered workout',
              icon: Icons.flash_on,
              gradient: LinearGradient(
                colors: [Colors.orange.shade600, Colors.deepOrange.shade800],
              ),
              onTap: () => context.go(AppRoutes.quickWorkout),
            ),
            const SizedBox(height: 16),
            _TrainingCard(
              title: 'Workout Recommendations',
              subtitle: 'Personalized AI workout plans',
              icon: Icons.auto_awesome,
              gradient: LinearGradient(
                colors: [Colors.purple.shade600, Colors.purple.shade900],
              ),
              onTap: () => context.go('/workout-recommendations'),
            ),
            const SizedBox(height: 16),
            _TrainingCard(
              title: 'Adaptive Difficulty',
              subtitle: 'AI adjusts workout challenge',
              icon: Icons.trending_up,
              gradient: LinearGradient(
                colors: [Colors.blue.shade600, Colors.blue.shade900],
              ),
              onTap: () => context.go('/adaptive-difficulty'),
            ),
            const SizedBox(height: 16),
            _TrainingCard(
              title: 'Recovery Dashboard',
              subtitle: 'Track muscle recovery & readiness',
              icon: Icons.healing,
              gradient: LinearGradient(
                colors: [Colors.green.shade600, Colors.green.shade900],
              ),
              onTap: () => context.go('/recovery-dashboard'),
            ),
            const SizedBox(height: 16),
            _TrainingCard(
              title: 'Goal Prediction',
              subtitle: 'See progress toward your goals',
              icon: Icons.flag,
              gradient: LinearGradient(
                colors: [Colors.amber.shade600, Colors.amber.shade900],
              ),
              onTap: () => context.go('/goal_prediction'), // Correct route
            ),
            const SizedBox(height: 16),
            _TrainingCard(
              title: 'Workout History',
              subtitle: 'View all completed workouts',
              icon: Icons.history,
              gradient: LinearGradient(
                colors: [Colors.indigo.shade600, Colors.indigo.shade900],
              ),
              onTap: () => context.go('/workout-history'),
            ),
            const SizedBox(height: 16),
            _TrainingCard(
              title: 'Workout Library',
              subtitle: 'View and manage your own workouts',
              icon: Icons.folder_special,
              gradient: LinearGradient(
                colors: [Colors.teal.shade600, Colors.teal.shade900],
              ),
              onTap: () => context.go('/workout-library'),
            ),
            const SizedBox(height: 16),
            _TrainingCard(
              title: 'Workout Builder',
              subtitle: 'Create your own custom workout',
              icon: Icons.build,
              gradient: LinearGradient(
                colors: [Colors.deepPurple.shade600, Colors.deepPurple.shade900],
              ),
              onTap: () => context.go('/workout-builder'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigation(currentIndex: 1),
    );
  }
}

class _TrainingCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;

  const _TrainingCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
