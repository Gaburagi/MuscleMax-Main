import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ai_workout_provider.dart';
import '../models/ai_models.dart';
import '../utils/app_colors.dart';
import 'package:intl/intl.dart';

class RecoveryDashboardScreen extends StatefulWidget {
  const RecoveryDashboardScreen({super.key});

  @override
  State<RecoveryDashboardScreen> createState() => _RecoveryDashboardScreenState();
}

class _RecoveryDashboardScreenState extends State<RecoveryDashboardScreen> {
  
  @override
  void initState() {
    super.initState();
    // Initialize with some demo data for testing
    Future.microtask(() {
      final provider = context.read<AIWorkoutProvider>();
      // Simulate recent workouts
      provider.updateMuscleRecovery('Chest', 5000, WorkoutIntensity.hard);
      provider.updateMuscleRecovery('Legs', 8000, WorkoutIntensity.extreme);
      provider.updateMuscleRecovery('Back', 6000, WorkoutIntensity.moderate);
    });
  }

  @override
  Widget build(BuildContext context) {
    final aiProvider = context.watch<AIWorkoutProvider>();
    final muscleRecovery = aiProvider.getMuscleGroupRecoveryStatus();
    
    // Calculate average readiness
    final avgFatigue = muscleRecovery.map((m) => m.fatigueLevel).reduce((a, b) => a + b) / muscleRecovery.length;
    final readinessScore = (100 - avgFatigue).clamp(0.0, 100.0).toDouble();
    
    // Demo data for overtraining check
    final recentWorkouts = [
      DateTime.now().subtract(const Duration(days: 1)),
      DateTime.now().subtract(const Duration(days: 2)),
      DateTime.now().subtract(const Duration(days: 3)),
      DateTime.now().subtract(const Duration(days: 4)),
    ];
    final recentRPE = [8.0, 8.5, 7.5, 9.0];
    
    final overtraining = aiProvider.checkOvertraining(recentWorkouts, recentRPE);
    final deloadRec = aiProvider.getDeloadRecommendation(4, overtraining);
    final restDayRec = aiProvider.getRestDayRecommendation(4, readinessScore);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        automaticallyImplyLeading: true,
        title: const Text(
          'RECOVERY & READINESS',
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
            // Overall Readiness Score
            _buildReadinessCard(readinessScore, restDayRec),
            const SizedBox(height: 20),
            
            // Muscle Recovery Heatmap
            _buildSectionHeader('Muscle Recovery Status', Icons.healing),
            const SizedBox(height: 12),
            _buildMuscleRecoveryGrid(muscleRecovery),
            const SizedBox(height: 24),
            
            // Overtraining Warning
            if (overtraining.riskLevel > 30) ...[
              _buildSectionHeader('Overtraining Alert', Icons.warning),
              const SizedBox(height: 12),
              _buildOvertrainingCard(overtraining),
              const SizedBox(height: 24),
            ],
            
            // Deload Recommendation
            if (deloadRec.shouldDeload) ...[
              _buildSectionHeader('Deload Week Recommended', Icons.schedule),
              const SizedBox(height: 12),
              _buildDeloadCard(deloadRec),
              const SizedBox(height: 24),
            ],
            
            // Rest Day Recommendation
            _buildSectionHeader('Rest Day Status', Icons.bed),
            const SizedBox(height: 12),
            _buildRestDayCard(restDayRec),
            
            const SizedBox(height: 100), // Space for bottom button
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pop(context),
        backgroundColor: AppColors.primaryRed,
        icon: const Icon(Icons.home),
        label: const Text(
          'BACK TO HOME',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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

  Widget _buildReadinessCard(double score, RestDayRecommendation restRec) {
    Color scoreColor;
    String status;
    IconData icon;
    
    if (score >= 70) {
      scoreColor = Colors.green;
      status = 'Ready to Train';
      icon = Icons.check_circle;
    } else if (score >= 50) {
      scoreColor = Colors.orange;
      status = 'Moderate Readiness';
      icon = Icons.warning;
    } else {
      scoreColor = Colors.red;
      status = 'Need Rest';
      icon = Icons.cancel;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scoreColor.withOpacity(0.2),
            AppColors.backgroundCard,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scoreColor.withOpacity(0.5), width: 2),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Overall Readiness',
                    style: TextStyle(
                      color: AppColors.textGray,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(icon, color: scoreColor, size: 28),
                      const SizedBox(width: 8),
                      Text(
                        status,
                        style: TextStyle(
                          color: scoreColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Large circular score
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: scoreColor, width: 4),
                  color: scoreColor.withOpacity(0.1),
                ),
                child: Center(
                  child: Text(
                    '${score.toInt()}',
                    style: TextStyle(
                      color: scoreColor,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (restRec.needsRestDay) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Rest day recommended: ${restRec.alternativeActivity}',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMuscleRecoveryGrid(List<MuscleGroupRecovery> recovery) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: recovery.length,
      itemBuilder: (context, index) {
        final muscle = recovery[index];
        return _buildMuscleCard(muscle);
      },
    );
  }

  Widget _buildMuscleCard(MuscleGroupRecovery muscle) {
    Color fatigueColor;
    if (muscle.fatigueLevel < 30) {
      fatigueColor = Colors.green;
    } else if (muscle.fatigueLevel < 60) {
      fatigueColor = Colors.orange;
    } else {
      fatigueColor = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: fatigueColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                muscle.muscleGroup,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: fatigueColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${muscle.fatigueLevel.toInt()}%',
                  style: TextStyle(
                    color: fatigueColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Fatigue bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: muscle.fatigueLevel / 100,
              backgroundColor: AppColors.textGray.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation(fatigueColor),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            muscle.recommendation,
            style: TextStyle(
              color: AppColors.textGray,
              fontSize: 11,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          if (muscle.hoursUntilRecovered > 0)
            Row(
              children: [
                Icon(Icons.access_time, size: 12, color: fatigueColor),
                const SizedBox(width: 4),
                Text(
                  '${muscle.hoursUntilRecovered}h until recovered',
                  style: TextStyle(
                    color: fatigueColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildOvertrainingCard(OvertrainingIndicators indicators) {
    Color riskColor;
    if (indicators.riskLevel < 30) {
      riskColor = Colors.green;
    } else if (indicators.riskLevel < 60) {
      riskColor = Colors.orange;
    } else {
      riskColor = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            riskColor.withOpacity(0.2),
            AppColors.backgroundCard,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: riskColor.withOpacity(0.5), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                indicators.isOvertraining ? 'Overtraining Detected!' : 'Elevated Risk',
                style: TextStyle(
                  color: riskColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: riskColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${indicators.riskLevel.toInt()}% Risk',
                  style: TextStyle(
                    color: riskColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (indicators.indicators.isNotEmpty) ...[
            Text(
              'Indicators:',
              style: TextStyle(
                color: AppColors.textGray,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...indicators.indicators.map((indicator) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(Icons.circle, size: 8, color: riskColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      indicator,
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 12),
          ],
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: riskColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb, color: riskColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    indicators.recommendation,
                    style: TextStyle(
                      color: riskColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeloadCard(DeloadRecommendation deload) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.purple.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.calendar_today, color: Colors.purple),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Deload Week',
                      style: TextStyle(
                        color: Colors.purple,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Start: ${DateFormat('MMM d').format(deload.recommendedStartDate)}',
                      style: TextStyle(
                        color: AppColors.textGray,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              deload.reason,
              style: TextStyle(
                color: Colors.purple,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDeloadStat(
                  'Volume',
                  '-${deload.volumeReduction.toInt()}%',
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDeloadStat(
                  'Intensity',
                  '-${deload.intensityReduction.toInt()}%',
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Guidelines:',
            style: TextStyle(
              color: AppColors.textGray,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...deload.guidelines.take(3).map((guideline) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check_circle, size: 16, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    guideline,
                    style: TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildDeloadStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: AppColors.textGray,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestDayCard(RestDayRecommendation restRec) {
    Color urgencyColor;
    IconData urgencyIcon;
    
    switch (restRec.urgency) {
      case 'critical':
        urgencyColor = Colors.red;
        urgencyIcon = Icons.error;
        break;
      case 'high':
        urgencyColor = Colors.orange;
        urgencyIcon = Icons.warning;
        break;
      case 'medium':
        urgencyColor = Colors.yellow;
        urgencyIcon = Icons.info;
        break;
      default:
        urgencyColor = Colors.green;
        urgencyIcon = Icons.check_circle;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: urgencyColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(urgencyIcon, color: urgencyColor, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restRec.needsRestDay ? 'Rest Day Needed' : 'No Rest Day Needed',
                      style: TextStyle(
                        color: urgencyColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${restRec.urgency.toUpperCase()} Priority',
                      style: TextStyle(
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
          ...restRec.reasons.map((reason) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(Icons.circle, size: 8, color: urgencyColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    reason,
                    style: TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          )),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: urgencyColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.fitness_center, color: urgencyColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Alternative: ${restRec.alternativeActivity}',
                    style: TextStyle(
                      color: urgencyColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
