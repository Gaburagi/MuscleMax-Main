import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../utils/app_colors.dart';
import '../providers/user_provider.dart';
import '../providers/workout_provider.dart';
import '../utils/routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final workoutProvider = context.watch<WorkoutProvider>();
    final user = userProvider.user;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'HELLO,',
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                        Text(
                          user?.fullName.split(' ').first.toUpperCase() ?? 'USER',
                          style: Theme.of(context).textTheme.displayLarge,
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined, color: AppColors.textWhite, size: 28),
                      onPressed: () {},
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),

                // Stats Cards
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Workouts',
                        value: '${workoutProvider.totalWorkoutsCompleted}',
                        icon: Icons.fitness_center,
                        color: AppColors.primaryRed,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatCard(
                        title: 'Total Time',
                        value: '${workoutProvider.totalWorkoutTime.inMinutes}m',
                        icon: Icons.timer,
                        color: AppColors.accentOrange,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Quick Actions
                Text(
                  'QUICK START',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                
                _QuickActionButton(
                  title: 'Browse Training Programs',
                  subtitle: 'Find the perfect workout for you',
                  icon: Icons.list_alt,
                  onTap: () => context.go(AppRoutes.training),
                ),
                
                const SizedBox(height: 12),
                
                _QuickActionButton(
                  title: 'View Profile',
                  subtitle: 'Check your stats and goals',
                  icon: Icons.person,
                  onTap: () => context.go(AppRoutes.profile),
                ),

                const SizedBox(height: 12),
                
                _QuickActionButton(
                  title: 'Community Hub',
                  subtitle: 'Challenges, leaderboards & shared workouts',
                  icon: Icons.people,
                  onTap: () => context.go(AppRoutes.community),
                ),

                const SizedBox(height: 12),

                _QuickActionButton(
                  title: 'Friends',
                  subtitle: 'Connect with friends & view their activity',
                  icon: Icons.group,
                  onTap: () => context.go(AppRoutes.friends),
                ),

                const SizedBox(height: 32),

                // Today's Recommended
                if (workoutProvider.workoutPrograms.isNotEmpty) ...[
                  Text(
                    'RECOMMENDED FOR YOU',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  ...workoutProvider.workoutPrograms.take(2).map(
                    (program) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundCard,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                gradient: AppColors.orangeGradient,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.fitness_center, color: AppColors.textWhite),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    program.name,
                                    style: const TextStyle(
                                      color: AppColors.textWhite,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${program.difficulty} • ${program.durationMinutes} min',
                                    style: const TextStyle(
                                      color: AppColors.textGray,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.play_circle_fill, color: AppColors.primaryRed, size: 32),
                              onPressed: () {
                                context.push('${AppRoutes.workoutDetail}?workoutId=${program.id}');
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const _BottomNav(currentIndex: 0),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textWhite,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textGray,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: AppColors.redGradient,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.textWhite),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: AppColors.textWhite, size: 16),
          ],
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;

  const _BottomNav({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundDark,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home,
                label: 'Home',
                isSelected: currentIndex == 0,
                onTap: () => context.go(AppRoutes.home),
              ),
              _NavItem(
                icon: Icons.fitness_center,
                label: 'Training',
                isSelected: currentIndex == 1,
                onTap: () => context.go(AppRoutes.training),
              ),
              _NavItem(
                icon: Icons.bar_chart,
                label: 'Progress',
                isSelected: currentIndex == 2,
                onTap: () => context.go(AppRoutes.progress),
              ),
              _NavItem(
                icon: Icons.person,
                label: 'Profile',
                isSelected: currentIndex == 3,
                onTap: () => context.go(AppRoutes.profile),
              ),
              _NavItem(
                icon: Icons.restaurant,
                label: 'Nutrition',
                isSelected: currentIndex == 4,
                onTap: () => context.go(AppRoutes.nutrition),
              ),
            ],
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.primaryRed : AppColors.textGray,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.primaryRed : AppColors.textGray,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
