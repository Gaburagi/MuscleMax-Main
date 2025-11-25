import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/gamification_provider.dart';
import '../models/gamification_model.dart';
import '../utils/app_colors.dart';
import '../utils/routes.dart';
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
    final totalXP = achievements
        .where((a) => a.isUnlocked)
        .fold(0, (sum, a) => sum + a.xpReward);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => context.go(AppRoutes.progressHub),
          tooltip: 'Back',
        ),
        title: const Text(
          'ACHIEVEMENTS',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),
        centerTitle: true,
        actions: [
          // Info button
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white70),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: AppColors.backgroundCard,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: const Text(
                    'About Achievements',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: const Text(
                    'Complete workouts, maintain streaks, set PRs, and engage with the community to unlock achievements and earn XP!',
                    style: TextStyle(color: AppColors.textGray),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'GOT IT',
                        style: TextStyle(color: AppColors.primaryRed),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(196),
          child: Column(
            children: [
              // Enhanced Stats section
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryRed.withOpacity(0.2),
                      Colors.purple.withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primaryRed.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatCard(
                      icon: Icons.emoji_events,
                      label: 'Unlocked',
                      value: '$unlockedCount',
                      subtitle: '/${achievements.length}',
                      color: Colors.amber,
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: AppColors.textGray.withOpacity(0.2),
                    ),
                    _StatCard(
                      icon: Icons.star,
                      label: 'Total XP',
                      value: totalXP.toString(),
                      color: AppColors.primaryRed,
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: AppColors.textGray.withOpacity(0.2),
                    ),
                    _StatCard(
                      icon: Icons.trending_up,
                      label: 'Progress',
                      value: '${((unlockedCount / achievements.length) * 100).toInt()}',
                      subtitle: '%',
                      color: Colors.green,
                    ),
                  ],
                ),
              ),
              // Tabs with icons
              TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: AppColors.primaryRed,
                indicatorWeight: 3,
                indicatorSize: TabBarIndicatorSize.label,
                labelColor: AppColors.primaryRed,
                unselectedLabelColor: AppColors.textGray,
                labelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
                tabs: const [
                  Tab(
                    icon: Icon(Icons.grid_view, size: 18),
                    text: 'ALL',
                  ),
                  Tab(
                    icon: Icon(Icons.fitness_center, size: 18),
                    text: 'WORKOUTS',
                  ),
                  Tab(
                    icon: Icon(Icons.local_fire_department, size: 18),
                    text: 'STREAK',
                  ),
                  Tab(
                    icon: Icon(Icons.trending_up, size: 18),
                    text: 'PR',
                  ),
                  Tab(
                    icon: Icon(Icons.group, size: 18),
                    text: 'SOCIAL',
                  ),
                  Tab(
                    icon: Icon(Icons.restaurant, size: 18),
                    text: 'NUTRITION',
                  ),
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
  final String? subtitle;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                height: 1,
              ),
            ),
            if (subtitle != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  subtitle!,
                  style: TextStyle(
                    color: color.withOpacity(0.7),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textGray,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _AchievementsList extends StatelessWidget {
  final List<Achievement> achievements;

  const _AchievementsList({required this.achievements});

  String _getEmptyMessage() {
    if (achievements.isEmpty) {
      return 'No achievements in this category yet';
    }
    return '';
  }

  IconData _getEmptyIcon() {
    if (achievements.isEmpty) {
      return Icons.workspace_premium;
    }
    return Icons.emoji_events;
  }

  @override
  Widget build(BuildContext context) {
    if (achievements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.backgroundCard,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.textGray.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: Icon(
                _getEmptyIcon(),
                size: 64,
                color: AppColors.textGray.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _getEmptyMessage(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textGray,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Keep working out to unlock achievements!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textGray.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    // Group achievements: unlocked first, then locked
    final unlockedAchievements =
        achievements.where((a) => a.isUnlocked).toList();
    final lockedAchievements =
        achievements.where((a) => !a.isUnlocked).toList();
    final sortedAchievements = [...unlockedAchievements, ...lockedAchievements];

    return Column(
      children: [
        // Category stats header
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.textGray.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 18,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${unlockedAchievements.length} Unlocked',
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                width: 1,
                height: 20,
                color: AppColors.textGray.withOpacity(0.3),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.lock,
                    size: 18,
                    color: AppColors.textGray,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${lockedAchievements.length} Locked',
                    style: const TextStyle(
                      color: AppColors.textGray,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Achievement list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: 16,
            ),
            itemCount: sortedAchievements.length,
            itemBuilder: (context, index) {
              final achievement = sortedAchievements[index];
              return _AchievementCard(achievement: achievement);
            },
          ),
        ),
      ],
    );
  }
}

class _AchievementCard extends StatefulWidget {
  final Achievement achievement;

  const _AchievementCard({required this.achievement});

  @override
  State<_AchievementCard> createState() => _AchievementCardState();
}

class _AchievementCardState extends State<_AchievementCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  IconData _getIcon() {
    // Map emoji icons to material icons
    switch (widget.achievement.icon) {
      case '🏃':
        return Icons.directions_run;
      case '💪':
        return Icons.fitness_center;
      case '⚔️':
        return Icons.military_tech;
      case '🏆':
        return Icons.emoji_events;
      case '🔥':
        return Icons.local_fire_department;
      case '🌟':
        return Icons.auto_awesome;
      case '👑':
        return Icons.workspace_premium;
      case '🎯':
        return Icons.track_changes;
      case '📈':
        return Icons.trending_up;
      case '⭐':
        return Icons.star;
      case '👋':
        return Icons.waving_hand;
      case '🤝':
        return Icons.handshake;
      case '📱':
        return Icons.share;
      case '🍽️':
        return Icons.restaurant_menu;
      case '💧':
        return Icons.water_drop;
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

  Color _getCategoryColor() {
    switch (widget.achievement.category) {
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
    final isLocked = !widget.achievement.isUnlocked;
    final progress = widget.achievement.currentProgress / widget.achievement.requiredCount;
    final categoryColor = _getCategoryColor();

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            gradient: isLocked
                ? null
                : LinearGradient(
                    colors: [
                      categoryColor.withOpacity(0.15),
                      AppColors.backgroundCard,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            color: isLocked ? AppColors.backgroundCard : null,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isLocked
                  ? AppColors.textGray.withOpacity(0.2)
                  : categoryColor.withOpacity(0.4),
              width: isLocked ? 1 : 2,
            ),
            boxShadow: isLocked
                ? null
                : [
                    BoxShadow(
                      color: categoryColor.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Enhanced Icon
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    gradient: isLocked
                        ? null
                        : LinearGradient(
                            colors: [
                              categoryColor.withOpacity(0.3),
                              categoryColor.withOpacity(0.1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    color: isLocked
                        ? AppColors.textGray.withOpacity(0.1)
                        : null,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isLocked
                          ? AppColors.textGray.withOpacity(0.2)
                          : categoryColor.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        _getIcon(),
                        size: 36,
                        color: isLocked
                            ? AppColors.textGray.withOpacity(0.5)
                            : categoryColor,
                      ),
                      if (isLocked)
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.backgroundCard,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.lock,
                              size: 16,
                              color: AppColors.textGray,
                            ),
                          ),
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
                        children: [
                          Expanded(
                            child: Text(
                              widget.achievement.name,
                              style: TextStyle(
                                color: isLocked
                                    ? AppColors.textGray
                                    : AppColors.textWhite,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  categoryColor.withOpacity(0.25),
                                  categoryColor.withOpacity(0.15),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: categoryColor.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.stars,
                                  size: 14,
                                  color: categoryColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '+${widget.achievement.xpReward}',
                                  style: TextStyle(
                                    color: categoryColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.achievement.description,
                        style: const TextStyle(
                          color: AppColors.textGray,
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Progress section
                      if (isLocked) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.timeline,
                                  size: 14,
                                  color: AppColors.textGray,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${widget.achievement.currentProgress}/${widget.achievement.requiredCount}',
                                  style: const TextStyle(
                                    color: AppColors.textGray,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: categoryColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${(progress * 100).toInt()}%',
                                style: TextStyle(
                                  color: categoryColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Stack(
                          children: [
                            Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppColors.textGray.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            FractionallySizedBox(
                              widthFactor: progress.clamp(0.0, 1.0),
                              child: Container(
                                height: 8,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      categoryColor,
                                      categoryColor.withOpacity(0.7),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                  boxShadow: [
                                    BoxShadow(
                                      color: categoryColor.withOpacity(0.4),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: categoryColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: categoryColor.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                size: 16,
                                color: categoryColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                widget.achievement.unlockedDate != null
                                    ? 'Unlocked ${DateFormat('MMM d, yyyy').format(widget.achievement.unlockedDate!)}'
                                    : 'Unlocked',
                                style: TextStyle(
                                  color: categoryColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
