import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/custom_workout_provider.dart';
import '../models/custom_workout_model.dart';
import '../utils/routes.dart';
import '../utils/app_colors.dart';

class WorkoutLibraryScreen extends StatelessWidget {
  const WorkoutLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go(AppRoutes.home),
        ),
        title: const Text(
          'MY WORKOUTS',
          style: TextStyle(
            fontFamily: 'Bebas Neue',
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Color(0xFFC22F42)),
            onPressed: () => context.push(AppRoutes.workoutBuilder),
          ),
        ],
      ),
      body: Consumer<CustomWorkoutProvider>(
        builder: (context, provider, child) {
          if (provider.customWorkouts.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Favorites Section
              if (provider.favoriteWorkouts.isNotEmpty) ...[
                const Text(
                  'FAVORITES',
                  style: TextStyle(
                    fontFamily: 'Bebas Neue',
                    fontSize: 18,
                    color: Color(0xFFC22F42),
                  ),
                ),
                const SizedBox(height: 12),
                ...provider.favoriteWorkouts.map((workout) =>
                    _buildWorkoutCard(context, workout, provider)),
                const SizedBox(height: 24),
              ],

              // All Workouts Section
              const Text(
                'ALL WORKOUTS',
                style: TextStyle(
                  fontFamily: 'Bebas Neue',
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              ...provider.customWorkouts.map((workout) =>
                  _buildWorkoutCard(context, workout, provider)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.fitness_center,
            size: 80,
            color: Color(0xFF333333),
          ),
          const SizedBox(height: 20),
          const Text(
            'NO CUSTOM WORKOUTS YET',
            style: TextStyle(
              fontFamily: 'Bebas Neue',
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create your first custom workout\nto get started!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 14,
              color: Color(0xFF696969),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.push(AppRoutes.workoutBuilder),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'CREATE WORKOUT',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutCard(BuildContext context, CustomWorkout workout,
      CustomWorkoutProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF333333),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/workout-detail/${workout.id}'),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            workout.name.toUpperCase(),
                            style: const TextStyle(
                              fontFamily: 'Bebas Neue',
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                          if (workout.description != null)
                            Text(
                              workout.description!,
                              style: const TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 12,
                                color: Color(0xFF696969),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        workout.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: workout.isFavorite
                            ? const Color(0xFFC22F42)
                            : Colors.white,
                      ),
                      onPressed: () => provider.toggleFavorite(workout.id),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildInfoChip(
                      Icons.fitness_center,
                      '${workout.totalExercises} exercises',
                    ),
                    const SizedBox(width: 12),
                    _buildInfoChip(
                      Icons.timer,
                      '~${workout.estimatedDuration} min',
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F0F0F),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        workout.category.toUpperCase(),
                        style: const TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFC22F42),
                        ),
                      ),
                    ),
                  ],
                ),
                if (workout.lastPerformed != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Last performed: ${_formatDate(workout.lastPerformed!)} • ${workout.timesPerformed}x completed',
                    style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 11,
                      color: Color(0xFF696969),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _showScheduleDialog(context, workout),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFC22F42)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'SCHEDULE',
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFC22F42),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          provider.startWorkout(workout);
                          context.push(AppRoutes.activeCustomWorkout);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryRed,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'START',
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF696969)),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 11,
            color: Color(0xFF696969),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showScheduleDialog(BuildContext context, CustomWorkout workout) {
    context.push(AppRoutes.workoutCalendar);
  }
}
