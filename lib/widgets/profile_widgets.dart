import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/profile_extensions.dart';
import '../models/gamification_model.dart';
import '../providers/profile_stats_provider.dart';
import '../providers/gamification_provider.dart';
import '../utils/app_colors.dart';
import '../screens/social_links_screen.dart';
import '../screens/status_mood_screen.dart';
import '../screens/profile_visitors_screen.dart';
import '../screens/featured_badges_screen.dart';

// Profile Stats Showcase Widget
class ProfileStatsShowcase extends StatelessWidget {
  const ProfileStatsShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    final statsProvider = context.watch<ProfileStatsProvider>();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryRed.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bar_chart, color: AppColors.primaryRed, size: 20),
              SizedBox(width: 8),
              Text(
                'LIFETIME STATS',
                style: TextStyle(
                  color: AppColors.primaryRed,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Grid of stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  '${statsProvider.totalWorkouts}',
                  'Workouts',
                  Icons.fitness_center,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  '${(statsProvider.totalWeightLifted / 1000).toStringAsFixed(1)}t',
                  'Weight Lifted',
                  Icons.monitor_weight,
                  Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  '${statsProvider.longestStreak}',
                  'Best Streak',
                  Icons.local_fire_department,
                  Colors.red,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  '${(statsProvider.totalCaloriesBurned / 1000).toStringAsFixed(1)}k',
                  'Calories Burned',
                  Icons.whatshot,
                  Colors.amber,
                ),
              ),
            ],
          ),
          
          // Favorite Exercise
          if (statsProvider.favoriteExercise != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.purple.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.purple, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Favorite Exercise',
                          style: TextStyle(
                            color: AppColors.textGray,
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          statsProvider.favoriteExercise!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          // Top 3 PRs
          if (statsProvider.topPRs.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'TOP PERSONAL RECORDS',
              style: TextStyle(
                color: AppColors.textGray,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            ...statsProvider.topPRs.take(3).map((pr) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  const Icon(Icons.emoji_events, color: Colors.amber, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      pr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textGray,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// Profile Visitors Widget
class ProfileVisitorsWidget extends StatelessWidget {
  const ProfileVisitorsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final statsProvider = context.watch<ProfileStatsProvider>();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ProfileVisitorsScreen(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.visibility, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'PROFILE VIEWS',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      '${statsProvider.profileViews}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
                  ],
                ),
              ],
            ),
          
            if (statsProvider.recentVisitors.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'RECENT VISITORS',
                style: TextStyle(
                  color: AppColors.textGray,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 70,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: statsProvider.recentVisitors.take(10).length,
                  itemBuilder: (context, index) {
                    final visitor = statsProvider.recentVisitors[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.primaryRed,
                            backgroundImage: visitor.userAvatar != null
                                ? FileImage(File(visitor.userAvatar!))
                                : null,
                            child: visitor.userAvatar == null
                                ? Text(
                                    visitor.userName[0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(height: 4),
                          SizedBox(
                            width: 50,
                            child: Text(
                              visitor.userName,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Profile Badges Widget
class ProfileBadgesWidget extends StatelessWidget {
  const ProfileBadgesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final statsProvider = context.watch<ProfileStatsProvider>();
    final gamificationProvider = context.watch<GamificationProvider>();
    
    final pinnedBadges = statsProvider.pinnedBadges
        .map((id) {
          try {
            return gamificationProvider.achievements.firstWhere((a) => a.id == id);
          } catch (e) {
            return null;
          }
        })
        .whereType<Achievement>()
        .toList();

    if (pinnedBadges.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.workspace_premium, color: Colors.amber, size: 20),
              SizedBox(width: 8),
              Text(
                'BADGES',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: pinnedBadges.map((achievement) {
              // Determine rarity color based on XP reward
              final Color rarityColor = achievement.xpReward >= 500
                  ? Colors.purple  // Legendary
                  : achievement.xpReward >= 250
                      ? Colors.orange  // Epic
                      : achievement.xpReward >= 100
                          ? Colors.blue  // Rare
                          : Colors.grey;  // Common

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: rarityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: rarityColor),
                ),
                child: Column(
                  children: [
                    Text(
                      achievement.icon,
                      style: const TextStyle(fontSize: 32),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      achievement.name,
                      style: TextStyle(
                        color: rarityColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// Profile Status Widget
class ProfileStatusWidget extends StatelessWidget {
  const ProfileStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: context.read<ProfileStatsProvider>().getCurrentStatus(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        
        final mood = snapshot.data!['mood'] as ProfileMood?;
        final statusText = snapshot.data!['customText'] as String?;
        
        if (mood == null && (statusText == null || statusText.isEmpty)) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StatusMoodScreen(),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.backgroundCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.mood, color: Colors.white24, size: 32),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Set your status',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
                ],
              ),
            ),
          );
        }

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const StatusMoodScreen(),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E88E5), Color(0xFF42A5F5)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                if (mood != null)
                  Text(
                    mood.emoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Status',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        statusText ?? mood?.label ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.edit, color: Colors.white70, size: 18),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Social Links Widget
class SocialLinksWidget extends StatelessWidget {
  const SocialLinksWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SocialLink>>(
      future: context.read<ProfileStatsProvider>().getSocialLinks(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SocialLinksScreen(),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.backgroundCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.link, color: Colors.white24, size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Add social links',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
                ],
              ),
            ),
          );
        }

        final links = snapshot.data!;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.link, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'LINKS',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SocialLinksScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'MANAGE',
                      style: TextStyle(
                        color: AppColors.primaryRed,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.5,
                ),
                itemCount: links.length,
                itemBuilder: (context, index) {
                  final link = links[index];
                  return InkWell(
                    onTap: () async {
                      final uri = Uri.parse(link.url);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundDark,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _getColorForPlatform(link.platform).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _getIconForPlatform(link.platform),
                            color: _getColorForPlatform(link.platform),
                            size: 28,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            link.displayName ?? link.platform.toUpperCase(),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getIconForPlatform(String platform) {
    switch (platform) {
      case 'instagram':
        return Icons.camera_alt;
      case 'tiktok':
        return Icons.music_note;
      case 'youtube':
        return Icons.play_circle;
      case 'spotify':
        return Icons.music_video;
      case 'website':
        return Icons.language;
      default:
        return Icons.link;
    }
  }

  Color _getColorForPlatform(String platform) {
    switch (platform) {
      case 'instagram':
        return Colors.pink;
      case 'tiktok':
        return Colors.black;
      case 'youtube':
        return Colors.red;
      case 'spotify':
        return Colors.green;
      case 'website':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}

// Story Highlights Widget
class StoryHighlightsWidget extends StatelessWidget {
  const StoryHighlightsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final statsProvider = context.watch<ProfileStatsProvider>();

    if (statsProvider.storyHighlights.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'HIGHLIGHTS',
            style: TextStyle(
              color: AppColors.textGray,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: statsProvider.storyHighlights.length,
            itemBuilder: (context, index) {
              final highlight = statsProvider.storyHighlights[index];
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Column(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primaryRed, width: 2),
                        image: DecorationImage(
                          image: FileImage(File(highlight.coverImage)),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: 70,
                      child: Text(
                        highlight.title,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// Workout Anthem Widget
class WorkoutAnthemWidget extends StatelessWidget {
  const WorkoutAnthemWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final statsProvider = context.watch<ProfileStatsProvider>();

    if (statsProvider.workoutAnthem == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade700, Colors.deepPurple.shade900],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.music_note,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'WORKOUT ANTHEM',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statsProvider.anthemTitle ?? 'My Workout Song',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  statsProvider.anthemArtist ?? 'Artist',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.play_circle_filled, color: Colors.white, size: 40),
            onPressed: () async {
              final uri = Uri.parse(statsProvider.workoutAnthem!);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
          ),
        ],
      ),
    );
  }
}

class FeaturedBadgesWidget extends StatelessWidget {
  const FeaturedBadgesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final statsProvider = context.watch<ProfileStatsProvider>();
    final gamificationProvider = context.watch<GamificationProvider>();
    final pinnedBadgeIds = statsProvider.pinnedBadges.take(3).toList();

    if (pinnedBadgeIds.isEmpty) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FeaturedBadgesScreen(),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white12),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.emoji_events, color: Colors.white24, size: 20),
              SizedBox(width: 8),
              Text(
                'Feature badges',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                ),
              ),
              SizedBox(width: 4),
              Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 14),
            ],
          ),
        ),
      );
    }

    final featuredBadges = pinnedBadgeIds
        .map((id) => gamificationProvider.achievements.firstWhere(
              (a) => a.id == id && a.isUnlocked,
              orElse: () => Achievement(
                id: '',
                name: '',
                description: '',
                icon: '🏆',
                requiredCount: 0,
                category: '',
              ),
            ))
        .where((a) => a.id.isNotEmpty)
        .toList();

    if (featuredBadges.isEmpty) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const FeaturedBadgesScreen(),
          ),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: featuredBadges.map((achievement) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Tooltip(
              message: achievement.name,
              child: Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryRed.withOpacity(0.3),
                      AppColors.accentRed.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primaryRed.withOpacity(0.5),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryRed.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      achievement.icon,
                      style: const TextStyle(fontSize: 28),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      achievement.name.split(' ').first,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
