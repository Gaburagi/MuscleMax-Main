import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../utils/app_colors.dart';
import '../widgets/bottom_navigation.dart';
import '../providers/user_provider.dart';
import '../utils/routes.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppColors.textWhite),
                      onPressed: () => context.go(AppRoutes.home),
                    ),
                    Expanded(
                      child: Text(
                        'PROFILE',
                        style: Theme.of(context).textTheme.displayMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: AppColors.primaryRed),
                      onPressed: () => context.go(AppRoutes.profileSetup),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Profile Picture
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.orangeGradient,
                  ),
                  child: const Icon(Icons.person, size: 50, color: AppColors.textWhite),
                ),
                
                const SizedBox(height: 16),
                
                Text(
                  user?.fullName ?? 'User',
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                Text(
                  user?.email ?? '',
                  style: const TextStyle(
                    color: AppColors.textGray,
                    fontSize: 14,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Stats
                if (user?.age != null || user?.height != null || user?.weight != null)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundCard,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        if (user?.age != null)
                          _StatItem(label: 'Age', value: '${user!.age} years'),
                        if (user?.height != null)
                          _StatItem(label: 'Height', value: '${user!.height?.toInt()} cm'),
                        if (user?.weight != null)
                          _StatItem(label: 'Weight', value: '${user!.weight?.toInt()} kg'),
                      ],
                    ),
                  ),
                
                const SizedBox(height: 24),
                
                // Fitness Goal
                if (user?.fitnessGoal != null)
                  _InfoCard(
                    title: 'FITNESS GOAL',
                    content: user!.fitnessGoal!,
                  ),
                
                const SizedBox(height: 16),
                
                // Exercise Preferences
                if (user?.selectedExercises.isNotEmpty ?? false)
                  _InfoCard(
                    title: 'EXERCISE PREFERENCES',
                    content: user!.selectedExercises.join(', '),
                  ),
                
                const SizedBox(height: 32),
                
                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await userProvider.logout();
                      if (context.mounted) {
                        context.go(AppRoutes.login);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentRed,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('LOGOUT'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavigation(currentIndex: 3),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textWhite,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textGray,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String content;

  const _InfoCard({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.primaryRed,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              color: AppColors.textWhite,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
