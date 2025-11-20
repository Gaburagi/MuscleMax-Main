import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ai_models.dart';
import '../providers/ai_workout_provider.dart';
import '../providers/custom_workout_provider.dart';
import '../providers/user_provider.dart';
import '../utils/app_colors.dart';
import 'quick_workout_generator_screen.dart';
import 'active_ai_workout_screen.dart';

class WorkoutRecommendationsScreen extends StatefulWidget {
  const WorkoutRecommendationsScreen({super.key});

  @override
  State<WorkoutRecommendationsScreen> createState() => _WorkoutRecommendationsScreenState();
}

class _WorkoutRecommendationsScreenState extends State<WorkoutRecommendationsScreen> {
  bool _isLoading = true;
  List<WorkoutRecommendation> _recommendations = [];

  @override
  void initState() {
    super.initState();
    _generateRecommendations();
  }

  Future<void> _generateRecommendations() async {
    setState(() => _isLoading = true);
    
    final aiProvider = context.read<AIWorkoutProvider>();
    final customWorkoutProvider = context.read<CustomWorkoutProvider>();
    final userProvider = context.read<UserProvider>();
    
    // Simulate AI processing
    await Future.delayed(const Duration(seconds: 1));
    
    // Get workout history data
    final recentWorkoutCount = customWorkoutProvider.completedWorkouts.length;
    final recentMuscleGroups = _getRecentMuscleGroups(customWorkoutProvider);
    final lastWorkoutDate = customWorkoutProvider.completedWorkouts.isNotEmpty
        ? customWorkoutProvider.completedWorkouts.last.completedAt
        : null;
    
    // Generate recommendations
    final recommendations = aiProvider.generateRecommendations(
      recentWorkoutCount: recentWorkoutCount,
      recentMuscleGroups: recentMuscleGroups,
      lastWorkoutDate: lastWorkoutDate,
      userGoal: userProvider.user?.fitnessGoal ?? 'general_fitness',
      fitnessLevel: 5, // Could be enhanced with actual fitness level
      availableTime: 60,
    );
    
    setState(() {
      _recommendations = recommendations;
      _isLoading = false;
    });
  }

