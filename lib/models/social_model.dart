// Leaderboard entry for rankings
class LeaderboardEntry {
  final String userId;
  final String userName;
  final String? avatarUrl;
  final int value; // XP, streak days, or workout count
  final int rank;
  final int? level;
  final String? title;
  final bool isCurrentUser;

  LeaderboardEntry({
    required this.userId,
    required this.userName,
    this.avatarUrl,
    required this.value,
    required this.rank,
    this.level,
    this.title,
    this.isCurrentUser = false,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'userName': userName,
    'avatarUrl': avatarUrl,
    'value': value,
    'rank': rank,
    'level': level,
    'title': title,
    'isCurrentUser': isCurrentUser,
  };

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      userId: json['userId'],
      userName: json['userName'],
      avatarUrl: json['avatarUrl'],
      value: json['value'],
      rank: json['rank'],
      level: json['level'],
      title: json['title'],
      isCurrentUser: json['isCurrentUser'] ?? false,
    );
  }
}

// Challenge types
enum ChallengeType {
  prBattle,      // Beat a specific PR
  streakMatch,   // Match or beat a streak
  workoutCount,  // Complete X workouts
  xpRace,        // Earn X XP first
  exerciseTotal, // Total weight/reps for an exercise
}

// Challenge status
enum ChallengeStatus {
  pending,   // Sent, awaiting acceptance
  active,    // Accepted, in progress
  completed, // Finished, winner determined
  declined,  // Rejected by recipient
  expired,   // Time limit exceeded
}

// Challenge between users
class Challenge {
  final String id;
  final String challengerId;
  final String challengerName;
  final String opponentId;
  final String opponentName;
  final ChallengeType type;
  final ChallengeStatus status;
  final String description;
  final Map<String, dynamic> targetValue; // Type-specific target
  final Map<String, dynamic> challengerProgress;
  final Map<String, dynamic> opponentProgress;
  final DateTime createdAt;
  final DateTime expiresAt;
  final DateTime? completedAt;
  final String? winnerId;
  final int xpReward;

  Challenge({
    required this.id,
    required this.challengerId,
    required this.challengerName,
    required this.opponentId,
    required this.opponentName,
    required this.type,
    required this.status,
    required this.description,
    required this.targetValue,
    required this.challengerProgress,
    required this.opponentProgress,
    required this.createdAt,
    required this.expiresAt,
    this.completedAt,
    this.winnerId,
    this.xpReward = 100,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'challengerId': challengerId,
    'challengerName': challengerName,
    'opponentId': opponentId,
    'opponentName': opponentName,
    'type': type.name,
    'status': status.name,
    'description': description,
    'targetValue': targetValue,
    'challengerProgress': challengerProgress,
    'opponentProgress': opponentProgress,
    'createdAt': createdAt.toIso8601String(),
    'expiresAt': expiresAt.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
    'winnerId': winnerId,
    'xpReward': xpReward,
  };

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'],
      challengerId: json['challengerId'],
      challengerName: json['challengerName'],
      opponentId: json['opponentId'],
      opponentName: json['opponentName'],
      type: ChallengeType.values.firstWhere((e) => e.name == json['type']),
      status: ChallengeStatus.values.firstWhere((e) => e.name == json['status']),
      description: json['description'],
      targetValue: Map<String, dynamic>.from(json['targetValue']),
      challengerProgress: Map<String, dynamic>.from(json['challengerProgress']),
      opponentProgress: Map<String, dynamic>.from(json['opponentProgress']),
      createdAt: DateTime.parse(json['createdAt']),
      expiresAt: DateTime.parse(json['expiresAt']),
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      winnerId: json['winnerId'],
      xpReward: json['xpReward'] ?? 100,
    );
  }

  Challenge copyWith({
    ChallengeStatus? status,
    Map<String, dynamic>? challengerProgress,
    Map<String, dynamic>? opponentProgress,
    DateTime? completedAt,
    String? winnerId,
  }) {
    return Challenge(
      id: id,
      challengerId: challengerId,
      challengerName: challengerName,
      opponentId: opponentId,
      opponentName: opponentName,
      type: type,
      status: status ?? this.status,
      description: description,
      targetValue: targetValue,
      challengerProgress: challengerProgress ?? this.challengerProgress,
      opponentProgress: opponentProgress ?? this.opponentProgress,
      createdAt: createdAt,
      expiresAt: expiresAt,
      completedAt: completedAt ?? this.completedAt,
      winnerId: winnerId ?? this.winnerId,
      xpReward: xpReward,
    );
  }
}

