import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/gamification_model.dart';

// Result class for workout completion with level-up info
class WorkoutCompletionResult {
  final List<Achievement> unlockedAchievements;
  final bool leveledUp;
  final int? newLevel;
  final String? newTitle;
  final int xpGained;

  WorkoutCompletionResult({
    required this.unlockedAchievements,
    required this.leveledUp,
    this.newLevel,
    this.newTitle,
    required this.xpGained,
  });
}

class GamificationProvider with ChangeNotifier {
  UserLevel _userLevel = UserLevel(
    level: 1,
    currentXP: 0,
    xpForNextLevel: UserLevel.xpRequiredForLevel(1),
    title: 'Beginner',
  );
  
  List<Achievement> _achievements = [];
  WorkoutStreak _streak = WorkoutStreak();
  List<DailyChallenge> _dailyChallenges = [];
  List<XPEvent> _xpHistory = [];

  UserLevel get userLevel => _userLevel;
  List<Achievement> get achievements => _achievements;
  WorkoutStreak get streak => _streak;
  List<DailyChallenge> get dailyChallenges => _dailyChallenges;
  List<XPEvent> get xpHistory => _xpHistory;

  int get totalXP => _xpHistory.fold(0, (sum, event) => sum + event.xpGained);
  int get unlockedAchievementsCount => 
      _achievements.where((a) => a.isUnlocked).length;

  Future<void> loadData() async {
    await Future.wait([
      _loadUserLevel(),
      _loadAchievements(),
      _loadStreak(),
      _loadDailyChallenges(),
      _loadXPHistory(),
    ]);
    _initializeAchievements();
    _checkAndGenerateDailyChallenges();
    notifyListeners();
  }