  List<String> _getRecentMuscleGroups(CustomWorkoutProvider provider) {
    final recentWorkouts = provider.completedWorkouts.take(5).toList();
    final muscleGroups = <String>{};
    
    // Extract muscle groups from recent workouts
    // Note: WorkoutCompletionRecord doesn't have exercises field
    // This is a simplified version that returns common muscle groups
    if (recentWorkouts.isNotEmpty) {
      muscleGroups.addAll(['Chest', 'Back', 'Legs']); // Placeholder
    }
    
    return muscleGroups.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundCard,
        title: const Text(
          'AI RECOMMENDATIONS',
          style: TextStyle(
            fontFamily: 'Bebas Neue',
            fontSize: 24,
            letterSpacing: 2,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _generateRecommendations,
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingView()
          : _recommendations.isEmpty
              ? _buildEmptyView()
              : _buildRecommendationsList(),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryRed),
          ),
          const SizedBox(height: 24),
          Text(
            'Analyzing your workout history...',
            style: TextStyle(
              color: AppColors.textGray,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'AI is generating personalized recommendations',
            style: TextStyle(
              color: AppColors.textGray.withOpacity(0.7),
              fontSize: 14,
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
              Icons.fitness_center_outlined,
              size: 80,
              color: AppColors.textGray.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Complete a few workouts first',
              style: TextStyle(
                color: AppColors.textWhite,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'AI needs some workout data to generate personalized recommendations',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textGray,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QuickWorkoutGeneratorScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              icon: const Icon(Icons.psychology),
              label: const Text('GENERATE QUICK WORKOUT'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _recommendations.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildHeader();
        }
        
        final recommendation = _recommendations[index - 1];
        return _RecommendationCard(
          recommendation: recommendation,
          rank: index,
        );
      },
    );
  }

  Widget _buildHeader() {
    final readiness = context.watch<AIWorkoutProvider>().currentReadiness;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryRed, Color(0xFFD32F2F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Personalized For You',
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
          const SizedBox(height: 16),
          if (readiness != null) ...[
            Text(
              'Readiness Score: ${readiness.overallScore.toInt()}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              readiness.recommendation,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
              ),
            ),
          ] else ...[
            Text(
              'Based on your workout history, goals, and recovery status',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final WorkoutRecommendation recommendation;
  final int rank;

  const _RecommendationCard({
    required this.recommendation,
    required this.rank,
  });

  Color _getIntensityColor() {
    switch (recommendation.intensity) {
      case WorkoutIntensity.light:
        return const Color(0xFF4CAF50);
      case WorkoutIntensity.moderate:
        return AppColors.accentOrange;
      case WorkoutIntensity.hard:
        return AppColors.primaryRed;
      case WorkoutIntensity.extreme:
        return const Color(0xFF9C27B0);
    }
  }

  IconData _getIntensityIcon() {
    switch (recommendation.intensity) {
      case WorkoutIntensity.light:
        return Icons.spa;
      case WorkoutIntensity.moderate:
        return Icons.trending_up;
      case WorkoutIntensity.hard:
        return Icons.whatshot;
      case WorkoutIntensity.extreme:
        return Icons.flash_on;
    }
  }

  String _getIntensityLabel() {
    return recommendation.intensity.name.toUpperCase();
  }

  void _startWorkoutFromRecommendation(BuildContext context) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Generating your workout...'),
              ],
            ),
          ),
        ),
      ),
    );

    // Get AI provider
    final aiProvider = context.read<AIWorkoutProvider>();

    // Generate workout based on recommendation parameters
    final workoutRequest = WorkoutGenerationRequest(
      availableMinutes: recommendation.estimatedDuration,
      intensity: recommendation.intensity,
      targetMuscleGroups: recommendation.muscleGroups,
      availableEquipment: [], // Use any equipment
      goal: _getGoalFromRecommendation(),
      fitnessLevel: 5,
    );

    final generatedWorkout = await aiProvider.generateQuickWorkout(workoutRequest);

    // Close loading dialog
    if (context.mounted) {
      Navigator.pop(context);
      
      // Navigate to active workout screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ActiveAIWorkoutScreen(workout: generatedWorkout),
        ),
      );
    }
  }

  String _getGoalFromRecommendation() {
    // Extract goal from workout name or reasoning
    final name = recommendation.workoutName.toLowerCase();
    if (name.contains('strength')) return 'strength';
    if (name.contains('muscle') || name.contains('hypertrophy')) return 'hypertrophy';
    if (name.contains('endurance') || name.contains('cardio')) return 'endurance';
    if (name.contains('weight loss') || name.contains('fat')) return 'weight_loss';
    return 'general_fitness';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: rank == 1 
              ? AppColors.primaryRed.withOpacity(0.5)
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _startWorkoutFromRecommendation(context),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    if (rank == 1) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryRed,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'TOP PICK',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(
                        recommendation.workoutName,
                        style: const TextStyle(
                          fontFamily: 'Bebas Neue',
                          fontSize: 20,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getIntensityColor().withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _getIntensityColor(), width: 1.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getIntensityIcon(),
                            color: _getIntensityColor(),
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getIntensityLabel(),
                            style: TextStyle(
                              color: _getIntensityColor(),
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
                
                // Stats Row
                Row(
                  children: [
                    _StatChip(
                      icon: Icons.timer_outlined,
                      label: '${recommendation.estimatedDuration} min',
                    ),
                    const SizedBox(width: 8),
                    _StatChip(
                      icon: Icons.local_fire_department_outlined,
                      label: '~${recommendation.estimatedCalories} cal',
                    ),
                    const SizedBox(width: 8),
                    _StatChip(
                      icon: Icons.fitness_center,
                      label: '${recommendation.exerciseCount} exercises',
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Muscle Groups
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: recommendation.muscleGroups.map((muscle) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryRed.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        muscle,
                        style: TextStyle(
                          color: AppColors.textWhite,
                          fontSize: 11,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 16),
                
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
                    children: [
                      Icon(
                        Icons.psychology,
                        color: AppColors.textGray,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          recommendation.reasoning,
                          style: TextStyle(
                            color: AppColors.textGray,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Benefits
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: recommendation.benefits.map((benefit) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: const Color(0xFF4CAF50),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              benefit,
                              style: TextStyle(
                                color: AppColors.textWhite,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 16),
                
                // Action Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _startWorkoutFromRecommendation(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryRed,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'START THIS WORKOUT',
                      style: TextStyle(
                        fontFamily: 'Bebas Neue',
                        fontSize: 16,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.textGray, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: AppColors.textGray,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