// Workout post for social feed
class WorkoutPost {
  final String id;
  final String userId;
  final String userName;
  final String? avatarUrl;
  final String? workoutName; // Optional for general posts
  final int? durationMinutes; // Optional for general posts
  final int? exercisesCompleted; // Optional for general posts
  final int? caloriesBurned;
  final List<String> personalRecords; // PR descriptions
  final int? xpGained; // Optional for general posts
  final List<String> achievements; // Achievement names unlocked
  final DateTime timestamp;
  final List<String> likedBy; // User IDs who liked
  final List<WorkoutComment> comments;
  final String? note; // Post text content (can be used for general posts)
  final List<String> imageUrls; // Attached images
  final List<String> videoUrls; // Attached videos
  final String postType; // 'workout', 'general', 'achievement', 'pr'

  WorkoutPost({
    required this.id,
    required this.userId,
    required this.userName,
    this.avatarUrl,
    this.workoutName,
    this.durationMinutes,
    this.exercisesCompleted,
    this.caloriesBurned,
    this.personalRecords = const [],
    this.xpGained,
    this.achievements = const [],
    required this.timestamp,
    this.likedBy = const [],
    this.comments = const [],
    this.note,
    this.imageUrls = const [],
    this.videoUrls = const [],
    this.postType = 'general',
  });

  int get likeCount => likedBy.length;
  int get commentCount => comments.length;
  bool get isWorkoutPost => postType == 'workout';

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'userName': userName,
    'avatarUrl': avatarUrl,
    'workoutName': workoutName,
    'durationMinutes': durationMinutes,
    'exercisesCompleted': exercisesCompleted,
    'caloriesBurned': caloriesBurned,
    'personalRecords': personalRecords,
    'xpGained': xpGained,
    'achievements': achievements,
    'timestamp': timestamp.toIso8601String(),
    'likedBy': likedBy,
    'comments': comments.map((c) => c.toJson()).toList(),
    'note': note,
    'imageUrls': imageUrls,
    'videoUrls': videoUrls,
    'postType': postType,
  };

  factory WorkoutPost.fromJson(Map<String, dynamic> json) {
    return WorkoutPost(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      avatarUrl: json['avatarUrl'],
      workoutName: json['workoutName'],
      durationMinutes: json['durationMinutes'],
      exercisesCompleted: json['exercisesCompleted'],
      caloriesBurned: json['caloriesBurned'],
      personalRecords: List<String>.from(json['personalRecords'] ?? []),
      xpGained: json['xpGained'],
      achievements: List<String>.from(json['achievements'] ?? []),
      timestamp: DateTime.parse(json['timestamp']),
      likedBy: List<String>.from(json['likedBy'] ?? []),
      comments: (json['comments'] as List?)
          ?.map((c) => WorkoutComment.fromJson(c))
          .toList() ?? [],
      note: json['note'],
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      videoUrls: List<String>.from(json['videoUrls'] ?? []),
      postType: json['postType'] ?? 'general',
    );
  }

  WorkoutPost copyWith({
    List<String>? likedBy,
    List<WorkoutComment>? comments,
  }) {
    return WorkoutPost(
      id: id,
      userId: userId,
      userName: userName,
      avatarUrl: avatarUrl,
      workoutName: workoutName,
      durationMinutes: durationMinutes,
      exercisesCompleted: exercisesCompleted,
      caloriesBurned: caloriesBurned,
      personalRecords: personalRecords,
      xpGained: xpGained,
      achievements: achievements,
      timestamp: timestamp,
      likedBy: likedBy ?? this.likedBy,
      comments: comments ?? this.comments,
      note: note,
      imageUrls: imageUrls,
      videoUrls: videoUrls,
      postType: postType,
    );
  }
}

// Comment on workout post
class WorkoutComment {
  final String id;
  final String userId;
  final String userName;
  final String? avatarUrl;
  final String text;
  final DateTime timestamp;

