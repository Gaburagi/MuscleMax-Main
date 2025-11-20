// import 'custom_workout_models.dart'; // Not needed

// AI Workout Generation Request
class WorkoutGenerationRequest {
  final int availableMinutes; // 30-120 mins
  final WorkoutIntensity intensity;
  final List<String> targetMuscleGroups; // empty = full body
  final List<String> availableEquipment;
  final String goal; // strength, hypertrophy, endurance, weight_loss, general_fitness
  final int? fitnessLevel; // 1-10 scale
  final List<String>? recentWorkouts; // IDs of recent workouts for variety

  WorkoutGenerationRequest({
    required this.availableMinutes,
    required this.intensity,
    this.targetMuscleGroups = const [],
    this.availableEquipment = const [],
    required this.goal,
    this.fitnessLevel,
    this.recentWorkouts,
  });

  Map<String, dynamic> toJson() => {
    'availableMinutes': availableMinutes,
    'intensity': intensity.name,
    'targetMuscleGroups': targetMuscleGroups,
    'availableEquipment': availableEquipment,
    'goal': goal,
    'fitnessLevel': fitnessLevel,
    'recentWorkouts': recentWorkouts,
  };
}

enum WorkoutIntensity {
  light,      // RPE 4-5, recovery focus
  moderate,   // RPE 6-7, balanced
  hard,       // RPE 8-9, challenging
  extreme,    // RPE 9-10, max effort
}

// AI Workout Recommendation
class WorkoutRecommendation {
  final String workoutId;
  final String workoutName;
  final int estimatedDuration;
  final WorkoutIntensity intensity;
  final List<String> muscleGroups;
  final int estimatedCalories;
  final double confidenceScore; // 0-1, how well it matches user needs
  final String reasoning; // Why this workout was recommended
  final List<String> benefits;
  final int exerciseCount;

  WorkoutRecommendation({
    required this.workoutId,
    required this.workoutName,
    required this.estimatedDuration,
    required this.intensity,
    required this.muscleGroups,
    required this.estimatedCalories,
    required this.confidenceScore,
    required this.reasoning,
    required this.benefits,
    required this.exerciseCount,
  });
}

// AI-Generated Workout Plan
class AIGeneratedWorkout {
  final String id;
  final String name;
  final int totalDuration;
  final WorkoutIntensity intensity;
  final List<AIExerciseBlock> exercises;
  final String goal;
  final int estimatedCalories;
  final List<String> muscleGroupsTargeted;
  final DateTime generatedAt;
  final String aiReasoning;

  AIGeneratedWorkout({
    required this.id,
    required this.name,
    required this.totalDuration,
    required this.intensity,
    required this.exercises,
    required this.goal,
    required this.estimatedCalories,
    required this.muscleGroupsTargeted,
    required this.generatedAt,
    required this.aiReasoning,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'totalDuration': totalDuration,
    'intensity': intensity.name,
    'exercises': exercises.map((e) => e.toJson()).toList(),
    'goal': goal,
    'estimatedCalories': estimatedCalories,
    'muscleGroupsTargeted': muscleGroupsTargeted,
    'generatedAt': generatedAt.toIso8601String(),
    'aiReasoning': aiReasoning,
  };

  factory AIGeneratedWorkout.fromJson(Map<String, dynamic> json) {
    return AIGeneratedWorkout(
      id: json['id'],
      name: json['name'],
      totalDuration: json['totalDuration'],
      intensity: WorkoutIntensity.values.firstWhere((e) => e.name == json['intensity']),
      exercises: (json['exercises'] as List)
          .map((e) => AIExerciseBlock.fromJson(e))
          .toList(),
      goal: json['goal'],
      estimatedCalories: json['estimatedCalories'],
      muscleGroupsTargeted: List<String>.from(json['muscleGroupsTargeted']),
      generatedAt: DateTime.parse(json['generatedAt']),
      aiReasoning: json['aiReasoning'],
    );
  }
}

// AI Exercise Block (similar to CustomExercise but with AI metadata)
class AIExerciseBlock {
  final String exerciseName;
  final String muscleGroup;
  final int sets;
  final int reps;
  final int restSeconds;
  final String? notes;
  final int estimatedDuration; // seconds
  final String difficulty; // beginner, intermediate, advanced
  final List<String>? equipment;

