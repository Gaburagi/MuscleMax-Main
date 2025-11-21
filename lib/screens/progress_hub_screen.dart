import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/app_colors.dart';
import '../utils/routes.dart';

class ProgressHubScreen extends StatelessWidget {
  const ProgressHubScreen({super.key});

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
          'PROGRESS HUB',
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
              'AI Progress Features',
              style: TextStyle(
                color: AppColors.textGray,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            _ProgressCard(
              title: 'Adaptive Difficulty',
              subtitle: 'AI-powered workout difficulty adjustment',
              icon: Icons.trending_up,
              gradient: LinearGradient(
                colors: [Colors.orange.shade600, Colors.deepOrange.shade800],
              ),
              onTap: () => context.go('/adaptive-difficulty'),
            ),
            const SizedBox(height: 16),
            _ProgressCard(
              title: 'Recovery & Readiness',
              subtitle: 'Track your recovery status',
              icon: Icons.healing,
              gradient: LinearGradient(
                colors: [Colors.green.shade600, Colors.green.shade900],
              ),
              onTap: () => context.go('/recovery-dashboard'),
            ),
            const SizedBox(height: 16),
            _ProgressCard(
              title: 'Goal Predictions',
              subtitle: 'AI-powered goal achievement forecasts',
              icon: Icons.analytics,
              gradient: LinearGradient(
                colors: [Colors.purple.shade600, Colors.purple.shade900],
              ),
              onTap: () => context.go(AppRoutes.goals),
            ),
            const SizedBox(height: 32),
            const Text(
              'Progress Tracking',
              style: TextStyle(
                color: AppColors.textGray,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            _ProgressCard(
              title: 'Body Measurements',
              subtitle: 'Track weight, muscle mass, and body fat',
              icon: Icons.straighten,
              gradient: LinearGradient(
                colors: [Colors.blue.shade600, Colors.blue.shade900],
              ),
              onTap: () => context.go('/body-measurements'),
            ),
            const SizedBox(height: 16),
            _ProgressCard(
              title: 'Progress Photos',
              subtitle: 'Visual transformation timeline',
              icon: Icons.photo_camera,
              gradient: LinearGradient(
                colors: [Colors.teal.shade600, Colors.teal.shade900],
              ),
              onTap: () => context.go('/progress-photos'),
            ),
            const SizedBox(height: 16),
            _ProgressCard(
              title: 'Personal Records',
              subtitle: 'Track your strength PRs',
              icon: Icons.emoji_events,
              gradient: LinearGradient(
                colors: [Colors.amber.shade600, Colors.amber.shade900],
              ),
              onTap: () => context.go('/personal-records'),
            ),
            const SizedBox(height: 16),
            _ProgressCard(
              title: 'Progress Reports',
              subtitle: 'Comprehensive progress analysis',
              icon: Icons.assessment,
              gradient: LinearGradient(
                colors: [Colors.indigo.shade600, Colors.indigo.shade900],
              ),
              onTap: () => context.go('/progress-reports'),
            ),
            const SizedBox(height: 16),
            _ProgressCard(
              title: 'Achievements',
              subtitle: 'Badges and milestones unlocked',
              icon: Icons.military_tech,
              gradient: LinearGradient(
                colors: [Colors.red.shade600, Colors.red.shade900],
              ),
              onTap: () => context.go(AppRoutes.achievements),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;

  const _ProgressCard({
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
