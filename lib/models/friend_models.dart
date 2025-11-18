// Friend-related models for Phase 7

class Friend {
  final String id;
  final String name;
  final String? avatarUrl;
  final int totalWorkouts;
  final int currentStreak;
  final DateTime? lastWorkoutDate;
  final String status; // 'active', 'inactive'
  final DateTime friendsSince;

  Friend({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.totalWorkouts = 0,
    this.currentStreak = 0,
    this.lastWorkoutDate,
    this.status = 'active',
    required this.friendsSince,
  });

  Friend copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    int? totalWorkouts,
    int? currentStreak,
    DateTime? lastWorkoutDate,
    String? status,
    DateTime? friendsSince,
  }) {
    return Friend(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      totalWorkouts: totalWorkouts ?? this.totalWorkouts,
      currentStreak: currentStreak ?? this.currentStreak,
      lastWorkoutDate: lastWorkoutDate ?? this.lastWorkoutDate,
      status: status ?? this.status,
      friendsSince: friendsSince ?? this.friendsSince,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'avatarUrl': avatarUrl,
    'totalWorkouts': totalWorkouts,
    'currentStreak': currentStreak,
    'lastWorkoutDate': lastWorkoutDate?.toIso8601String(),
    'status': status,
    'friendsSince': friendsSince.toIso8601String(),
  };

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      id: json['id'],
      name: json['name'],
      avatarUrl: json['avatarUrl'],
      totalWorkouts: json['totalWorkouts'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
      lastWorkoutDate: json['lastWorkoutDate'] != null
          ? DateTime.parse(json['lastWorkoutDate'])
          : null,
      status: json['status'] ?? 'active',
      friendsSince: DateTime.parse(json['friendsSince']),
    );
  }
}

class FriendActivity {
  final String id;
  final String friendId;
  final String friendName;
  final String activityType; // 'workout_completed', 'achievement_unlocked', 'challenge_joined'
  final String title;
  final String? description;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  FriendActivity({
    required this.id,
    required this.friendId,
    required this.friendName,
    required this.activityType,
    required this.title,
    this.description,
    required this.timestamp,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'friendId': friendId,
    'friendName': friendName,
    'activityType': activityType,
    'title': title,
    'description': description,
    'timestamp': timestamp.toIso8601String(),
    'metadata': metadata,
  };

  factory FriendActivity.fromJson(Map<String, dynamic> json) {
    return FriendActivity(
      id: json['id'],
      friendId: json['friendId'],
      friendName: json['friendName'],
      activityType: json['activityType'],
      title: json['title'],
      description: json['description'],
      timestamp: DateTime.parse(json['timestamp']),
      metadata: json['metadata'],
    );
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }
}

class FriendRequest {
  final String id;
  final String fromUserId;
  final String fromUserName;
  final DateTime requestDate;
  final String status; // 'pending', 'accepted', 'rejected'

  FriendRequest({
    required this.id,
    required this.fromUserId,
    required this.fromUserName,
    required this.requestDate,
    this.status = 'pending',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'fromUserId': fromUserId,
    'fromUserName': fromUserName,
    'requestDate': requestDate.toIso8601String(),
    'status': status,
  };

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(
      id: json['id'],
      fromUserId: json['fromUserId'],
      fromUserName: json['fromUserName'],
      requestDate: DateTime.parse(json['requestDate']),
      status: json['status'] ?? 'pending',
    );
  }
}
