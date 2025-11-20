import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/custom_workout_provider.dart';
import '../providers/workout_provider.dart';
import '../providers/gamification_provider.dart';
import '../utils/app_colors.dart';
import '../models/workout_model.dart';
import '../models/gamification_model.dart';
import 'workout_share_screen.dart';

enum WorkoutFilter {
  today,
  yesterday,
  lastWeek,
  all,
}

class WorkoutHistoryScreen extends StatefulWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  State<WorkoutHistoryScreen> createState() => _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends State<WorkoutHistoryScreen> {
  WorkoutFilter _selectedFilter = WorkoutFilter.today;

  @override
  Widget build(BuildContext context) {
    final customWorkoutProvider = context.watch<CustomWorkoutProvider>();
    final workoutProvider = context.watch<WorkoutProvider>();
    final gamificationProvider = context.watch<GamificationProvider>();

    // Combine all workouts from different sources
    final allWorkouts = _combineAllWorkouts(
      customWorkoutProvider.completedWorkouts,
      workoutProvider.workoutHistory,
    );

    // Filter workouts
    final filteredWorkouts = _filterWorkouts(allWorkouts);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'WORKOUT HISTORY',
                      style: TextStyle(
                        fontFamily: 'Bebas Neue',
                        fontSize: 28,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),

              // Filter Chips
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Today', WorkoutFilter.today),
                      const SizedBox(width: 8),
                      _buildFilterChip('Yesterday', WorkoutFilter.yesterday),
                      const SizedBox(width: 8),
                      _buildFilterChip('Last Week', WorkoutFilter.lastWeek),
                      const SizedBox(width: 8),
                      _buildFilterChip('All Time', WorkoutFilter.all),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Workouts List
              Expanded(
                child: filteredWorkouts.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: filteredWorkouts.length,
                        itemBuilder: (context, index) {
                          final workout = filteredWorkouts[index];
                          return _buildWorkoutCard(
                            context,
                            workout,
                            gamificationProvider,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, WorkoutFilter filter) {
    final isSelected = _selectedFilter == filter;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = filter),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.redGradient : null,
          color: isSelected ? null : AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.inputBorder,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    String message;
    switch (_selectedFilter) {
      case WorkoutFilter.today:
        message = 'No workouts completed today yet';
      case WorkoutFilter.yesterday:
        message = 'No workouts completed yesterday';
      case WorkoutFilter.lastWeek:
        message = 'No workouts in the last 7 days';
      case WorkoutFilter.all:
        message = 'No workout history available';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center,
            size: 64,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutCard(
    BuildContext context,
    UnifiedWorkout workout,
    GamificationProvider gamificationProvider,
  ) {
    // Get achievements for this workout
    final workoutAchievements = gamificationProvider.achievements
        .where((a) => 
            a.isUnlocked &&
            a.unlockedDate != null &&
            _isSameDay(a.unlockedDate!, workout.completedAt))
        .take(2)
        .toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _shareWorkout(
            context,
            workout,
            workoutAchievements,
          ),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            workout.name,
                            style: const TextStyle(
                              fontFamily: 'Bebas Neue',
                              fontSize: 20,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDate(workout.completedAt),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: AppColors.redGradient,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.share,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Stats Row
                Row(
                  children: [
                    _buildStat(Icons.timer, '${workout.duration} min'),
                    const SizedBox(width: 16),
                    _buildStat(
                        Icons.fitness_center, '${workout.exercises} exercises'),
                    const SizedBox(width: 16),
                    _buildStat(Icons.local_fire_department, '${workout.calories} cal'),
                  ],
                ),

                // Achievements (if any)
                if (workoutAchievements.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: workoutAchievements.map((achievement) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accentOrange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.accentOrange.withOpacity(0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              achievement.icon,
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              achievement.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStat(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: AppColors.primaryRed,
          size: 16,
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  List<UnifiedWorkout> _combineAllWorkouts(
    List<WorkoutCompletionRecord> customWorkouts,
    List<WorkoutSession> programWorkouts,
  ) {
    final List<UnifiedWorkout> combined = [];

    // Add custom workouts
    for (var workout in customWorkouts) {
      combined.add(UnifiedWorkout(
        name: workout.workoutName,
        completedAt: workout.completedAt,
        duration: workout.durationMinutes,
        exercises: workout.exerciseCount,
        calories: workout.durationMinutes * 5,
        type: 'Custom',
      ));
    }

    // Add program workouts
    for (var session in programWorkouts) {
      if (session.isCompleted && session.endTime != null) {
        final duration = session.duration?.inMinutes ?? 0;
        combined.add(UnifiedWorkout(
          name: 'Workout Session',
          completedAt: session.endTime!,
          duration: duration,
          exercises: session.exerciseLogs.length,
          calories: duration * 5,
          type: 'Program',
        ));
      }
    }

    // Sort by date (most recent first)
    combined.sort((a, b) => b.completedAt.compareTo(a.completedAt));

    return combined;
  }

  List<UnifiedWorkout> _filterWorkouts(List<UnifiedWorkout> workouts) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final lastWeek = today.subtract(const Duration(days: 7));

    switch (_selectedFilter) {
      case WorkoutFilter.today:
        return workouts.where((w) => _isSameDay(w.completedAt, today)).toList();

      case WorkoutFilter.yesterday:
        return workouts.where((w) => _isSameDay(w.completedAt, yesterday)).toList();

      case WorkoutFilter.lastWeek:
        return workouts
            .where((w) =>
                w.completedAt.isAfter(lastWeek) ||
                w.completedAt.isAtSameMomentAs(lastWeek))
            .toList();

      case WorkoutFilter.all:
        return workouts;
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (_isSameDay(date, today)) {
      return 'Today at ${_formatTime(date)}';
    } else if (_isSameDay(date, yesterday)) {
      return 'Yesterday at ${_formatTime(date)}';
    } else {
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return '${months[date.month - 1]} ${date.day} at ${_formatTime(date)}';
    }
  }

  String _formatTime(DateTime date) {
    final hour =
        date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  void _shareWorkout(
    BuildContext context,
    UnifiedWorkout workout,
    List<Achievement> achievements,
  ) {
    final xpGained = workout.duration * 10;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutShareScreen(
          workoutName: workout.name,
          durationSeconds: workout.duration * 60,
          exercisesCompleted: workout.exercises,
          caloriesBurned: workout.calories,
          xpGained: xpGained,
          achievementsUnlocked: achievements,
          note: '',
          completedAt: workout.completedAt,
        ),
      ),
    );
  }
}

// Helper class to unify different workout types
class UnifiedWorkout {
  final String name;
  final DateTime completedAt;
  final int duration;
  final int exercises;
  final int calories;
  final String type;

  UnifiedWorkout({
    required this.name,
    required this.completedAt,
    required this.duration,
    required this.exercises,
    required this.calories,
    required this.type,
  });
}
