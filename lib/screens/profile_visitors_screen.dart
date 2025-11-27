import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../providers/profile_stats_provider.dart';
import '../models/profile_extensions.dart';

class ProfileVisitorsScreen extends StatelessWidget {
  const ProfileVisitorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final statsProvider = context.watch<ProfileStatsProvider>();
    final visitors = statsProvider.profileVisitors;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundCard,
        title: const Text(
          'PROFILE VISITORS',
          style: TextStyle(
            fontFamily: 'Bebas Neue',
            fontSize: 22,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
      ),
      body: visitors.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: visitors.length,
              itemBuilder: (context, index) {
                final visitor = visitors[index];
                return _VisitorCard(visitor: visitor);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.visibility_off,
            size: 80,
            color: Colors.white.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          const Text(
            'No visitors yet',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Share your profile to get visitors!',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _VisitorCard extends StatelessWidget {
  final ProfileVisitor visitor;

  const _VisitorCard({required this.visitor});

  @override
  Widget build(BuildContext context) {
    final timeAgo = _getTimeAgo(visitor.visitedAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primaryRed.withOpacity(0.2),
            backgroundImage: visitor.userAvatar != null
                ? NetworkImage(visitor.userAvatar!)
                : null,
            child: visitor.userAvatar == null
                ? Text(
                    visitor.userName[0].toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.primaryRed,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          // Name and time
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  visitor.userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeAgo,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Visit icon
          const Icon(
            Icons.visibility,
            color: Colors.white38,
            size: 20,
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
