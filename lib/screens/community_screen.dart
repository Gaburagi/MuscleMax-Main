import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../providers/community_provider.dart';
import '../providers/custom_workout_provider.dart';
import '../models/community_models.dart';
import '../utils/app_colors.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabChange);
    // Load data immediately and sync achievements
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final communityProvider = context.read<CommunityProvider>();
      final customWorkoutProvider = context.read<CustomWorkoutProvider>();
      
      communityProvider.loadCommunityData().then((_) async {
        // Update achievements with real workout stats
        await communityProvider.updateAchievementsWithStats(
          customWorkoutProvider.totalCompletedWorkouts,
          customWorkoutProvider.getCurrentStreak(),
        );
        if (mounted) {
          setState(() {});
        }
      });
    });
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
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
          'COMMUNITY',
          style: TextStyle(
            fontFamily: 'Bebas Neue',
            fontSize: 24,
            letterSpacing: 1.5,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryRed,
          labelColor: Colors.white,
          unselectedLabelColor: AppColors.textGray,
          labelStyle: const TextStyle(
            fontFamily: 'DM Sans',
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          tabs: const [
            Tab(text: 'SHARED'),
            Tab(text: 'CHALLENGES'),
            Tab(text: 'LEADERBOARD'),
            Tab(text: 'BADGES'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _SharedWorkoutsTab(key: ValueKey('shared_$_currentTabIndex')),
          _ChallengesTab(key: ValueKey('challenges_$_currentTabIndex')),
          _LeaderboardTab(key: ValueKey('leaderboard_$_currentTabIndex')),
          _BadgesTab(key: ValueKey('badges_$_currentTabIndex')),
        ],
      ),
    );
  }
}

// Shared Workouts Tab  
class _SharedWorkoutsTab extends StatefulWidget {
  const _SharedWorkoutsTab({super.key});

  @override
  State<_SharedWorkoutsTab> createState() => _SharedWorkoutsTabState();
}

