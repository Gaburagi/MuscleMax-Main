import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/profile_extensions.dart';

class ProfileStatsProvider with ChangeNotifier {
  UserModel? _user;

  // Getters
  int get totalWorkouts => _user?.totalWorkouts ?? 0;
  double get totalWeightLifted => _user?.totalWeightLifted ?? 0.0;
  int get longestStreak => _user?.longestStreak ?? 0;
  String? get favoriteExercise => _user?.favoriteExercise;
  int get totalCaloriesBurned => _user?.totalCaloriesBurned ?? 0;
  List<String> get topPRs => _user?.topPRs ?? [];
  int get profileViews => _user?.profileViews ?? 0;
  List<ProfileVisitor> get recentVisitors => _user?.recentVisitors ?? [];
  List<String> get earnedBadges => _user?.earnedBadges ?? [];
  List<String> get pinnedBadges => _user?.pinnedBadges ?? [];
  String? get currentMood => _user?.currentMood;
  String? get statusText => _user?.statusText;
  DateTime? get statusTimestamp => _user?.statusTimestamp;
  List<SocialLink> get socialLinks => _user?.socialLinks ?? [];
  List<StoryHighlight> get storyHighlights => _user?.storyHighlights ?? [];
  String? get workoutAnthem => _user?.workoutAnthem;
  String? get anthemTitle => _user?.anthemTitle;
  String? get anthemArtist => _user?.anthemArtist;

  void setUser(UserModel user) {
    _user = user;
    notifyListeners();
  }

  // Update workout stats
  Future<void> updateWorkoutStats({
    required int workoutsIncrement,
    required double weightLifted,
    required int caloriesBurned,
    required String exerciseName,
  }) async {
    if (_user == null) return;

    final newTotalWorkouts = _user!.totalWorkouts + workoutsIncrement;
    final newTotalWeight = _user!.totalWeightLifted + weightLifted;
    final newTotalCalories = _user!.totalCaloriesBurned + caloriesBurned;

    // Update favorite exercise (simple frequency tracking)
    final favoriteExercise = exerciseName;

    _user = _user!.copyWith(
      totalWorkouts: newTotalWorkouts,
      totalWeightLifted: newTotalWeight,
      totalCaloriesBurned: newTotalCalories,
      favoriteExercise: favoriteExercise,
    );

    await _saveUser();
    notifyListeners();
  }

  // Update streak
  Future<void> updateStreak(int newStreak) async {
    if (_user == null) return;

    if (newStreak > _user!.longestStreak) {
      _user = _user!.copyWith(longestStreak: newStreak);
      await _saveUser();
      notifyListeners();
    }
  }

  // Add PR to top PRs
  Future<void> addPersonalRecord(String prDescription) async {
    if (_user == null) return;

    final List<String> updatedPRs = List.from(_user!.topPRs);
    updatedPRs.insert(0, prDescription);

    // Keep only top 3
    if (updatedPRs.length > 3) {
      updatedPRs.removeRange(3, updatedPRs.length);
    }

    _user = _user!.copyWith(topPRs: updatedPRs);
    await _saveUser();
    notifyListeners();
  }

  // Profile visitors
  Future<void> recordProfileVisit(String userId, String userName, {String? userAvatar}) async {
    if (_user == null) return;

    final visitor = ProfileVisitor(
      userId: userId,
      userName: userName,
      userAvatar: userAvatar,
      visitedAt: DateTime.now(),
    );

    final List<ProfileVisitor> updatedVisitors = [visitor, ..._user!.recentVisitors];

    // Keep only last 20 visitors
    if (updatedVisitors.length > 20) {
      updatedVisitors.removeRange(20, updatedVisitors.length);
    }

    _user = _user!.copyWith(
      profileViews: _user!.profileViews + 1,
      recentVisitors: updatedVisitors,
    );

    await _saveUser();
    notifyListeners();
  }

  // Badge management
  Future<void> earnBadge(String badgeId) async {
    if (_user == null) return;

    if (!_user!.earnedBadges.contains(badgeId)) {
      final List<String> updatedBadges = [..._user!.earnedBadges, badgeId];
      _user = _user!.copyWith(earnedBadges: updatedBadges);
      await _saveUser();
      notifyListeners();
    }
  }

  Future<void> pinBadge(String badgeId) async {
    if (_user == null) return;

    if (!_user!.earnedBadges.contains(badgeId)) return;

    final List<String> updatedPinned = [..._user!.pinnedBadges];

    if (updatedPinned.contains(badgeId)) {
      updatedPinned.remove(badgeId);
    } else if (updatedPinned.length < 5) {
      updatedPinned.add(badgeId);
    } else {
      // Max 5 pinned, replace oldest
      updatedPinned.removeAt(0);
      updatedPinned.add(badgeId);
    }

    _user = _user!.copyWith(pinnedBadges: updatedPinned);
    await _saveUser();
    notifyListeners();
  }

  // Status updates
  Future<void> updateStatus({
    required String mood,
    required String statusText,
  }) async {
    if (_user == null) return;

    _user = _user!.copyWith(
      currentMood: mood,
      statusText: statusText,
      statusTimestamp: DateTime.now(),
    );

    await _saveUser();
    notifyListeners();
  }

  Future<void> clearStatus() async {
    if (_user == null) return;

    _user = _user!.copyWith(
      currentMood: null,
      statusText: null,
      statusTimestamp: null,
    );

    await _saveUser();
    notifyListeners();
  }

