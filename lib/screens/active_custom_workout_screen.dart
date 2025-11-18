import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/custom_workout_model.dart';
import '../providers/custom_workout_provider.dart';
import '../utils/app_colors.dart';
import 'package:go_router/go_router.dart';

class ActiveCustomWorkoutScreen extends StatefulWidget {
  const ActiveCustomWorkoutScreen({super.key});

  @override
  State<ActiveCustomWorkoutScreen> createState() => _ActiveCustomWorkoutScreenState();
}

class _ActiveCustomWorkoutScreenState extends State<ActiveCustomWorkoutScreen> {
  Timer? _workoutTimer;
  int _workoutSecondsElapsed = 0;

  @override
  void initState() {
    super.initState();
    _startWorkoutTimer();
  }

  void _startWorkoutTimer() {
    _workoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _workoutSecondsElapsed++;
      });
    });
  }

  @override
  void dispose() {
    _workoutTimer?.cancel();
    super.dispose();
  }

  void _completeSet(CustomWorkoutProvider provider, int exerciseIndex, int setIndex) {
    if (provider.activeWorkout == null) return;
    
    provider.completeSet(exerciseIndex, setIndex);
    
    final workout = provider.activeWorkout;
    if (workout == null || exerciseIndex >= workout.exercises.length) return;
    
    final exercise = workout.exercises[exerciseIndex];
    
    // Check if we need to start rest timer
    if (setIndex < exercise.sets.length - 1 || exerciseIndex < workout.exercises.length - 1) {
      provider.startRestTimer(exercise.restTime);
    }
  }

  void _completeWorkout(CustomWorkoutProvider provider) {
    _workoutTimer?.cancel();
    provider.finishWorkout();
    
    context.go('/workout-summary?duration=$_workoutSecondsElapsed&exercises=${provider.activeWorkout?.exercises.length ?? 0}');
  }

  void _quitWorkout(CustomWorkoutProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF333333),
        title: const Text(
          'Quit Workout?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Your progress will not be saved.',
          style: TextStyle(color: Color(0xFF696969)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: Color(0xFF696969))),
          ),
          TextButton(
            onPressed: () {
              _workoutTimer?.cancel();
              provider.cancelWorkout();
              Navigator.pop(context);
              context.pop();
            },
            child: Text('QUIT', style: TextStyle(color: AppColors.primaryRed)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CustomWorkoutProvider>(
      builder: (context, provider, child) {
        final workout = provider.activeWorkout;
        
        if (workout == null || workout.exercises.isEmpty) {
          return Scaffold(
            backgroundColor: const Color(0xFF0F0F0F),
            body: const Center(
              child: Text(
                'No active workout',
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }

        final exerciseIndex = provider.activeExerciseIndex.clamp(0, workout.exercises.length - 1);
        final currentExercise = workout.exercises[exerciseIndex];
        final progress = (exerciseIndex + 1) / workout.exercises.length;

        return Scaffold(
          backgroundColor: const Color(0xFF0F0F0F),
          body: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => _quitWorkout(provider),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              _formatDuration(_workoutSecondsElapsed),
                              style: const TextStyle(
                                fontFamily: 'Bebas Neue',
                                fontSize: 24,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Exercise ${exerciseIndex + 1} of ${workout.exercises.length}',
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                // Progress Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: const Color(0xFF333333),
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryRed),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 32),

                // Main Content
                Expanded(
                  child: provider.isRestTimerActive
                      ? _buildRestScreen(provider)
                      : _buildExerciseScreen(provider, currentExercise, exerciseIndex),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildExerciseScreen(CustomWorkoutProvider provider, WorkoutExercise exercise, int exerciseIndex) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Exercise Image Placeholder
          Container(
            width: double.infinity,
            height: 250,
            decoration: BoxDecoration(
              color: const Color(0xFF333333),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.fitness_center,
                  size: 80,
                  color: AppColors.primaryRed.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  exercise.template.name,
                  style: const TextStyle(
                    fontFamily: 'DM Sans',
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Exercise Name
          Text(
            exercise.template.name,
            style: const TextStyle(
              fontFamily: 'Bebas Neue',
              color: Colors.white,
              fontSize: 28,
              letterSpacing: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            exercise.template.muscleGroup,
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 14,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),

          // Sets Section
          Text(
            'SETS',
            style: TextStyle(
              fontFamily: 'Bebas Neue',
              fontSize: 18,
              color: Colors.white.withOpacity(0.8),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),

          // Sets List
          ...List.generate(exercise.sets.length, (setIndex) {
            final set = exercise.sets[setIndex];
            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: set.isCompleted
                    ? AppColors.primaryRed.withOpacity(0.2)
                    : const Color(0xFF333333),
                borderRadius: BorderRadius.circular(12),
                border: set.isCompleted
                    ? Border.all(color: AppColors.primaryRed, width: 2)
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: set.isCompleted
                          ? AppColors.primaryRed
                          : Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${setIndex + 1}',
                        style: const TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Set ${setIndex + 1}',
                          style: const TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${set.reps} reps${(set.weight ?? 0) > 0 ? ' • ${set.weight}kg' : ''}',
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!set.isCompleted)
                    SizedBox(
                      width: 70,
                      height: 36,
                      child: ElevatedButton(
                        onPressed: () => _completeSet(provider, exerciseIndex, setIndex),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryRed,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        child: const Text(
                          'DONE',
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  else
                    const Icon(Icons.check_circle, color: Colors.green, size: 32),
                ],
              ),
            );
          }),
          const SizedBox(height: 24),

          // Next Exercise Button
          if (exercise.isComplete)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (exerciseIndex < provider.activeWorkout!.exercises.length - 1) {
                    provider.nextExercise();
                  } else {
                    _completeWorkout(provider);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryRed,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  exerciseIndex < provider.activeWorkout!.exercises.length - 1
                      ? 'NEXT EXERCISE'
                      : 'FINISH WORKOUT',
                  style: const TextStyle(
                    fontFamily: 'Bebas Neue',
                    fontSize: 16,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRestScreen(CustomWorkoutProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Rest Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primaryRed.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.timer,
                size: 60,
                color: AppColors.primaryRed,
              ),
            ),
            const SizedBox(height: 32),

            // Rest Title
            const Text(
              'REST',
              style: TextStyle(
                fontFamily: 'Bebas Neue',
                color: Colors.white,
                fontSize: 32,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 24),

            // Countdown Timer
            Text(
              '${provider.remainingRestTime}',
              style: TextStyle(
                fontFamily: 'Bebas Neue',
                color: AppColors.primaryRed,
                fontSize: 72,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'seconds',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 16,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 32),

            // Add/Remove Time Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => provider.addRestTime(-15),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF333333),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      '-15s',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => provider.addRestTime(15),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF333333),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      '+15s',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => provider.addRestTime(30),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF333333),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      '+30s',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Skip Rest Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => provider.skipRest(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  side: BorderSide(color: AppColors.primaryRed, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'SKIP REST',
                  style: TextStyle(
                    fontFamily: 'Bebas Neue',
                    color: AppColors.primaryRed,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
