import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../models/ai_models.dart';
import '../providers/ai_workout_provider.dart';
import '../providers/gamification_provider.dart';
import '../providers/profile_stats_provider.dart';
import '../providers/social_provider.dart';
// import '../providers/workout_history_provider.dart'; // Will be created later
import '../utils/app_colors.dart';
import 'workout_share_screen.dart';
import '../widgets/exercise_video_player.dart';
import '../data/exercise_database.dart';

class ActiveAIWorkoutScreen extends StatefulWidget {
  final AIGeneratedWorkout workout;

  const ActiveAIWorkoutScreen({super.key, required this.workout});

  @override
  State<ActiveAIWorkoutScreen> createState() => _ActiveAIWorkoutScreenState();
}

class _ActiveAIWorkoutScreenState extends State<ActiveAIWorkoutScreen> {
  int _currentExerciseIndex = 0;
  int _currentSet = 1;
  int _elapsedSeconds = 0;
  bool _isResting = false;
  int _restSecondsRemaining = 0;
  Timer? _timer;
  final List<Map<String, dynamic>> _completedSets = [];

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
        if (_isResting && _restSecondsRemaining > 0) {
          _restSecondsRemaining--;
          if (_restSecondsRemaining == 0) {
            _isResting = false;
          }
        }
      });
    });
  }

  AIExerciseBlock get _currentExercise => widget.workout.exercises[_currentExerciseIndex];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundCard,
        title: Text(
          widget.workout.name.toUpperCase(),
          style: const TextStyle(
            fontFamily: 'Bebas Neue',
            fontSize: 20,
            letterSpacing: 1.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _showQuitDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildProgressBar(),
          Expanded(
            child: _isResting ? _buildRestView() : _buildExerciseView(),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = (_currentExerciseIndex + 1) / widget.workout.exercises.length;
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.backgroundCard,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Exercise ${_currentExerciseIndex + 1}/${widget.workout.exercises.length}',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              Text(
                _formatTime(_elapsedSeconds),
                style: const TextStyle(
                  color: AppColors.primaryRed,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryRed),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseView() {
    // Find the exercise in the database to get video URL
    final exerciseData = ExerciseDatabase.findExerciseByName(_currentExercise.exerciseName);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video Player Section
          if (exerciseData?.videoUrl != null && exerciseData!.videoUrl!.isNotEmpty)
            Container(
              width: double.infinity,
              height: 250,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: AppColors.backgroundCard,
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              child: ExerciseVideoPlayer(
                videoUrl: exerciseData.videoUrl!,
                autoPlay: true,
              ),
            ),
          _buildExerciseHeader(),
          const SizedBox(height: 24),
          _buildSetInfo(),
          const SizedBox(height: 24),
          _buildExerciseDetails(),
          const SizedBox(height: 32),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildExerciseHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryRed.withOpacity(0.3),
            AppColors.primaryRedDark.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: AppColors.primaryRed,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.fitness_center, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentExercise.exerciseName,
                      style: const TextStyle(
                        fontFamily: 'Bebas Neue',
                        fontSize: 24,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      _currentExercise.muscleGroup,
                      style: const TextStyle(
                        color: AppColors.textGray,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_currentExercise.notes != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber, width: 1),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline, color: Colors.amber, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _currentExercise.notes!,
                      style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSetInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatColumn('SET', '$_currentSet / ${_currentExercise.sets}'),
              _buildStatColumn('REPS', '${_currentExercise.reps}'),
              _buildStatColumn('REST', '${_currentExercise.restSeconds}s'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textGray,
            fontSize: 12,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Bebas Neue',
            fontSize: 28,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow(Icons.trending_up, 'Difficulty', _currentExercise.difficulty),
          if (_currentExercise.equipment != null) ...[
            const SizedBox(height: 12),
            _buildDetailRow(Icons.fitness_center, 'Equipment', _currentExercise.equipment!.join(', ')),
          ],
          const SizedBox(height: 12),
          _buildDetailRow(Icons.timer, 'Est. Duration', '${_currentExercise.estimatedDuration ~/ 60} min'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryRed, size: 20),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: const TextStyle(
            color: AppColors.textGray,
            fontSize: 13,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
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
              _currentSet < _currentExercise.sets ? 'COMPLETE SET' : 'FINISH EXERCISE',
              style: const TextStyle(
                fontFamily: 'Bebas Neue',
                fontSize: 18,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _skipExercise,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white24),
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'SKIP EXERCISE',
              style: TextStyle(
                fontFamily: 'Bebas Neue',
                fontSize: 16,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRestView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryRed, width: 4),
            ),
            child: Center(
              child: Text(
                '$_restSecondsRemaining',
                style: const TextStyle(
                  fontFamily: 'Bebas Neue',
                  fontSize: 72,
                  color: AppColors.primaryRed,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'REST TIME',
            style: TextStyle(
              fontFamily: 'Bebas Neue',
              fontSize: 24,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isResting = false;
                _restSecondsRemaining = 0;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: const Text('SKIP REST'),
          ),
        ],
      ),
    );
  }

  void _completeSet() {
    _completedSets.add({
      'exercise': _currentExercise.exerciseName,
      'set': _currentSet,
      'reps': _currentExercise.reps,
    });

    if (_currentSet < _currentExercise.sets) {
      // Start rest timer
      setState(() {
        _isResting = true;
        _restSecondsRemaining = _currentExercise.restSeconds;
        _currentSet++;
      });
    } else {
      // Move to next exercise
      _nextExercise();
    }
  }

  void _skipExercise() {
    _nextExercise();
  }

  void _nextExercise() {
    if (_currentExerciseIndex < widget.workout.exercises.length - 1) {
      setState(() {
        _currentExerciseIndex++;
        _currentSet = 1;
        _isResting = false;
      });
    } else {
      _completeWorkout();
    }
  }

  void _completeWorkout() async {
    _timer?.cancel();
    
    // Award gamification rewards
    final gamificationProvider = context.read<GamificationProvider>();
    final result = await gamificationProvider.onWorkoutCompleted();
    
    // Update profile stats
    final profileStatsProvider = context.read<ProfileStatsProvider>();
    await profileStatsProvider.updateWorkoutStats(
      workoutsIncrement: 1,
      weightLifted: 0,
      caloriesBurned: widget.workout.estimatedCalories,
      exerciseName: widget.workout.name,
    );
    
    // Track muscle recovery for AI
    final aiProvider = context.read<AIWorkoutProvider>();
    final muscleGroups = widget.workout.muscleGroupsTargeted;
    final volumeLoad = widget.workout.totalDuration.toDouble() * widget.workout.exercises.length;
    for (final muscleGroup in muscleGroups) {
      aiProvider.updateMuscleRecovery(muscleGroup, volumeLoad, widget.workout.intensity);
    }
    
    // Post to social feed
    final socialProvider = context.read<SocialProvider>();
    await socialProvider.postWorkout(
      workoutName: widget.workout.name,
      durationMinutes: _elapsedSeconds ~/ 60,
      exercisesCompleted: widget.workout.exercises.length,
      caloriesBurned: widget.workout.estimatedCalories,
      personalRecords: [],
      xpGained: result.xpGained,
      achievements: result.unlockedAchievements.map((a) => a.name).toList(),
      note: widget.workout.aiReasoning,
    );
    
    // Show completion dialog
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
            _buildSummaryRow('Duration', _formatTime(_elapsedSeconds)),
            _buildSummaryRow('Exercises', '${widget.workout.exercises.length}'),
            _buildSummaryRow('Est. Calories', '${widget.workout.estimatedCalories}'),
            _buildSummaryRow('XP Gained', '+${(widget.workout.totalDuration / 2).round()}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WorkoutShareScreen(
                    workoutName: widget.workout.name,
                    durationSeconds: _elapsedSeconds,
                    exercisesCompleted: widget.workout.exercises.length,
                    caloriesBurned: widget.workout.estimatedCalories,
                    xpGained: result.xpGained,
                    achievementsUnlocked: result.unlockedAchievements,
                    note: widget.workout.aiReasoning,
                    completedAt: DateTime.now(),
                  ),
                ),
              );
            },
            child: const Text('SHARE', style: TextStyle(color: AppColors.primaryRed)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close workout screen
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

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textGray)),
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

  void _showQuitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        title: const Text('Quit Workout?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Your progress won\'t be saved.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: AppColors.textGray)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close workout screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
            ),
            child: const Text('QUIT'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}