  AIExerciseBlock({
    required this.exerciseName,
    required this.muscleGroup,
    required this.sets,
    required this.reps,
    required this.restSeconds,
    this.notes,
    required this.estimatedDuration,
    required this.difficulty,
    this.equipment,
  });

  Map<String, dynamic> toJson() => {
    'exerciseName': exerciseName,
    'muscleGroup': muscleGroup,
    'sets': sets,
    'reps': reps,
    'restSeconds': restSeconds,
    'notes': notes,
    'estimatedDuration': estimatedDuration,
    'difficulty': difficulty,
    'equipment': equipment,
  };

  factory AIExerciseBlock.fromJson(Map<String, dynamic> json) {
    return AIExerciseBlock(
      exerciseName: json['exerciseName'],
      muscleGroup: json['muscleGroup'],
      sets: json['sets'],
      reps: json['reps'],
      restSeconds: json['restSeconds'],
      notes: json['notes'],
      estimatedDuration: json['estimatedDuration'],
      difficulty: json['difficulty'],
      equipment: json['equipment'] != null ? List<String>.from(json['equipment']) : null,
    );
  }
}

// Muscle Recovery Status
class MuscleRecoveryStatus {
  final String muscleGroup;
  final double fatigueLevel; // 0-1, 0 = fully recovered, 1 = highly fatigued
  final DateTime lastWorked;
  final int hoursSinceLastWorkout;
  final bool readyToTrain;
  final String recommendation;

  MuscleRecoveryStatus({
    required this.muscleGroup,
    required this.fatigueLevel,
    required this.lastWorked,
    required this.hoursSinceLastWorkout,
    required this.readyToTrain,
    required this.recommendation,
  });
}

// Workout Performance Analysis
class WorkoutPerformanceAnalysis {
  final String workoutId;
  final DateTime completedAt;
  final double performanceScore; // 0-100
  final int volumeLoad; // total weight x reps
  final double avgRestTime;
  final int totalReps;
  final double avgRPE;
  final List<String> strengths;
  final List<String> improvements;
  final String nextWorkoutSuggestion;

  WorkoutPerformanceAnalysis({
    required this.workoutId,
    required this.completedAt,
    required this.performanceScore,
    required this.volumeLoad,
    required this.avgRestTime,
    required this.totalReps,
    required this.avgRPE,
    required this.strengths,
    required this.improvements,
    required this.nextWorkoutSuggestion,
  });
}

// User Readiness Score
class ReadinessScore {
  final double overallScore; // 0-100
  final double muscleRecovery; // 0-100
  final double motivationLevel; // 0-100
  final double recentConsistency; // 0-100
  final DateTime calculatedAt;
  final String recommendation;
  final List<String> factors;

  ReadinessScore({
    required this.overallScore,
    required this.muscleRecovery,
    required this.motivationLevel,
    required this.recentConsistency,
    required this.calculatedAt,
    required this.recommendation,
    required this.factors,
  });
}

// Adaptive Difficulty Adjustment
class DifficultyAdjustment {
  final String exerciseName;
  final String adjustmentType; // increase_weight, increase_reps, decrease_weight, decrease_reps, maintain
  final double? newWeight;
  final int? newReps;
  final String reasoning;
  final double confidenceScore; // 0-1

  DifficultyAdjustment({
    required this.exerciseName,
    required this.adjustmentType,
    this.newWeight,
    this.newReps,
    required this.reasoning,
    required this.confidenceScore,
  });
}

// Exercise Performance Tracking
class ExercisePerformance {
  final String exerciseId;
  final String exerciseName;
  final List<SetPerformance> sets;
  final DateTime performedAt;
  final double? averageRPE;
  final bool completedAllSets;
  final bool completedAllReps;
  final int totalRestTime; // seconds

  ExercisePerformance({
    required this.exerciseId,
    required this.exerciseName,
    required this.sets,
    required this.performedAt,
    this.averageRPE,
    required this.completedAllSets,
    required this.completedAllReps,
    required this.totalRestTime,
  });
}

// Individual Set Performance
class SetPerformance {
  final int setNumber;
  final int targetReps;
  final int actualReps;
  final double? weight;
  final int restTime; // seconds
  final int? rpe; // Rate of Perceived Exertion 1-10

