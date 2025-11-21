import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/ai_workout_provider.dart';
import '../models/ai_models.dart';
import '../utils/app_colors.dart';
import 'package:intl/intl.dart';

class GoalPredictionScreen extends StatefulWidget {
  const GoalPredictionScreen({super.key});

  @override
  State<GoalPredictionScreen> createState() => _GoalPredictionScreenState();
}

class _GoalPredictionScreenState extends State<GoalPredictionScreen> {
  String _selectedGoalType = 'weight_loss';
  
  // Sample goal data - in real app, this would come from user settings
  final Map<String, Map<String, dynamic>> _goalData = {
    'weight_loss': {
      'current': 85.0,
      'target': 75.0,
      'unit': 'kg',
      'deadline': DateTime.now().add(const Duration(days: 90)),
      'historical': [
        GoalDataPoint(date: DateTime.now().subtract(const Duration(days: 42)), value: 89.0),
        GoalDataPoint(date: DateTime.now().subtract(const Duration(days: 35)), value: 88.5),
        GoalDataPoint(date: DateTime.now().subtract(const Duration(days: 28)), value: 88.0),
        GoalDataPoint(date: DateTime.now().subtract(const Duration(days: 21)), value: 87.2),
        GoalDataPoint(date: DateTime.now().subtract(const Duration(days: 14)), value: 86.5),
        GoalDataPoint(date: DateTime.now().subtract(const Duration(days: 7)), value: 85.8),
        GoalDataPoint(date: DateTime.now(), value: 85.0),
      ],
    },
    'muscle_gain': {
      'current': 70.0,
      'target': 75.0,
      'unit': 'kg',
      'deadline': DateTime.now().add(const Duration(days: 120)),
      'historical': [
        GoalDataPoint(date: DateTime.now().subtract(const Duration(days: 56)), value: 68.0),
        GoalDataPoint(date: DateTime.now().subtract(const Duration(days: 49)), value: 68.3),
        GoalDataPoint(date: DateTime.now().subtract(const Duration(days: 42)), value: 68.7),
        GoalDataPoint(date: DateTime.now().subtract(const Duration(days: 35)), value: 69.0),
        GoalDataPoint(date: DateTime.now().subtract(const Duration(days: 28)), value: 69.3),
        GoalDataPoint(date: DateTime.now().subtract(const Duration(days: 21)), value: 69.5),
        GoalDataPoint(date: DateTime.now().subtract(const Duration(days: 14)), value: 69.7),
        GoalDataPoint(date: DateTime.now().subtract(const Duration(days: 7)), value: 69.9),
        GoalDataPoint(date: DateTime.now(), value: 70.0),
      ],
    },
    'strength_increase': {
      'current': 100.0,
      'target': 140.0,
      'unit': 'kg',
      'deadline': DateTime.now().add(const Duration(days: 180)),
      'historical': [
        GoalDataPoint(date: DateTime.now().subtract(const Duration(days: 63)), value: 90.0),
        GoalDataPoint(date: DateTime.now().subtract(const Duration(days: 56)), value: 92.0),
        GoalDataPoint(date: DateTime.now().subtract(const Duration(days: 49)), value: 93.5),
        GoalDataPoint(date: DateTime.now().subtract(const Duration(days: 42)), value: 95.0),
        GoalDataPoint(date: DateTime.now().subtract(const Duration(days: 35)), value: 96.0),
        GoalDataPoint(date: DateTime.now().subtract(const Duration(days: 28)), value: 97.5),
        GoalDataPoint(date: DateTime.now().subtract(const Duration(days: 21)), value: 98.5),
        GoalDataPoint(date: DateTime.now().subtract(const Duration(days: 14)), value: 99.0),
        GoalDataPoint(date: DateTime.now().subtract(const Duration(days: 7)), value: 99.5),
        GoalDataPoint(date: DateTime.now(), value: 100.0),
      ],
    },
  };

