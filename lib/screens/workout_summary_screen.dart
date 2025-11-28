import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/routes.dart';
import 'package:go_router/go_router.dart';

class WorkoutSummaryScreen extends StatelessWidget {
  final int durationSeconds;
  final int exercisesCompleted;

  const WorkoutSummaryScreen({
    super.key,
    required this.durationSeconds,
    required this.exercisesCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    final estimatedCalories = (durationSeconds / 60 * 5).toInt(); // Rough estimate

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const Spacer(),

                // Success Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.primaryRed.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    size: 80,
                    color: AppColors.primaryRed,
                  ),
                ),
                const SizedBox(height: 32),

                // Congratulations Title
                Text(
                  'WORKOUT',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: AppColors.textWhite,
                    fontSize: 32,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'COMPLETE!',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: AppColors.primaryRed,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 48),

                // Stats Cards
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundCard,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _buildStatRow(
                        icon: Icons.access_time,
                        label: 'Duration',
                        value: '$minutes min $seconds sec',
                      ),
                      const Divider(
                        height: 32,
                        color: AppColors.backgroundDark,
                      ),
                      _buildStatRow(
                        icon: Icons.fitness_center,
                        label: 'Exercises',
                        value: '$exercisesCompleted completed',
                      ),
                      const Divider(
                        height: 32,
                        color: AppColors.backgroundDark,
                      ),
                      _buildStatRow(
                        icon: Icons.local_fire_department,
                        label: 'Calories',
                        value: '~$estimatedCalories cal',
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                // Motivational Message
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primaryRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primaryRed.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '"The only bad workout is the one that didn\'t happen."',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textWhite,
                      fontStyle: FontStyle.italic,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),

                // Done Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate back to training hub
                      context.go(AppRoutes.training);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryRed,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'DONE',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textWhite,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // View Progress Button
                TextButton(
                  onPressed: () {
                    context.go(AppRoutes.progress);
                  },
                  child: const Text(
                    'View Progress',
                    style: TextStyle(
                      color: AppColors.textGray,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primaryRed.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppColors.primaryRed,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textGray,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