  // Check if status expired (24 hours)
  bool get isStatusExpired {
    if (_user?.statusTimestamp == null) return true;
    return DateTime.now().difference(_user!.statusTimestamp!).inHours >= 24;
  }

  // Social links
  Future<void> addSocialLink(SocialLink link) async {
    if (_user == null) return;

    final List<SocialLink> updatedLinks = [..._user!.socialLinks];

    if (updatedLinks.length < 5) {
      updatedLinks.add(link);
      _user = _user!.copyWith(socialLinks: updatedLinks);
      await _saveUser();
      notifyListeners();
    }
  }

  Future<void> removeSocialLink(int index) async {
    if (_user == null) return;

    final List<SocialLink> updatedLinks = [..._user!.socialLinks];
    updatedLinks.removeAt(index);

    _user = _user!.copyWith(socialLinks: updatedLinks);
    await _saveUser();
    notifyListeners();
  }

  // Story highlights
  Future<void> addStoryHighlight(StoryHighlight highlight) async {
    if (_user == null) return;

    final List<StoryHighlight> updatedHighlights = [..._user!.storyHighlights, highlight];

    _user = _user!.copyWith(storyHighlights: updatedHighlights);
    await _saveUser();
    notifyListeners();
  }

  Future<void> removeStoryHighlight(String highlightId) async {
    if (_user == null) return;

    final List<StoryHighlight> updatedHighlights = _user!.storyHighlights
        .where((h) => h.id != highlightId)
        .toList();

    _user = _user!.copyWith(storyHighlights: updatedHighlights);
    await _saveUser();
    notifyListeners();
  }

  Future<void> addStoryItem(String highlightId, StoryItem item) async {
    if (_user == null) return;

    final List<StoryHighlight> updatedHighlights = _user!.storyHighlights.map((h) {
      if (h.id == highlightId) {
        final updatedItems = [...h.items];
        if (updatedItems.length < 10) {
          updatedItems.add(item);
        }
        return StoryHighlight(
          id: h.id,
          title: h.title,
          coverImage: h.coverImage,
          items: updatedItems,
          createdAt: h.createdAt,
          isPermanent: h.isPermanent,
        );
      }
      return h;
    }).toList();

    _user = _user!.copyWith(storyHighlights: updatedHighlights);
    await _saveUser();
    notifyListeners();
  }

  // Music anthem
  Future<void> setWorkoutAnthem({
    required String anthemUrl,
    required String title,
    required String artist,
  }) async {
    if (_user == null) return;

    _user = _user!.copyWith(
      workoutAnthem: anthemUrl,
      anthemTitle: title,
      anthemArtist: artist,
    );

    await _saveUser();
    notifyListeners();
  }

  Future<void> removeWorkoutAnthem() async {
    if (_user == null) return;

    _user = _user!.copyWith(
      workoutAnthem: null,
      anthemTitle: null,
      anthemArtist: null,
    );

    await _saveUser();
    notifyListeners();
  }

  // Badge checking logic
  Future<void> checkAndAwardBadges() async {
    if (_user == null) return;

    bool badgesAwarded = false;

    // Streak badges
    if (_user!.longestStreak >= 7 && !_user!.earnedBadges.contains('streak_7')) {
      await earnBadge('streak_7');
      badgesAwarded = true;
    }
    if (_user!.longestStreak >= 30 && !_user!.earnedBadges.contains('streak_30')) {
      await earnBadge('streak_30');
      badgesAwarded = true;
    }
    if (_user!.longestStreak >= 100 && !_user!.earnedBadges.contains('streak_100')) {
      await earnBadge('streak_100');
      badgesAwarded = true;
    }

    // Achievement badges
    if (_user!.topPRs.isNotEmpty && !_user!.earnedBadges.contains('first_pr')) {
      await earnBadge('first_pr');
      badgesAwarded = true;
    }
    if (_user!.totalWorkouts >= 100 && !_user!.earnedBadges.contains('century_club')) {
      await earnBadge('century_club');
      badgesAwarded = true;
    }
    if (_user!.totalWeightLifted >= 10000 && !_user!.earnedBadges.contains('beast_mode')) {
      await earnBadge('beast_mode');
      badgesAwarded = true;
    }

    if (badgesAwarded) {
      notifyListeners();
    }
  }

  // Persistence
  Future<void> _saveUser() async {
    if (_user == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', jsonEncode(_user!.toJson()));
    } catch (e) {
      debugPrint('Error saving user: $e');
    }
  }

  // Get purchased items from shop
  Future<List<String>> getPurchasedItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final purchased = prefs.getStringList('purchased_shop_items') ?? [];
      return purchased;
    } catch (e) {
      return [];
    }
  }

  // Purchase shop item
  Future<bool> purchaseShopItem(String itemId, int xpCost, int currentXP) async {
    if (currentXP < xpCost) return false;

    try {
      final prefs = await SharedPreferences.getInstance();
      final purchased = prefs.getStringList('purchased_shop_items') ?? [];
      
      if (!purchased.contains(itemId)) {
        purchased.add(itemId);
        await prefs.setStringList('purchased_shop_items', purchased);
        return true;
      }
    } catch (e) {
      debugPrint('Error purchasing item: $e');
    }
    return false;
  }
}
