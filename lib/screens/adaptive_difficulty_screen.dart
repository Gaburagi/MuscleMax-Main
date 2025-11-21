import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/ai_models.dart';
import '../providers/ai_workout_provider.dart';
import '../utils/app_colors.dart';
import '../utils/routes.dart';

class AdaptiveDifficultyScreen extends StatelessWidget {
  const AdaptiveDifficultyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final aiProvider = context.watch<AIWorkoutProvider>();
    final adjustments = aiProvider.difficultyAdjustments;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundCard,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
        ),
        title: const Text(
          'ADAPTIVE DIFFICULTY',
          style: TextStyle(
            fontFamily: 'Bebas Neue',
            fontSize: 24,
            letterSpacing: 2,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          if (adjustments.isEmpty)
            IconButton(
              icon: const Icon(Icons.science, color: Colors.white),
              tooltip: 'Load Demo Data',
              onPressed: () {
                context.read<AIWorkoutProvider>().generateDemoPerformanceData();
              },
            ),
        ],
      ),
      body: adjustments.isEmpty
          ? _buildEmptyView()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: adjustments.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildHeader();
                }
                
                final entry = adjustments.entries.elementAt(index - 1);
                return _AdjustmentCard(
                  exerciseId: entry.key,
                  adjustment: entry.value,
                );
              },
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C4DFF), Color(0xFF9C27B0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.trending_up, color: Colors.white, size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'AI-Powered Progress',
                  style: TextStyle(
                    fontFamily: 'Bebas Neue',
                    fontSize: 24,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Based on your recent performance, AI has analyzed your progress and generated personalized difficulty adjustments.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.insights_outlined,
              size: 80,
              color: AppColors.textGray.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            const Text(
              'No adjustments yet',
              style: TextStyle(
                color: AppColors.textWhite,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Complete a few workout sessions and AI will analyze your performance to suggest optimal difficulty adjustments',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textGray,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdjustmentCard extends StatelessWidget {
  final String exerciseId;
  final DifficultyAdjustment adjustment;

  const _AdjustmentCard({
    required this.exerciseId,
    required this.adjustment,
  });

  Color _getAdjustmentColor() {
    switch (adjustment.adjustmentType) {
      case 'increase_weight':
      case 'increase_reps':
        return const Color(0xFF4CAF50); // Green
      case 'decrease_weight':
      case 'decrease_reps':
        return AppColors.accentOrange;
      case 'maintain':
        return const Color(0xFF2196F3);
      default:
        return AppColors.textGray;
    }
  }

  IconData _getAdjustmentIcon() {
    switch (adjustment.adjustmentType) {
      case 'increase_weight':
      case 'increase_reps':
        return Icons.arrow_upward;
      case 'decrease_weight':
      case 'decrease_reps':
        return Icons.arrow_downward;
      case 'maintain':
        return Icons.check_circle;
      default:
        return Icons.help_outline;
    }
  }

  String _getAdjustmentLabel() {
    switch (adjustment.adjustmentType) {
      case 'increase_weight':
        return 'INCREASE WEIGHT';
      case 'increase_reps':
        return 'INCREASE REPS';
      case 'decrease_weight':
        return 'DECREASE WEIGHT';
      case 'decrease_reps':
        return 'DECREASE REPS';
      case 'maintain':
        return 'MAINTAIN';
      default:
        return 'ADJUST';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getAdjustmentColor();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getAdjustmentIcon(),
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      adjustment.exerciseName,
                      style: const TextStyle(
                        fontFamily: 'Bebas Neue',
                        fontSize: 20,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      _getAdjustmentLabel(),
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.psychology, color: color, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${(adjustment.confidenceScore * 100).toInt()}%',
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Adjustment Details
          if (adjustment.newWeight != null || adjustment.newReps != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (adjustment.newWeight != null) ...[
                    Column(
                      children: [
                        const Text(
                          'New Weight',
                          style: TextStyle(
                            color: AppColors.textGray,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${adjustment.newWeight!.toStringAsFixed(1)} lbs',
                          style: TextStyle(
                            color: color,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Bebas Neue',
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (adjustment.newReps != null) ...[
                    Column(
                      children: [
                        const Text(
                          'New Reps',
                          style: TextStyle(
                            color: AppColors.textGray,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${adjustment.newReps}',
                          style: TextStyle(
                            color: color,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Bebas Neue',
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // AI Reasoning
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: AppColors.textGray,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    adjustment.reasoning,
                    style: const TextStyle(
                      color: AppColors.textGray,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Adjustment applied to ${adjustment.exerciseName}'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: color),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: Icon(Icons.check, color: color),
                  label: Text(
                    'APPLY',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Adjustment dismissed'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.textGray),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.close, color: AppColors.textGray),
                  label: const Text(
                    'DISMISS',
                    style: TextStyle(
                      color: AppColors.textGray,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