  SetPerformance({
    required this.setNumber,
    required this.targetReps,
    required this.actualReps,
    this.weight,
    required this.restTime,
    this.rpe,
  });
}

// Recovery Status for Muscle Groups
class MuscleGroupRecovery {
  final String muscleGroup;
  final double fatigueLevel; // 0-100 (0 = fully recovered, 100 = extremely fatigued)
  final DateTime lastWorked;
  final int hoursUntilRecovered;
  final bool readyToTrain;
  final String recommendation; // "Rest", "Light work", "Ready for intense training"
  final int workoutsThisWeek;
  final double weeklyVolumeLoad;

  MuscleGroupRecovery({
    required this.muscleGroup,
    required this.fatigueLevel,
    required this.lastWorked,
    required this.hoursUntilRecovered,
    required this.readyToTrain,
    required this.recommendation,
    required this.workoutsThisWeek,
    required this.weeklyVolumeLoad,
  });
}

// Overtraining Detection
class OvertrainingIndicators {
  final bool isOvertraining;
  final double riskLevel; // 0-100
  final List<String> indicators; // declining performance, high frequency, low recovery
  final List<String> symptoms;
  final String recommendation;
  final bool needsDeload;
  final int consecutiveHighIntensityDays;
  final double avgRecoveryScore; // last 7 days

  OvertrainingIndicators({
    required this.isOvertraining,
    required this.riskLevel,
    required this.indicators,
    required this.symptoms,
    required this.recommendation,
    required this.needsDeload,
    required this.consecutiveHighIntensityDays,
    required this.avgRecoveryScore,
  });
}

// Deload Week Suggestion
class DeloadRecommendation {
  final bool shouldDeload;
  final String reason;
  final DateTime recommendedStartDate;
  final int durationDays;
  final double volumeReduction; // percentage (e.g., 40-50%)
  final double intensityReduction; // percentage
  final List<String> guidelines;
  final int weeksSinceLastDeload;

  DeloadRecommendation({
    required this.shouldDeload,
    required this.reason,
    required this.recommendedStartDate,
    required this.durationDays,
    required this.volumeReduction,
    required this.intensityReduction,
    required this.guidelines,
    required this.weeksSinceLastDeload,
  });
}

// Rest Day Recommendation
class RestDayRecommendation {
  final bool needsRestDay;
  final String urgency; // low, medium, high, critical
  final List<String> reasons;
  final List<String> fatigueMuscleGroups;
  final String alternativeActivity; // "Complete rest", "Light cardio", "Stretching", "Yoga"
  final int consecutiveWorkoutDays;
  final double currentReadinessScore;

  RestDayRecommendation({
    required this.needsRestDay,
    required this.urgency,
    required this.reasons,
    required this.fatigueMuscleGroups,
    required this.alternativeActivity,
    required this.consecutiveWorkoutDays,
    required this.currentReadinessScore,
  });
}

// Goal Progress Prediction
class GoalPrediction {
  final String goalType; // weight_loss, muscle_gain, strength_increase
  final double currentValue;
  final double targetValue;
  final double predictedValue;
  final DateTime estimatedCompletionDate;
  final double confidenceLevel; // 0-1
  final String trajectory; // ahead, on_track, behind
  final List<String> recommendations;
  final List<GoalDataPoint> historicalData;
  final List<GoalDataPoint> projectedData;
  final double weeklyProgressRate;
  final int daysToGoal;

  GoalPrediction({
    required this.goalType,
    required this.currentValue,
    required this.targetValue,
    required this.predictedValue,
    required this.estimatedCompletionDate,
    required this.confidenceLevel,
    required this.trajectory,
    required this.recommendations,
    required this.historicalData,
    required this.projectedData,
    required this.weeklyProgressRate,
    required this.daysToGoal,
  });
}

// Data point for goal tracking charts
class GoalDataPoint {
  final DateTime date;
  final double value;
  final bool isProjected;

  GoalDataPoint({
    required this.date,
    required this.value,
    this.isProjected = false,
  });
}
