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

class _TrainingScreenState extends State<TrainingScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final workoutProvider = context.watch<WorkoutProvider>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with background image
              Container(
                height: 180,
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage('assets/images/training_tab_background.png'),
                    fit: BoxFit.cover,
                  ),
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.6),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white, shadows: [
                              Shadow(color: Colors.black, blurRadius: 8),
                            ]),
                            onPressed: () => context.go(AppRoutes.home),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.library_books, color: Colors.white, shadows: [
                                  Shadow(color: Colors.black, blurRadius: 8),
                                ]),
                                onPressed: () => context.push(AppRoutes.workoutLibrary),
                              ),
                              IconButton(
                                icon: const Icon(Icons.history, color: Colors.white, shadows: [
                                  Shadow(color: Colors.black, blurRadius: 8),
                                ]),
                                onPressed: () => context.push(AppRoutes.workoutHistory),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        'TRAINING',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'BebasNeue',
                          letterSpacing: 2,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.8),
                              blurRadius: 20,
                              offset: const Offset(0, 2),
                            ),
                            Shadow(
                              color: AppColors.primaryRed.withOpacity(0.5),
                              blurRadius: 30,
                              offset: const Offset(0, 0),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Choose your workout program',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.8),
                              blurRadius: 10,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Quick Actions Grid
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.2,
                        children: [
                          _QuickActionCard(
                            title: 'Custom\nWorkouts',
                            icon: Icons.fitness_center,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF3B3B), Color(0xFFFF6B6B)],
                            ),
                            onTap: () => context.push(AppRoutes.workoutLibrary),
                          ),
                          _QuickActionCard(
                            title: 'Workout\nHistory',
                            icon: Icons.history,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF9333EA), Color(0xFFC084FC)],
                            ),
                            onTap: () => context.push(AppRoutes.workoutHistory),
                          ),
                          _QuickActionCard(
                            title: 'AI Workout\nGenerator',
                            icon: Icons.auto_awesome,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
                            ),
                            onTap: () => context.push('/ai-workout'),
                          ),
                          _QuickActionCard(
                            title: 'Workout\nPlanner',
                            icon: Icons.calendar_today,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF059669), Color(0xFF34D399)],
                            ),
                            onTap: () {
                              // TODO: Add workout planner route
                            },
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Program Categories
                      const Text(
                        'WORKOUT PROGRAMS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'BebasNeue',
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      _ProgramCard(
                        title: 'Beginner Programs',
                        subtitle: 'Perfect for starting your fitness journey',
                        icon: Icons.directions_walk,
                        color: const Color(0xFF059669),
                        workoutCount: workoutProvider.getWorkoutsByDifficulty('Beginner').length,
                        onTap: () => context.push('${AppRoutes.training}/beginner'),
                      ),
                      const SizedBox(height: 12),
                      _ProgramCard(
                        title: 'Intermediate Programs',
                        subtitle: 'Take your training to the next level',
                        icon: Icons.directions_run,
                        color: const Color(0xFF3B82F6),
                        workoutCount: workoutProvider.getWorkoutsByDifficulty('Intermediate').length,
                        onTap: () => context.push('${AppRoutes.training}/intermediate'),
                      ),
                      const SizedBox(height: 12),
                      _ProgramCard(
                        title: 'Advanced Programs',
                        subtitle: 'Push your limits and achieve greatness',
                        icon: Icons.flash_on,
                        color: const Color(0xFFFF3B3B),
                        workoutCount: workoutProvider.getWorkoutsByDifficulty('Advanced').length,
                        onTap: () => context.push('${AppRoutes.training}/advanced'),
                      ),
                    ],
                  ),
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

class _QuickActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
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
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: Colors.white,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgramCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final int workoutCount;
  final VoidCallback onTap;

  const _ProgramCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.workoutCount,
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
            color: AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 32,
                ),
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
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$workoutCount workouts available',
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: color,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