  @override
  Widget build(BuildContext context) {
    final aiProvider = context.watch<AIWorkoutProvider>();
    final goalInfo = _goalData[_selectedGoalType]!;
    
    final prediction = aiProvider.predictGoalCompletion(
      goalType: _selectedGoalType,
      currentValue: goalInfo['current'],
      targetValue: goalInfo['target'],
      historicalData: goalInfo['historical'],
      goalDeadline: goalInfo['deadline'],
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'GOAL PREDICTIONS',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Goal Type Selector
            _buildGoalTypeSelector(),
            const SizedBox(height: 20),
            
            // Main Prediction Card
            _buildPredictionCard(prediction, goalInfo),
            const SizedBox(height: 20),
            
            // Progress Chart (simplified visualization)
            _buildSectionHeader('Progress Forecast', Icons.show_chart),
            const SizedBox(height: 12),
            _buildProgressChart(prediction, goalInfo),
            const SizedBox(height: 24),
            
            // Trajectory Status
            _buildSectionHeader('Current Trajectory', Icons.trending_up),
            const SizedBox(height: 12),
            _buildTrajectoryCard(prediction),
            const SizedBox(height: 24),
            
            // AI Recommendations
            _buildSectionHeader('AI Recommendations', Icons.lightbulb),
            const SizedBox(height: 12),
            _buildRecommendationsCard(prediction),
            
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryRed, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildGoalTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildGoalTypeChip('weight_loss', 'Weight Loss', Icons.trending_down),
          ),
          Expanded(
            child: _buildGoalTypeChip('muscle_gain', 'Muscle Gain', Icons.fitness_center),
          ),
          Expanded(
            child: _buildGoalTypeChip('strength_increase', 'Strength', Icons.flash_on),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalTypeChip(String value, String label, IconData icon) {
    final isSelected = _selectedGoalType == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedGoalType = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryRed : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.textGray,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textGray,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionCard(GoalPrediction prediction, Map<String, dynamic> goalInfo) {
    Color trajectoryColor;
    IconData trajectoryIcon;
    String trajectoryText;
    
    if (prediction.trajectory == 'ahead') {
      trajectoryColor = Colors.green;
      trajectoryIcon = Icons.rocket_launch;
      trajectoryText = 'Ahead of Schedule';
    } else if (prediction.trajectory == 'on_track') {
      trajectoryColor = Colors.blue;
      trajectoryIcon = Icons.check_circle;
      trajectoryText = 'On Track';
    } else {
      trajectoryColor = Colors.orange;
      trajectoryIcon = Icons.warning;
      trajectoryText = 'Behind Schedule';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            trajectoryColor.withOpacity(0.2),
            AppColors.backgroundCard,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: trajectoryColor.withOpacity(0.5), width: 2),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Goal Prediction',
                    style: TextStyle(
                      color: AppColors.textGray,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(trajectoryIcon, color: trajectoryColor, size: 28),
                      const SizedBox(width: 8),
                      Text(
                        trajectoryText,
                        style: TextStyle(
                          color: trajectoryColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Confidence badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: trajectoryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      '${(prediction.confidenceLevel * 100).toInt()}%',
                      style: TextStyle(
                        color: trajectoryColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Confidence',
                      style: TextStyle(
                        color: AppColors.textGray,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Current vs Target
          Row(
            children: [
              Expanded(
                child: _buildStatColumn(
                  'Current',
                  '${prediction.currentValue.toStringAsFixed(1)} ${goalInfo['unit']}',
                  Colors.blue,
                ),
              ),
              const Icon(Icons.arrow_forward, color: AppColors.textGray),
              Expanded(
                child: _buildStatColumn(
                  'Target',
                  '${prediction.targetValue.toStringAsFixed(1)} ${goalInfo['unit']}',
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: AppColors.textGray.withOpacity(0.2)),
          const SizedBox(height: 16),
          // Estimated completion
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Estimated Completion',
                    style: TextStyle(
                      color: AppColors.textGray,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM d, yyyy').format(prediction.estimatedCompletionDate),
                    style: TextStyle(
                      color: trajectoryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Days to Goal',
                    style: TextStyle(
                      color: AppColors.textGray,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${prediction.daysToGoal}',
                    style: TextStyle(
                      color: trajectoryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textGray,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressChart(GoalPrediction prediction, Map<String, dynamic> goalInfo) {
    // Simplified chart representation
    final allPoints = [...prediction.historicalData, ...prediction.projectedData];
    if (allPoints.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text(
            'Not enough data for visualization',
            style: TextStyle(color: AppColors.textGray),
          ),
        ),
      );
    }

    final minValue = allPoints.map((p) => p.value).reduce((a, b) => a < b ? a : b) - 2;
    final maxValue = allPoints.map((p) => p.value).reduce((a, b) => a > b ? a : b) + 2;
    
    return Container(
      height: 200,
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
              _buildChartLegend('Historical', Colors.blue, false),
              _buildChartLegend('Projected', Colors.green, true),
              _buildChartLegend('Target', Colors.red, false),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: CustomPaint(
              size: Size.infinite,
              painter: _ProgressChartPainter(
                historicalData: prediction.historicalData,
                projectedData: prediction.projectedData,
                targetValue: prediction.targetValue,
                minValue: minValue,
                maxValue: maxValue,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Past',
                style: TextStyle(color: AppColors.textGray, fontSize: 10),
              ),
              Text(
                'Now',
                style: TextStyle(color: AppColors.textGray, fontSize: 10),
              ),
              Text(
                'Future',
                style: TextStyle(color: AppColors.textGray, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartLegend(String label, Color color, bool isDashed) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        if (isDashed)
          Container(
            width: 4,
            height: 3,
            color: Colors.transparent,
          ),
        if (isDashed)
          Container(
            width: 8,
            height: 3,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textGray,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildTrajectoryCard(GoalPrediction prediction) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTrajectoryMetric(
                'Weekly Progress',
                '${prediction.weeklyProgressRate >= 0 ? '+' : ''}${prediction.weeklyProgressRate.toStringAsFixed(2)}',
                Icons.speed,
                Colors.blue,
              ),
              Container(width: 1, height: 40, color: AppColors.textGray.withOpacity(0.2)),
              _buildTrajectoryMetric(
                'Confidence',
                '${(prediction.confidenceLevel * 100).toInt()}%',
                Icons.analytics,
                Colors.purple,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrajectoryMetric(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textGray,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationsCard(GoalPrediction prediction) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryRed.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: prediction.recommendations.map((rec) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.lightbulb,
                  color: AppColors.primaryRed,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    rec,
                    style: const TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// Custom painter for the progress chart
class _ProgressChartPainter extends CustomPainter {
  final List<GoalDataPoint> historicalData;
  final List<GoalDataPoint> projectedData;
  final double targetValue;
  final double minValue;
  final double maxValue;

  _ProgressChartPainter({
    required this.historicalData,
    required this.projectedData,
    required this.targetValue,
    required this.minValue,
    required this.maxValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final allPoints = [...historicalData, ...projectedData];
    if (allPoints.isEmpty) return;

    // Draw target line
    final targetY = size.height - ((targetValue - minValue) / (maxValue - minValue)) * size.height;
    final targetPaint = Paint()
      ..color = Colors.red.withOpacity(0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(0, targetY),
      Offset(size.width, targetY),
      targetPaint,
    );

    // Draw historical line
    if (historicalData.length > 1) {
      final historicalPaint = Paint()
        ..color = Colors.blue
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final historicalPath = Path();
      for (int i = 0; i < historicalData.length; i++) {
        final x = (i / (allPoints.length - 1)) * size.width;
        final y = size.height - ((historicalData[i].value - minValue) / (maxValue - minValue)) * size.height;
        if (i == 0) {
          historicalPath.moveTo(x, y);
        } else {
          historicalPath.lineTo(x, y);
        }
      }
      canvas.drawPath(historicalPath, historicalPaint);
    }

    // Draw projected line (dashed)
    if (projectedData.isNotEmpty) {
      final projectedPaint = Paint()
        ..color = Colors.green
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final startIdx = historicalData.length - 1;
      for (int i = 0; i < projectedData.length - 1; i++) {
        final x1 = ((startIdx + i) / (allPoints.length - 1)) * size.width;
        final y1 = size.height - ((projectedData[i].value - minValue) / (maxValue - minValue)) * size.height;
        final x2 = ((startIdx + i + 1) / (allPoints.length - 1)) * size.width;
        final y2 = size.height - ((projectedData[i + 1].value - minValue) / (maxValue - minValue)) * size.height;
        
        // Draw dashed line
        const dashWidth = 8.0;
        const dashSpace = 4.0;
        double distance = 0;
        final totalDistance = (Offset(x2, y2) - Offset(x1, y1)).distance;
        
        while (distance < totalDistance) {
          final t1 = distance / totalDistance;
          final t2 = ((distance + dashWidth) / totalDistance).clamp(0.0, 1.0);
          canvas.drawLine(
            Offset(x1 + (x2 - x1) * t1, y1 + (y2 - y1) * t1),
            Offset(x1 + (x2 - x1) * t2, y1 + (y2 - y1) * t2),
            projectedPaint,
          );
          distance += dashWidth + dashSpace;
        }
      }
    }

    // Draw data points
    final pointPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (int i = 0; i < allPoints.length; i++) {
      final x = (i / (allPoints.length - 1)) * size.width;
      final y = size.height - ((allPoints[i].value - minValue) / (maxValue - minValue)) * size.height;
      canvas.drawCircle(Offset(x, y), 4, pointPaint);
      
      final borderPaint = Paint()
        ..color = allPoints[i].isProjected ? Colors.green : Colors.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(Offset(x, y), 4, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
