import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../providers/gamification_provider.dart';
import '../providers/profile_stats_provider.dart';

class FeaturedBadgesScreen extends StatefulWidget {
  const FeaturedBadgesScreen({super.key});

  @override
  State<FeaturedBadgesScreen> createState() => _FeaturedBadgesScreenState();
}

class _FeaturedBadgesScreenState extends State<FeaturedBadgesScreen> {
  final Set<String> _selectedBadges = {};

  @override
  void initState() {
    super.initState();
    final pinnedBadges = context.read<ProfileStatsProvider>().pinnedBadges;
    _selectedBadges.addAll(pinnedBadges.take(3)); // Only show first 3
  }

  @override
  Widget build(BuildContext context) {
    final gamificationProvider = context.watch<GamificationProvider>();
    final unlockedAchievements = gamificationProvider.achievements
        .where((a) => a.isUnlocked)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundCard,
        title: const Text(
          'FEATURED BADGES',
          style: TextStyle(
            fontFamily: 'Bebas Neue',
            fontSize: 22,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: AppColors.primaryRed),
            onPressed: _saveFeaturedBadges,
          ),
        ],
      ),
      body: unlockedAchievements.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.emoji_events_outlined, 
                    size: 80, 
                    color: Colors.white24,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No badges earned yet',
                    style: TextStyle(
                      color: AppColors.textGray,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Complete workouts to earn badges!',
                    style: TextStyle(
                      color: AppColors.textGray,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  color: AppColors.backgroundCard,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select up to 3 badges to feature on your profile',
                        style: TextStyle(
                          color: AppColors.textGray,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) {
                          final badgeId = _selectedBadges.length > index
                              ? _selectedBadges.elementAt(index)
                              : null;
                          final achievement = badgeId != null
                              ? unlockedAchievements.firstWhere(
                                  (a) => a.id == badgeId,
                                  orElse: () => unlockedAchievements.first,
                                )
                              : null;

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: achievement != null
                                    ? AppColors.primaryRed.withOpacity(0.2)
                                    : AppColors.backgroundDark,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: achievement != null
                                      ? AppColors.primaryRed
                                      : Colors.white12,
                                  width: 2,
                                ),
                              ),
                              child: achievement != null
                                  ? Center(
                                      child: Text(
                                        achievement.icon,
                                        style: const TextStyle(fontSize: 32),
                                      ),
                                    )
                                  : Icon(
                                      Icons.add,
                                      color: Colors.white24,
                                      size: 32,
                                    ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: unlockedAchievements.length,
                    itemBuilder: (context, index) {
                      final achievement = unlockedAchievements[index];
                      final isSelected = _selectedBadges.contains(achievement.id);

                      return GestureDetector(
                        onTap: () => _toggleBadge(achievement.id),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.backgroundCard,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primaryRed
                                  : Colors.white12,
                              width: isSelected ? 3 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                achievement.icon,
                                style: const TextStyle(fontSize: 40),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  achievement.name,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: isSelected
                                        ? AppColors.primaryRed
                                        : Colors.white,
                                    fontSize: 11,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                const Padding(
                                  padding: EdgeInsets.only(top: 4),
                                  child: Icon(
                                    Icons.check_circle,
                                    color: AppColors.primaryRed,
                                    size: 20,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  void _toggleBadge(String badgeId) {
    setState(() {
      if (_selectedBadges.contains(badgeId)) {
        _selectedBadges.remove(badgeId);
      } else if (_selectedBadges.length < 3) {
        _selectedBadges.add(badgeId);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Maximum 3 badges can be featured'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  Future<void> _saveFeaturedBadges() async {
    final profileStatsProvider = context.read<ProfileStatsProvider>();
    
    // Clear existing pinned badges
    final currentPinned = List<String>.from(profileStatsProvider.pinnedBadges);
    for (final badgeId in currentPinned) {
      await profileStatsProvider.pinBadge(badgeId); // Toggle off
    }
    
    // Add selected badges
    for (final badgeId in _selectedBadges) {
      await profileStatsProvider.pinBadge(badgeId);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Featured badges updated!')),
      );
      Navigator.pop(context);
    }
  }
}
