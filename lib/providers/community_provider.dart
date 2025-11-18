import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/community_models.dart';
import '../models/custom_workout_model.dart';

class CommunityProvider with ChangeNotifier {
  List<SharedWorkout> _sharedWorkouts = [];
  List<Achievement> _achievements = [];
  List<LeaderboardEntry> _leaderboard = [];
  List<Challenge> _challenges = [];
  Set<String> _likedWorkouts = {};

  List<SharedWorkout> get sharedWorkouts => _sharedWorkouts;
  List<Achievement> get achievements => _achievements;
  List<Achievement> get unlockedAchievements => _achievements.where((a) => a.isUnlocked).toList();
  List<LeaderboardEntry> get leaderboard => _leaderboard;
  List<Challenge> get challenges => _challenges;
  List<Challenge> get activeChallenges => _challenges.where((c) => c.isJoined).toList();
  Set<String> get likedWorkouts => _likedWorkouts;

  Future<void> loadCommunityData() async {
    await Future.wait([
      _loadSharedWorkouts(),
      _loadAchievements(),
      _loadChallenges(),
      _loadLeaderboard(),
    ]);
    notifyListeners();
  }

  Future<void> _loadSharedWorkouts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('shared_workouts');
      if (data != null) {
        final List<dynamic> list = jsonDecode(data);
        _sharedWorkouts = list.map((w) => SharedWorkout.fromJson(w)).toList();
      } else {
        // Initialize with demo shared workouts
        _sharedWorkouts = _generateDemoSharedWorkouts();
        await _saveSharedWorkouts();
      }

