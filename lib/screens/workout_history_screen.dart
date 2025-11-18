import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/custom_workout_provider.dart';
import '../utils/app_colors.dart';
import 'package:intl/intl.dart';

class WorkoutHistoryScreen extends StatelessWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'WORKOUT HISTORY',
          style: TextStyle(
            fontFamily: 'Bebas Neue',
            fontSize: 24,
            letterSpacing: 1.5,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<CustomWorkoutProvider>(
        builder: (context, provider, child) {
          final completedWorkouts = provider.completedWorkouts;

          if (completedWorkouts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 80,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Workout History',
                    style: TextStyle(
                      fontFamily: 'Bebas Neue',
                      fontSize: 24,
                      color: Colors.white.withOpacity(0.6),
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Complete a workout to see it here',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats Overview
                _buildStatsOverview(completedWorkouts),
                const SizedBox(height: 32),

                // Recent Workouts
                const Text(
                  'RECENT WORKOUTS',
                  style: TextStyle(
                    fontFamily: 'Bebas Neue',
                    fontSize: 20,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 16),

                // Workout History List
                ...completedWorkouts.reversed.map((record) {
                  return _buildWorkoutCard(record);
                }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsOverview(List<WorkoutCompletionRecord> workouts) {
    final totalWorkouts = workouts.length;
    final totalDuration = workouts.fold<int>(
      0,
      (sum, record) => sum + record.durationMinutes,
    );
    final totalExercises = workouts.fold<int>(
      0,
      (sum, record) => sum + record.exerciseCount,
    );
    final avgDuration = totalWorkouts > 0 ? totalDuration ~/ totalWorkouts : 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryRed.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          const Text(
            'YOUR STATS',
            style: TextStyle(
              fontFamily: 'Bebas Neue',
              fontSize: 18,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Total\nWorkouts', totalWorkouts.toString()),
              _buildStatItem('Total Time', '${totalDuration}m'),
              _buildStatItem('Avg Duration', '${avgDuration}m'),
              _buildStatItem('Exercises', totalExercises.toString()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Bebas Neue',
            fontSize: 32,
            color: AppColors.primaryRed,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 12,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildWorkoutCard(WorkoutCompletionRecord record) {
    final date = DateFormat('MMM dd, yyyy').format(record.completedAt);
    final time = DateFormat('h:mm a').format(record.completedAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF333333),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  record.workoutName,
                  style: const TextStyle(
                    fontFamily: 'Bebas Neue',
                    fontSize: 20,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryRed.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  record.category,
                  style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 12,
                    color: AppColors.primaryRed,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Date and Time
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 14,
                color: Colors.white.withOpacity(0.5),
              ),
              const SizedBox(width: 6),
              Text(
                date,
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.access_time,
                size: 14,
                color: Colors.white.withOpacity(0.5),
              ),
              const SizedBox(width: 6),
              Text(
                time,
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Stats
          Row(
            children: [
              _buildCardStat(Icons.fitness_center, '${record.exerciseCount} Exercises'),
              const SizedBox(width: 20),
              _buildCardStat(Icons.timer, '${record.durationMinutes} min'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardStat(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.primaryRed,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 13,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
