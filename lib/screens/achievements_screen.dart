import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/gamification_provider.dart';
import '../models/gamification_model.dart';
import '../utils/app_colors.dart';
import 'package:intl/intl.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gamificationProvider = context.watch<GamificationProvider>();
    final achievements = gamificationProvider.achievements;

    final unlockedCount =
        achievements.where((a) => a.isUnlocked).length;

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
          'ACHIEVEMENTS',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              // Stats section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatCard(
                      icon: Icons.emoji_events,
                      label: 'Unlocked',
                      value: '$unlockedCount/${achievements.length}',
                      color: Colors.amber,
                    ),
                    _StatCard(
                      icon: Icons.star,
                      label: 'Total XP',
                      value: achievements
                          .where((a) => a.isUnlocked)
                          .fold(0, (sum, a) => sum + a.xpReward)
                          .toString(),
                      color: AppColors.primaryRed,
                    ),
                    _StatCard(
                      icon: Icons.lock_open,
                      label: 'Progress',
                      value: '${((unlockedCount / achievements.length) * 100).toInt()}%',
                      color: Colors.green,
                    ),
                  ],
                ),
              ),
              // Tabs
              TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: AppColors.primaryRed,
                indicatorWeight: 3,
                labelColor: AppColors.primaryRed,
                unselectedLabelColor: AppColors.textGray,
                labelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                tabs: const [
                  Tab(text: 'ALL'),
                  Tab(text: 'WORKOUTS'),
                  Tab(text: 'STREAK'),
                  Tab(text: 'PR'),
                  Tab(text: 'SOCIAL'),
                  Tab(text: 'NUTRITION'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _AchievementsList(achievements: achievements),
          _AchievementsList(
            achievements: achievements
                .where((a) => a.category == 'workouts')
                .toList(),
          ),
          _AchievementsList(
            achievements:
                achievements.where((a) => a.category == 'streak').toList(),
          ),
          _AchievementsList(
            achievements:
                achievements.where((a) => a.category == 'prs').toList(),
          ),
          _AchievementsList(
            achievements:
                achievements.where((a) => a.category == 'social').toList(),
          ),
          _AchievementsList(
            achievements: achievements
                .where((a) => a.category == 'nutrition')
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: AppColors.textGray,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementsList extends StatelessWidget {
  final List<Achievement> achievements;

  const _AchievementsList({required this.achievements});

  @override
  Widget build(BuildContext context) {
    if (achievements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 80,
              color: AppColors.textGray.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No achievements in this category',
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
      padding: const EdgeInsets.all(16),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        return _AchievementCard(achievement: achievement);
      },
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;

  const _AchievementCard({required this.achievement});

  IconData _getIcon() {
    switch (achievement.icon) {
      case 'fitness_center':
        return Icons.fitness_center;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'trending_up':
        return Icons.trending_up;
      case 'group':
        return Icons.group;
      case 'restaurant':
        return Icons.restaurant;
      case 'water_drop':
        return Icons.water_drop;
      case 'share':
        return Icons.share;
      case 'military_tech':
        return Icons.military_tech;
      case 'whatshot':
        return Icons.whatshot;
      case 'emoji_events':
        return Icons.emoji_events;
      default:
        return Icons.emoji_events;
    }
  }

  Color _getColor() {
    if (!achievement.isUnlocked) {
      return AppColors.textGray;
    }
    switch (achievement.category) {
      case 'workouts':
        return AppColors.primaryRed;
      case 'streak':
        return Colors.orange;
      case 'prs':
        return Colors.purple;
      case 'social':
        return Colors.blue;
      case 'nutrition':
        return Colors.green;
      default:
        return AppColors.primaryRed;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLocked = !achievement.isUnlocked;
    final progress = achievement.currentProgress / achievement.requiredCount;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLocked
              ? Colors.transparent
              : _getColor().withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: _getColor().withOpacity(isLocked ? 0.2 : 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  _getIcon(),
                  size: 32,
                  color: isLocked
                      ? AppColors.textGray.withOpacity(0.5)
                      : _getColor(),
                ),
                if (isLocked)
                  Icon(
                    Icons.lock,
                    size: 20,
                    color: AppColors.textGray.withOpacity(0.7),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        achievement.name,
                        style: TextStyle(
                          color: isLocked
                              ? AppColors.textGray
                              : AppColors.textWhite,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getColor().withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 12,
                            color: _getColor(),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '+${achievement.xpReward} XP',
                            style: TextStyle(
                              color: _getColor(),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: TextStyle(
                    color: AppColors.textGray,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                // Progress bar
                if (isLocked) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${achievement.currentProgress}/${achievement.requiredCount}',
                        style: TextStyle(
                          color: AppColors.textGray,
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: TextStyle(
                          color: AppColors.textGray,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      backgroundColor: AppColors.textGray.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(_getColor()),
                      minHeight: 6,
                    ),
                  ),
                ] else ...[
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 14,
                        color: _getColor(),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Unlocked ${DateFormat('MMM d, yyyy').format(achievement.unlockedDate!)}',
                        style: TextStyle(
                          color: _getColor(),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
