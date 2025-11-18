import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/custom_workout_model.dart';
import 'community_provider.dart';

class WorkoutCompletionRecord {
  final String workoutId;
  final String workoutName;
  final String category;
  final DateTime completedAt;
  final int durationMinutes;
  final int exerciseCount;

  WorkoutCompletionRecord({
    required this.workoutId,
    required this.workoutName,
    required this.category,
    required this.completedAt,
    required this.durationMinutes,
    required this.exerciseCount,
  });

  Map<String, dynamic> toJson() => {
    'workoutId': workoutId,
    'workoutName': workoutName,
    'category': category,
    'completedAt': completedAt.toIso8601String(),
    'durationMinutes': durationMinutes,
    'exerciseCount': exerciseCount,
  };

  factory WorkoutCompletionRecord.fromJson(Map<String, dynamic> json) {
    return WorkoutCompletionRecord(
      workoutId: json['workoutId'],
      workoutName: json['workoutName'],
      category: json['category'],
      completedAt: DateTime.parse(json['completedAt']),
      durationMinutes: json['durationMinutes'],
      exerciseCount: json['exerciseCount'],
    );
  }
}

class CustomWorkoutProvider with ChangeNotifier {
  List<CustomWorkout> _customWorkouts = [];
  List<ScheduledWorkout> _scheduledWorkouts = [];
  List<ExerciseTemplate> _exerciseTemplates = [];
  List<WorkoutCompletionRecord> _completionHistory = [];
  CustomWorkout? _activeWorkout;
  int _activeExerciseIndex = 0;
  bool _isRestTimerActive = false;
  int _remainingRestTime = 0;
  DateTime? _workoutStartTime;
  CommunityProvider? _communityProvider;

  void setCommunityProvider(CommunityProvider provider) {
    _communityProvider = provider;
  }

  List<CustomWorkout> get customWorkouts => _customWorkouts;
  List<ScheduledWorkout> get scheduledWorkouts => _scheduledWorkouts;
  List<ExerciseTemplate> get exerciseTemplates => _exerciseTemplates;
  List<WorkoutCompletionRecord> get completedWorkouts => _completionHistory;
  CustomWorkout? get activeWorkout => _activeWorkout;
  int get activeExerciseIndex => _activeExerciseIndex;
  bool get isRestTimerActive => _isRestTimerActive;
  int get remainingRestTime => _remainingRestTime;

  WorkoutExercise? get activeExercise {
    if (_activeWorkout != null &&
        _activeExerciseIndex < _activeWorkout!.exercises.length) {
      return _activeWorkout!.exercises[_activeExerciseIndex];
    }
    return null;
  }

  Future<void> loadWorkouts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load custom workouts
      final workoutsData = prefs.getString('custom_workouts');
      if (workoutsData != null) {
        final List<dynamic> workoutsList = jsonDecode(workoutsData);
        _customWorkouts =
            workoutsList.map((w) => CustomWorkout.fromJson(w)).toList();
      }

      // Load scheduled workouts
      final scheduledData = prefs.getString('scheduled_workouts');
      if (scheduledData != null) {
        final List<dynamic> scheduledList = jsonDecode(scheduledData);
        _scheduledWorkouts =
            scheduledList.map((s) => ScheduledWorkout.fromJson(s)).toList();
      }

      // Load completion history
      final historyData = prefs.getString('workout_completion_history');
      if (historyData != null) {
        final List<dynamic> historyList = jsonDecode(historyData);
        _completionHistory =
            historyList.map((h) => WorkoutCompletionRecord.fromJson(h)).toList();
      }

