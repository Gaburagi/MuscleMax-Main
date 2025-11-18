import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/workout_model.dart';

class WorkoutProvider extends ChangeNotifier {
  List<WorkoutProgram> _workoutPrograms = [];
  List<WorkoutSession> _workoutHistory = [];
  WorkoutSession? _activeSession;
  bool _isLoading = false;

  List<WorkoutProgram> get workoutPrograms => _workoutPrograms;
  List<WorkoutSession> get workoutHistory => _workoutHistory;
  WorkoutSession? get activeSession => _activeSession;
  bool get isLoading => _isLoading;

  WorkoutProvider() {
    _initializeMockData();
    loadWorkoutHistory();
  }

  void _initializeMockData() {
    _workoutPrograms = [
      WorkoutProgram(
        id: '1',
        name: 'Be Free',
        difficulty: 'Beginner',
        durationMinutes: 20,
        description: 'Full body workout for beginners',
        exercises: [
          Exercise(
            id: 'e1',
            name: 'Push-ups',
            sets: 3,
            reps: 10,
            restSeconds: 60,
          ),
          Exercise(
            id: 'e2',
            name: 'Squats',
            sets: 3,
            reps: 15,
            restSeconds: 60,
          ),
        ],
      ),
      WorkoutProgram(
        id: '2',
        name: 'Energym',
        difficulty: 'Beginner',
        durationMinutes: 20,
        description: 'High energy cardio workout',
        exercises: [
          Exercise(
            id: 'e3',
            name: 'Jumping Jacks',
            sets: 3,
            reps: 20,
            restSeconds: 30,
          ),
          Exercise(
            id: 'e4',
            name: 'Burpees',
            sets: 3,
            reps: 10,
            restSeconds: 45,
          ),
        ],
      ),
      WorkoutProgram(
        id: '3',
        name: 'Full Shot Woman Stretching Arm',
        difficulty: 'Beginner',
        durationMinutes: 30,
        description: 'Stretching and flexibility workout',
        exercises: [
          Exercise(
            id: 'e5',
            name: 'Arm Stretches',
            sets: 2,
            reps: 10,
            restSeconds: 30,
          ),
          Exercise(
            id: 'e6',
            name: 'Leg Stretches',
            sets: 2,
            reps: 10,
            restSeconds: 30,
          ),
        ],
      ),
      WorkoutProgram(
        id: '4',
        name: 'Athlete Practicing Claps hands Arm Balance',
        difficulty: 'Intermediate',
        durationMinutes: 50,
        description: 'Advanced arm strength training',
        exercises: [
          Exercise(
            id: 'e7',
            name: 'Clap Push-ups',
            sets: 4,
            reps: 8,
            restSeconds: 90,
          ),
          Exercise(
            id: 'e8',
            name: 'Plank',
            sets: 3,
            reps: 1,
            restSeconds: 60,
          ),
        ],
      ),
      WorkoutProgram(
        id: '5',
        name: 'Athlete Practicing Monochrome',
        difficulty: 'Advanced',
        durationMinutes: 20,
        description: 'High intensity interval training',
        exercises: [
          Exercise(
            id: 'e9',
            name: 'Sprint Intervals',
            sets: 5,
            reps: 1,
            restSeconds: 120,
          ),
          Exercise(
            id: 'e10',
            name: 'Mountain Climbers',
            sets: 4,
            reps: 20,
            restSeconds: 60,
          ),
        ],
      ),
    ];
  }

  List<WorkoutProgram> getWorkoutsByDifficulty(String difficulty) {
    return _workoutPrograms
        .where((w) => w.difficulty == difficulty)
        .toList();
  }

  List<WorkoutProgram> getFavoriteWorkouts() {
    return _workoutPrograms.where((w) => w.isFavorite).toList();
  }

  Future<void> toggleFavorite(String workoutId) async {
    final index = _workoutPrograms.indexWhere((w) => w.id == workoutId);
    if (index != -1) {
      _workoutPrograms[index] = _workoutPrograms[index].copyWith(
        isFavorite: !_workoutPrograms[index].isFavorite,
      );
      notifyListeners();
    }
  }

  Future<void> startWorkout(WorkoutProgram program) async {
    _activeSession = WorkoutSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      workoutProgramId: program.id,
      startTime: DateTime.now(),
    );
    notifyListeners();
  }

  Future<void> completeWorkout() async {
    if (_activeSession != null) {
      final completedSession = WorkoutSession(
        id: _activeSession!.id,
        workoutProgramId: _activeSession!.workoutProgramId,
        startTime: _activeSession!.startTime,
        endTime: DateTime.now(),
        exerciseLogs: _activeSession!.exerciseLogs,
        isCompleted: true,
      );

      _workoutHistory.add(completedSession);
      await _saveWorkoutHistory();

      _activeSession = null;
      notifyListeners();
    }
  }

  Future<void> cancelWorkout() async {
    _activeSession = null;
    notifyListeners();
  }

  Future<void> loadWorkoutHistory() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList('workoutHistory');
      if (historyJson != null) {
        _workoutHistory = historyJson
            .map((item) => WorkoutSession.fromJson(json.decode(item)))
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading workout history: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveWorkoutHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = _workoutHistory
          .map((session) => json.encode(session.toJson()))
          .toList();
      await prefs.setStringList('workoutHistory', historyJson);
    } catch (e) {
      debugPrint('Error saving workout history: $e');
    }
  }

  int get totalWorkoutsCompleted => _workoutHistory.length;

  Duration get totalWorkoutTime {
    return _workoutHistory.fold(
      Duration.zero,
      (total, session) => total + (session.duration ?? Duration.zero),
    );
  }

  WorkoutProgram? getWorkoutById(String id) {
    try {
      return _workoutPrograms.firstWhere((workout) => workout.id == id);
    } catch (e) {
      return null;
    }
  }
}
