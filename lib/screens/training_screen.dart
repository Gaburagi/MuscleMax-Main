import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../utils/app_colors.dart';
import '../providers/workout_provider.dart';
import '../utils/routes.dart';
import '../widgets/bottom_navigation.dart';

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workoutProvider = context.watch<WorkoutProvider>();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppColors.textWhite),
                      onPressed: () => context.go(AppRoutes.home),
                    ),
                    Expanded(
                      child: Text(
                        'TRAINING',
                        style: Theme.of(context).textTheme.displayMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.library_books, color: AppColors.primaryRed),
                      onPressed: () => context.push(AppRoutes.workoutLibrary),
                    ),
                    IconButton(
                      icon: const Icon(Icons.history, color: AppColors.primaryRed),
                      onPressed: () => context.push(AppRoutes.workoutHistory),
                    ),
                  ],
                ),
              ),
              
              // Quick access to custom workouts
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: TextButton.icon(
                  onPressed: () => context.push(AppRoutes.workoutLibrary),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF333333),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.add_circle_outline, color: AppColors.primaryRed, size: 20),
                  label: const Text(
                    'MY CUSTOM WORKOUTS',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              
              TabBar(
                controller: _tabController,
                indicatorColor: AppColors.primaryRed,
                labelColor: AppColors.textWhite,
                unselectedLabelColor: AppColors.textGray,
                tabs: const [
                  Tab(text: 'Beginner'),
                  Tab(text: 'Intermediate'),
                  Tab(text: 'Advanced'),
                ],
              ),
              
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _WorkoutList(workoutProvider.getWorkoutsByDifficulty('Beginner')),
                    _WorkoutList(workoutProvider.getWorkoutsByDifficulty('Intermediate')),
                    _WorkoutList(workoutProvider.getWorkoutsByDifficulty('Advanced')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavigation(currentIndex: 1),
    );
  }
}

class _WorkoutList extends StatelessWidget {
  final List<dynamic> workouts;

  const _WorkoutList(this.workouts);

  @override
  Widget build(BuildContext context) {
    if (workouts.isEmpty) {
      return const Center(
        child: Text(
          'No workouts available',
          style: TextStyle(color: AppColors.textGray),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: workouts.length,
      itemBuilder: (context, index) {
        final workout = workouts[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.backgroundCard,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workout.name,
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.timer, color: AppColors.textGray, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${workout.durationMinutes} min',
                      style: const TextStyle(color: AppColors.textGray, fontSize: 12),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.fitness_center, color: AppColors.textGray, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${workout.exercises.length} exercises',
                      style: const TextStyle(color: AppColors.textGray, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context.push('${AppRoutes.workoutDetail}?workoutId=${workout.id}');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryRed,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('START WORKOUT'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
