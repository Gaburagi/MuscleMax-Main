import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/social_provider.dart';
import '../models/social_model.dart';
import '../utils/app_colors.dart';

class WorkoutFeedScreen extends StatefulWidget {
  const WorkoutFeedScreen({super.key});

  @override
  State<WorkoutFeedScreen> createState() => _WorkoutFeedScreenState();
}

class _WorkoutFeedScreenState extends State<WorkoutFeedScreen> {
  final TextEditingController _commentController = TextEditingController();
  String? _commentingOnPostId;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socialProvider = context.watch<SocialProvider>();
    final feed = socialProvider.workoutFeed;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        title: const Text(
          'WORKOUT FEED',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
      ),
      body: feed.isEmpty
          ? Center(
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
            )
          : RefreshIndicator(
              onRefresh: () async {
                await socialProvider.loadData();
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: feed.length,
                itemBuilder: (context, index) {
                  return _WorkoutPostCard(
                    post: feed[index],
                    onLike: () => socialProvider.likePost(feed[index].id),
                    onComment: () {
                      setState(() {
                        _commentingOnPostId = feed[index].id;
                      });
                      _showCommentDialog(feed[index]);
                    },
                  );
                },
              ),
            ),
    );
  }

  void _showCommentDialog(WorkoutPost post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        title: const Text(
          'Add Comment',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: _commentController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Write a comment...',
            hintStyle: const TextStyle(color: AppColors.textGray),
            filled: true,
            fillColor: AppColors.backgroundDark,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
          maxLines: 3,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              _commentController.clear();
              Navigator.pop(context);
            },
            child: const Text(
              'CANCEL',
              style: TextStyle(color: AppColors.textGray),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_commentController.text.trim().isNotEmpty) {
                await context.read<SocialProvider>().commentOnPost(
                      post.id,
                      _commentController.text.trim(),
                    );
                _commentController.clear();
                if (mounted) {
                  Navigator.pop(context);
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
            ),
            child: const Text(
              'POST',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkoutPostCard extends StatelessWidget {
  final WorkoutPost post;
  final VoidCallback onLike;
  final VoidCallback onComment;

  const _WorkoutPostCard({
    required this.post,
    required this.onLike,
    required this.onComment,
  });

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

  @override
  Widget build(BuildContext context) {
    final socialProvider = context.read<SocialProvider>();
    final isLiked = post.likedBy.contains(socialProvider.currentUserId);

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
          // Header: User info and timestamp
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
            ],
          ),

          const SizedBox(height: 16),

          // Workout details
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

          // Stats row
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _StatChip(
                icon: Icons.timer,
                label: '${post.durationMinutes} min',
                color: Colors.blue,
              ),
              _StatChip(
                icon: Icons.fitness_center,
                label: '${post.exercisesCompleted} exercises',
                color: Colors.orange,
              ),
              if (post.caloriesBurned != null)
                _StatChip(
                  icon: Icons.local_fire_department,
                  label: '${post.caloriesBurned} kcal',
                  color: Colors.red,
                ),
              _StatChip(
                icon: Icons.star,
                label: '+${post.xpGained} XP',
                color: Colors.amber,
              ),
            ],
          ),

          // Personal records
          if (post.personalRecords.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
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
                      Icon(Icons.emoji_events, color: Colors.purple, size: 18),
                      SizedBox(width: 6),
                      Text(
                        'New Personal Record!',
                        style: TextStyle(
                          color: Colors.purple,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ...post.personalRecords.map((pr) => Text(
                        pr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      )),
                ],
              ),
            ),
          ],

          // Achievements
          if (post.achievements.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: post.achievements.map((achievement) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.emoji_events, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        achievement,
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],

          // User note
          if (post.note != null && post.note!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              post.note!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],

          const SizedBox(height: 16),
          const Divider(color: Colors.grey, height: 1),
          const SizedBox(height: 12),

          // Action buttons: Like and Comment
          Row(
            children: [
              _ActionButton(
                icon: isLiked ? Icons.favorite : Icons.favorite_border,
                label: '${post.likeCount}',
                color: isLiked ? Colors.red : AppColors.textGray,
                onTap: onLike,
              ),
              const SizedBox(width: 24),
              _ActionButton(
                icon: Icons.comment_outlined,
                label: '${post.commentCount}',
                color: AppColors.textGray,
                onTap: onComment,
              ),
              const Spacer(),
              _ActionButton(
                icon: Icons.share_outlined,
                label: 'Share',
                color: AppColors.textGray,
                onTap: () {
                  // Share functionality
                },
              ),
            ],
          ),

          // Comments section
          if (post.comments.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(color: Colors.grey, height: 1),
            const SizedBox(height: 12),
            ...post.comments.take(2).map((comment) => _CommentTile(comment: comment)),
            if (post.comments.length > 2)
              TextButton(
                onPressed: () {
                  // Show all comments dialog
                },
                child: Text(
                  'View all ${post.comments.length} comments',
                  style: const TextStyle(color: AppColors.textGray, fontSize: 12),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final WorkoutComment comment;

  const _CommentTile({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
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
          const SizedBox(width: 10),
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
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTimestamp(comment.timestamp),
                      style: const TextStyle(
                        color: AppColors.textGray,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.text,
                  style: const TextStyle(
                    color: AppColors.textGray,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inDays}d';
    }
  }
}
