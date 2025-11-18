// Community-related models for Phase 7

class SharedWorkout {
  final String id;
  final String workoutId;
  final String workoutName;
  final String category;
  final String description;
  final String sharedBy;
  final String sharedByName;
  final DateTime sharedAt;
  final int exerciseCount;
  final int likes;
  final int clones;
  final List<String> tags;

  SharedWorkout({
    required this.id,
    required this.workoutId,
    required this.workoutName,
    required this.category,
    required this.description,
    required this.sharedBy,
    required this.sharedByName,
    required this.sharedAt,
    required this.exerciseCount,
    this.likes = 0,
    this.clones = 0,
    this.tags = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'workoutId': workoutId,
    'workoutName': workoutName,
    'category': category,
    'description': description,
    'sharedBy': sharedBy,
    'sharedByName': sharedByName,
    'sharedAt': sharedAt.toIso8601String(),
    'exerciseCount': exerciseCount,
    'likes': likes,
    'clones': clones,
    'tags': tags,
  };

  factory SharedWorkout.fromJson(Map<String, dynamic> json) {
    return SharedWorkout(
      id: json['id'],
      workoutId: json['workoutId'],
      workoutName: json['workoutName'],
      category: json['category'],
      description: json['description'],
      sharedBy: json['sharedBy'],
      sharedByName: json['sharedByName'],
      sharedAt: DateTime.parse(json['sharedAt']),
      exerciseCount: json['exerciseCount'],
      likes: json['likes'] ?? 0,
      clones: json['clones'] ?? 0,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
    );
  }
}

class Achievement {
  final String id;
  final String name;
  final String description;
  final String icon;
  final int requiredCount;
  final String category; // 'workouts', 'consistency', 'milestones'
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int currentProgress;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.requiredCount,
    required this.category,
    this.isUnlocked = false,
    this.unlockedAt,
    this.currentProgress = 0,
  });

  Achievement copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    int? requiredCount,
    String? category,
    bool? isUnlocked,
    DateTime? unlockedAt,
    int? currentProgress,
  }) {
    return Achievement(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      requiredCount: requiredCount ?? this.requiredCount,
      category: category ?? this.category,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      currentProgress: currentProgress ?? this.currentProgress,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'icon': icon,
    'requiredCount': requiredCount,
    'category': category,
    'isUnlocked': isUnlocked,
    'unlockedAt': unlockedAt?.toIso8601String(),
    'currentProgress': currentProgress,
  };

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      icon: json['icon'],
      requiredCount: json['requiredCount'],
      category: json['category'],
      isUnlocked: json['isUnlocked'] ?? false,
      unlockedAt: json['unlockedAt'] != null ? DateTime.parse(json['unlockedAt']) : null,
      currentProgress: json['currentProgress'] ?? 0,
    );
  }
}

class LeaderboardEntry {
  final String userId;
  final String userName;
  final int rank;
  final int score;
  final String metric; // 'workouts', 'exercises', 'streak'
  final String period; // 'weekly', 'monthly', 'alltime'

  LeaderboardEntry({
    required this.userId,
    required this.userName,
    required this.rank,
    required this.score,
    required this.metric,
    required this.period,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'userName': userName,
    'rank': rank,
    'score': score,
    'metric': metric,
    'period': period,
  };

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      userId: json['userId'],
      userName: json['userName'],
      rank: json['rank'],
      score: json['score'],
      metric: json['metric'],
      period: json['period'],
    );
  }
}

class Challenge {
  final String id;
  final String name;
  final String description;
  final String type; // 'daily', 'weekly', 'monthly'
  final int targetCount;
  final String metric; // 'workouts', 'exercises', 'minutes'
  final DateTime startDate;
  final DateTime endDate;
  final int participants;
  final int currentProgress;
  final bool isJoined;

  Challenge({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.targetCount,
    required this.metric,
    required this.startDate,
    required this.endDate,
    this.participants = 0,
    this.currentProgress = 0,
    this.isJoined = false,
  });

  Challenge copyWith({
    String? id,
    String? name,
    String? description,
    String? type,
    int? targetCount,
    String? metric,
    DateTime? startDate,
    DateTime? endDate,
    int? participants,
    int? currentProgress,
    bool? isJoined,
  }) {
    return Challenge(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      targetCount: targetCount ?? this.targetCount,
      metric: metric ?? this.metric,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      participants: participants ?? this.participants,
      currentProgress: currentProgress ?? this.currentProgress,
      isJoined: isJoined ?? this.isJoined,
    );
  }

  double get progressPercentage => (currentProgress / targetCount * 100).clamp(0, 100);
  
  int get daysRemaining => endDate.difference(DateTime.now()).inDays;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'type': type,
    'targetCount': targetCount,
    'metric': metric,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'participants': participants,
    'currentProgress': currentProgress,
    'isJoined': isJoined,
  };

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: json['type'],
      targetCount: json['targetCount'],
      metric: json['metric'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      participants: json['participants'] ?? 0,
      currentProgress: json['currentProgress'] ?? 0,
      isJoined: json['isJoined'] ?? false,
    );
  }
}
