import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../providers/user_provider.dart';
import '../utils/app_colors.dart';
import '../utils/routes.dart';
import 'package:go_router/go_router.dart';
import '../widgets/bottom_navigation.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final int _currentNavIndex = 2; // Progress tab in bottom nav

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
    final workoutProvider = context.watch<WorkoutProvider>();
    final userProvider = context.watch<UserProvider>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'YOUR',
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            color: AppColors.textWhite,
                            fontSize: 32,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'PROGRESS',
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            color: AppColors.primaryRed,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Track your fitness journey',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textGray,
                      ),
                    ),
                  ],
                ),
              ),

              // Tab Bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColors.backgroundCard,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppColors.primaryRed,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: AppColors.textWhite,
                  unselectedLabelColor: AppColors.textGray,
                  tabs: const [
                    Tab(text: 'Overview'),
                    Tab(text: 'Statistics'),
                    Tab(text: 'Achievements'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Tab Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(workoutProvider, userProvider),
                    _buildStatisticsTab(workoutProvider),
                    _buildAchievementsTab(workoutProvider),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavigation(currentIndex: 2),
    );
  }

  Widget _buildOverviewTab(WorkoutProvider workoutProvider, UserProvider userProvider) {
    final totalWorkouts = workoutProvider.totalWorkoutsCompleted;
    final totalTime = workoutProvider.totalWorkoutTime;
    final estimatedCalories = (totalTime.inMinutes * 5).toInt();
    final currentStreak = _calculateStreak(workoutProvider.workoutHistory);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Body Measurements Button
          ElevatedButton.icon(
            onPressed: () {
              context.push('/body-measurements');
            },
            icon: const Icon(Icons.monitor_weight),
            label: const Text('Body Measurements & Goals'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Personal Records Button
          ElevatedButton.icon(
            onPressed: () {
              context.push('/personal-records');
            },
            icon: const Icon(Icons.emoji_events),
            label: const Text('Personal Records'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Progress Photos Button
          ElevatedButton.icon(
            onPressed: () {
              context.push('/progress-photos');
            },
            icon: const Icon(Icons.photo_library),
            label: const Text('Progress Photos'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Progress Reports Button
          ElevatedButton.icon(
            onPressed: () {
              context.push('/progress-reports');
            },
            icon: const Icon(Icons.assessment),
            label: const Text('Progress Reports'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Main Stats Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.fitness_center,
                  value: totalWorkouts.toString(),
                  label: 'Workouts',
                  color: AppColors.primaryRed,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.local_fire_department,
                  value: currentStreak.toString(),
                  label: 'Day Streak',
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.access_time,
                  value: '${totalTime.inMinutes}',
                  label: 'Minutes',
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.whatshot,
                  value: estimatedCalories.toString(),
                  label: 'Calories',
                  color: Colors.deepOrange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Weekly Progress
          Text(
            'WEEKLY PROGRESS',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textWhite,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          _buildWeeklyChart(workoutProvider),
          const SizedBox(height: 24),

          // Recent Workouts
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'RECENT WORKOUTS',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textWhite,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              if (workoutProvider.workoutHistory.isNotEmpty)
                TextButton(
                  onPressed: () {
                    _tabController.animateTo(1);
                  },
                  child: const Text(
                    'See All',
                    style: TextStyle(color: AppColors.primaryRed),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          workoutProvider.workoutHistory.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: workoutProvider.workoutHistory.take(5).length,
                  itemBuilder: (context, index) {
                    final session = workoutProvider.workoutHistory.reversed.toList()[index];
                    final program = workoutProvider.getWorkoutById(session.workoutProgramId);
                    return _buildRecentWorkoutCard(session, program?.name ?? 'Workout');
                  },
                ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStatisticsTab(WorkoutProvider workoutProvider) {
    final totalWorkouts = workoutProvider.totalWorkoutsCompleted;
    final totalTime = workoutProvider.totalWorkoutTime;
    final avgDuration = totalWorkouts > 0 ? totalTime.inMinutes ~/ totalWorkouts : 0;
    final estimatedCalories = (totalTime.inMinutes * 5).toInt();

    // Calculate favorite workout
    final workoutCounts = <String, int>{};
    for (var session in workoutProvider.workoutHistory) {
      workoutCounts[session.workoutProgramId] = (workoutCounts[session.workoutProgramId] ?? 0) + 1;
    }
    String? favoriteWorkoutId;
    int maxCount = 0;
    workoutCounts.forEach((id, count) {
      if (count > maxCount) {
        maxCount = count;
        favoriteWorkoutId = id;
      }
    });
    final favoriteWorkout = favoriteWorkoutId != null 
        ? workoutProvider.getWorkoutById(favoriteWorkoutId!)?.name ?? 'N/A'
        : 'N/A';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // All Time Stats
          Text(
            'ALL TIME STATISTICS',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textWhite,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailedStatCard(
            icon: Icons.fitness_center,
            title: 'Total Workouts',
            value: totalWorkouts.toString(),
            subtitle: 'Keep pushing!',
          ),
          const SizedBox(height: 12),
          _buildDetailedStatCard(
            icon: Icons.access_time,
            title: 'Total Time',
            value: _formatDuration(totalTime),
            subtitle: '${(totalTime.inHours)} hours of training',
          ),
          const SizedBox(height: 12),
          _buildDetailedStatCard(
            icon: Icons.timer,
            title: 'Average Duration',
            value: '$avgDuration min',
            subtitle: 'Per workout session',
          ),
          const SizedBox(height: 12),
          _buildDetailedStatCard(
            icon: Icons.whatshot,
            title: 'Calories Burned',
            value: '~$estimatedCalories',
            subtitle: 'Estimated total',
          ),
          const SizedBox(height: 12),
          _buildDetailedStatCard(
            icon: Icons.favorite,
            title: 'Favorite Workout',
            value: favoriteWorkout,
            subtitle: '$maxCount times completed',
          ),
          const SizedBox(height: 24),

          // Monthly Comparison
          Text(
            'MONTHLY COMPARISON',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textWhite,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          _buildMonthlyChart(workoutProvider),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildAchievementsTab(WorkoutProvider workoutProvider) {
    final totalWorkouts = workoutProvider.totalWorkoutsCompleted;
    final totalMinutes = workoutProvider.totalWorkoutTime.inMinutes;
    final currentStreak = _calculateStreak(workoutProvider.workoutHistory);

    final achievements = [
      Achievement(
        title: 'First Step',
        description: 'Complete your first workout',
        icon: Icons.directions_walk,
        isUnlocked: totalWorkouts >= 1,
        progress: totalWorkouts >= 1 ? 1.0 : 0.0,
        color: Colors.green,
      ),
      Achievement(
        title: 'Consistency King',
        description: 'Maintain a 7-day streak',
        icon: Icons.local_fire_department,
        isUnlocked: currentStreak >= 7,
        progress: (currentStreak / 7).clamp(0.0, 1.0),
        color: Colors.orange,
      ),
      Achievement(
        title: 'Getting Started',
        description: 'Complete 5 workouts',
        icon: Icons.star,
        isUnlocked: totalWorkouts >= 5,
        progress: (totalWorkouts / 5).clamp(0.0, 1.0),
        color: Colors.blue,
      ),
      Achievement(
        title: 'Dedicated',
        description: 'Complete 10 workouts',
        icon: Icons.emoji_events,
        isUnlocked: totalWorkouts >= 10,
        progress: (totalWorkouts / 10).clamp(0.0, 1.0),
        color: Colors.purple,
      ),
      Achievement(
        title: 'Time Keeper',
        description: 'Exercise for 60 minutes total',
        icon: Icons.access_time,
        isUnlocked: totalMinutes >= 60,
        progress: (totalMinutes / 60).clamp(0.0, 1.0),
        color: Colors.teal,
      ),
      Achievement(
        title: 'Marathon',
        description: 'Exercise for 5 hours total',
        icon: Icons.timer,
        isUnlocked: totalMinutes >= 300,
        progress: (totalMinutes / 300).clamp(0.0, 1.0),
        color: Colors.indigo,
      ),
      Achievement(
        title: 'Fitness Warrior',
        description: 'Complete 25 workouts',
        icon: Icons.military_tech,
        isUnlocked: totalWorkouts >= 25,
        progress: (totalWorkouts / 25).clamp(0.0, 1.0),
        color: Colors.red,
      ),
      Achievement(
        title: 'Legend',
        description: 'Complete 50 workouts',
        icon: Icons.workspace_premium,
        isUnlocked: totalWorkouts >= 50,
        progress: (totalWorkouts / 50).clamp(0.0, 1.0),
        color: Colors.amber,
      ),
    ];

    final unlockedCount = achievements.where((a) => a.isUnlocked).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress Summary
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.redGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.emoji_events,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$unlockedCount / ${achievements.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Achievements Unlocked',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'ALL ACHIEVEMENTS',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textWhite,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),

          // Achievement Cards
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: achievements.length,
            itemBuilder: (context, index) {
              return _buildAchievementCard(achievements[index]);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textWhite,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textGray,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryRed.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primaryRed, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textGray,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textGray,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(WorkoutProvider workoutProvider) {
    final now = DateTime.now();
    final weekDays = List.generate(7, (index) {
      return now.subtract(Duration(days: 6 - index));
    });

    final workoutCounts = <DateTime, int>{};
    for (var session in workoutProvider.workoutHistory) {
      final date = DateTime(
        session.startTime.year,
        session.startTime.month,
        session.startTime.day,
      );
      workoutCounts[date] = (workoutCounts[date] ?? 0) + 1;
    }

    final maxCount = workoutCounts.values.isEmpty ? 1 : workoutCounts.values.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: weekDays.map((day) {
              final normalizedDay = DateTime(day.year, day.month, day.day);
              final count = workoutCounts[normalizedDay] ?? 0;
              final height = maxCount > 0 ? (count / maxCount * 100).clamp(20.0, 100.0) : 20.0;

              return Column(
                children: [
                  Container(
                    width: 32,
                    height: height,
                    decoration: BoxDecoration(
                      gradient: count > 0 ? AppColors.redGradient : null,
                      color: count > 0 ? null : AppColors.backgroundDark,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getDayInitial(day.weekday),
                    style: const TextStyle(
                      color: AppColors.textGray,
                      fontSize: 12,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyChart(WorkoutProvider workoutProvider) {
    final now = DateTime.now();
    final months = List.generate(6, (index) {
      final month = DateTime(now.year, now.month - (5 - index), 1);
      return month;
    });

    final monthlyWorkouts = <String, int>{};
    for (var session in workoutProvider.workoutHistory) {
      final key = '${session.startTime.year}-${session.startTime.month}';
      monthlyWorkouts[key] = (monthlyWorkouts[key] ?? 0) + 1;
    }

    final maxCount = monthlyWorkouts.values.isEmpty ? 1 : monthlyWorkouts.values.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: months.map((month) {
              final key = '${month.year}-${month.month}';
              final count = monthlyWorkouts[key] ?? 0;
              final height = maxCount > 0 ? (count / maxCount * 120).clamp(30.0, 120.0) : 30.0;

              return Column(
                children: [
                  Container(
                    width: 40,
                    height: height,
                    decoration: BoxDecoration(
                      gradient: count > 0 ? AppColors.redGradient : null,
                      color: count > 0 ? null : AppColors.backgroundDark,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        count > 0 ? count.toString() : '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getMonthAbbr(month.month),
                    style: const TextStyle(
                      color: AppColors.textGray,
                      fontSize: 10,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentWorkoutCard(session, String workoutName) {
    final duration = session.duration ?? Duration.zero;
    final durationStr = '${duration.inMinutes} min';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryRed.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.check_circle,
              color: AppColors.primaryRed,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workoutName,
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(session.startTime),
                  style: const TextStyle(
                    color: AppColors.textGray,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            durationStr,
            style: const TextStyle(
              color: AppColors.primaryRed,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        border: achievement.isUnlocked
            ? Border.all(color: achievement.color.withOpacity(0.3), width: 1)
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: achievement.isUnlocked
                  ? achievement.color.withOpacity(0.2)
                  : AppColors.backgroundDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              achievement.icon,
              color: achievement.isUnlocked ? achievement.color : AppColors.textGray,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      achievement.title,
                      style: TextStyle(
                        color: achievement.isUnlocked ? AppColors.textWhite : AppColors.textGray,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (achievement.isUnlocked) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.verified,
                        color: achievement.color,
                        size: 18,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: const TextStyle(
                    color: AppColors.textGray,
                    fontSize: 12,
                  ),
                ),
                if (!achievement.isUnlocked && achievement.progress > 0) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: achievement.progress,
                      backgroundColor: AppColors.backgroundDark,
                      valueColor: AlwaysStoppedAnimation<Color>(achievement.color),
                      minHeight: 6,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.fitness_center,
            size: 64,
            color: AppColors.textGray.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          const Text(
            'No workouts yet',
            style: TextStyle(
              color: AppColors.textWhite,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Complete your first workout to start tracking progress',
            style: TextStyle(
              color: AppColors.textGray,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              context.go(AppRoutes.training);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('START WORKOUT'),
          ),
        ],
      ),
    );
  }

  int _calculateStreak(List<dynamic> workoutHistory) {
    if (workoutHistory.isEmpty) return 0;

    final sortedSessions = workoutHistory.toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    var streak = 0;
    var checkDate = today;

    for (var session in sortedSessions) {
      final sessionDate = DateTime(
        session.startTime.year,
        session.startTime.month,
        session.startTime.day,
      );

      if (sessionDate.isAtSameMomentAs(checkDate)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else if (sessionDate.isBefore(checkDate)) {
        break;
      }
    }

    return streak;
  }

  String _getDayInitial(int weekday) {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return days[weekday - 1];
  }

  String _getMonthAbbr(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == yesterday) {
      return 'Yesterday';
    } else {
      return '${_getMonthAbbr(date.month)} ${date.day}';
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}

class Achievement {
  final String title;
  final String description;
  final IconData icon;
  final bool isUnlocked;
  final double progress;
  final Color color;

  Achievement({
    required this.title,
    required this.description,
    required this.icon,
    required this.isUnlocked,
    required this.progress,
    required this.color,
  });
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;

  const _BottomNav({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundDark,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            icon: Icons.home,
            label: 'Home',
            isSelected: currentIndex == 0,
            onTap: () => context.go(AppRoutes.home),
          ),
          _NavItem(
            icon: Icons.fitness_center,
            label: 'Training',
            isSelected: currentIndex == 1,
            onTap: () => context.go(AppRoutes.training),
          ),
          _NavItem(
            icon: Icons.bar_chart,
            label: 'Progress',
            isSelected: currentIndex == 2,
            onTap: () => context.go(AppRoutes.progress),
          ),
          _NavItem(
            icon: Icons.person,
            label: 'Profile',
            isSelected: currentIndex == 3,
            onTap: () => context.go(AppRoutes.profile),
          ),
          _NavItem(
            icon: Icons.restaurant,
            label: 'Nutrition',
            isSelected: currentIndex == 4,
            onTap: () => context.go(AppRoutes.nutrition),
          ),
        ],
      ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isSelected ? AppColors.primaryRed : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
