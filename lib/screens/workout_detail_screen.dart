import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/workout_model.dart';
import '../providers/workout_provider.dart';
import '../utils/app_colors.dart';
import '../utils/routes.dart';
import '../widgets/exercise_video_player.dart';
import 'package:go_router/go_router.dart';

class WorkoutDetailScreen extends StatelessWidget {
  final String workoutId;

  const WorkoutDetailScreen({
    super.key,
    required this.workoutId,
  });

  @override
  Widget build(BuildContext context) {
    final workoutProvider = context.watch<WorkoutProvider>();
    final workout = workoutProvider.getWorkoutById(workoutId);

    if (workout == null) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.backgroundGradient,
          ),
          child: const Center(
            child: Text('Workout not found'),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppColors.textWhite),
                      onPressed: () => context.pop(),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.favorite_border, color: AppColors.textWhite),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

              // Workout Info
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        workout.name,
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: AppColors.textWhite,
                          fontSize: 32,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Stats
                      Row(
                        children: [
                          _buildStatChip(Icons.access_time, '${workout.durationMinutes} min'),
                          const SizedBox(width: 12),
                          _buildStatChip(Icons.local_fire_department, '${workout.estimatedCalories} cal'),
                          const SizedBox(width: 12),
                          _buildStatChip(Icons.fitness_center, '${workout.exercises.length} exercises'),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Difficulty Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: _getDifficultyColor(workout.difficulty).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _getDifficultyColor(workout.difficulty),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          workout.difficulty.toUpperCase(),
                          style: TextStyle(
                            color: _getDifficultyColor(workout.difficulty),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Description
                      Text(
                        workout.description ?? 'No description available',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textGray,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Exercise List Header
                      Text(
                        'EXERCISES',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.textWhite,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Exercise List
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: workout.exercises.length,
                        itemBuilder: (context, index) {
                          final exercise = workout.exercises[index];
                          return _ExerciseCard(
                            exercise: exercise,
                            index: index,
                          );
                        },
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // Start Workout Button (Fixed at bottom)
      floatingActionButton: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: ElevatedButton(
          onPressed: () {
            context.push('${AppRoutes.activeWorkout}?workoutId=$workoutId');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryRed,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'START WORKOUT',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textWhite,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildStatChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.textGray, size: 16),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.textGray,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return AppColors.primaryRed;
      default:
        return AppColors.textGray;
    }
  }
}

class _ExerciseCard extends StatefulWidget {
  final Exercise exercise;
  final int index;

  const _ExerciseCard({
    required this.exercise,
    required this.index,
  });

  @override
  State<_ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<_ExerciseCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Exercise Number
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primaryRed.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${widget.index + 1}',
                        style: const TextStyle(
                          color: AppColors.primaryRed,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Exercise Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.exercise.name,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppColors.textWhite,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (widget.exercise.videoUrl != null)
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryRed.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.play_circle_outline,
                                      color: AppColors.primaryRed,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'VIDEO',
                                      style: TextStyle(
                                        color: AppColors.primaryRed,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.exercise.sets} sets × ${widget.exercise.reps} reps',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textGray,
                          ),
                        ),
                        if ((widget.exercise.restSeconds ?? 0) > 0)
                          Text(
                            'Rest: ${widget.exercise.restSeconds}s',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textGray,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Expand/Collapse Icon
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.textGray,
                  ),
                ],
              ),
            ),
          ),

          // Expanded Content
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: AppColors.backgroundDark, height: 1),
                  const SizedBox(height: 16),

                  // Video Tutorial
                  if (widget.exercise.videoUrl != null) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.video_library,
                          color: AppColors.primaryRed,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Video Tutorial',
                          style: TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ExerciseVideoPlayer(
                      videoUrl: widget.exercise.videoUrl!,
                      autoPlay: false,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Instructions
                  if (widget.exercise.instructions != null) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.primaryRed,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Instructions',
                          style: TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.exercise.instructions!,
                      style: TextStyle(
                        color: AppColors.textGray,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}
