import 'dart:async';
import 'package:flutter/material.dart';

class NotificationProvider extends ChangeNotifier {
  final List<NotificationItem> _notifications = [];
  Timer? _waterReminderTimer;

  List<NotificationItem> get notifications => _notifications;
  
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  NotificationProvider() {
    _loadSampleNotifications();
    _startWaterReminders();
  }
  
  void _startWaterReminders() {
    // Send water reminder every 2 hours
    _waterReminderTimer = Timer.periodic(const Duration(hours: 2), (timer) {
      triggerWaterReminder();
    });
  }
  
  @override
  void dispose() {
    _waterReminderTimer?.cancel();
    super.dispose();
  }

  void _loadSampleNotifications() {
    _notifications.addAll([
      NotificationItem(
        id: '1',
        type: NotificationType.achievement,
        title: 'New Achievement Unlocked!',
        message: 'You\'ve completed your first week streak! 🔥',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false,
      ),
      NotificationItem(
        id: '2',
        type: NotificationType.challenge,
        title: 'Daily Challenge',
        message: 'Complete 50 push-ups today to earn 100 XP',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        isRead: false,
      ),
      NotificationItem(
        id: '3',
        type: NotificationType.friend,
        title: 'Friend Request',
        message: 'John Doe wants to connect with you',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        isRead: false,
      ),
      NotificationItem(
        id: '4',
        type: NotificationType.workout,
        title: 'Workout Reminder',
        message: 'Time for your evening workout! 💪',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
      ),
      NotificationItem(
        id: '5',
        type: NotificationType.level,
        title: 'Level Up!',
        message: 'Congratulations! You\'ve reached Level 5',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        isRead: true,
      ),
    ]);
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = NotificationItem(
        id: _notifications[index].id,
        type: _notifications[index].type,
        title: _notifications[index].title,
        message: _notifications[index].message,
        timestamp: _notifications[index].timestamp,
        isRead: true,
      );
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = NotificationItem(
          id: _notifications[i].id,
          type: _notifications[i].type,
          title: _notifications[i].title,
          message: _notifications[i].message,
          timestamp: _notifications[i].timestamp,
          isRead: true,
        );
      }
    }
    notifyListeners();
  }

  void addNotification(NotificationItem notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }

  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }

  // Trigger notifications based on events
  void triggerAchievementUnlocked(String achievementName) {
    addNotification(NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: NotificationType.achievement,
      title: 'Achievement Unlocked! 🏆',
      message: achievementName,
      timestamp: DateTime.now(),
      isRead: false,
    ));
  }

  void triggerWaterReminder() {
    // Check if already reminded in last 2 hours
    final recentWaterReminder = _notifications.any((n) => 
      n.type == NotificationType.general &&
      n.title.contains('Water') &&
      DateTime.now().difference(n.timestamp).inHours < 2
    );
    
    if (!recentWaterReminder) {
      addNotification(NotificationItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: NotificationType.general,
        title: 'Stay Hydrated! 💧',
        message: 'Time to drink some water. Keep your body hydrated!',
        timestamp: DateTime.now(),
        isRead: false,
      ));
    }
  }

  void triggerWorkoutReminder(String workoutName) {
    addNotification(NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: NotificationType.workout,
      title: 'Workout Time! 💪',
      message: 'Time for your $workoutName workout',
      timestamp: DateTime.now(),
      isRead: false,
    ));
  }

  void triggerDailyChallengeComplete(int xpEarned) {
    addNotification(NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: NotificationType.challenge,
      title: 'Challenge Complete! ⚡',
      message: 'You earned $xpEarned XP from completing today\'s challenge!',
      timestamp: DateTime.now(),
      isRead: false,
    ));
  }

  void triggerLevelUp(int newLevel, String newTitle) {
    addNotification(NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: NotificationType.level,
      title: 'Level Up! 🎉',
      message: 'Congratulations! You\'ve reached Level $newLevel: $newTitle',
      timestamp: DateTime.now(),
      isRead: false,
    ));
  }

  void triggerStreakMilestone(int streakDays) {
    addNotification(NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: NotificationType.achievement,
      title: 'Streak Milestone! 🔥',
      message: 'Amazing! You\'ve maintained a $streakDays-day workout streak!',
      timestamp: DateTime.now(),
      isRead: false,
    ));
  }
}

enum NotificationType {
  achievement,
  challenge,
  friend,
  workout,
  level,
  general,
}

class NotificationItem {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;

  NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.isRead,
  });
}
