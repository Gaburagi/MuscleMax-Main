import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/social_provider.dart';
import '../models/social_model.dart';
import '../utils/app_colors.dart';

class LeaderboardsScreen extends StatefulWidget {
  const LeaderboardsScreen({super.key});

  @override
  State<LeaderboardsScreen> createState() => _LeaderboardsScreenState();
}

class _LeaderboardsScreenState extends State<LeaderboardsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _timeFilter = 'Monthly'; // Weekly, Monthly, All Time

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socialProvider = context.watch<SocialProvider>();

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'LEADERBOARDS',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onSelected: (value) {
              setState(() {
                _timeFilter = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'Weekly', child: Text('Weekly')),
              const PopupMenuItem(value: 'Monthly', child: Text('Monthly')),
              const PopupMenuItem(value: 'All Time', child: Text('All Time')),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryRed,
          indicatorWeight: 3,
          labelColor: AppColors.primaryRed,
          unselectedLabelColor: AppColors.textGray,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          tabs: const [
            Tab(text: 'XP'),
            Tab(text: 'STREAKS'),
            Tab(text: 'WORKOUTS'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Time filter display
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today, size: 16, color: AppColors.textGray),
                const SizedBox(width: 8),
                Text(
                  _timeFilter,
                  style: TextStyle(
                    color: AppColors.textGray,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          // Leaderboard content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _LeaderboardList(
                  entries: socialProvider.xpLeaderboard,
                  icon: Icons.star,
                  color: AppColors.primaryRed,
                  suffix: 'XP',
                  showLevel: true,
                ),
                _LeaderboardList(
                  entries: socialProvider.streakLeaderboard,
                  icon: Icons.local_fire_department,
                  color: Colors.orange,
                  suffix: 'days',
                  showLevel: false,
                ),
                _LeaderboardList(
                  entries: socialProvider.workoutLeaderboard,
                  icon: Icons.fitness_center,
                  color: Colors.blue,
                  suffix: 'workouts',
                  showLevel: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardList extends StatelessWidget {
  final List<LeaderboardEntry> entries;
  final IconData icon;
  final Color color;
  final String suffix;
  final bool showLevel;

  const _LeaderboardList({
    required this.entries,
    required this.icon,
    required this.color,
    required this.suffix,
    required this.showLevel,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 80,
              color: AppColors.textGray.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No rankings yet',
              style: TextStyle(
                color: AppColors.textGray,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return _LeaderboardCard(
          entry: entry,
          icon: icon,
          color: color,
          suffix: suffix,
          showLevel: showLevel,
        );
      },
    );
  }
}

class _LeaderboardCard extends StatelessWidget {
  final LeaderboardEntry entry;
  final IconData icon;
  final Color color;
  final String suffix;
  final bool showLevel;

  const _LeaderboardCard({
    required this.entry,
    required this.icon,
    required this.color,
    required this.suffix,
    required this.showLevel,
  });

  Color _getRankColor() {
    switch (entry.rank) {
      case 1:
        return Colors.amber; // Gold
      case 2:
        return Colors.grey[400]!; // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return AppColors.textGray;
    }
  }

  Widget _getRankWidget() {
    if (entry.rank <= 3) {
      return Icon(
        Icons.emoji_events,
        color: _getRankColor(),
        size: 32,
      );
    }
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          '${entry.rank}',
          style: TextStyle(
            color: AppColors.textGray,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: entry.isCurrentUser
            ? color.withOpacity(0.15)
            : AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: entry.isCurrentUser ? color.withOpacity(0.5) : Colors.transparent,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          // Rank
          _getRankWidget(),
          
          const SizedBox(width: 16),
          
          // Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: color.withOpacity(0.2),
            child: entry.avatarUrl != null
                ? ClipOval(child: Image.network(entry.avatarUrl!, fit: BoxFit.cover))
                : Icon(Icons.person, color: color, size: 28),
          ),
          
          const SizedBox(width: 16),
          
          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        entry.userName,
                        style: TextStyle(
                          color: entry.isCurrentUser ? color : AppColors.textWhite,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (entry.isCurrentUser) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'YOU',
                          style: TextStyle(
                            color: color,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (showLevel && entry.level != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Level ${entry.level} • ${entry.title}',
                    style: TextStyle(
                      color: AppColors.textGray,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Value
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${entry.value}',
                    style: TextStyle(
                      color: color,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                suffix,
                style: TextStyle(
                  color: AppColors.textGray,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