class _SharedWorkoutsTabState extends State<_SharedWorkoutsTab> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryRed,
        ),
      );
    }

    final provider = context.read<CommunityProvider>();
    final workouts = provider.sharedWorkouts;
    
    if (workouts.isEmpty) {
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
              'No Shared Workouts Yet',
              style: TextStyle(
                fontFamily: 'Bebas Neue',
                fontSize: 24,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: workouts.length,
          itemBuilder: (context, index) {
            final workout = workouts[index];
            final provider = context.read<CommunityProvider>();
            final isLiked = provider.isLiked(workout.id);

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.darkGray,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.primaryRed,
                          child: Text(
                            workout.sharedByName.isNotEmpty 
                                ? workout.sharedByName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontFamily: 'DM Sans',
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                workout.sharedByName,
                                style: const TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                DateFormat('MMM dd, yyyy').format(workout.sharedAt),
                                style: TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryRed.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            workout.category,
                            style: const TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryRed,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Workout Details
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workout.workoutName,
                          style: const TextStyle(
                            fontFamily: 'Bebas Neue',
                            fontSize: 22,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          workout.description,
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.fitness_center, size: 16, color: AppColors.primaryRed),
                            const SizedBox(width: 6),
                            Text(
                              '${workout.exerciseCount} Exercises',
                              style: const TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Actions
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Like button
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              setState(() {
                                context.read<CommunityProvider>().toggleLike(workout.id);
                              });
                            },
                            child: Row(
                              children: [
                                Icon(
                                  isLiked ? Icons.favorite : Icons.favorite_border,
                                  size: 20,
                                  color: isLiked ? AppColors.primaryRed : Colors.white,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${workout.likes}',
                                  style: const TextStyle(
                                    fontFamily: 'DM Sans',
                                    fontSize: 13,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                        // Clone count
                        Row(
                          children: [
                            const Icon(Icons.content_copy, size: 20, color: Colors.white),
                            const SizedBox(width: 6),
                            Text(
                              '${workout.clones}',
                              style: const TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 13,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        // Clone button
                        SizedBox(
                          width: 90,
                          height: 36,
                          child: ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                // Increment clone count
                                context.read<CommunityProvider>().cloneSharedWorkout(workout.id);
                                
                                // Create workout in custom library
                                context.read<CustomWorkoutProvider>().createWorkoutFromShared(
                                  name: workout.workoutName,
                                  description: workout.description,
                                  category: workout.category,
                                  exerciseCount: workout.exerciseCount,
                                );
                              });
                              
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Workout cloned to your library!'),
                                  backgroundColor: AppColors.primaryRed,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryRed,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'CLONE',
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
  }
}

// Challenges Tab
class _ChallengesTab extends StatefulWidget {
  const _ChallengesTab({super.key});

  @override
  State<_ChallengesTab> createState() => _ChallengesTabState();
}

class _ChallengesTabState extends State<_ChallengesTab> {
  @override
  void initState() {
    super.initState();
    // Update challenges with current workout data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateChallenges();
    });
  }

  Future<void> _updateChallenges() async {
    final customWorkoutProvider = context.read<CustomWorkoutProvider>();
    final communityProvider = context.read<CommunityProvider>();
    
    // Get challenges and update their progress
    for (final challenge in communityProvider.challenges) {
      if (!challenge.isJoined) continue;
      
      final stats = customWorkoutProvider.getWorkoutStatsForPeriod(
        challenge.startDate,
        challenge.endDate,
      );
      
      await communityProvider.updateChallengesWithWorkoutData(
        totalWorkoutsInPeriod: stats['totalWorkouts'],
        totalExercisesInPeriod: stats['totalExercises'],
        totalMinutesInPeriod: stats['totalMinutes'],
        workoutDatesInPeriod: stats['workoutDates'],
      );
      
      break; // Only need to run once
    }
    
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<CommunityProvider>();
    final challenges = provider.challenges;

    return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: challenges.length,
          itemBuilder: (context, index) {
            final challenge = challenges[index];

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: challenge.isJoined
                      ? [
                          AppColors.primaryRed.withOpacity(0.2),
                          AppColors.primaryRedDark.withOpacity(0.1),
                        ]
                      : [
                          AppColors.darkGray,
                          AppColors.darkGray,
                        ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: challenge.isJoined
                    ? Border.all(color: AppColors.primaryRed, width: 2)
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryRed,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.flag,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              challenge.name,
                              style: const TextStyle(
                                fontFamily: 'Bebas Neue',
                                fontSize: 20,
                                color: Colors.white,
                                letterSpacing: 1,
                              ),
                            ),
                            Text(
                              challenge.description,
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Progress bar (if joined)
                  if (challenge.isJoined) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progress: ${challenge.currentProgress}/${challenge.targetCount} ${_getMetricLabel(challenge.metric)}',
                          style: const TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${challenge.progressPercentage.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 13,
                            color: AppColors.primaryRed,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: challenge.progressPercentage / 100,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryRed),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Stats row
                  Row(
                    children: [
                      Icon(Icons.people, size: 16, color: Colors.white.withOpacity(0.7)),
                      const SizedBox(width: 6),
                      Text(
                        '${challenge.participants} participants',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Icon(Icons.access_time, size: 16, color: Colors.white.withOpacity(0.7)),
                      const SizedBox(width: 6),
                      Text(
                        '${challenge.daysRemaining} days left',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Join/Leave button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          context.read<CommunityProvider>().toggleChallengeJoin(challenge.id);
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: challenge.isJoined
                            ? AppColors.darkGray
                            : AppColors.primaryRed,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        challenge.isJoined ? 'LEAVE CHALLENGE' : 'JOIN CHALLENGE',
                        style: const TextStyle(
                          fontFamily: 'DM Sans',
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
  }

  String _getMetricLabel(String metric) {
    switch (metric) {
      case 'workouts':
        return 'workouts';
      case 'exercises':
        return 'exercises';
      case 'minutes':
        return 'minutes';
      case 'days':
        return 'days';
      default:
        return '';
    }
  }
}

// Leaderboard Tab
class _LeaderboardTab extends StatefulWidget {
  const _LeaderboardTab({super.key});

  @override
  State<_LeaderboardTab> createState() => _LeaderboardTabState();
}

class _LeaderboardTabState extends State<_LeaderboardTab> {
  String _selectedPeriod = 'monthly'; // 'weekly', 'monthly', 'alltime'
  List<LeaderboardEntry> _leaderboard = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateLeaderboard();
    });
  }

  void _generateLeaderboard() {
    final customWorkoutProvider = context.read<CustomWorkoutProvider>();
    final now = DateTime.now();
    
    DateTime startDate;
    switch (_selectedPeriod) {
      case 'weekly':
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        startDate = DateTime(weekStart.year, weekStart.month, weekStart.day);
        break;
      case 'monthly':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'alltime':
      default:
        startDate = DateTime(2000, 1, 1);
        break;
    }

    final stats = customWorkoutProvider.getWorkoutStatsForPeriod(startDate, now);
    final userScore = stats['totalWorkouts'] as int;

    // Generate leaderboard with user and demo competitors
    _leaderboard = _generateDemoLeaderboardWithUser(userScore, _selectedPeriod);
    
    if (mounted) setState(() {});
  }

  List<LeaderboardEntry> _generateDemoLeaderboardWithUser(int userScore, String period) {
    // Create demo competitors with scores around the user's score
    final random = DateTime.now().millisecondsSinceEpoch % 100;
    final entries = <LeaderboardEntry>[
      LeaderboardEntry(
        userId: 'user_1',
        userName: 'Alex Thunder',
        rank: 1,
        score: userScore + 15 + (random % 5),
        metric: 'workouts',
        period: period,
      ),
      LeaderboardEntry(
        userId: 'user_2',
        userName: 'Sarah Lightning',
        rank: 2,
        score: userScore + 8 + (random % 3),
        metric: 'workouts',
        period: period,
      ),
      LeaderboardEntry(
        userId: 'user_3',
        userName: 'Mike Steel',
        rank: 3,
        score: userScore + 4 + (random % 2),
        metric: 'workouts',
        period: period,
      ),
      LeaderboardEntry(
        userId: 'current_user',
        userName: 'You',
        rank: 4,
        score: userScore,
        metric: 'workouts',
        period: period,
      ),
      LeaderboardEntry(
        userId: 'user_4',
        userName: 'Chris Boulder',
        rank: 5,
        score: userScore > 2 ? userScore - 2 : 0,
        metric: 'workouts',
        period: period,
      ),
      LeaderboardEntry(
        userId: 'user_5',
        userName: 'Emma Fierce',
        rank: 6,
        score: userScore > 4 ? userScore - 4 : 0,
        metric: 'workouts',
        period: period,
      ),
      LeaderboardEntry(
        userId: 'user_6',
        userName: 'David Titan',
        rank: 7,
        score: userScore > 6 ? userScore - 6 : 0,
        metric: 'workouts',
        period: period,
      ),
    ];

    // Sort by score and reassign ranks
    entries.sort((a, b) => b.score.compareTo(a.score));
    for (int i = 0; i < entries.length; i++) {
      entries[i] = LeaderboardEntry(
        userId: entries[i].userId,
        userName: entries[i].userName,
        rank: i + 1,
        score: entries[i].score,
        metric: entries[i].metric,
        period: entries[i].period,
      );
    }

    return entries;
  }

  @override
  Widget build(BuildContext context) {
    final leaderboard = _leaderboard;

    return Column(
          children: [
            // Period selector
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.darkGray,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _PeriodButton(
                      label: 'WEEKLY',
                      isSelected: _selectedPeriod == 'weekly',
                      onTap: () {
                        setState(() {
                          _selectedPeriod = 'weekly';
                        });
                        _generateLeaderboard();
                      },
                    ),
                  ),
                  Expanded(
                    child: _PeriodButton(
                      label: 'MONTHLY',
                      isSelected: _selectedPeriod == 'monthly',
                      onTap: () {
                        setState(() {
                          _selectedPeriod = 'monthly';
                        });
                        _generateLeaderboard();
                      },
                    ),
                  ),
                  Expanded(
                    child: _PeriodButton(
                      label: 'ALL TIME',
                      isSelected: _selectedPeriod == 'alltime',
                      onTap: () {
                        setState(() {
                          _selectedPeriod = 'alltime';
                        });
                        _generateLeaderboard();
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Leaderboard list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: leaderboard.length,
                itemBuilder: (context, index) {
                  final entry = leaderboard[index];
                  final isCurrentUser = entry.userName == 'You';
                  final medalColor = index == 0
                      ? const Color(0xFFFFD700)
                      : index == 1
                          ? const Color(0xFFC0C0C0)
                          : index == 2
                              ? const Color(0xFFCD7F32)
                              : null;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isCurrentUser
                          ? AppColors.primaryRed.withOpacity(0.2)
                          : AppColors.darkGray,
                      borderRadius: BorderRadius.circular(12),
                      border: isCurrentUser
                          ? Border.all(color: AppColors.primaryRed, width: 2)
                          : null,
                    ),
                    child: Row(
                      children: [
                        // Rank
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: medalColor ?? Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: medalColor != null
                                ? Icon(Icons.emoji_events, color: medalColor, size: 24)
                                : Text(
                                    '#${entry.rank}',
                                    style: const TextStyle(
                                      fontFamily: 'DM Sans',
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            entry.userName,
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 15,
                              fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Text(
                          '${entry.score} workouts',
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isCurrentUser ? AppColors.primaryRed : Colors.white,
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

class _PeriodButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryRed : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
          ),
        ),
      ),
    );
  }
}

// Badges Tab
class _BadgesTab extends StatefulWidget {
  const _BadgesTab({super.key});

  @override
  State<_BadgesTab> createState() => _BadgesTabState();
}

class _BadgesTabState extends State<_BadgesTab> {
  @override
  void initState() {
    super.initState();
    // Update achievements with current workout stats
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final customWorkoutProvider = context.read<CustomWorkoutProvider>();
      final communityProvider = context.read<CommunityProvider>();
      communityProvider.updateAchievementsWithStats(
        customWorkoutProvider.totalCompletedWorkouts,
        customWorkoutProvider.getCurrentStreak(),
      ).then((_) {
        if (mounted) setState(() {});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<CommunityProvider>();
    final achievements = provider.achievements;

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemCount: achievements.length,
          itemBuilder: (context, index) {
            final achievement = achievements[index];

            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: achievement.isUnlocked
                      ? [
                          AppColors.primaryRed.withOpacity(0.3),
                          AppColors.primaryRedDark.withOpacity(0.2),
                        ]
                      : [
                          AppColors.darkGray,
                          Colors.black.withOpacity(0.5),
                        ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: achievement.isUnlocked
                    ? Border.all(color: AppColors.primaryRed, width: 2)
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Badge icon
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: achievement.isUnlocked
                          ? AppColors.primaryRed
                          : Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        achievement.icon,
                        style: TextStyle(
                          fontSize: 32,
                          color: achievement.isUnlocked
                              ? Colors.white
                              : Colors.white.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    achievement.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Bebas Neue',
                      fontSize: 16,
                      color: achievement.isUnlocked
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    achievement.description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                  if (!achievement.isUnlocked) ...[
                    const SizedBox(height: 12),
                    Text(
                      '${achievement.currentProgress}/${achievement.requiredCount}',
                      style: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryRed,
                      ),
                    ),
                  ],
                  if (achievement.isUnlocked && achievement.unlockedAt != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      DateFormat('MMM dd').format(achievement.unlockedAt!),
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 10,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
  }
}
