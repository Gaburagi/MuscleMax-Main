import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/social_model.dart';

class SocialProvider with ChangeNotifier {
  // Current user info
  String _currentUserId = 'user_001';
  String _currentUserName = 'You';
  
  // Leaderboards
  List<LeaderboardEntry> _xpLeaderboard = [];
  List<LeaderboardEntry> _streakLeaderboard = [];
  List<LeaderboardEntry> _workoutLeaderboard = [];
  
  // Challenges
  List<Challenge> _challenges = [];
  
  // Workout feed
  List<WorkoutPost> _workoutFeed = [];
  
  // Teams
  List<Team> _teams = [];
  Team? _currentUserTeam;
  List<TeamBattle> _teamBattles = [];
  
  // Getters
  List<LeaderboardEntry> get xpLeaderboard => _xpLeaderboard;
  List<LeaderboardEntry> get streakLeaderboard => _streakLeaderboard;
  List<LeaderboardEntry> get workoutLeaderboard => _workoutLeaderboard;
  List<Challenge> get challenges => _challenges;
  List<Challenge> get activeChallenges => 
      _challenges.where((c) => c.status == ChallengeStatus.active).toList();
  List<Challenge> get pendingChallenges => 
      _challenges.where((c) => 
        c.status == ChallengeStatus.pending && c.opponentId == _currentUserId
      ).toList();
  List<WorkoutPost> get workoutFeed => _workoutFeed;
  List<Team> get teams => _teams;
  Team? get currentUserTeam => _currentUserTeam;
  List<TeamBattle> get teamBattles => _teamBattles;
  List<TeamBattle> get activeTeamBattles => 
      _teamBattles.where((b) => b.isActive).toList();
  
  String get currentUserId => _currentUserId;
  String get currentUserName => _currentUserName;

  // Initialize with sample data
  Future<void> loadData() async {
    await Future.wait([
      _loadLeaderboards(),
      _loadChallenges(),
      _loadWorkoutFeed(),
      _loadTeams(),
      _loadTeamBattles(),
    ]);
    notifyListeners();
  }

  Future<void> _loadLeaderboards() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load XP leaderboard
      final xpData = prefs.getString('xp_leaderboard');
      if (xpData != null) {
        final List<dynamic> list = jsonDecode(xpData);
        _xpLeaderboard = list.map((e) => LeaderboardEntry.fromJson(e)).toList();
      } else {
        _xpLeaderboard = _generateSampleXPLeaderboard();
        await _saveLeaderboards();
      }
      
      // Load streak leaderboard
      final streakData = prefs.getString('streak_leaderboard');
      if (streakData != null) {
        final List<dynamic> list = jsonDecode(streakData);
        _streakLeaderboard = list.map((e) => LeaderboardEntry.fromJson(e)).toList();
      } else {
        _streakLeaderboard = _generateSampleStreakLeaderboard();
        await _saveLeaderboards();
      }
      