  Future<void> _loadUserLevel() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('user_level');
      if (data != null) {
        _userLevel = UserLevel.fromJson(jsonDecode(data));
      }
    } catch (e) {
      debugPrint('Error loading user level: $e');
    }
  }

  Future<void> _loadAchievements() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('achievements');
      if (data != null) {
        final List<dynamic> list = jsonDecode(data);
        _achievements = list.map((a) => Achievement.fromJson(a)).toList();
      }
    } catch (e) {
      debugPrint('Error loading achievements: $e');
    }
  }

  Future<void> _loadStreak() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('workout_streak');
      if (data != null) {
        _streak = WorkoutStreak.fromJson(jsonDecode(data));
      }
    } catch (e) {
      debugPrint('Error loading streak: $e');
    }
  }

  Future<void> _loadDailyChallenges() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('daily_challenges');
      if (data != null) {
        final List<dynamic> list = jsonDecode(data);
        _dailyChallenges = list.map((c) => DailyChallenge.fromJson(c)).toList();
      }
    } catch (e) {
      debugPrint('Error loading daily challenges: $e');
    }
  }

  Future<void> _loadXPHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('xp_history');
      if (data != null) {
        final List<dynamic> list = jsonDecode(data);
        _xpHistory = list.map((e) => XPEvent.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('Error loading XP history: $e');
    }
  }

  Future<void> _saveUserLevel() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_level', jsonEncode(_userLevel.toJson()));
  }

  Future<void> _saveAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'achievements',
      jsonEncode(_achievements.map((a) => a.toJson()).toList()),
    );
  }

  Future<void> _saveStreak() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('workout_streak', jsonEncode(_streak.toJson()));
  }

  Future<void> _saveDailyChallenges() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'daily_challenges',
      jsonEncode(_dailyChallenges.map((c) => c.toJson()).toList()),
    );
  }

  Future<void> _saveXPHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'xp_history',
      jsonEncode(_xpHistory.map((e) => e.toJson()).toList()),
    );
  }

  // Initialize default achievements if empty
  void _initializeAchievements() {
    if (_achievements.isNotEmpty) return;

    _achievements = [
      // Workout achievements
      Achievement(
        id: 'first_workout',
        name: 'Getting Started',
        description: 'Complete your first workout',
        icon: '🏃',
        requiredCount: 1,
        category: 'workouts',
        xpReward: 50,
      ),
      Achievement(
        id: 'ten_workouts',
        name: 'Consistent Effort',
        description: 'Complete 10 workouts',
        icon: '💪',
        requiredCount: 10,
        category: 'workouts',
        xpReward: 100,
      ),
      Achievement(
        id: 'fifty_workouts',
        name: 'Fitness Warrior',
        description: 'Complete 50 workouts',
        icon: '⚔️',
        requiredCount: 50,
        category: 'workouts',
        xpReward: 250,
      ),
      Achievement(
        id: 'hundred_workouts',
        name: 'Century Club',
        description: 'Complete 100 workouts',
        icon: '🏆',
        requiredCount: 100,
        category: 'workouts',
        xpReward: 500,
      ),

      // Streak achievements
      Achievement(
        id: 'week_streak',
        name: 'Week Warrior',
        description: 'Maintain a 7-day workout streak',
        icon: '🔥',
        requiredCount: 7,
        category: 'streak',
        xpReward: 150,
      ),
      Achievement(
        id: 'month_streak',
        name: 'Dedication',
        description: 'Maintain a 30-day workout streak',
        icon: '🌟',
        requiredCount: 30,
        category: 'streak',
        xpReward: 500,
      ),
      Achievement(
        id: 'hundred_day_streak',
        name: 'Unstoppable',
        description: 'Maintain a 100-day workout streak',
        icon: '👑',
        requiredCount: 100,
        category: 'streak',
        xpReward: 1000,
      ),

      // PR achievements
      Achievement(
        id: 'first_pr',
        name: 'Personal Best',
        description: 'Achieve your first personal record',
        icon: '🎯',
        requiredCount: 1,
        category: 'prs',
        xpReward: 75,
      ),
      Achievement(
        id: 'ten_prs',
        name: 'Record Breaker',
        description: 'Achieve 10 personal records',
        icon: '📈',
        requiredCount: 10,
        category: 'prs',
        xpReward: 200,
      ),
      Achievement(
        id: 'fifty_prs',
        name: 'Elite Athlete',
        description: 'Achieve 50 personal records',
        icon: '⭐',
        requiredCount: 50,
        category: 'prs',
        xpReward: 500,
      ),

      // Social achievements
      Achievement(
        id: 'first_friend',
        name: 'Social Butterfly',
        description: 'Add your first friend',
        icon: '👋',
        requiredCount: 1,
        category: 'social',
        xpReward: 50,
      ),
      Achievement(
        id: 'ten_friends',
        name: 'Popular',
        description: 'Have 10 friends',
        icon: '🤝',
        requiredCount: 10,
        category: 'social',
        xpReward: 150,
      ),
      Achievement(
        id: 'first_post',
        name: 'Sharing Progress',
        description: 'Share your first post',
        icon: '📱',
        requiredCount: 1,
        category: 'social',
        xpReward: 50,
      ),

      // Nutrition achievements
      Achievement(
        id: 'calorie_goal',
        name: 'Macro Master',
        description: 'Hit your calorie goal 7 days in a row',
        icon: '🍽️',
        requiredCount: 7,
        category: 'nutrition',
        xpReward: 150,
      ),
      Achievement(
        id: 'water_goal',
        name: 'Hydration Hero',
        description: 'Hit your water goal 7 days in a row',
        icon: '💧',
        requiredCount: 7,
        category: 'nutrition',
        xpReward: 100,
      ),

      // Volume achievements
      Achievement(
        id: 'volume_10k',
        name: 'Weight Shifter',
        description: 'Lift a total of 10,000 kg',
        icon: '⚡',
        requiredCount: 10000,
        category: 'volume',
        xpReward: 200,
      ),
      Achievement(
        id: 'volume_50k',
        name: 'Iron Mountain',
        description: 'Lift a total of 50,000 kg',
        icon: '🏔️',
        requiredCount: 50000,
        category: 'volume',
        xpReward: 500,
      ),
      Achievement(
        id: 'volume_100k',
        name: 'Steel Titan',
        description: 'Lift a total of 100,000 kg',
        icon: '🦾',
        requiredCount: 100000,
        category: 'volume',
        xpReward: 1000,
      ),

      // Time-based achievements
      Achievement(
        id: 'total_hours_10',
        name: 'Time Investment',
        description: 'Complete 10 hours of training',
        icon: '⏰',
        requiredCount: 600,
        category: 'time',
        xpReward: 150,
      ),
      Achievement(
        id: 'total_hours_50',
        name: 'Time Warrior',
        description: 'Complete 50 hours of training',
        icon: '⏳',
        requiredCount: 3000,
        category: 'time',
        xpReward: 400,
      ),
      Achievement(
        id: 'total_hours_100',
        name: 'Time Master',
        description: 'Complete 100 hours of training',
        icon: '🕐',
        requiredCount: 6000,
        category: 'time',
        xpReward: 750,
      ),

      // Early bird/Night owl achievements
      Achievement(
        id: 'early_bird',
        name: 'Early Bird',
        description: 'Complete 10 workouts before 7 AM',
        icon: '🌅',
        requiredCount: 10,
        category: 'timing',
        xpReward: 200,
      ),
      Achievement(
        id: 'night_owl',
        name: 'Night Owl',
        description: 'Complete 10 workouts after 9 PM',
        icon: '🌙',
        requiredCount: 10,
        category: 'timing',
        xpReward: 200,
      ),

      // Consistency achievements
      Achievement(
        id: 'weekly_warrior',
        name: 'Weekly Warrior',
        description: 'Train 5+ times in one week',
        icon: '📅',
        requiredCount: 5,
        category: 'consistency',
        xpReward: 100,
      ),
      Achievement(
        id: 'monthly_champion',
        name: 'Monthly Champion',
        description: 'Train 20+ times in one month',
        icon: '📆',
        requiredCount: 20,
        category: 'consistency',
        xpReward: 300,
      ),
      Achievement(
        id: 'year_long',
        name: 'Year-Long Dedication',
        description: 'Train at least once every week for a year',
        icon: '🎊',
        requiredCount: 52,
        category: 'consistency',
        xpReward: 1500,
      ),

      // Exercise-specific achievements
      Achievement(
        id: 'bench_master',
        name: 'Bench Press Master',
        description: 'Perform 100 sets of bench press',
        icon: '🏋️',
        requiredCount: 100,
        category: 'exercise',
        xpReward: 300,
      ),
      Achievement(
        id: 'squat_king',
        name: 'Squat King',
        description: 'Perform 100 sets of squats',
        icon: '👑',
        requiredCount: 100,
        category: 'exercise',
        xpReward: 300,
      ),
      Achievement(
        id: 'deadlift_demon',
        name: 'Deadlift Demon',
        description: 'Perform 100 sets of deadlifts',
        icon: '😈',
        requiredCount: 100,
        category: 'exercise',
        xpReward: 300,
      ),
      Achievement(
        id: 'pullup_pro',
        name: 'Pull-up Pro',
        description: 'Complete 500 pull-ups',
        icon: '🎯',
        requiredCount: 500,
        category: 'exercise',
        xpReward: 350,
      ),
      Achievement(
        id: 'pushup_master',
        name: 'Push-up Master',
        description: 'Complete 1000 push-ups',
        icon: '💯',
        requiredCount: 1000,
        category: 'exercise',
        xpReward: 400,
      ),

      // Variety achievements
      Achievement(
        id: 'exercise_explorer',
        name: 'Exercise Explorer',
        description: 'Try 20 different exercises',
        icon: '🧭',
        requiredCount: 20,
        category: 'variety',
        xpReward: 200,
      ),
      Achievement(
        id: 'well_rounded',
        name: 'Well Rounded',
        description: 'Train all major muscle groups in one week',
        icon: '🔄',
        requiredCount: 1,
        category: 'variety',
        xpReward: 150,
      ),

      // Milestone achievements
      Achievement(
        id: 'first_month',
        name: 'First Month',
        description: 'Complete your first month of training',
        icon: '🎯',
        requiredCount: 1,
        category: 'milestone',
        xpReward: 100,
      ),
      Achievement(
        id: 'half_year',
        name: 'Half Year Hero',
        description: 'Train consistently for 6 months',
        icon: '⭐',
        requiredCount: 1,
        category: 'milestone',
        xpReward: 500,
      ),
      Achievement(
        id: 'one_year',
        name: 'One Year Anniversary',
        description: 'Complete one full year of training',
        icon: '🎂',
        requiredCount: 1,
        category: 'milestone',
        xpReward: 1000,
      ),

      // Transformation achievements
      Achievement(
        id: 'weight_change_5',
        name: 'First Steps',
        description: 'Change your weight by 5 kg',
        icon: '📊',
        requiredCount: 5,
        category: 'transformation',
        xpReward: 150,
      ),
      Achievement(
        id: 'weight_change_10',
        name: 'Transformation',
        description: 'Change your weight by 10 kg',
        icon: '🦋',
        requiredCount: 10,
        category: 'transformation',
        xpReward: 300,
      ),
      Achievement(
        id: 'weight_change_20',
        name: 'Total Metamorphosis',
        description: 'Change your weight by 20 kg',
        icon: '✨',
        requiredCount: 20,
        category: 'transformation',
        xpReward: 600,
      ),
    ];
  }

  // Award XP and check for level up
  Future<bool> awardXP(int amount, String action, {String? description}) async {
    _userLevel = UserLevel(
      level: _userLevel.level,
      currentXP: _userLevel.currentXP + amount,
      xpForNextLevel: _userLevel.xpForNextLevel,
      title: _userLevel.title,
    );

    // Add to history
    _xpHistory.insert(0, XPEvent(
      action: action,
      xpGained: amount,
      timestamp: DateTime.now(),
      description: description,
    ));

    // Check for level up
    bool leveledUp = false;
    while (_userLevel.currentXP >= _userLevel.xpForNextLevel) {
      _userLevel = UserLevel(
        level: _userLevel.level + 1,
        currentXP: _userLevel.currentXP - _userLevel.xpForNextLevel,
        xpForNextLevel: UserLevel.xpRequiredForLevel(_userLevel.level + 1),
        title: UserLevel.titleForLevel(_userLevel.level + 1),
      );
      leveledUp = true;
    }

    await _saveUserLevel();
    await _saveXPHistory();
    notifyListeners();

    return leveledUp;
  }

  // Update workout streak
  Future<void> recordWorkout() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Always add workout to the list (even multiple per day)
    _streak = _streak.copyWith(
      workoutDates: [..._streak.workoutDates, now],
    );

    // Update streak only once per day
    if (_streak.lastWorkoutDate != null) {
      final lastWorkout = DateTime(
        _streak.lastWorkoutDate!.year,
        _streak.lastWorkoutDate!.month,
        _streak.lastWorkoutDate!.day,
      );

      if (lastWorkout == today) {
        // Same day - don't update streak, but workout was already added above
        await _saveStreak();
        notifyListeners();
        return;
      }

      // Check if streak continues (yesterday)
      final yesterday = today.subtract(const Duration(days: 1));
      if (lastWorkout == yesterday) {
        // Continue streak
        _streak = _streak.copyWith(
          currentStreak: _streak.currentStreak + 1,
          longestStreak: max(_streak.longestStreak, _streak.currentStreak + 1),
          lastWorkoutDate: now,
        );
      } else {
        // Streak broken
        _streak = _streak.copyWith(
          currentStreak: 1,
          lastWorkoutDate: now,
        );
      }
    } else {
      // First workout
      _streak = _streak.copyWith(
        currentStreak: 1,
        longestStreak: 1,
        lastWorkoutDate: now,
      );
    }

    await _saveStreak();
    
    // Check streak achievements
    await _checkAchievement('week_streak', _streak.currentStreak);
    await _checkAchievement('month_streak', _streak.currentStreak);
    await _checkAchievement('hundred_day_streak', _streak.currentStreak);
    
    notifyListeners();
  }

  // Update achievement progress
  Future<List<Achievement>> _checkAchievement(String achievementId, int progress) async {
    final List<Achievement> unlockedAchievements = [];
    final index = _achievements.indexWhere((a) => a.id == achievementId);
    
    if (index != -1 && !_achievements[index].isUnlocked) {
      _achievements[index] = _achievements[index].copyWith(
        currentProgress: progress,
      );

      if (progress >= _achievements[index].requiredCount) {
        _achievements[index] = _achievements[index].copyWith(
          isUnlocked: true,
          unlockedDate: DateTime.now(),
        );
        await awardXP(
          _achievements[index].xpReward,
          'achievement_unlocked',
          description: _achievements[index].name,
        );
        unlockedAchievements.add(_achievements[index]);
      }

      await _saveAchievements();
      notifyListeners();
    }

    return unlockedAchievements;
  }

  // Called when workout completed
  Future<WorkoutCompletionResult> onWorkoutCompleted() async {
    final unlockedAchievements = <Achievement>[];
    
    // Award XP and check for level up
    final leveledUp = await awardXP(20, 'workout_complete', description: 'Completed a workout');
    
    // Update streak
    await recordWorkout();
    
    // Update workout count achievements
    final workoutCount = _streak.workoutDates.length;
    unlockedAchievements.addAll(
      await _checkAchievement('first_workout', workoutCount)
    );
    unlockedAchievements.addAll(
      await _checkAchievement('ten_workouts', workoutCount)
    );
    unlockedAchievements.addAll(
      await _checkAchievement('fifty_workouts', workoutCount)
    );
    unlockedAchievements.addAll(
      await _checkAchievement('hundred_workouts', workoutCount)
    );

    // Update daily challenges
    await _updateDailyChallengeProgress('workout', 1);
    
    return WorkoutCompletionResult(
      unlockedAchievements: unlockedAchievements,
      leveledUp: leveledUp,
      newLevel: leveledUp ? _userLevel.level : null,
      newTitle: leveledUp ? _userLevel.title : null,
      xpGained: 20,
    );
  }

  // Called when PR achieved
  Future<List<Achievement>> onPRrchieved() async {
    final unlockedAchievements = <Achievement>[];
    
    await awardXP(30, 'pr_achieved', description: 'New personal record!');
    
    // Get current PR count from achievements
    int prCount = 0;
    final firstPR = _achievements.firstWhere((a) => a.id == 'first_pr');
    prCount = firstPR.currentProgress + 1;
    
    unlockedAchievements.addAll(await _checkAchievement('first_pr', prCount));
    unlockedAchievements.addAll(await _checkAchievement('ten_prs', prCount));
    unlockedAchievements.addAll(await _checkAchievement('fifty_prs', prCount));
    
    return unlockedAchievements;
  }

  // Called when goal completed
  Future<void> onGoalCompleted() async {
    await awardXP(50, 'goal_completed', description: 'Completed a fitness goal');
  }

  // Called when friend added
  Future<List<Achievement>> onFriendAdded() async {
    final unlockedAchievements = <Achievement>[];
    
    await awardXP(10, 'friend_added');
    
    int friendCount = 0;
    final firstFriend = _achievements.firstWhere((a) => a.id == 'first_friend');
    friendCount = firstFriend.currentProgress + 1;
    
    unlockedAchievements.addAll(await _checkAchievement('first_friend', friendCount));
    unlockedAchievements.addAll(await _checkAchievement('ten_friends', friendCount));
    
    return unlockedAchievements;
  }

  // Called when post shared
  Future<List<Achievement>> onPostShared() async {
    final unlockedAchievements = <Achievement>[];
    
    await awardXP(15, 'post_shared');
    
    int postCount = 0;
    final firstPost = _achievements.firstWhere((a) => a.id == 'first_post');
    postCount = firstPost.currentProgress + 1;
    
    unlockedAchievements.addAll(await _checkAchievement('first_post', postCount));
    
    return unlockedAchievements;
  }

  // Daily Challenges
  void _checkAndGenerateDailyChallenges() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Remove old challenges
    _dailyChallenges.removeWhere((c) => 
      DateTime(c.date.year, c.date.month, c.date.day).isBefore(today)
    );

    // Generate new challenges if empty
    if (_dailyChallenges.isEmpty) {
      _dailyChallenges = _generateDailyChallenges(today);
      _saveDailyChallenges();
    }
  }

  List<DailyChallenge> _generateDailyChallenges(DateTime date) {
    final random = Random(date.millisecondsSinceEpoch);
    final challenges = <DailyChallenge>[];

    // Workout challenge
    final workoutTypes = [
      ('Complete 1 workout', 1, 25),
      ('Complete 2 workouts', 2, 50),
      ('Exercise for 30 minutes', 30, 30),
    ];
    final workout = workoutTypes[random.nextInt(workoutTypes.length)];
    challenges.add(DailyChallenge(
      id: 'daily_workout_${date.millisecondsSinceEpoch}',
      title: workout.$1,
      description: 'Keep the momentum going!',
      type: 'workout',
      targetValue: workout.$2,
      xpReward: workout.$3,
      date: date,
    ));

    // Nutrition challenge
    final nutritionTypes = [
      ('Hit your calorie goal', 1, 20),
      ('Drink 8 glasses of water', 8, 15),
      ('Log all your meals', 4, 25),
    ];
    final nutrition = nutritionTypes[random.nextInt(nutritionTypes.length)];
    challenges.add(DailyChallenge(
      id: 'daily_nutrition_${date.millisecondsSinceEpoch}',
      title: nutrition.$1,
      description: 'Fuel your body right',
      type: 'nutrition',
      targetValue: nutrition.$2,
      xpReward: nutrition.$3,
      date: date,
    ));

    // Social challenge  
    if (random.nextBool()) {
      challenges.add(DailyChallenge(
        id: 'daily_social_${date.millisecondsSinceEpoch}',
        title: 'Share your progress',
        description: 'Inspire others with your journey',
        type: 'social',
        targetValue: 1,
        xpReward: 20,
        date: date,
      ));
    }

    return challenges;
  }

  Future<DailyChallenge?> _updateDailyChallengeProgress(String type, int progress) async {
    final index = _dailyChallenges.indexWhere(
      (c) => c.type == type && !c.isCompleted
    );

    if (index != -1) {
      final challenge = _dailyChallenges[index];
      final newProgress = challenge.currentProgress + progress;
      
      _dailyChallenges[index] = challenge.copyWith(
        currentProgress: newProgress,
        isCompleted: newProgress >= challenge.targetValue,
      );

      if (_dailyChallenges[index].isCompleted) {
        await awardXP(
          _dailyChallenges[index].xpReward,
          'challenge_completed',
          description: _dailyChallenges[index].title,
        );
      }

      await _saveDailyChallenges();
      notifyListeners();
      
      return _dailyChallenges[index].isCompleted ? _dailyChallenges[index] : null;
    }

    return null;
  }

  // Public method to update challenge progress
  Future<DailyChallenge?> updateChallengeProgress(String type, int progress) async {
    return await _updateDailyChallengeProgress(type, progress);
  }
}
