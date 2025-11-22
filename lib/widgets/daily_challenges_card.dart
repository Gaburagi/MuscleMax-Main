import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/gamification_provider.dart';
import '../models/gamification_model.dart';
import '../utils/app_colors.dart';

class DailyChallengesCard extends StatelessWidget {
  const DailyChallengesCard({super.key});

  @override
  Widget build(BuildContext context) {
    final gamificationProvider = context.watch<GamificationProvider>();
    final challenges = gamificationProvider.dailyChallenges;
    
    if (challenges.isEmpty) {
      return const SizedBox.shrink();
    }

    final completedCount = challenges.where((c) => c.isCompleted).length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryRed.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.track_changes,
                      color: AppColors.primaryRed,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'DAILY CHALLENGES',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        '$completedCount / ${challenges.length} Completed',
                        style: const TextStyle(
                          color: AppColors.textGray,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (completedCount == challenges.length)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'All Done!',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          ...challenges.map((challenge) => _ChallengeItem(
            challenge: challenge,
            onProgressUpdate: (value) {
              gamificationProvider.updateChallengeProgress(
                challenge.id,
                value,
              );
            },
          )),
        ],
      ),
    );
  }
}

class _ChallengeItem extends StatelessWidget {
  final DailyChallenge challenge;
  final Function(int) onProgressUpdate;

  const _ChallengeItem({
    required this.challenge,
    required this.onProgressUpdate,
  });

  IconData _getIcon() {
    switch (challenge.type) {
      case 'workout':
        return Icons.fitness_center;
      case 'nutrition':
        return Icons.restaurant;
      case 'social':
        return Icons.share;
      default:
        return Icons.track_changes;
    }
  }

  Color _getColor() {
    if (challenge.isCompleted) {
      return Colors.green;
    }
    switch (challenge.type) {
      case 'workout':
        return AppColors.primaryRed;
      case 'nutrition':
        return Colors.orange;
      case 'social':
        return Colors.blue;
      default:
        return AppColors.primaryRed;
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = challenge.currentProgress / challenge.targetValue;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: challenge.isCompleted
              ? Colors.green.withOpacity(0.3)
              : Colors.transparent,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getIcon(),
                color: _getColor(),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      challenge.title,
                      style: TextStyle(
                        color: challenge.isCompleted
                            ? AppColors.textGray
                            : AppColors.textWhite,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        decoration: challenge.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    Text(
                      challenge.description,
                      style: const TextStyle(
                        color: AppColors.textGray,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: _getColor().withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.star,
                      size: 10,
                      color: _getColor(),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '+${challenge.xpReward}',
                      style: TextStyle(
                        color: _getColor(),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    backgroundColor: AppColors.textGray.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(_getColor()),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${challenge.currentProgress}/${challenge.targetValue}',
                style: const TextStyle(
                  color: AppColors.textGray,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