      // Initialize exercise templates
      _initializeExerciseTemplates();

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading workouts: $e');
      _initializeExerciseTemplates();
    }
  }

  Future<void> _saveWorkouts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save custom workouts
      final workoutsJson =
          jsonEncode(_customWorkouts.map((w) => w.toJson()).toList());
      await prefs.setString('custom_workouts', workoutsJson);

      // Save scheduled workouts
      final scheduledJson =
          jsonEncode(_scheduledWorkouts.map((s) => s.toJson()).toList());
      await prefs.setString('scheduled_workouts', scheduledJson);
    } catch (e) {
      debugPrint('Error saving workouts: $e');
    }
  }

  void _initializeExerciseTemplates() {
    _exerciseTemplates = [
      // Chest
      ExerciseTemplate(
        id: 'bench_press',
        name: 'Barbell Bench Press',
        category: 'strength',
        muscleGroup: 'Chest',
        description: 'Classic chest exercise targeting pectorals, shoulders, and triceps.',
      ),
      ExerciseTemplate(
        id: 'dumbbell_press',
        name: 'Dumbbell Chest Press',
        category: 'strength',
        muscleGroup: 'Chest',
        description: 'Unilateral chest press for balanced development.',
      ),
      ExerciseTemplate(
        id: 'push_ups',
        name: 'Push-Ups',
        category: 'strength',
        muscleGroup: 'Chest',
        description: 'Bodyweight exercise for chest, shoulders, and core.',
      ),
      // Back
      ExerciseTemplate(
        id: 'deadlift',
        name: 'Deadlift',
        category: 'strength',
        muscleGroup: 'Back',
        description: 'Full-body compound movement focusing on posterior chain.',
      ),
      ExerciseTemplate(
        id: 'pull_ups',
        name: 'Pull-Ups',
        category: 'strength',
        muscleGroup: 'Back',
        description: 'Bodyweight back exercise for lats and biceps.',
      ),
      ExerciseTemplate(
        id: 'barbell_row',
        name: 'Barbell Row',
        category: 'strength',
        muscleGroup: 'Back',
        description: 'Mid-back compound exercise.',
      ),
      // Legs
      ExerciseTemplate(
        id: 'squat',
        name: 'Barbell Squat',
        category: 'strength',
        muscleGroup: 'Legs',
        description: 'King of leg exercises, works quads, glutes, and hamstrings.',
      ),
      ExerciseTemplate(
        id: 'leg_press',
        name: 'Leg Press',
        category: 'strength',
        muscleGroup: 'Legs',
        description: 'Machine-based leg exercise.',
      ),
      ExerciseTemplate(
        id: 'lunges',
        name: 'Dumbbell Lunges',
        category: 'strength',
        muscleGroup: 'Legs',
        description: 'Unilateral leg exercise for balance and strength.',
      ),
      // Shoulders
      ExerciseTemplate(
        id: 'overhead_press',
        name: 'Overhead Press',
        category: 'strength',
        muscleGroup: 'Shoulders',
        description: 'Compound shoulder exercise.',
      ),
      ExerciseTemplate(
        id: 'lateral_raise',
        name: 'Lateral Raise',
        category: 'strength',
        muscleGroup: 'Shoulders',
        description: 'Isolation exercise for side delts.',
      ),
      // Arms
      ExerciseTemplate(
        id: 'bicep_curl',
        name: 'Barbell Curl',
        category: 'strength',
        muscleGroup: 'Arms',
        description: 'Classic bicep exercise.',
      ),
      ExerciseTemplate(
        id: 'tricep_dips',
        name: 'Tricep Dips',
        category: 'strength',
        muscleGroup: 'Arms',
        description: 'Bodyweight tricep exercise.',
      ),
      // Cardio
      ExerciseTemplate(
        id: 'running',
        name: 'Running',
        category: 'cardio',
        muscleGroup: 'Full Body',
        description: 'Cardiovascular endurance training.',
      ),
      ExerciseTemplate(
        id: 'cycling',
        name: 'Cycling',
        category: 'cardio',
        muscleGroup: 'Legs',
        description: 'Low-impact cardio exercise.',
      ),
      ExerciseTemplate(
        id: 'jump_rope',
        name: 'Jump Rope',
        category: 'cardio',
        muscleGroup: 'Full Body',
        description: 'High-intensity cardio exercise.',
      ),
    ];
  }

  Future<void> addCustomWorkout(CustomWorkout workout) async {
    _customWorkouts.add(workout);
    await _saveWorkouts();
    notifyListeners();
  }

  // Create a custom workout from shared workout data
  Future<void> createWorkoutFromShared({
    required String name,
    required String description,
    required String category,
    required int exerciseCount,
  }) async {
    // For now, create a workout with placeholder exercises based on category
    // In a real app, you'd fetch the actual exercise data from the server
    final exercises = _generatePlaceholderExercises(category, exerciseCount);
    
    final workout = CustomWorkout(
      id: 'workout_${DateTime.now().millisecondsSinceEpoch}',
      name: '$name (Cloned)',
      description: description,
      exercises: exercises,
      category: category,
      estimatedDuration: exerciseCount * 5, // Rough estimate: 5 min per exercise
      createdAt: DateTime.now(),
    );
    
    await addCustomWorkout(workout);
  }

  List<WorkoutExercise> _generatePlaceholderExercises(String category, int count) {
    // Filter templates by category
    final categoryTemplates = _exerciseTemplates.where((template) {
      if (category.toLowerCase() == 'strength') {
        return template.category == 'strength';
      } else if (category.toLowerCase() == 'cardio') {
        return template.category == 'cardio';
      }
      return true; // Include all for mixed/other categories
    }).toList();

    if (categoryTemplates.isEmpty) {
      categoryTemplates.addAll(_exerciseTemplates.take(5));
    }

    final exercises = <WorkoutExercise>[];
    for (int i = 0; i < count && i < categoryTemplates.length; i++) {
      final template = categoryTemplates[i % categoryTemplates.length];
      exercises.add(
        WorkoutExercise(
          id: 'exercise_${DateTime.now().millisecondsSinceEpoch}_$i',
          template: template,
          sets: List.generate(
            3,
            (index) => CustomExerciseSet(reps: 12, weight: 20.0),
          ),
          restTime: 60,
          orderIndex: i,
        ),
      );
    }
    return exercises;
  }

  Future<void> updateCustomWorkout(CustomWorkout workout) async {
    final index = _customWorkouts.indexWhere((w) => w.id == workout.id);
    if (index != -1) {
      _customWorkouts[index] = workout;
      await _saveWorkouts();
      notifyListeners();
    }
  }

  Future<void> deleteCustomWorkout(String workoutId) async {
    _customWorkouts.removeWhere((w) => w.id == workoutId);
    _scheduledWorkouts.removeWhere((s) => s.workout.id == workoutId);
    await _saveWorkouts();
    notifyListeners();
  }

  Future<void> toggleFavorite(String workoutId) async {
    final index = _customWorkouts.indexWhere((w) => w.id == workoutId);
    if (index != -1) {
      _customWorkouts[index] = _customWorkouts[index].copyWith(
        isFavorite: !_customWorkouts[index].isFavorite,
      );
      await _saveWorkouts();
      notifyListeners();
    }
  }

  Future<void> scheduleWorkout(
      CustomWorkout workout, DateTime scheduledDate) async {
    final scheduled = ScheduledWorkout(
      id: '${workout.id}_${scheduledDate.millisecondsSinceEpoch}',
      workout: workout,
      scheduledDate: scheduledDate,
    );
    _scheduledWorkouts.add(scheduled);
    await _saveWorkouts();
    notifyListeners();
  }

  Future<void> unscheduleWorkout(String scheduledWorkoutId) async {
    _scheduledWorkouts.removeWhere((s) => s.id == scheduledWorkoutId);
    await _saveWorkouts();
    notifyListeners();
  }

  Future<void> completeScheduledWorkout(String scheduledWorkoutId) async {
    final index = _scheduledWorkouts.indexWhere((s) => s.id == scheduledWorkoutId);
    if (index != -1) {
      _scheduledWorkouts[index] = _scheduledWorkouts[index].copyWith(
        isCompleted: true,
        completedAt: DateTime.now(),
      );
      
      // Update workout stats
      final workoutId = _scheduledWorkouts[index].workout.id;
      final workoutIndex = _customWorkouts.indexWhere((w) => w.id == workoutId);
      if (workoutIndex != -1) {
        _customWorkouts[workoutIndex] = _customWorkouts[workoutIndex].copyWith(
          timesPerformed: _customWorkouts[workoutIndex].timesPerformed + 1,
          lastPerformed: DateTime.now(),
        );
      }
      
      // Add to completion history
      final workout = _scheduledWorkouts[index].workout;
      final completionRecord = WorkoutCompletionRecord(
        workoutId: workout.id,
        workoutName: workout.name,
        category: workout.category,
        completedAt: DateTime.now(),
        durationMinutes: workout.estimatedDuration,
        exerciseCount: workout.exercises.length,
      );
      _completionHistory.add(completionRecord);
      await _saveCompletionHistory();
      
      // Check achievements
      if (_communityProvider != null) {
        await _communityProvider!.checkAchievements(
          totalCompletedWorkouts,
          getCurrentStreak(),
        );
        
        // Update challenge progress
        await _updateChallengeProgress();
      }
      
      await _saveWorkouts();
      notifyListeners();
    }
  }

  List<ScheduledWorkout> getWorkoutsForDate(DateTime date) {
    return _scheduledWorkouts.where((s) {
      return s.scheduledDate.year == date.year &&
          s.scheduledDate.month == date.month &&
          s.scheduledDate.day == date.day;
    }).toList();
  }

  List<ScheduledWorkout> getWorkoutsForWeek(DateTime startDate) {
    final endDate = startDate.add(const Duration(days: 7));
    return _scheduledWorkouts.where((s) {
      return s.scheduledDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
          s.scheduledDate.isBefore(endDate);
    }).toList();
  }

  // Active workout session management
  void startWorkout(CustomWorkout workout) {
    _activeWorkout = workout.copyWith(
      exercises: workout.exercises
          .map((e) => e.copyWith(
                sets: e.sets
                    .map((s) => s.copyWith(isCompleted: false))
                    .toList(),
              ))
          .toList(),
    );
    _activeExerciseIndex = 0;
    _workoutStartTime = DateTime.now();
    notifyListeners();
  }

  void completeSet(int exerciseIndex, int setIndex) {
    if (_activeWorkout == null) return;

    final exercises = List<WorkoutExercise>.from(_activeWorkout!.exercises);
    final exercise = exercises[exerciseIndex];
    final sets = List<CustomExerciseSet>.from(exercise.sets);
    sets[setIndex] = sets[setIndex].copyWith(isCompleted: true);
    exercises[exerciseIndex] = exercise.copyWith(sets: sets);
    _activeWorkout = _activeWorkout!.copyWith(exercises: exercises);

    // Auto-start rest timer after completing a set
    if (setIndex < sets.length - 1) {
      startRestTimer(exercise.restTime);
    }

    notifyListeners();
  }

  void startRestTimer(int seconds) {
    _isRestTimerActive = true;
    _remainingRestTime = seconds;
    notifyListeners();
  }

  void decrementRestTime() {
    if (_remainingRestTime > 0) {
      _remainingRestTime--;
      if (_remainingRestTime == 0) {
        _isRestTimerActive = false;
      }
      notifyListeners();
    }
  }

  void skipRest() {
    _isRestTimerActive = false;
    _remainingRestTime = 0;
    notifyListeners();
  }

  void addRestTime(int seconds) {
    _remainingRestTime += seconds;
    notifyListeners();
  }

  void nextExercise() {
    if (_activeWorkout != null &&
        _activeExerciseIndex < _activeWorkout!.exercises.length - 1) {
      _activeExerciseIndex++;
      notifyListeners();
    }
  }

  void previousExercise() {
    if (_activeExerciseIndex > 0) {
      _activeExerciseIndex--;
      notifyListeners();
    }
  }

  Future<void> finishWorkout() async {
    if (_activeWorkout == null) return;

    // Calculate workout duration
    final endTime = DateTime.now();
    final duration = _workoutStartTime != null
        ? endTime.difference(_workoutStartTime!).inMinutes
        : 0;

    // Add completion record
    final completionRecord = WorkoutCompletionRecord(
      workoutId: _activeWorkout!.id,
      workoutName: _activeWorkout!.name,
      category: _activeWorkout!.category,
      completedAt: endTime,
      durationMinutes: duration,
      exerciseCount: _activeWorkout!.exercises.length,
    );
    _completionHistory.add(completionRecord);

    // Update workout stats
    final workoutIndex = _customWorkouts.indexWhere((w) => w.id == _activeWorkout!.id);
    if (workoutIndex != -1) {
      _customWorkouts[workoutIndex] = _customWorkouts[workoutIndex].copyWith(
        timesPerformed: _customWorkouts[workoutIndex].timesPerformed + 1,
        lastPerformed: DateTime.now(),
      );
    }

    _activeWorkout = null;
    _activeExerciseIndex = 0;
    _isRestTimerActive = false;
    _remainingRestTime = 0;
    _workoutStartTime = null;

    await _saveWorkouts();
    await _saveCompletionHistory();
    
    // Check and update achievements
    if (_communityProvider != null) {
      await _communityProvider!.checkAchievements(
        totalCompletedWorkouts,
        getCurrentStreak(),
      );
      
      // Update challenge progress
      await _updateChallengeProgress();
    }
    
    notifyListeners();
  }

  Future<void> _updateChallengeProgress() async {
    if (_communityProvider == null) return;

    final challenges = _communityProvider!.challenges;

    // Update each joined challenge with relevant data for its period
    for (final challenge in challenges) {
      if (!challenge.isJoined) continue;

      final stats = getWorkoutStatsForPeriod(challenge.startDate, challenge.endDate);
      
      await _communityProvider!.updateChallengesWithWorkoutData(
        totalWorkoutsInPeriod: stats['totalWorkouts'],
        totalExercisesInPeriod: stats['totalExercises'],
        totalMinutesInPeriod: stats['totalMinutes'],
        workoutDatesInPeriod: stats['workoutDates'],
      );
      
      // Only need to calculate once for all challenges
      break;
    }
  }

  void cancelWorkout() {
    _activeWorkout = null;
    _activeExerciseIndex = 0;
    _isRestTimerActive = false;
    _remainingRestTime = 0;
    _workoutStartTime = null;
    notifyListeners();
  }

  Future<void> _saveCompletionHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = jsonEncode(_completionHistory.map((r) => r.toJson()).toList());
    await prefs.setString('workout_completion_history', historyJson);
  }

  List<CustomWorkout> get favoriteWorkouts =>
      _customWorkouts.where((w) => w.isFavorite).toList();

  List<CustomWorkout> getWorkoutsByCategory(String category) =>
      _customWorkouts.where((w) => w.category == category).toList();

  // Statistics methods for achievements
  int get totalCompletedWorkouts => _completionHistory.length;

  int getCurrentStreak() {
    if (_completionHistory.isEmpty) return 0;

    final sortedHistory = List<WorkoutCompletionRecord>.from(_completionHistory)
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));

    int streak = 0;
    DateTime? lastDate;

    for (var record in sortedHistory) {
      final recordDate = DateTime(
        record.completedAt.year,
        record.completedAt.month,
        record.completedAt.day,
      );

      if (lastDate == null) {
        // First record
        final today = DateTime.now();
        final todayDate = DateTime(today.year, today.month, today.day);
        final yesterday = todayDate.subtract(const Duration(days: 1));
        
        // Only count if workout was today or yesterday
        if (recordDate.isAtSameMomentAs(todayDate) || recordDate.isAtSameMomentAs(yesterday)) {
          streak = 1;
          lastDate = recordDate;
        } else {
          break; // Streak broken
        }
      } else {
        final expectedDate = lastDate.subtract(const Duration(days: 1));
        if (recordDate.isAtSameMomentAs(lastDate)) {
          // Same day, skip
          continue;
        } else if (recordDate.isAtSameMomentAs(expectedDate)) {
          // Consecutive day
          streak++;
          lastDate = recordDate;
        } else {
          // Streak broken
          break;
        }
      }
    }

    return streak;
  }

  int get totalExercisesCompleted {
    return _completionHistory.fold(0, (sum, record) => sum + record.exerciseCount);
  }

  int get totalWorkoutMinutes {
    return _completionHistory.fold(0, (sum, record) => sum + record.durationMinutes);
  }

  // Get workout stats for a specific time period (for challenges)
  Map<String, dynamic> getWorkoutStatsForPeriod(DateTime startDate, DateTime endDate) {
    final workoutsInPeriod = _completionHistory.where((record) {
      return record.completedAt.isAfter(startDate.subtract(const Duration(seconds: 1))) &&
             record.completedAt.isBefore(endDate.add(const Duration(seconds: 1)));
    }).toList();

    final totalWorkouts = workoutsInPeriod.length;
    final totalExercises = workoutsInPeriod.fold(0, (sum, record) => sum + record.exerciseCount);
    final totalMinutes = workoutsInPeriod.fold(0, (sum, record) => sum + record.durationMinutes);
    final workoutDates = workoutsInPeriod.map((record) => record.completedAt).toList();

    return {
      'totalWorkouts': totalWorkouts,
      'totalExercises': totalExercises,
      'totalMinutes': totalMinutes,
      'workoutDates': workoutDates,
    };
  }
}
