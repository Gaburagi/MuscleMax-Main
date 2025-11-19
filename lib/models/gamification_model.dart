class UserLevel {
  final int level;
  final int currentXP;
  final int xpForNextLevel;
  final String title;

  UserLevel({
    required this.level,
    required this.currentXP,
    required this.xpForNextLevel,
    required this.title,
  });

  double get progress => currentXP / xpForNextLevel;

  // XP required increases with level (exponential curve)
  static int xpRequiredForLevel(int level) {
    return (100 * level * 1.5).round();
  }

  static String titleForLevel(int level) {
    if (level < 5) return 'Beginner';
    if (level < 10) return 'Novice';
    if (level < 20) return 'Intermediate';
    if (level < 35) return 'Advanced';
    if (level < 50) return 'Expert';
    if (level < 75) return 'Master';
    if (level < 100) return 'Legend';
    return 'Mythic';
  }

  Map<String, dynamic> toJson() => {
    'level': level,
    'currentXP': currentXP,
    'xpForNextLevel': xpForNextLevel,
    'title': title,
  };

  factory UserLevel.fromJson(Map<String, dynamic> json) {
    return UserLevel(
      level: json['level'],
      currentXP: json['currentXP'],
      xpForNextLevel: json['xpForNextLevel'],
      title: json['title'],
    );
  }
}

class Achievement {
  final String id;
  final String name;
  final String description;
  final String icon;
  final int requiredCount;
  final String category; // workouts, prs, streak, social, nutrition
  final int xpReward;
  final bool isUnlocked;
  final int currentProgress;
  final DateTime? unlockedDate;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.requiredCount,
    required this.category,
    this.xpReward = 50,
    this.isUnlocked = false,
    this.currentProgress = 0,
    this.unlockedDate,
  });

  double get progressPercentage => 
      (currentProgress / requiredCount * 100).clamp(0, 100);

  Achievement copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    int? requiredCount,
    String? category,
    int? xpReward,
    bool? isUnlocked,
    int? currentProgress,
    DateTime? unlockedDate,
  }) {
    return Achievement(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      requiredCount: requiredCount ?? this.requiredCount,
      category: category ?? this.category,
      xpReward: xpReward ?? this.xpReward,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      currentProgress: currentProgress ?? this.currentProgress,
      unlockedDate: unlockedDate ?? this.unlockedDate,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'icon': icon,
    'requiredCount': requiredCount,
    'category': category,
    'xpReward': xpReward,
    'isUnlocked': isUnlocked,
    'currentProgress': currentProgress,
    'unlockedDate': unlockedDate?.toIso8601String(),
  };

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      icon: json['icon'],
      requiredCount: json['requiredCount'],
      category: json['category'],
      xpReward: json['xpReward'] ?? 50,
      isUnlocked: json['isUnlocked'] ?? false,
      currentProgress: json['currentProgress'] ?? 0,
      unlockedDate: json['unlockedDate'] != null 
          ? DateTime.parse(json['unlockedDate']) 
          : null,
    );
  }
}

class WorkoutStreak {
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastWorkoutDate;
  final List<DateTime> workoutDates;

  WorkoutStreak({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastWorkoutDate,
    this.workoutDates = const [],
  });

  bool get isActiveToday {
    if (lastWorkoutDate == null) return false;
    final now = DateTime.now();
    final lastWorkout = lastWorkoutDate!;
    return now.year == lastWorkout.year &&
           now.month == lastWorkout.month &&
           now.day == lastWorkout.day;
  }

  WorkoutStreak copyWith({
    int? currentStreak,
    int? longestStreak,
    DateTime? lastWorkoutDate,
    List<DateTime>? workoutDates,
  }) {
    return WorkoutStreak(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastWorkoutDate: lastWorkoutDate ?? this.lastWorkoutDate,
      workoutDates: workoutDates ?? this.workoutDates,
    );
  }

  Map<String, dynamic> toJson() => {
    'currentStreak': currentStreak,
    'longestStreak': longestStreak,
    'lastWorkoutDate': lastWorkoutDate?.toIso8601String(),
    'workoutDates': workoutDates.map((d) => d.toIso8601String()).toList(),
  };

  factory WorkoutStreak.fromJson(Map<String, dynamic> json) {
    return WorkoutStreak(
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      lastWorkoutDate: json['lastWorkoutDate'] != null
          ? DateTime.parse(json['lastWorkoutDate'])
          : null,
      workoutDates: json['workoutDates'] != null
          ? (json['workoutDates'] as List)
              .map((d) => DateTime.parse(d))
              .toList()
          : [],
    );
  }
}

class DailyChallenge {
  final String id;
  final String title;
  final String description;
  final String type; // workout, nutrition, social
  final int targetValue;
  final int currentProgress;
  final int xpReward;
  final DateTime date;
  final bool isCompleted;

  DailyChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.targetValue,
    this.currentProgress = 0,
    this.xpReward = 25,
    required this.date,
    this.isCompleted = false,
  });

  double get progressPercentage => 
      (currentProgress / targetValue * 100).clamp(0, 100);

  DailyChallenge copyWith({
    String? id,
    String? title,
    String? description,
    String? type,
    int? targetValue,
    int? currentProgress,
    int? xpReward,
    DateTime? date,
    bool? isCompleted,
  }) {
    return DailyChallenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      targetValue: targetValue ?? this.targetValue,
      currentProgress: currentProgress ?? this.currentProgress,
      xpReward: xpReward ?? this.xpReward,
      date: date ?? this.date,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'type': type,
    'targetValue': targetValue,
    'currentProgress': currentProgress,
    'xpReward': xpReward,
    'date': date.toIso8601String(),
    'isCompleted': isCompleted,
  };

  factory DailyChallenge.fromJson(Map<String, dynamic> json) {
    return DailyChallenge(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: json['type'],
      targetValue: json['targetValue'],
      currentProgress: json['currentProgress'] ?? 0,
      xpReward: json['xpReward'] ?? 25,
      date: DateTime.parse(json['date']),
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}

class XPEvent {
  final String action; // workout_complete, pr_achieved, goal_completed, etc.
  final int xpGained;
  final DateTime timestamp;
  final String? description;

  XPEvent({
    required this.action,
    required this.xpGained,
    required this.timestamp,
    this.description,
  });

  Map<String, dynamic> toJson() => {
    'action': action,
    'xpGained': xpGained,
    'timestamp': timestamp.toIso8601String(),
    'description': description,
  };

  factory XPEvent.fromJson(Map<String, dynamic> json) {
    return XPEvent(
      action: json['action'],
      xpGained: json['xpGained'],
      timestamp: DateTime.parse(json['timestamp']),
      description: json['description'],
    );
  }
}
