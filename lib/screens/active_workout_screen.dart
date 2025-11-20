import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/workout_model.dart';
import '../providers/workout_provider.dart';
import '../providers/gamification_provider.dart';
import '../providers/social_provider.dart';
import '../providers/ai_workout_provider.dart';
import '../models/ai_models.dart';
import '../utils/app_colors.dart';
import 'package:go_router/go_router.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  final String workoutId;

  const ActiveWorkoutScreen({
    super.key,
    required this.workoutId,
  });

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  int _currentExerciseIndex = 0;
  int _currentSet = 1;
  bool _isResting = false;
  int _restSecondsRemaining = 0;
  Timer? _restTimer;
  Timer? _workoutTimer;
  int _workoutSecondsElapsed = 0;
  final List<SetLog> _completedSets = [];
  WorkoutProgram? _workout;

  @override
  void initState() {
    super.initState();
    _startWorkoutTimer();
    // Load workout after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWorkout();
    });
  }

  void _loadWorkout() {
    final workoutProvider = context.read<WorkoutProvider>();
    _workout = workoutProvider.getWorkoutById(widget.workoutId);
    if (_workout != null) {
      workoutProvider.startWorkout(_workout!);
      setState(() {});
    }
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
    _restTimer?.cancel();
    _workoutTimer?.cancel();
    super.dispose();
  }

  void _completeSet() {
    if (_workout == null) return;

    final currentExercise = _workout!.exercises[_currentExerciseIndex];
    
    setState(() {
      _completedSets.add(SetLog(
        setNumber: _currentSet,
        reps: currentExercise.reps,
        weight: 0, // Can be enhanced later to allow user input
      ));

      if (_currentSet < currentExercise.sets) {
        // More sets remaining for this exercise
        _currentSet++;
        _startRestTimer(currentExercise.restSeconds ?? 0);
      } else {
        // Move to next exercise
        if (_currentExerciseIndex < _workout!.exercises.length - 1) {
          _currentExerciseIndex++;
          _currentSet = 1;
          _startRestTimer(currentExercise.restSeconds ?? 0);
        } else {
          // Workout complete!
          _completeWorkout();
        }
      }
    });
  }

  void _startRestTimer(int seconds) {
    if (seconds == 0) return;
    
    setState(() {
      _isResting = true;
      _restSecondsRemaining = seconds;
    });

    _restTimer?.cancel();
    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _restSecondsRemaining--;
        if (_restSecondsRemaining <= 0) {
          _isResting = false;
          timer.cancel();
        }
      });
    });
  }

  void _skipRest() {
    _restTimer?.cancel();
    setState(() {
      _isResting = false;
      _restSecondsRemaining = 0;
    });
  }

  void _completeWorkout() async {
    _workoutTimer?.cancel();
    _restTimer?.cancel();

    final workoutProvider = context.read<WorkoutProvider>();
    workoutProvider.completeWorkout();

    // Award gamification rewards
    final gamificationProvider = context.read<GamificationProvider>();
    final result = await gamificationProvider.onWorkoutCompleted();
    
    // Track muscle recovery for AI
    final aiProvider = context.read<AIWorkoutProvider>();
    final muscleGroups = _getMuscleGroupsFromExercises();
    final volumeLoad = (_workoutSecondsElapsed / 60.0) * (_workout?.exercises.length ?? 1);
    final intensity = _estimateIntensity();
    for (final muscleGroup in muscleGroups) {
      aiProvider.updateMuscleRecovery(muscleGroup, volumeLoad, intensity);
    }
    
    // Post to social feed
    final socialProvider = context.read<SocialProvider>();
    await socialProvider.postWorkout(
      workoutName: _workout!.name,
      durationMinutes: _workoutSecondsElapsed ~/ 60,
      exercisesCompleted: _workout!.exercises.length,
      caloriesBurned: _calculateCalories(),
      personalRecords: [],
      xpGained: result.xpGained,
      achievements: result.unlockedAchievements.map((a) => a.name).toList(),
    );
    
    // Show completion dialog with achievements
    if (mounted) {
      _showCompletionDialog(result);
    }
  }

  int _calculateCalories() {
    // Rough estimate: 5 calories per minute
    return (_workoutSecondsElapsed ~/ 60) * 5;
  }

  void _showCompletionDialog(WorkoutCompletionResult result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '🎉 WORKOUT COMPLETE!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Bebas Neue',
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSummaryRow('Duration', _formatDuration(_workoutSecondsElapsed)),
            _buildSummaryRow('Exercises', '${_workout!.exercises.length}'),
            _buildSummaryRow('Est. Calories', '${_calculateCalories()}'),
            _buildSummaryRow('XP Gained', '+${result.xpGained}'),
            if (result.leveledUp) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryRed.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Text(
                      '🎊 LEVEL UP!',
                      style: TextStyle(
                        color: AppColors.primaryRed,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (result.newTitle != null)
                      Text(
                        result.newTitle!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
              ),
            ],
            if (result.unlockedAchievements.isNotEmpty) ...[
              const SizedBox(height: 16),
              ...result.unlockedAchievements.map((achievement) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Text(
                        achievement.icon,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              achievement.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              achievement.description,
                              style: TextStyle(
                                color: AppColors.textGray,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )),
            ],
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              context.go('/home'); // Go to home
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
            ),
            child: const Text('DONE'),
          ),
        ],
      ),
    );
  }

  List<String> _getMuscleGroupsFromExercises() {
    if (_workout == null) return [];
    
    final Set<String> muscleGroups = {};
    for (final exercise in _workout!.exercises) {
      final name = exercise.name.toLowerCase();
      if (name.contains('chest') || name.contains('bench') || name.contains('push up')) {
        muscleGroups.add('Chest');
      }
      if (name.contains('back') || name.contains('row') || name.contains('pull')) {
        muscleGroups.add('Back');
      }
      if (name.contains('leg') || name.contains('squat') || name.contains('lunge')) {
        muscleGroups.add('Legs');
      }
      if (name.contains('shoulder') || name.contains('press')) {
        muscleGroups.add('Shoulders');
      }
      if (name.contains('arm') || name.contains('curl') || name.contains('tricep')) {
        muscleGroups.add('Arms');
      }
      if (name.contains('core') || name.contains('abs') || name.contains('plank')) {
        muscleGroups.add('Core');
      }
    }
    return muscleGroups.isEmpty ? ['Chest', 'Back', 'Legs'] : muscleGroups.toList();
  }

  WorkoutIntensity _estimateIntensity() {
    final minutes = _workoutSecondsElapsed ~/ 60;
    if (minutes < 20) return WorkoutIntensity.light;
    if (minutes < 40) return WorkoutIntensity.moderate;
    if (minutes < 60) return WorkoutIntensity.hard;
    return WorkoutIntensity.extreme;
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppColors.textGray)),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _quitWorkout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        title: const Text(
          'Quit Workout?',
          style: TextStyle(color: AppColors.textWhite),
        ),
        content: const Text(
          'Your progress will not be saved.',
          style: TextStyle(color: AppColors.textGray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: AppColors.textGray)),
          ),
          TextButton(
            onPressed: () {
              _workoutTimer?.cancel();
              _restTimer?.cancel();
              Navigator.pop(context);
              context.pop();
            },
            child: const Text('QUIT', style: TextStyle(color: AppColors.primaryRed)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_workout == null) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.backgroundGradient,
          ),
          child: const Center(
            child: Text('Workout not found', style: TextStyle(color: AppColors.textWhite)),
          ),
        ),
      );
    }

    final currentExercise = _workout!.exercises[_currentExerciseIndex];
    final progress = (_currentExerciseIndex + 1) / _workout!.exercises.length;

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
                      icon: const Icon(Icons.close, color: AppColors.textWhite),
                      onPressed: _quitWorkout,
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            _formatDuration(_workoutSecondsElapsed),
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.textWhite,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Exercise ${_currentExerciseIndex + 1} of ${_workout!.exercises.length}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 48), // Balance the close button
                  ],
                ),
              ),

              // Progress Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.backgroundCard,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryRed),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 32),

              // Main Content
              Expanded(
                child: _isResting ? _buildRestScreen() : _buildExerciseScreen(currentExercise),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseScreen(Exercise exercise) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Exercise Image Placeholder
          Container(
            width: double.infinity,
            height: 250,
            decoration: BoxDecoration(
              color: AppColors.backgroundCard,
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
                  'Exercise Demo',
                  style: TextStyle(
                    color: AppColors.textGray.withOpacity(0.5),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Exercise Name
          Text(
            exercise.name,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              color: AppColors.textWhite,
              fontSize: 28,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Set Info
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.backgroundCard,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  'SET $_currentSet OF ${exercise.sets}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primaryRed,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${exercise.reps}',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: AppColors.textWhite,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'REPS',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.textGray,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Complete Set Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _completeSet,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'COMPLETE SET',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textWhite,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Skip Exercise Button
          TextButton(
            onPressed: () {
              if (_currentExerciseIndex < _workout!.exercises.length - 1) {
                setState(() {
                  _currentExerciseIndex++;
                  _currentSet = 1;
                });
              } else {
                _completeWorkout();
              }
            },
            child: const Text(
              'Skip Exercise',
              style: TextStyle(
                color: AppColors.textGray,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestScreen() {
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
              child: const Icon(
                Icons.timer,
                size: 60,
                color: AppColors.primaryRed,
              ),
            ),
            const SizedBox(height: 32),

            // Rest Title
            Text(
              'REST',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: AppColors.textWhite,
                fontSize: 32,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 24),

            // Countdown Timer
            Text(
              '$_restSecondsRemaining',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: AppColors.primaryRed,
                fontSize: 72,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'seconds',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textGray,
              ),
            ),
            const SizedBox(height: 32),

            // Add/Remove Time Buttons
            Row(
              children: [
                Expanded(
                  child: _buildTimeButton('-15s', () {
                    setState(() {
                      _restSecondsRemaining = (_restSecondsRemaining - 15).clamp(0, 999);
                      if (_restSecondsRemaining <= 0) {
                        _skipRest();
                      }
                    });
                  }),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTimeButton('+15s', () {
                    setState(() {
                      _restSecondsRemaining += 15;
                    });
                  }),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTimeButton('+30s', () {
                    setState(() {
                      _restSecondsRemaining += 30;
                    });
                  }),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Skip Rest Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _skipRest,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  side: const BorderSide(color: AppColors.primaryRed, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'SKIP REST',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primaryRed,
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

  Widget _buildTimeButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.backgroundCard,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textWhite,
          fontWeight: FontWeight.bold,
          fontSize: 13,
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
