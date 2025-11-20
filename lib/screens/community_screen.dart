import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../providers/community_provider.dart';
import '../providers/custom_workout_provider.dart';
import '../providers/social_provider.dart';
import '../models/community_models.dart';
import '../models/social_model.dart' as social;
import '../utils/app_colors.dart';
import 'team_battles_screen.dart';
import 'create_post_screen.dart';
import 'image_viewer_screen.dart';

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
        actions: [
          IconButton(
            icon: const Icon(Icons.shield, color: AppColors.primaryRed),
            tooltip: 'Team Battles',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TeamBattlesScreen(),
                ),
              );
            },
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
            fontSize: 12,
          ),
          tabs: const [
            Tab(text: 'FEED'),
            Tab(text: 'CHALLENGES'),
            Tab(text: 'LEADERBOARD'),
            Tab(text: 'BADGES'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _WorkoutFeedTab(key: ValueKey('feed_$_currentTabIndex')),
          _ChallengesTab(key: ValueKey('challenges_$_currentTabIndex')),
          _NewLeaderboardTab(key: ValueKey('leaderboard_$_currentTabIndex')),
          _BadgesTab(key: ValueKey('badges_$_currentTabIndex')),
        ],
      ),
      floatingActionButton: _currentTabIndex == 0 // Only show on Feed tab
          ? FloatingActionButton.extended(
              onPressed: () => _showCreatePostDialog(context),
              backgroundColor: AppColors.primaryRed,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'POST',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            )
          : null,
    );
  }

  void _showCreatePostDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreatePostScreen(),
      ),
    );
  }
}

// Workout Feed Tab
class _WorkoutFeedTab extends StatelessWidget {
  const _WorkoutFeedTab({super.key});

