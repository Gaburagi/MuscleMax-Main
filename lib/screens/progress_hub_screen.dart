import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/app_colors.dart';
import '../utils/routes.dart';
import '../widgets/bottom_navigation.dart';

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
              'Progress & Achievements',
              style: TextStyle(
                color: AppColors.textGray,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
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
              title: 'Progress Photos',
              subtitle: 'Visualize your transformation',
              icon: Icons.photo_camera,
              gradient: LinearGradient(
                colors: [Colors.purple.shade600, Colors.purple.shade900],
              ),
              onTap: () => context.go('/progress-photos'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigation(currentIndex: 2),
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