      // Load workout leaderboard
      final workoutData = prefs.getString('workout_leaderboard');
      if (workoutData != null) {
        final List<dynamic> list = jsonDecode(workoutData);
        _workoutLeaderboard = list.map((e) => LeaderboardEntry.fromJson(e)).toList();
      } else {
        _workoutLeaderboard = _generateSampleWorkoutLeaderboard();
        await _saveLeaderboards();
      }
    } catch (e) {
      debugPrint('Error loading leaderboards: $e');
    }
  }

  Future<void> _loadChallenges() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('challenges');
      if (data != null) {
        final List<dynamic> list = jsonDecode(data);
        _challenges = list.map((c) => Challenge.fromJson(c)).toList();
      } else {
        _challenges = _generateSampleChallenges();
        await _saveChallenges();
      }
    } catch (e) {
      debugPrint('Error loading challenges: $e');
    }
  }

  Future<void> _loadWorkoutFeed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('workout_feed');
      if (data != null) {
        final List<dynamic> list = jsonDecode(data);
        _workoutFeed = list.map((p) => WorkoutPost.fromJson(p)).toList();
      } else {
        _workoutFeed = _generateSampleWorkoutFeed();
        await _saveWorkoutFeed();
      }
    } catch (e) {
      debugPrint('Error loading workout feed: $e');
    }
  }

  Future<void> _loadTeams() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('teams');
      if (data != null) {
        final List<dynamic> list = jsonDecode(data);
        _teams = list.map((t) => Team.fromJson(t)).toList();
        
        // Find current user's team
        _currentUserTeam = _teams.firstWhere(
          (t) => t.members.any((m) => m.userId == _currentUserId),
          orElse: () => _teams.first, // Default to first team for demo
        );
      } else {
        _teams = _generateSampleTeams();
        _currentUserTeam = _teams.first;
        await _saveTeams();
      }
    } catch (e) {
      debugPrint('Error loading teams: $e');
    }
  }

  Future<void> _loadTeamBattles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('team_battles');
      if (data != null) {
        final List<dynamic> list = jsonDecode(data);
        _teamBattles = list.map((b) => TeamBattle.fromJson(b)).toList();
      } else {
        _teamBattles = _generateSampleTeamBattles();
        await _saveTeamBattles();
      }
    } catch (e) {
      debugPrint('Error loading team battles: $e');
    }
  }

  // Save methods
  Future<void> _saveLeaderboards() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('xp_leaderboard', 
        jsonEncode(_xpLeaderboard.map((e) => e.toJson()).toList()));
    await prefs.setString('streak_leaderboard',
        jsonEncode(_streakLeaderboard.map((e) => e.toJson()).toList()));
    await prefs.setString('workout_leaderboard',
        jsonEncode(_workoutLeaderboard.map((e) => e.toJson()).toList()));
  }

  Future<void> _saveChallenges() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('challenges',
        jsonEncode(_challenges.map((c) => c.toJson()).toList()));
  }

  Future<void> _saveWorkoutFeed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('workout_feed',
        jsonEncode(_workoutFeed.map((p) => p.toJson()).toList()));
  }

  Future<void> _saveTeams() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('teams',
        jsonEncode(_teams.map((t) => t.toJson()).toList()));
  }

  Future<void> _saveTeamBattles() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('team_battles',
        jsonEncode(_teamBattles.map((b) => b.toJson()).toList()));
  }

  // Update leaderboard with user's current stats
  Future<void> updateLeaderboards({
    int? xp,
    int? streak,
    int? workouts,
    int? level,
    String? title,
  }) async {
    if (xp != null) {
      _updateLeaderboard(_xpLeaderboard, xp, level: level, title: title);
    }
    if (streak != null) {
      _updateLeaderboard(_streakLeaderboard, streak);
    }
    if (workouts != null) {
      _updateLeaderboard(_workoutLeaderboard, workouts);
    }
    await _saveLeaderboards();
    notifyListeners();
  }

  void _updateLeaderboard(List<LeaderboardEntry> leaderboard, int newValue, {int? level, String? title}) {
    // Find current user entry
    final index = leaderboard.indexWhere((e) => e.isCurrentUser);
    
    if (index != -1) {
      // Update existing entry
      leaderboard[index] = LeaderboardEntry(
        userId: _currentUserId,
        userName: _currentUserName,
        value: newValue,
        rank: leaderboard[index].rank,
        level: level ?? leaderboard[index].level,
        title: title ?? leaderboard[index].title,
        isCurrentUser: true,
      );
    } else {
      // Add new entry
      leaderboard.add(LeaderboardEntry(
        userId: _currentUserId,
        userName: _currentUserName,
        value: newValue,
        rank: leaderboard.length + 1,
        level: level,
        title: title,
        isCurrentUser: true,
      ));
    }
    
    // Re-sort and update ranks
    leaderboard.sort((a, b) => b.value.compareTo(a.value));
    for (int i = 0; i < leaderboard.length; i++) {
      leaderboard[i] = LeaderboardEntry(
        userId: leaderboard[i].userId,
        userName: leaderboard[i].userName,
        avatarUrl: leaderboard[i].avatarUrl,
        value: leaderboard[i].value,
        rank: i + 1,
        level: leaderboard[i].level,
        title: leaderboard[i].title,
        isCurrentUser: leaderboard[i].isCurrentUser,
      );
    }
  }

  // Challenge methods
  Future<void> createChallenge({
    required String opponentId,
    required String opponentName,
    required ChallengeType type,
    required String description,
    required Map<String, dynamic> targetValue,
    int durationDays = 7,
  }) async {
    final challenge = Challenge(
      id: 'challenge_${DateTime.now().millisecondsSinceEpoch}',
      challengerId: _currentUserId,
      challengerName: _currentUserName,
      opponentId: opponentId,
      opponentName: opponentName,
      type: type,
      status: ChallengeStatus.pending,
      description: description,
      targetValue: targetValue,
      challengerProgress: {},
      opponentProgress: {},
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(Duration(days: durationDays)),
      xpReward: 100,
    );
    
    _challenges.insert(0, challenge);
    await _saveChallenges();
    notifyListeners();
  }

  Future<void> acceptChallenge(String challengeId) async {
    final index = _challenges.indexWhere((c) => c.id == challengeId);
    if (index != -1) {
      _challenges[index] = _challenges[index].copyWith(
        status: ChallengeStatus.active,
      );
      await _saveChallenges();
      notifyListeners();
    }
  }

  Future<void> declineChallenge(String challengeId) async {
    final index = _challenges.indexWhere((c) => c.id == challengeId);
    if (index != -1) {
      _challenges[index] = _challenges[index].copyWith(
        status: ChallengeStatus.declined,
      );
      await _saveChallenges();
      notifyListeners();
    }
  }

  Future<void> updateChallengeProgress(
    String challengeId,
    String userId,
    Map<String, dynamic> progress,
  ) async {
    final index = _challenges.indexWhere((c) => c.id == challengeId);
    if (index != -1) {
      final challenge = _challenges[index];
      
      if (userId == challenge.challengerId) {
        _challenges[index] = challenge.copyWith(
          challengerProgress: progress,
        );
      } else {
        _challenges[index] = challenge.copyWith(
          opponentProgress: progress,
        );
      }
      
      // Check if challenge completed
      await _checkChallengeCompletion(_challenges[index]);
      await _saveChallenges();
      notifyListeners();
    }
  }

  Future<void> _checkChallengeCompletion(Challenge challenge) async {
    // Logic to determine if challenge is complete and who won
    // This would be implemented based on challenge type
  }

  // Workout feed methods
  Future<void> postWorkout({
    required String workoutName,
    required int durationMinutes,
    required int exercisesCompleted,
    int? caloriesBurned,
    List<String> personalRecords = const [],
    int xpGained = 0,
    List<String> achievements = const [],
    String? note,
  }) async {
    final post = WorkoutPost(
      id: 'post_${DateTime.now().millisecondsSinceEpoch}',
      userId: _currentUserId,
      userName: _currentUserName,
      workoutName: workoutName,
      durationMinutes: durationMinutes,
      exercisesCompleted: exercisesCompleted,
      caloriesBurned: caloriesBurned,
      personalRecords: personalRecords,
      xpGained: xpGained,
      achievements: achievements,
      timestamp: DateTime.now(),
      likedBy: [],
      comments: [],
      note: note,
    );
    
    _workoutFeed.insert(0, post);
    await _saveWorkoutFeed();
    notifyListeners();
  }

  Future<void> likePost(String postId) async {
    final index = _workoutFeed.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = _workoutFeed[index];
      final likedBy = List<String>.from(post.likedBy);
      
      if (likedBy.contains(_currentUserId)) {
        likedBy.remove(_currentUserId);
      } else {
        likedBy.add(_currentUserId);
      }
      
      _workoutFeed[index] = post.copyWith(likedBy: likedBy);
      await _saveWorkoutFeed();
      notifyListeners();
    }
  }

  Future<void> commentOnPost(String postId, String text) async {
    final index = _workoutFeed.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = _workoutFeed[index];
      final comments = List<WorkoutComment>.from(post.comments);
      
      comments.add(WorkoutComment(
        id: 'comment_${DateTime.now().millisecondsSinceEpoch}',
        userId: _currentUserId,
        userName: _currentUserName,
        text: text,
        timestamp: DateTime.now(),
      ));
      
      _workoutFeed[index] = post.copyWith(comments: comments);
      await _saveWorkoutFeed();
      notifyListeners();
    }
  }

  // Team methods
  Future<void> createTeam({
    required String name,
    String? description,
  }) async {
    final team = Team(
      id: 'team_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      description: description,
      captainId: _currentUserId,
      members: [
        TeamMember(
          userId: _currentUserId,
          userName: _currentUserName,
          contributedXP: 0,
          contributedWorkouts: 0,
          joinedAt: DateTime.now(),
        ),
      ],
      totalXP: 0,
      totalWorkouts: 0,
      createdAt: DateTime.now(),
      activeBattleIds: [],
    );
    
    _teams.insert(0, team);
    _currentUserTeam = team;
    await _saveTeams();
    notifyListeners();
  }

  Future<void> updateTeamStats(int xpGained, int workoutCount) async {
    if (_currentUserTeam == null) return;
    
    // Update team totals
    final updatedTeam = Team(
      id: _currentUserTeam!.id,
      name: _currentUserTeam!.name,
      description: _currentUserTeam!.description,
      avatarUrl: _currentUserTeam!.avatarUrl,
      captainId: _currentUserTeam!.captainId,
      members: _currentUserTeam!.members.map((m) {
        if (m.userId == _currentUserId) {
          return TeamMember(
            userId: m.userId,
            userName: m.userName,
            avatarUrl: m.avatarUrl,
            contributedXP: m.contributedXP + xpGained,
            contributedWorkouts: m.contributedWorkouts + workoutCount,
            joinedAt: m.joinedAt,
          );
        }
        return m;
      }).toList(),
      totalXP: _currentUserTeam!.totalXP + xpGained,
      totalWorkouts: _currentUserTeam!.totalWorkouts + workoutCount,
      createdAt: _currentUserTeam!.createdAt,
      activeBattleIds: _currentUserTeam!.activeBattleIds,
    );
    
    final index = _teams.indexWhere((t) => t.id == _currentUserTeam!.id);
    if (index != -1) {
      _teams[index] = updatedTeam;
      _currentUserTeam = updatedTeam;
      await _saveTeams();
      
      // Update active team battles
      await _updateTeamBattleScores(_currentUserTeam!.id, xpGained);
      notifyListeners();
    }
  }

  Future<void> _updateTeamBattleScores(String teamId, int xpGained) async {
    for (int i = 0; i < _teamBattles.length; i++) {
      final battle = _teamBattles[i];
      if (!battle.isActive) continue;
      
      if (battle.team1Id == teamId) {
        _teamBattles[i] = battle.copyWith(
          team1Score: battle.team1Score + xpGained,
        );
      } else if (battle.team2Id == teamId) {
        _teamBattles[i] = battle.copyWith(
          team2Score: battle.team2Score + xpGained,
        );
      }
      
      // Check if battle ended
      if (DateTime.now().isAfter(battle.endDate)) {
        final winnerId = battle.team1Score > battle.team2Score
            ? battle.team1Id
            : battle.team2Id;
        _teamBattles[i] = _teamBattles[i].copyWith(
          isActive: false,
          winnerId: winnerId,
        );
      }
    }
    await _saveTeamBattles();
  }

  // Sample data generators
  List<LeaderboardEntry> _generateSampleXPLeaderboard() {
    final names = ['Sarah M.', 'Mike T.', 'Alex K.', 'Jordan P.', 'Chris L.', 
                   'Taylor W.', 'Morgan R.', 'Casey B.', 'Drew S.'];
    return List.generate(10, (i) {
      if (i == 3) {
        return LeaderboardEntry(
          userId: _currentUserId,
          userName: _currentUserName,
          value: 850,
          rank: i + 1,
          level: 5,
          title: 'Intermediate',
          isCurrentUser: true,
        );
      }
      return LeaderboardEntry(
        userId: 'user_${i + 2}',
        userName: names[i % names.length],
        value: 2000 - (i * 150),
        rank: i + 1,
        level: 8 - (i ~/ 2),
        title: ['Legend', 'Master', 'Expert', 'Advanced', 'Intermediate'][i ~/ 2],
      );
    });
  }

  List<LeaderboardEntry> _generateSampleStreakLeaderboard() {
    final names = ['Emma D.', 'Noah F.', 'Olivia H.', 'Liam G.', 'Ava N.',
                   'Ethan M.', 'Sophia P.', 'Mason Q.', 'Isabella R.'];
    return List.generate(10, (i) {
      if (i == 5) {
        return LeaderboardEntry(
          userId: _currentUserId,
          userName: _currentUserName,
          value: 12,
          rank: i + 1,
          isCurrentUser: true,
        );
      }
      return LeaderboardEntry(
        userId: 'user_${i + 2}',
        userName: names[i % names.length],
        value: 60 - (i * 5),
        rank: i + 1,
      );
    });
  }

  List<LeaderboardEntry> _generateSampleWorkoutLeaderboard() {
    final names = ['James L.', 'Emily W.', 'Daniel K.', 'Grace M.', 'Ryan B.',
                   'Hannah T.', 'Lucas F.', 'Chloe D.', 'Matthew S.'];
    return List.generate(10, (i) {
      if (i == 4) {
        return LeaderboardEntry(
          userId: _currentUserId,
          userName: _currentUserName,
          value: 28,
          rank: i + 1,
          isCurrentUser: true,
        );
      }
      return LeaderboardEntry(
        userId: 'user_${i + 2}',
        userName: names[i % names.length],
        value: 80 - (i * 6),
        rank: i + 1,
      );
    });
  }

  List<Challenge> _generateSampleChallenges() {
    return [
      Challenge(
        id: 'challenge_1',
        challengerId: 'user_002',
        challengerName: 'Sarah M.',
        opponentId: _currentUserId,
        opponentName: _currentUserName,
        type: ChallengeType.workoutCount,
        status: ChallengeStatus.pending,
        description: 'Complete 5 workouts this week',
        targetValue: {'count': 5},
        challengerProgress: {'count': 2},
        opponentProgress: {},
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        expiresAt: DateTime.now().add(const Duration(days: 5)),
        xpReward: 150,
      ),
    ];
  }

  List<WorkoutPost> _generateSampleWorkoutFeed() {
    return [
      WorkoutPost(
        id: 'post_1',
        userId: 'user_002',
        userName: 'Sarah M.',
        workoutName: 'Upper Body Strength',
        durationMinutes: 45,
        exercisesCompleted: 6,
        caloriesBurned: 320,
        personalRecords: ['Bench Press: 135 lbs x 8'],
        xpGained: 50,
        achievements: ['Consistent Effort'],
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        likedBy: ['user_003', 'user_004'],
        comments: [
          WorkoutComment(
            id: 'comment_1',
            userId: 'user_003',
            userName: 'Mike T.',
            text: 'Great work! 💪',
            timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
          ),
        ],
        note: 'Feeling strong today!',
      ),
    ];
  }

  List<Team> _generateSampleTeams() {
    return [
      Team(
        id: 'team_1',
        name: 'Iron Warriors',
        description: 'Lifting heavy, living strong',
        captainId: _currentUserId,
        members: [
          TeamMember(
            userId: _currentUserId,
            userName: _currentUserName,
            contributedXP: 450,
            contributedWorkouts: 15,
            joinedAt: DateTime.now().subtract(const Duration(days: 30)),
          ),
          TeamMember(
            userId: 'user_002',
            userName: 'Sarah M.',
            contributedXP: 380,
            contributedWorkouts: 12,
            joinedAt: DateTime.now().subtract(const Duration(days: 25)),
          ),
        ],
        totalXP: 830,
        totalWorkouts: 27,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        activeBattleIds: ['battle_1'],
      ),
    ];
  }

  List<TeamBattle> _generateSampleTeamBattles() {
    return [
      TeamBattle(
        id: 'battle_1',
        team1Id: 'team_1',
        team1Name: 'Iron Warriors',
        team2Id: 'team_2',
        team2Name: 'Fitness Legends',
        team1Score: 1250,
        team2Score: 1180,
        startDate: DateTime.now().subtract(const Duration(days: 5)),
        endDate: DateTime.now().add(const Duration(days: 2)),
        isActive: true,
        battleType: 'xp',
      ),
    ];
  }
}