  @override
  Widget build(BuildContext context) {
    final socialProvider = context.watch<SocialProvider>();
    final feed = socialProvider.workoutFeed;

    if (feed.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fitness_center,
              size: 80,
              color: AppColors.textGray.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No workouts yet',
              style: TextStyle(
                color: AppColors.textGray,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Complete a workout to share with friends!',
              style: TextStyle(
                color: AppColors.textGray,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: feed.length,
      itemBuilder: (context, index) {
        final post = feed[index];
        final isLiked = post.likedBy.contains(socialProvider.currentUserId);
        final isOwnPost = post.userId == socialProvider.currentUserId;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primaryRed,
                    child: Text(
                      post.userName[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _formatTimestamp(post.timestamp),
                          style: const TextStyle(
                            color: AppColors.textGray,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: AppColors.textGray),
                    color: AppColors.backgroundCard,
                    onSelected: (value) async {
                      if (value == 'delete' && isOwnPost) {
                        _showDeleteDialog(context, post.id, socialProvider);
                      } else if (value == 'report') {
                        _showReportDialog(context, post.id, socialProvider);
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return [
                        if (isOwnPost)
                          const PopupMenuItem<String>(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red, size: 20),
                                SizedBox(width: 12),
                                Text('Delete Post', style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          ),
                        if (!isOwnPost)
                          const PopupMenuItem<String>(
                            value: 'report',
                            child: Row(
                              children: [
                                Icon(Icons.flag, color: Colors.orange, size: 20),
                                SizedBox(width: 12),
                                Text('Report Post', style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          ),
                      ];
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Workout name
              Row(
                children: [
                  const Icon(Icons.fitness_center, color: AppColors.primaryRed, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      post.workoutName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Stats
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  _buildStatChip(Icons.timer, '${post.durationMinutes} min', Colors.blue),
                  _buildStatChip(Icons.fitness_center, '${post.exercisesCompleted} exercises', Colors.orange),
                  if (post.caloriesBurned != null)
                    _buildStatChip(Icons.local_fire_department, '${post.caloriesBurned} kcal', Colors.red),
                  _buildStatChip(Icons.star, '+${post.xpGained} XP', Colors.amber),
                ],
              ),
              // PRs
              if (post.personalRecords.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.purple.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.emoji_events, color: Colors.purple, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'New PR!',
                            style: TextStyle(
                              color: Colors.purple,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ...post.personalRecords.map((pr) => Text(
                            pr,
                            style: const TextStyle(color: Colors.white, fontSize: 11),
                          )),
                    ],
                  ),
                ),
              ],
              // Achievements
              if (post.achievements.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: post.achievements.map((achievement) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.emoji_events, color: Colors.amber, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            achievement,
                            style: const TextStyle(
                              color: Colors.amber,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
              if (post.note != null && post.note!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  post.note!,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ],
              // Images
              if (post.imageUrls.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildImageGrid(context, post.imageUrls),
              ],
              const SizedBox(height: 12),
              const Divider(color: Colors.grey, height: 1),
              const SizedBox(height: 8),
              // Actions
              Row(
                children: [
                  InkWell(
                    onTap: () => socialProvider.likePost(post.id),
                    child: Row(
                      children: [
                        Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked ? Colors.red : AppColors.textGray,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${post.likeCount}',
                          style: TextStyle(
                            color: isLiked ? Colors.red : AppColors.textGray,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  InkWell(
                    onTap: () => _showCommentsDialog(context, post, socialProvider),
                    child: Row(
                      children: [
                        const Icon(Icons.comment_outlined, color: AppColors.textGray, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          '${post.commentCount}',
                          style: const TextStyle(color: AppColors.textGray, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Show preview of comments
              if (post.comments.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Divider(color: Colors.grey, height: 1),
                const SizedBox(height: 8),
                ...post.comments.take(2).map((comment) => _buildCommentPreview(comment)),
                if (post.comments.length > 2)
                  TextButton(
                    onPressed: () => _showCommentsDialog(context, post, socialProvider),
                    child: Text(
                      'View all ${post.comments.length} comments',
                      style: const TextStyle(
                        color: AppColors.textGray,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentPreview(social.WorkoutComment comment) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: AppColors.primaryRed.withOpacity(0.3),
            child: Text(
              comment.userName[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTimestamp(comment.timestamp),
                      style: const TextStyle(
                        color: AppColors.textGray,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  comment.text,
                  style: const TextStyle(
                    color: AppColors.textGray,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCommentsDialog(
    BuildContext context,
    social.WorkoutPost post,
    SocialProvider socialProvider,
  ) {
    final commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            color: AppColors.backgroundDark,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Text(
                      'Comments',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${post.commentCount}',
                      style: const TextStyle(
                        color: AppColors.textGray,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.grey, height: 1),
              // Comments list
              Expanded(
                child: post.comments.isEmpty
                    ? const Center(
                        child: Text(
                          'No comments yet\nBe the first to comment!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textGray,
                            fontSize: 14,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: post.comments.length,
                        itemBuilder: (context, index) {
                          final comment = post.comments[index];
                          final isOwnComment = comment.userId == socialProvider.currentUserId;
                          return _buildCommentTile(
                            comment,
                            isOwnComment,
                            post.id,
                            socialProvider,
                            context,
                          );
                        },
                      ),
              ),
              // Comment input
              Container(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 12,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 12,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.backgroundCard,
                  border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: commentController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Add a comment...',
                          hintStyle: const TextStyle(color: AppColors.textGray),
                          filled: true,
                          fillColor: AppColors.backgroundDark,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () async {
                        if (commentController.text.trim().isNotEmpty) {
                          await socialProvider.commentOnPost(
                            post.id,
                            commentController.text.trim(),
                          );
                          commentController.clear();
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        }
                      },
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          gradient: AppColors.redGradient,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommentTile(
    social.WorkoutComment comment,
    bool isOwnComment,
    String postId,
    SocialProvider socialProvider,
    BuildContext context,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primaryRed.withOpacity(0.3),
                child: Text(
                  comment.userName[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _formatTimestamp(comment.timestamp),
                      style: const TextStyle(
                        color: AppColors.textGray,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: AppColors.textGray, size: 18),
                color: AppColors.backgroundCard,
                onSelected: (value) async {
                  if (value == 'delete' && isOwnComment) {
                    await socialProvider.deleteComment(postId, comment.id);
                  } else if (value == 'report') {
                    _showReportCommentDialog(context, comment.id, socialProvider);
                  }
                },
                itemBuilder: (BuildContext context) {
                  return [
                    if (isOwnComment)
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red, size: 18),
                            SizedBox(width: 10),
                            Text('Delete', style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    if (!isOwnComment)
                      const PopupMenuItem<String>(
                        value: 'report',
                        child: Row(
                          children: [
                            Icon(Icons.flag, color: Colors.orange, size: 18),
                            SizedBox(width: 10),
                            Text('Report', style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                  ];
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comment.text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    String postId,
    SocialProvider socialProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        title: const Text(
          'Delete Post?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'This action cannot be undone. Are you sure you want to delete this post?',
          style: TextStyle(color: AppColors.textGray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'CANCEL',
              style: TextStyle(color: AppColors.textGray),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await socialProvider.deletePost(postId);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Post deleted'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text(
              'DELETE',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showReportDialog(
    BuildContext context,
    String postId,
    SocialProvider socialProvider,
  ) {
    String? selectedReason;
    final detailsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppColors.backgroundCard,
          title: const Text(
            'Report Post',
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Why are you reporting this post?',
                  style: TextStyle(color: AppColors.textGray, fontSize: 14),
                ),
                const SizedBox(height: 12),
                ...[
                  'Spam',
                  'Harassment',
                  'Inappropriate Content',
                  'False Information',
                  'Other',
                ].map((reason) => RadioListTile<String>(
                      title: Text(
                        reason,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      value: reason,
                      groupValue: selectedReason,
                      activeColor: AppColors.primaryRed,
                      onChanged: (value) => setState(() => selectedReason = value),
                    )),
                const SizedBox(height: 12),
                TextField(
                  controller: detailsController,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Additional details (optional)',
                    hintStyle: const TextStyle(color: AppColors.textGray),
                    filled: true,
                    fillColor: AppColors.backgroundDark,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'CANCEL',
                style: TextStyle(color: AppColors.textGray),
              ),
            ),
            ElevatedButton(
              onPressed: selectedReason == null
                  ? null
                  : () async {
                      await socialProvider.reportPost(
                        postId,
                        selectedReason!,
                        detailsController.text.trim(),
                      );
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Report submitted. Thank you for helping keep our community safe.'),
                            backgroundColor: AppColors.primaryRed,
                            duration: Duration(seconds: 3),
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
              ),
              child: const Text(
                'SUBMIT',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGrid(BuildContext context, List<String> imageUrls) {
    if (imageUrls.isEmpty) return const SizedBox.shrink();

    if (imageUrls.length == 1) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ImageViewerScreen(
                imageUrls: imageUrls,
                initialIndex: 0,
              ),
            ),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            File(imageUrls[0]),
            width: double.infinity,
            height: 300,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 300,
                color: AppColors.backgroundCard,
                child: const Center(
                  child: Icon(Icons.broken_image, color: AppColors.textGray, size: 48),
                ),
              );
            },
          ),
        ),
      );
    }

    if (imageUrls.length == 2) {
      return Row(
        children: imageUrls.asMap().entries.map((entry) {
          final index = entry.key;
          final url = entry.value;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: index == 0 ? 4 : 0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ImageViewerScreen(
                        imageUrls: imageUrls,
                        initialIndex: index,
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(url),
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: AppColors.backgroundCard,
                        child: const Center(
                          child: Icon(Icons.broken_image, color: AppColors.textGray),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      );
    }

    // 3 or 4 images - grid layout
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: imageUrls.length > 4 ? 4 : imageUrls.length,
      itemBuilder: (gridContext, index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ImageViewerScreen(
                  imageUrls: imageUrls,
                  initialIndex: index,
                ),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.file(
                  File(imageUrls[index]),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.backgroundCard,
                      child: const Center(
                        child: Icon(Icons.broken_image, color: AppColors.textGray),
                      ),
                    );
                  },
                ),
                // Show "+X more" on last image if more than 4
                if (index == 3 && imageUrls.length > 4)
                  Container(
                    color: Colors.black54,
                    child: Center(
                      child: Text(
                        '+${imageUrls.length - 4}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showReportCommentDialog(
    BuildContext context,
    String commentId,
    SocialProvider socialProvider,
  ) {
    String? selectedReason;
    final detailsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppColors.backgroundCard,
          title: const Text(
            'Report Comment',
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Why are you reporting this comment?',
                  style: TextStyle(color: AppColors.textGray, fontSize: 14),
                ),
                const SizedBox(height: 12),
                ...[
                  'Spam',
                  'Harassment',
                  'Inappropriate Content',
                  'False Information',
                  'Other',
                ].map((reason) => RadioListTile<String>(
                      title: Text(
                        reason,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      value: reason,
                      groupValue: selectedReason,
                      activeColor: AppColors.primaryRed,
                      onChanged: (value) => setState(() => selectedReason = value),
                    )),
                const SizedBox(height: 12),
                TextField(
                  controller: detailsController,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Additional details (optional)',
                    hintStyle: const TextStyle(color: AppColors.textGray),
                    filled: true,
                    fillColor: AppColors.backgroundDark,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'CANCEL',
                style: TextStyle(color: AppColors.textGray),
              ),
            ),
            ElevatedButton(
              onPressed: selectedReason == null
                  ? null
                  : () async {
                      await socialProvider.reportComment(
                        commentId,
                        selectedReason!,
                        detailsController.text.trim(),
                      );
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Report submitted. Thank you.'),
                            backgroundColor: AppColors.primaryRed,
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
              ),
              child: const Text(
                'SUBMIT',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(timestamp);
    }
  }
}

// Shared Workouts Tab  
class _SharedWorkoutsTab extends StatefulWidget {
  const _SharedWorkoutsTab();

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
                            const Icon(Icons.fitness_center, size: 16, color: AppColors.primaryRed),
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
class _ChallengesTab extends StatelessWidget {
  const _ChallengesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final socialProvider = context.watch<SocialProvider>();
    final pendingChallenges = socialProvider.pendingChallenges;
    final activeChallenges = socialProvider.activeChallenges;

    if (pendingChallenges.isEmpty && activeChallenges.isEmpty) {
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
            const Text(
              'No active challenges',
              style: TextStyle(
                color: AppColors.textGray,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Create challenge dialog
              },
              icon: const Icon(Icons.add),
              label: const Text('CREATE CHALLENGE'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Pending Challenges Section
        if (pendingChallenges.isNotEmpty) ...[
          const Text(
            'PENDING CHALLENGES',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          ...pendingChallenges.map((challenge) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.emoji_events, color: Colors.orange, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${challenge.challengerName} challenged you!',
                              style: const TextStyle(
                                color: Colors.orange,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              challenge.description,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => socialProvider.acceptChallenge(challenge.id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: const Text('ACCEPT'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => socialProvider.declineChallenge(challenge.id),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                          ),
                          child: const Text(
                            'DECLINE',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 24),
        ],

        // Active Challenges Section
        if (activeChallenges.isNotEmpty) ...[
          const Text(
            'ACTIVE CHALLENGES',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          ...activeChallenges.map((challenge) {
            final isChallenger = challenge.challengerId == socialProvider.currentUserId;
            final myProgressMap = isChallenger ? challenge.challengerProgress : challenge.opponentProgress;
            final opponentProgressMap = isChallenger ? challenge.opponentProgress : challenge.challengerProgress;
            final opponentName = isChallenger ? challenge.opponentName : challenge.challengerName;
            
            final myProgress = myProgressMap['count'] ?? 0;
            final opponentProgress = opponentProgressMap['count'] ?? 0;
            final targetValue = challenge.targetValue['count'] ?? 0;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.backgroundCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primaryRed, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          challenge.description,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber, width: 1),
                        ),
                        child: Text(
                          '+${challenge.xpReward} XP',
                          style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'vs $opponentName',
                    style: const TextStyle(
                      color: AppColors.textGray,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'You',
                              style: TextStyle(
                                color: AppColors.textGray,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: targetValue > 0 ? myProgress / targetValue : 0,
                                backgroundColor: Colors.white.withOpacity(0.1),
                                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryRed),
                                minHeight: 8,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$myProgress / $targetValue',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              opponentName,
                              style: const TextStyle(
                                color: AppColors.textGray,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: targetValue > 0 ? opponentProgress / targetValue : 0,
                                backgroundColor: Colors.white.withOpacity(0.1),
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade400),
                                minHeight: 8,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$opponentProgress / $targetValue',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Expires: ${DateFormat('MMM d').format(challenge.expiresAt)}',
                        style: const TextStyle(
                          color: AppColors.textGray,
                          fontSize: 12,
                        ),
                      ),
                      if (challenge.winnerId != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: challenge.winnerId == socialProvider.currentUserId
                                ? Colors.green.withOpacity(0.2)
                                : Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            challenge.winnerId == socialProvider.currentUserId ? 'WON' : 'LOST',
                            style: TextStyle(
                              color: challenge.winnerId == socialProvider.currentUserId
                                  ? Colors.green
                                  : Colors.red,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }
}

// Leaderboard Tab
class _LeaderboardTab extends StatefulWidget {
  const _LeaderboardTab();

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

// New Leaderboard Tab using SocialProvider
class _NewLeaderboardTab extends StatefulWidget {
  const _NewLeaderboardTab({super.key});

  @override
  State<_NewLeaderboardTab> createState() => _NewLeaderboardTabState();
}

class _NewLeaderboardTabState extends State<_NewLeaderboardTab> {
  int _selectedTab = 0; // 0: XP, 1: Streaks, 2: Workouts

  @override
  Widget build(BuildContext context) {
    final socialProvider = context.watch<SocialProvider>();
    
    List<social.LeaderboardEntry> entries;
    IconData icon;
    Color color;
    String suffix;
    bool showLevel;
    
    switch (_selectedTab) {
      case 0: // XP
        entries = socialProvider.xpLeaderboard;
        icon = Icons.star;
        color = AppColors.primaryRed;
        suffix = 'XP';
        showLevel = true;
        break;
      case 1: // Streaks
        entries = socialProvider.streakLeaderboard;
        icon = Icons.local_fire_department;
        color = Colors.orange;
        suffix = 'days';
        showLevel = false;
        break;
      case 2: // Workouts
        entries = socialProvider.workoutLeaderboard;
        icon = Icons.fitness_center;
        color = Colors.blue;
        suffix = 'workouts';
        showLevel = false;
        break;
      default:
        entries = [];
        icon = Icons.star;
        color = AppColors.primaryRed;
        suffix = 'XP';
        showLevel = false;
    }

    return Column(
      children: [
        // Tab selector
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: _TabButton(
                  label: 'XP',
                  isSelected: _selectedTab == 0,
                  onTap: () => setState(() => _selectedTab = 0),
                  icon: Icons.star,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TabButton(
                  label: 'Streaks',
                  isSelected: _selectedTab == 1,
                  onTap: () => setState(() => _selectedTab = 1),
                  icon: Icons.local_fire_department,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TabButton(
                  label: 'Workouts',
                  isSelected: _selectedTab == 2,
                  onTap: () => setState(() => _selectedTab = 2),
                  icon: Icons.fitness_center,
                ),
              ),
            ],
          ),
        ),

        // Leaderboard list
        Expanded(
          child: entries.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.emoji_events_outlined,
                        size: 80,
                        color: AppColors.textGray.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No rankings yet',
                        style: TextStyle(
                          color: AppColors.textGray,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: entries.length > 5 ? 5 : entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    return _LeaderboardEntryCard(
                      entry: entry,
                      icon: icon,
                      color: color,
                      suffix: suffix,
                      showLevel: showLevel,
                    );
                  },
                ),
        ),

        // View full leaderboard button
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.push('/leaderboards'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'VIEW FULL LEADERBOARDS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData icon;

  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryRed
              : AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.textGray,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textGray,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardEntryCard extends StatelessWidget {
  final social.LeaderboardEntry entry;
  final IconData icon;
  final Color color;
  final String suffix;
  final bool showLevel;

  const _LeaderboardEntryCard({
    required this.entry,
    required this.icon,
    required this.color,
    required this.suffix,
    required this.showLevel,
  });

  Color _getRankColor() {
    switch (entry.rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey[400]!;
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return AppColors.textGray;
    }
  }

  Widget _getRankWidget() {
    if (entry.rank <= 3) {
      return Icon(
        Icons.emoji_events,
        color: _getRankColor(),
        size: 28,
      );
    }
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          '${entry.rank}',
          style: const TextStyle(
            color: AppColors.textGray,
            fontSize: 14,
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: entry.isCurrentUser
            ? color.withOpacity(0.15)
            : AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: entry.isCurrentUser ? color : Colors.transparent,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          _getRankWidget(),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withOpacity(0.2),
            child: Icon(Icons.person, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.userName,
                  style: TextStyle(
                    color: entry.isCurrentUser ? color : AppColors.textWhite,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (showLevel && entry.level != null)
                  Text(
                    'Lvl ${entry.level} • ${entry.title}',
                    style: const TextStyle(
                      color: AppColors.textGray,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                '${entry.value}',
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