  WorkoutComment({
    required this.id,
    required this.userId,
    required this.userName,
    this.avatarUrl,
    required this.text,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'userName': userName,
    'avatarUrl': avatarUrl,
    'text': text,
    'timestamp': timestamp.toIso8601String(),
  };

  factory WorkoutComment.fromJson(Map<String, dynamic> json) {
    return WorkoutComment(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      avatarUrl: json['avatarUrl'],
      text: json['text'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

// Team for team battles
class Team {
  final String id;
  final String name;
  final String? description;
  final String? avatarUrl;
  final String captainId;
  final List<TeamMember> members;
  final int totalXP;
  final int totalWorkouts;
  final DateTime createdAt;
  final List<String> activeBattleIds;

  Team({
    required this.id,
    required this.name,
    this.description,
    this.avatarUrl,
    required this.captainId,
    required this.members,
    required this.totalXP,
    required this.totalWorkouts,
    required this.createdAt,
    required this.activeBattleIds,
  });

  int get memberCount => members.length;
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'avatarUrl': avatarUrl,
    'captainId': captainId,
    'members': members.map((m) => m.toJson()).toList(),
    'totalXP': totalXP,
    'totalWorkouts': totalWorkouts,
    'createdAt': createdAt.toIso8601String(),
    'activeBattleIds': activeBattleIds,
  };

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      avatarUrl: json['avatarUrl'],
      captainId: json['captainId'],
      members: (json['members'] as List)
          .map((m) => TeamMember.fromJson(m))
          .toList(),
      totalXP: json['totalXP'],
      totalWorkouts: json['totalWorkouts'],
      createdAt: DateTime.parse(json['createdAt']),
      activeBattleIds: List<String>.from(json['activeBattleIds'] ?? []),
    );
  }
}

// Team member
class TeamMember {
  final String userId;
  final String userName;
  final String? avatarUrl;
  final int contributedXP;
  final int contributedWorkouts;
  final DateTime joinedAt;

  TeamMember({
    required this.userId,
    required this.userName,
    this.avatarUrl,
    required this.contributedXP,
    required this.contributedWorkouts,
    required this.joinedAt,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'userName': userName,
    'avatarUrl': avatarUrl,
    'contributedXP': contributedXP,
    'contributedWorkouts': contributedWorkouts,
    'joinedAt': joinedAt.toIso8601String(),
  };

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    return TeamMember(
      userId: json['userId'],
      userName: json['userName'],
      avatarUrl: json['avatarUrl'],
      contributedXP: json['contributedXP'],
      contributedWorkouts: json['contributedWorkouts'],
      joinedAt: DateTime.parse(json['joinedAt']),
    );
  }
}

// Team battle between two teams
class TeamBattle {
  final String id;
  final String team1Id;
  final String team1Name;
  final String team2Id;
  final String team2Name;
  final int team1Score;
  final int team2Score;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final String? winnerId;
  final String battleType; // 'xp', 'workouts', 'streak'

  TeamBattle({
    required this.id,
    required this.team1Id,
    required this.team1Name,
    required this.team2Id,
    required this.team2Name,
    required this.team1Score,
    required this.team2Score,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    this.winnerId,
    this.battleType = 'xp',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'team1Id': team1Id,
    'team1Name': team1Name,
    'team2Id': team2Id,
    'team2Name': team2Name,
    'team1Score': team1Score,
    'team2Score': team2Score,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'isActive': isActive,
    'winnerId': winnerId,
    'battleType': battleType,
  };

  factory TeamBattle.fromJson(Map<String, dynamic> json) {
    return TeamBattle(
      id: json['id'],
      team1Id: json['team1Id'],
      team1Name: json['team1Name'],
      team2Id: json['team2Id'],
      team2Name: json['team2Name'],
      team1Score: json['team1Score'],
      team2Score: json['team2Score'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      isActive: json['isActive'],
      winnerId: json['winnerId'],
      battleType: json['battleType'] ?? 'xp',
    );
  }

  TeamBattle copyWith({
    int? team1Score,
    int? team2Score,
    bool? isActive,
    String? winnerId,
  }) {
    return TeamBattle(
      id: id,
      team1Id: team1Id,
      team1Name: team1Name,
      team2Id: team2Id,
      team2Name: team2Name,
      team1Score: team1Score ?? this.team1Score,
      team2Score: team2Score ?? this.team2Score,
      startDate: startDate,
      endDate: endDate,
      isActive: isActive ?? this.isActive,
      winnerId: winnerId ?? this.winnerId,
      battleType: battleType,
    );
  }
}