      // Load liked workouts
      final likedData = prefs.getString('liked_workouts');
      if (likedData != null) {
        _likedWorkouts = Set<String>.from(jsonDecode(likedData));
      }
    } catch (e) {
      debugPrint('Error loading shared workouts: $e');
    }
  }

  Future<void> _loadAchievements() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('achievements');
      if (data != null) {
        final List<dynamic> list = jsonDecode(data);
        _achievements = list.map((a) => Achievement.fromJson(a)).toList();
      } else {
        // Initialize with default achievements
        _achievements = _generateDefaultAchievements();
        await _saveAchievements();
      }
    } catch (e) {
      debugPrint('Error loading achievements: $e');
    }
  }

  // Update achievements with current workout stats
  Future<void> updateAchievementsWithStats(int totalWorkouts, int currentStreak) async {
    await checkAchievements(totalWorkouts, currentStreak);
  }

  Future<void> _loadChallenges() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('challenges');
      if (data != null) {
        final List<dynamic> list = jsonDecode(data);
        _challenges = list.map((c) => Challenge.fromJson(c)).toList();
      } else {
        // Initialize with demo challenges
        _challenges = _generateDemoChallenges();
        await _saveChallenges();
      }
    } catch (e) {
      debugPrint('Error loading challenges: $e');
    }
  }

  Future<void> _loadLeaderboard() async {
    // Generate demo leaderboard
    _leaderboard = _generateDemoLeaderboard();
  }

  // Share a workout to the community
  Future<void> shareWorkout(CustomWorkout workout, String userName) async {
    final sharedWorkout = SharedWorkout(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      workoutId: workout.id,
      workoutName: workout.name,
      category: workout.category,
      description: workout.description ?? 'Custom workout',
      sharedBy: 'current_user',
      sharedByName: userName,
      sharedAt: DateTime.now(),
      exerciseCount: workout.exercises.length,
      tags: [workout.category, 'custom'],
    );

    _sharedWorkouts.insert(0, sharedWorkout);
    await _saveSharedWorkouts();
    notifyListeners();
  }

  // Like/unlike a shared workout
  void toggleLike(String workoutId) {
    if (_likedWorkouts.contains(workoutId)) {
      _likedWorkouts.remove(workoutId);
    } else {
      _likedWorkouts.add(workoutId);
    }

    notifyListeners();
    
    // Save asynchronously without awaiting
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('liked_workouts', jsonEncode(_likedWorkouts.toList()));
    });
  }

  bool isLiked(String workoutId) => _likedWorkouts.contains(workoutId);

  // Clone a shared workout
  void cloneSharedWorkout(String workoutId) {
    final index = _sharedWorkouts.indexWhere((w) => w.id == workoutId);
    if (index != -1) {
      final workout = _sharedWorkouts[index];
      _sharedWorkouts[index] = SharedWorkout(
        id: workout.id,
        workoutId: workout.workoutId,
        workoutName: workout.workoutName,
        category: workout.category,
        description: workout.description,
        sharedBy: workout.sharedBy,
        sharedByName: workout.sharedByName,
        sharedAt: workout.sharedAt,
        exerciseCount: workout.exerciseCount,
        likes: workout.likes,
        clones: workout.clones + 1,
        tags: workout.tags,
      );
      
      notifyListeners();
      
      // Save asynchronously without awaiting
      _saveSharedWorkouts();
    }
  }

  // Join/leave a challenge
  void toggleChallengeJoin(String challengeId) {
    final index = _challenges.indexWhere((c) => c.id == challengeId);
    if (index != -1) {
      final challenge = _challenges[index];
      _challenges[index] = challenge.copyWith(
        isJoined: !challenge.isJoined,
        participants: challenge.isJoined 
            ? challenge.participants - 1 
            : challenge.participants + 1,
      );
      
      notifyListeners();
      
      // Save asynchronously without awaiting
      _saveChallenges();
    }
  }

  // Update challenge progress
  Future<void> updateChallengeProgress(String challengeId, int progress) async {
    final index = _challenges.indexWhere((c) => c.id == challengeId);
    if (index != -1) {
      _challenges[index] = _challenges[index].copyWith(currentProgress: progress);
      await _saveChallenges();
      notifyListeners();
    }
  }

  // Update all joined challenges based on workout completion data
  Future<void> updateChallengesWithWorkoutData({
    required int totalWorkoutsInPeriod,
    required int totalExercisesInPeriod,
    required int totalMinutesInPeriod,
    required List<DateTime> workoutDatesInPeriod,
  }) async {
    bool updated = false;
    final now = DateTime.now();

    for (int i = 0; i < _challenges.length; i++) {
      final challenge = _challenges[i];
      
      // Only update joined challenges that are still active
      if (!challenge.isJoined || now.isAfter(challenge.endDate)) {
        continue;
      }

      int progress = 0;
      
      // Calculate progress based on challenge metric
      switch (challenge.metric) {
        case 'workouts':
          progress = totalWorkoutsInPeriod;
          break;
        case 'exercises':
          progress = totalExercisesInPeriod;
          break;
        case 'minutes':
          progress = totalMinutesInPeriod;
          break;
        case 'days':
          // Count unique workout days in the period
          final uniqueDays = workoutDatesInPeriod.map((date) => 
            DateTime(date.year, date.month, date.day)
          ).toSet().length;
          progress = uniqueDays;
          break;
      }

      // Update if progress changed
      if (progress != challenge.currentProgress) {
        _challenges[i] = challenge.copyWith(currentProgress: progress);
        updated = true;
      }
    }

    if (updated) {
      await _saveChallenges();
      notifyListeners();
    }
  }

  // Check and unlock achievements based on workout count
  Future<void> checkAchievements(int totalWorkouts, int currentStreak) async {
    bool updated = false;

    for (int i = 0; i < _achievements.length; i++) {
      final achievement = _achievements[i];
      if (!achievement.isUnlocked) {
        int progress = 0;
        
        if (achievement.category == 'workouts') {
          progress = totalWorkouts;
        } else if (achievement.category == 'consistency') {
          progress = currentStreak;
        }

        if (progress >= achievement.requiredCount) {
          _achievements[i] = achievement.copyWith(
            isUnlocked: true,
            unlockedAt: DateTime.now(),
            currentProgress: progress,
          );
          updated = true;
        } else {
          _achievements[i] = achievement.copyWith(currentProgress: progress);
        }
      }
    }

    if (updated) {
      await _saveAchievements();
      notifyListeners();
    }
  }

  Future<void> _saveSharedWorkouts() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(_sharedWorkouts.map((w) => w.toJson()).toList());
    await prefs.setString('shared_workouts', data);
  }

  Future<void> _saveAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(_achievements.map((a) => a.toJson()).toList());
    await prefs.setString('achievements', data);
  }

  Future<void> _saveChallenges() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(_challenges.map((c) => c.toJson()).toList());
    await prefs.setString('challenges', data);
  }

  // Demo data generators
  List<SharedWorkout> _generateDemoSharedWorkouts() {
    return [
      SharedWorkout(
        id: '1',
        workoutId: 'shared_1',
        workoutName: 'Full Body Blast',
        category: 'Strength',
        description: 'Intense full body workout for maximum gains',
        sharedBy: 'user_1',
        sharedByName: 'Alex Johnson',
        sharedAt: DateTime.now().subtract(const Duration(days: 2)),
        exerciseCount: 8,
        likes: 45,
        clones: 23,
        tags: ['Strength', 'Full Body', 'Advanced'],
      ),
      SharedWorkout(
        id: '2',
        workoutId: 'shared_2',
        workoutName: 'Cardio Killer',
        category: 'Cardio',
        description: 'High-intensity cardio to burn maximum calories',
        sharedBy: 'user_2',
        sharedByName: 'Sarah Martinez',
        sharedAt: DateTime.now().subtract(const Duration(days: 5)),
        exerciseCount: 6,
        likes: 67,
        clones: 34,
        tags: ['Cardio', 'HIIT', 'Fat Loss'],
      ),
      SharedWorkout(
        id: '3',
        workoutId: 'shared_3',
        workoutName: 'Upper Body Power',
        category: 'Strength',
        description: 'Build massive chest, back, and arms',
        sharedBy: 'user_3',
        sharedByName: 'Mike Chen',
        sharedAt: DateTime.now().subtract(const Duration(days: 7)),
        exerciseCount: 7,
        likes: 89,
        clones: 56,
        tags: ['Strength', 'Upper Body', 'Muscle Gain'],
      ),
    ];
  }

  List<Achievement> _generateDefaultAchievements() {
    return [
      Achievement(
        id: 'first_workout',
        name: 'First Steps',
        description: 'Complete your first workout',
        icon: '🏃',
        requiredCount: 1,
        category: 'workouts',
      ),
      Achievement(
        id: 'ten_workouts',
        name: 'Getting Strong',
        description: 'Complete 10 workouts',
        icon: '💪',
        requiredCount: 10,
        category: 'workouts',
      ),
      Achievement(
        id: 'fifty_workouts',
        name: 'Fitness Warrior',
        description: 'Complete 50 workouts',
        icon: '⚔️',
        requiredCount: 50,
        category: 'workouts',
      ),
      Achievement(
        id: 'hundred_workouts',
        name: 'Century Club',
        description: 'Complete 100 workouts',
        icon: '🏆',
        requiredCount: 100,
        category: 'workouts',
      ),
      Achievement(
        id: 'week_streak',
        name: 'Consistent',
        description: '7 day workout streak',
        icon: '🔥',
        requiredCount: 7,
        category: 'consistency',
      ),
      Achievement(
        id: 'month_streak',
        name: 'Unstoppable',
        description: '30 day workout streak',
        icon: '⚡',
        requiredCount: 30,
        category: 'consistency',
      ),
    ];
  }

  List<Challenge> _generateDemoChallenges() {
    final now = DateTime.now();
    // Get start of current week (Monday)
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartDate = DateTime(weekStart.year, weekStart.month, weekStart.day);
    final weekEndDate = weekStartDate.add(const Duration(days: 6, hours: 23, minutes: 59));
    
    return [
      Challenge(
        id: 'weekly_1',
        name: '5 Workouts This Week',
        description: 'Complete 5 workouts within 7 days',
        type: 'weekly',
        targetCount: 5,
        metric: 'workouts',
        startDate: weekStartDate,
        endDate: weekEndDate,
        participants: 234,
      ),
      Challenge(
        id: 'monthly_1',
        name: 'Workout Every Day',
        description: 'Workout at least once every day this month',
        type: 'monthly',
        targetCount: DateTime(now.year, now.month + 1, 0).day, // Days in month
        metric: 'days',
        startDate: DateTime(now.year, now.month, 1),
        endDate: DateTime(now.year, now.month + 1, 0, 23, 59, 59),
        participants: 567,
      ),
      Challenge(
        id: 'weekly_2',
        name: '100 Exercises Challenge',
        description: 'Complete 100 total exercises this week',
        type: 'weekly',
        targetCount: 100,
        metric: 'exercises',
        startDate: weekStartDate,
        endDate: weekEndDate,
        participants: 189,
      ),
    ];
  }

  List<LeaderboardEntry> _generateDemoLeaderboard() {
    return [
      LeaderboardEntry(userId: '1', userName: 'Alex Thunder', rank: 1, score: 89, metric: 'workouts', period: 'monthly'),
      LeaderboardEntry(userId: '2', userName: 'Sarah Power', rank: 2, score: 76, metric: 'workouts', period: 'monthly'),
      LeaderboardEntry(userId: '3', userName: 'Mike Beast', rank: 3, score: 68, metric: 'workouts', period: 'monthly'),
      LeaderboardEntry(userId: '4', userName: 'Emma Strong', rank: 4, score: 62, metric: 'workouts', period: 'monthly'),
      LeaderboardEntry(userId: '5', userName: 'You', rank: 5, score: 45, metric: 'workouts', period: 'monthly'),
      LeaderboardEntry(userId: '6', userName: 'Chris Fit', rank: 6, score: 43, metric: 'workouts', period: 'monthly'),
      LeaderboardEntry(userId: '7', userName: 'Lisa Iron', rank: 7, score: 38, metric: 'workouts', period: 'monthly'),
    ];
  }
}
