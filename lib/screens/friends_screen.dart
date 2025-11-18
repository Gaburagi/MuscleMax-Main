import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/friends_provider.dart';
import '../models/friend_models.dart';
import '../utils/app_colors.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Load friends data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FriendsProvider>().loadFriendsData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/home'),
        ),
        title: const Text(
          'FRIENDS',
          style: TextStyle(
            fontFamily: 'Bebas Neue',
            fontSize: 24,
            letterSpacing: 1.5,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add, color: Colors.white),
            onPressed: () => _showAddFriendDialog(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryRed,
          labelColor: Colors.white,
          unselectedLabelColor: AppColors.textGray,
          labelStyle: const TextStyle(
            fontFamily: 'DM Sans',
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: 'MY FRIENDS'),
            Tab(text: 'ACTIVITY FEED'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _FriendsListTab(),
          _ActivityFeedTab(),
        ],
      ),
    );
  }

  void _showAddFriendDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkGray,
        title: const Text(
          'Add Friend',
          style: TextStyle(
            fontFamily: 'Bebas Neue',
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter friend\'s name',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primaryRed),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context.read<FriendsProvider>().addFriend(controller.text);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

// Friends List Tab
class _FriendsListTab extends StatelessWidget {
  const _FriendsListTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<FriendsProvider>(
      builder: (context, provider, child) {
        final friends = provider.friends;

        if (friends.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 80,
                  color: Colors.white.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'No friends yet',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap + to add friends',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: friends.length,
          itemBuilder: (context, index) {
            final friend = friends[index];
            return _FriendCard(friend: friend);
          },
        );
      },
    );
  }
}

class _FriendCard extends StatelessWidget {
  final Friend friend;

  const _FriendCard({required this.friend});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.darkGray,
            AppColors.darkGray.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primaryRed,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                friend.name.isNotEmpty ? friend.name[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontFamily: 'Bebas Neue',
                  fontSize: 28,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Friend info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  friend.name,
                  style: const TextStyle(
                    fontFamily: 'Bebas Neue',
                    fontSize: 18,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.fitness_center,
                      size: 14,
                      color: Colors.white.withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${friend.totalWorkouts} workouts',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.local_fire_department,
                      size: 14,
                      color: AppColors.primaryRed,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${friend.currentStreak} day streak',
                      style: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12,
                        color: AppColors.primaryRed,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (friend.lastWorkoutDate != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Last workout: ${_getTimeAgo(friend.lastWorkoutDate!)}',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.4),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Actions
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.white.withOpacity(0.6)),
            color: AppColors.darkGray,
            onSelected: (value) {
              if (value == 'remove') {
                context.read<FriendsProvider>().removeFriend(friend.id);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'remove',
                child: Row(
                  children: [
                    const Icon(Icons.person_remove, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Remove Friend',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

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

// Activity Feed Tab
class _ActivityFeedTab extends StatelessWidget {
  const _ActivityFeedTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<FriendsProvider>(
      builder: (context, provider, child) {
        final activities = provider.activityFeed;

        if (activities.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.timeline,
                  size: 80,
                  color: Colors.white.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'No recent activity',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: activities.length,
          itemBuilder: (context, index) {
            final activity = activities[index];
            return _ActivityCard(activity: activity);
          },
        );
      },
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final FriendActivity activity;

  const _ActivityCard({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Activity icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getActivityColor().withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getActivityIcon(),
              color: _getActivityColor(),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // Activity details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.friendName,
                  style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryRed,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity.title,
                  style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                if (activity.description != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    activity.description!,
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Timestamp
          Text(
            activity.timeAgo,
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 11,
              color: Colors.white.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getActivityIcon() {
    switch (activity.activityType) {
      case 'workout_completed':
        return Icons.fitness_center;
      case 'achievement_unlocked':
        return Icons.emoji_events;
      case 'challenge_joined':
        return Icons.flag;
      default:
        return Icons.notifications;
    }
  }

  Color _getActivityColor() {
    switch (activity.activityType) {
      case 'workout_completed':
        return AppColors.primaryRed;
      case 'achievement_unlocked':
        return const Color(0xFFFFD700);
      case 'challenge_joined':
        return Colors.blue;
      default:
        return Colors.white;
    }
  }
}
