import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/friend_models.dart';

class FriendsProvider with ChangeNotifier {
  List<Friend> _friends = [];
  List<FriendActivity> _activityFeed = [];
  List<FriendRequest> _friendRequests = [];

  List<Friend> get friends => _friends;
  List<FriendActivity> get activityFeed => _activityFeed;
  List<FriendRequest> get pendingRequests =>
      _friendRequests.where((r) => r.status == 'pending').toList();

  Future<void> loadFriendsData() async {
    await Future.wait([
      _loadFriends(),
      _loadActivityFeed(),
      _loadFriendRequests(),
    ]);
    notifyListeners();
  }

  Future<void> _loadFriends() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('friends');
      if (data != null) {
        final List<dynamic> list = jsonDecode(data);
        _friends = list.map((f) => Friend.fromJson(f)).toList();
      } else {
        // Initialize with demo friends
        _friends = _generateDemoFriends();
        await _saveFriends();
      }
    } catch (e) {
      debugPrint('Error loading friends: $e');
    }
  }

  Future<void> _loadActivityFeed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('friend_activity');
      if (data != null) {
        final List<dynamic> list = jsonDecode(data);
        _activityFeed = list.map((a) => FriendActivity.fromJson(a)).toList();
      } else {
        // Initialize with demo activity
        _activityFeed = _generateDemoActivity();
        await _saveActivityFeed();
      }
    } catch (e) {
      debugPrint('Error loading activity feed: $e');
    }
  }

  Future<void> _loadFriendRequests() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('friend_requests');
      if (data != null) {
        final List<dynamic> list = jsonDecode(data);
        _friendRequests = list.map((r) => FriendRequest.fromJson(r)).toList();
      }
    } catch (e) {
      debugPrint('Error loading friend requests: $e');
    }
  }

  Future<void> addFriend(String name) async {
    final friend = Friend(
      id: 'friend_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      totalWorkouts: 0,
      currentStreak: 0,
      friendsSince: DateTime.now(),
    );
    _friends.add(friend);
    await _saveFriends();
    notifyListeners();
  }

  Future<void> removeFriend(String friendId) async {
    _friends.removeWhere((f) => f.id == friendId);
    await _saveFriends();
    notifyListeners();
  }

  Future<void> acceptFriendRequest(String requestId) async {
    final index = _friendRequests.indexWhere((r) => r.id == requestId);
    if (index != -1) {
      final request = _friendRequests[index];
      
      // Add as friend
      final friend = Friend(
        id: request.fromUserId,
        name: request.fromUserName,
        friendsSince: DateTime.now(),
      );
      _friends.add(friend);
      
      // Update request status
      _friendRequests[index] = FriendRequest(
        id: request.id,
        fromUserId: request.fromUserId,
        fromUserName: request.fromUserName,
        requestDate: request.requestDate,
        status: 'accepted',
      );
      
      await _saveFriends();
      await _saveFriendRequests();
      notifyListeners();
    }
  }

  Future<void> rejectFriendRequest(String requestId) async {
    final index = _friendRequests.indexWhere((r) => r.id == requestId);
    if (index != -1) {
      _friendRequests[index] = FriendRequest(
        id: _friendRequests[index].id,
        fromUserId: _friendRequests[index].fromUserId,
        fromUserName: _friendRequests[index].fromUserName,
        requestDate: _friendRequests[index].requestDate,
        status: 'rejected',
      );
      await _saveFriendRequests();
      notifyListeners();
    }
  }

  void addActivity(FriendActivity activity) {
    _activityFeed.insert(0, activity);
    _saveActivityFeed();
    notifyListeners();
  }

  Future<void> _saveFriends() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(_friends.map((f) => f.toJson()).toList());
    await prefs.setString('friends', data);
  }

  Future<void> _saveActivityFeed() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(_activityFeed.map((a) => a.toJson()).toList());
    await prefs.setString('friend_activity', data);
  }

  Future<void> _saveFriendRequests() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(_friendRequests.map((r) => r.toJson()).toList());
    await prefs.setString('friend_requests', data);
  }

  List<Friend> _generateDemoFriends() {
    final now = DateTime.now();
    return [
      Friend(
        id: 'friend_1',
        name: 'Alex Thunder',
        totalWorkouts: 45,
        currentStreak: 7,
        lastWorkoutDate: now.subtract(const Duration(hours: 3)),
        status: 'active',
        friendsSince: now.subtract(const Duration(days: 30)),
      ),
      Friend(
        id: 'friend_2',
        name: 'Sarah Lightning',
        totalWorkouts: 38,
        currentStreak: 5,
        lastWorkoutDate: now.subtract(const Duration(hours: 8)),
        status: 'active',
        friendsSince: now.subtract(const Duration(days: 45)),
      ),
      Friend(
        id: 'friend_3',
        name: 'Mike Steel',
        totalWorkouts: 52,
        currentStreak: 12,
        lastWorkoutDate: now.subtract(const Duration(hours: 1)),
        status: 'active',
        friendsSince: now.subtract(const Duration(days: 60)),
      ),
      Friend(
        id: 'friend_4',
        name: 'Emma Fierce',
        totalWorkouts: 29,
        currentStreak: 3,
        lastWorkoutDate: now.subtract(const Duration(days: 2)),
        status: 'active',
        friendsSince: now.subtract(const Duration(days: 20)),
      ),
      Friend(
        id: 'friend_5',
        name: 'Chris Boulder',
        totalWorkouts: 67,
        currentStreak: 15,
        lastWorkoutDate: now.subtract(const Duration(minutes: 45)),
        status: 'active',
        friendsSince: now.subtract(const Duration(days: 90)),
      ),
    ];
  }

  List<FriendActivity> _generateDemoActivity() {
    final now = DateTime.now();
    return [
      FriendActivity(
        id: 'activity_1',
        friendId: 'friend_3',
        friendName: 'Mike Steel',
        activityType: 'workout_completed',
        title: 'Completed Full Body Blast',
        description: '8 exercises • 45 minutes',
        timestamp: now.subtract(const Duration(hours: 1)),
      ),
      FriendActivity(
        id: 'activity_2',
        friendId: 'friend_5',
        friendName: 'Chris Boulder',
        activityType: 'workout_completed',
        title: 'Completed Upper Body Power',
        description: '6 exercises • 38 minutes',
        timestamp: now.subtract(const Duration(minutes: 45)),
      ),
      FriendActivity(
        id: 'activity_3',
        friendId: 'friend_1',
        friendName: 'Alex Thunder',
        activityType: 'achievement_unlocked',
        title: 'Unlocked "Week Warrior" badge',
        description: 'Completed 7 day streak!',
        timestamp: now.subtract(const Duration(hours: 3)),
      ),
      FriendActivity(
        id: 'activity_4',
        friendId: 'friend_2',
        friendName: 'Sarah Lightning',
        activityType: 'workout_completed',
        title: 'Completed Cardio Killer',
        description: '5 exercises • 30 minutes',
        timestamp: now.subtract(const Duration(hours: 8)),
      ),
      FriendActivity(
        id: 'activity_5',
        friendId: 'friend_1',
        friendName: 'Alex Thunder',
        activityType: 'challenge_joined',
        title: 'Joined "5 Workouts This Week"',
        description: 'Let\'s crush this challenge!',
        timestamp: now.subtract(const Duration(hours: 12)),
      ),
      FriendActivity(
        id: 'activity_6',
        friendId: 'friend_4',
        friendName: 'Emma Fierce',
        activityType: 'workout_completed',
        title: 'Completed Leg Day Destroyer',
        description: '7 exercises • 50 minutes',
        timestamp: now.subtract(const Duration(days: 1)),
      ),
    ];
  }
}
