import 'package:flutter/material.dart';
import 'dart:math';
import '../models/ai_models.dart';
// import '../models/custom_workout_models.dart'; // Not needed

class AIWorkoutProvider extends ChangeNotifier {
  final List<AIGeneratedWorkout> _generatedWorkouts = [];
  List<WorkoutRecommendation> _recommendations = [];
  ReadinessScore? _currentReadiness;
  final Map<String, MuscleRecoveryStatus> _muscleRecovery = {};
  final Map<String, List<ExercisePerformance>> _exerciseHistory = {}; // Track performance per exercise
  final Map<String, DifficultyAdjustment> _difficultyAdjustments = {}; // Current adjustments

  List<AIGeneratedWorkout> get generatedWorkouts => _generatedWorkouts;
  List<WorkoutRecommendation> get recommendations => _recommendations;
  ReadinessScore? get currentReadiness => _currentReadiness;
  Map<String, MuscleRecoveryStatus> get muscleRecovery => _muscleRecovery;
  Map<String, DifficultyAdjustment> get difficultyAdjustments => _difficultyAdjustments;

  // Exercise database with time estimates
  final Map<String, Map<String, dynamic>> _exerciseDatabase = {
    // Chest
    'Push-ups': {'muscle': 'Chest', 'time': 45, 'difficulty': 'beginner', 'equipment': ['bodyweight']},
    'Bench Press': {'muscle': 'Chest', 'time': 60, 'difficulty': 'intermediate', 'equipment': ['barbell']},
    'Dumbbell Chest Press': {'muscle': 'Chest', 'time': 50, 'difficulty': 'intermediate', 'equipment': ['dumbbells']},
    'Chest Flyes': {'muscle': 'Chest', 'time': 45, 'difficulty': 'intermediate', 'equipment': ['dumbbells']},
    
    // Back
    'Pull-ups': {'muscle': 'Back', 'time': 45, 'difficulty': 'intermediate', 'equipment': ['pull-up bar']},
    'Bent Over Rows': {'muscle': 'Back', 'time': 55, 'difficulty': 'intermediate', 'equipment': ['barbell']},
    'Lat Pulldowns': {'muscle': 'Back', 'time': 50, 'difficulty': 'beginner', 'equipment': ['cable machine']},
    'Deadlifts': {'muscle': 'Back', 'time': 60, 'difficulty': 'advanced', 'equipment': ['barbell']},
    
    // Legs
    'Squats': {'muscle': 'Legs', 'time': 60, 'difficulty': 'intermediate', 'equipment': ['barbell']},
    'Lunges': {'muscle': 'Legs', 'time': 45, 'difficulty': 'beginner', 'equipment': ['bodyweight', 'dumbbells']},
    'Leg Press': {'muscle': 'Legs', 'time': 50, 'difficulty': 'beginner', 'equipment': ['machine']},
    'Romanian Deadlifts': {'muscle': 'Legs', 'time': 55, 'difficulty': 'intermediate', 'equipment': ['barbell']},
    'Leg Curls': {'muscle': 'Legs', 'time': 40, 'difficulty': 'beginner', 'equipment': ['machine']},
    
    // Shoulders
    'Overhead Press': {'muscle': 'Shoulders', 'time': 55, 'difficulty': 'intermediate', 'equipment': ['barbell']},
    'Lateral Raises': {'muscle': 'Shoulders', 'time': 40, 'difficulty': 'beginner', 'equipment': ['dumbbells']},
    'Front Raises': {'muscle': 'Shoulders', 'time': 40, 'difficulty': 'beginner', 'equipment': ['dumbbells']},
    'Face Pulls': {'muscle': 'Shoulders', 'time': 40, 'difficulty': 'beginner', 'equipment': ['cable machine']},
    
    // Arms
    'Bicep Curls': {'muscle': 'Arms', 'time': 40, 'difficulty': 'beginner', 'equipment': ['dumbbells']},
    'Hammer Curls': {'muscle': 'Arms', 'time': 40, 'difficulty': 'beginner', 'equipment': ['dumbbells']},
    'Tricep Dips': {'muscle': 'Arms', 'time': 45, 'difficulty': 'intermediate', 'equipment': ['bodyweight']},
    'Tricep Extensions': {'muscle': 'Arms', 'time': 40, 'difficulty': 'beginner', 'equipment': ['dumbbells']},
    
    // Core
    'Planks': {'muscle': 'Core', 'time': 30, 'difficulty': 'beginner', 'equipment': ['bodyweight']},
    'Crunches': {'muscle': 'Core', 'time': 30, 'difficulty': 'beginner', 'equipment': ['bodyweight']},
    'Russian Twists': {'muscle': 'Core', 'time': 35, 'difficulty': 'beginner', 'equipment': ['bodyweight']},
    'Leg Raises': {'muscle': 'Core', 'time': 35, 'difficulty': 'intermediate', 'equipment': ['bodyweight']},
    
    // Cardio
    'Burpees': {'muscle': 'Full Body', 'time': 30, 'difficulty': 'intermediate', 'equipment': ['bodyweight']},
    'Mountain Climbers': {'muscle': 'Full Body', 'time': 30, 'difficulty': 'beginner', 'equipment': ['bodyweight']},
    'Jumping Jacks': {'muscle': 'Full Body', 'time': 30, 'difficulty': 'beginner', 'equipment': ['bodyweight']},
  };

  // Generate time-optimized workout
  Future<AIGeneratedWorkout> generateQuickWorkout(WorkoutGenerationRequest request) async {
    final exercises = <AIExerciseBlock>[];
    final targetMuscles = request.targetMuscleGroups.isEmpty
        ? ['Chest', 'Back', 'Legs', 'Shoulders', 'Arms', 'Core']
        : request.targetMuscleGroups;

    int remainingTime = request.availableMinutes * 60; // Convert to seconds
    remainingTime -= 300; // Reserve 5 mins for warmup/cooldown
    
    // Calculate exercise parameters based on intensity and goal
    final exerciseParams = _getExerciseParams(request.intensity, request.goal);
    
    // Filter exercises based on equipment and difficulty
    final availableExercises = _filterExercises(
      targetMuscles,
      request.availableEquipment,
      request.fitnessLevel ?? 5,
    );
    
    // Generate balanced workout
    final selectedExercises = _selectOptimalExercises(
      availableExercises,
      targetMuscles,
      remainingTime,
      exerciseParams,
    );
    
    // Create exercise blocks
    for (final exercise in selectedExercises) {
      final exerciseData = _exerciseDatabase[exercise]!;
      final sets = exerciseParams['sets'];
      final reps = exerciseParams['reps'];
      final rest = exerciseParams['rest'] as int;
      final setsCount = sets as int;
      final repsCount = reps as int;
      
      final exerciseTime = exerciseData['time'] as int;
      final estimatedTime = exerciseTime * setsCount + rest * (setsCount - 1);
      
      exercises.add(AIExerciseBlock(
        exerciseName: exercise,
        muscleGroup: exerciseData['muscle'],
        sets: setsCount,
        reps: repsCount,
        restSeconds: rest,
        estimatedDuration: estimatedTime,
        difficulty: exerciseData['difficulty'],
        equipment: List<String>.from(exerciseData['equipment']),
        notes: _generateExerciseNotes(exercise, request.goal),
      ));
    }
    
    final totalDuration = exercises.fold<int>(
      0,
      (sum, e) => sum + e.estimatedDuration,
    ) + 300; // Add warmup/cooldown
    
    final estimatedCalories = _calculateEstimatedCalories(
      totalDuration ~/ 60,
      request.intensity,
      request.goal,
    );
    
    final workout = AIGeneratedWorkout(
      id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
      name: _generateWorkoutName(targetMuscles, request.availableMinutes),
      totalDuration: totalDuration ~/ 60,
      intensity: request.intensity,
      exercises: exercises,
      goal: request.goal,
      estimatedCalories: estimatedCalories,
      muscleGroupsTargeted: targetMuscles,
      generatedAt: DateTime.now(),
      aiReasoning: _generateReasoning(request, exercises.length),
    );
    
    _generatedWorkouts.insert(0, workout);
    notifyListeners();
    return workout;
  }

  Map<String, int> _getExerciseParams(WorkoutIntensity intensity, String goal) {
    switch (intensity) {
      case WorkoutIntensity.light:
        return {'sets': 2, 'reps': goal == 'endurance' ? 20 : 12, 'rest': 45};
      case WorkoutIntensity.moderate:
        return {'sets': 3, 'reps': goal == 'strength' ? 6 : (goal == 'endurance' ? 15 : 10), 'rest': 60};
      case WorkoutIntensity.hard:
        return {'sets': 4, 'reps': goal == 'strength' ? 5 : (goal == 'endurance' ? 12 : 8), 'rest': 90};
      case WorkoutIntensity.extreme:
        return {'sets': 5, 'reps': goal == 'strength' ? 4 : (goal == 'endurance' ? 10 : 6), 'rest': 120};
    }
  }

  List<String> _filterExercises(
    List<String> targetMuscles,
    List<String> equipment,
    int fitnessLevel,
  ) {
    return _exerciseDatabase.entries
        .where((entry) {
          final data = entry.value;
          
          // Check muscle group
          if (!targetMuscles.contains(data['muscle'])) return false;
          
          // Check equipment availability (if specified)
          if (equipment.isNotEmpty) {
            final exerciseEquipment = List<String>.from(data['equipment']);
            if (!exerciseEquipment.any((eq) => equipment.contains(eq))) {
              return false;
            }
          }
          
          // Check difficulty vs fitness level
          final difficulty = data['difficulty'] as String;
          if (fitnessLevel < 4 && difficulty == 'advanced') return false;
          if (fitnessLevel < 3 && difficulty == 'intermediate') return false;
          
          return true;
        })
        .map((e) => e.key)
        .toList();
  }

  List<String> _selectOptimalExercises(
    List<String> available,
    List<String> targetMuscles,
    int remainingTime,
    Map<String, int> params,
  ) {
    final selected = <String>[];
    final musclesWorked = <String>{};
    final random = Random();
    
    // Try to hit each muscle group once
    for (final muscle in targetMuscles) {
      final muscleExercises = available
          .where((ex) => _exerciseDatabase[ex]!['muscle'] == muscle && !selected.contains(ex))
          .toList();
      
      if (muscleExercises.isNotEmpty) {
        final exercise = muscleExercises[random.nextInt(muscleExercises.length)];
        final exerciseTime = _exerciseDatabase[exercise]!['time'] as int;
        final totalTime = exerciseTime * params['sets']! + params['rest']! * (params['sets']! - 1);
        
        if (totalTime <= remainingTime) {
          selected.add(exercise);
          musclesWorked.add(muscle);
          remainingTime -= totalTime;
        }
      }
    }
    
    // Fill remaining time with compound movements
    while (remainingTime > 180 && selected.length < 8) {
      final remaining = available.where((ex) => !selected.contains(ex)).toList();
      if (remaining.isEmpty) break;
      
      final exercise = remaining[random.nextInt(remaining.length)];
      final exerciseTime = _exerciseDatabase[exercise]!['time'] as int;
      final totalTime = exerciseTime * params['sets']! + params['rest']! * (params['sets']! - 1);
      
      if (totalTime <= remainingTime) {
        selected.add(exercise);
        remainingTime -= totalTime;
      } else {
        break;
      }
    }
    
    return selected;
  }

  int _calculateEstimatedCalories(int minutes, WorkoutIntensity intensity, String goal) {
    final baseCalories = minutes * 6; // Base 6 cal/min
    final intensityMultiplier = {
      WorkoutIntensity.light: 0.8,
      WorkoutIntensity.moderate: 1.0,
      WorkoutIntensity.hard: 1.3,
      WorkoutIntensity.extreme: 1.5,
    }[intensity]!;
    
    return (baseCalories * intensityMultiplier).round();
  }

  String _generateWorkoutName(List<String> muscles, int minutes) {
    if (muscles.length == 1) {
      return '$minutes-Min ${muscles[0]} Blitz';
    } else if (muscles.length == 2) {
      return '$minutes-Min ${muscles[0]} & ${muscles[1]}';
    } else if (muscles.length >= 6) {
      return '$minutes-Min Full Body Express';
    } else {
      return '$minutes-Min Quick Workout';
    }
  }

  String _generateReasoning(WorkoutGenerationRequest request, int exerciseCount) {
    final reasons = <String>[];
    
    reasons.add('Optimized for your ${request.availableMinutes}-minute time window');
    reasons.add('${request.intensity.name.capitalize()} intensity to match your energy level');
    
    if (request.targetMuscleGroups.isNotEmpty) {
      reasons.add('Focuses on ${request.targetMuscleGroups.join(", ")}');
    } else {
      reasons.add('Balanced full-body workout');
    }
    
    reasons.add('$exerciseCount exercises selected for maximum efficiency');
    
    if (request.goal == 'weight_loss') {
      reasons.add('Higher rep ranges for calorie burn');
    } else if (request.goal == 'strength') {
      reasons.add('Lower reps with focus on progressive overload');
    } else if (request.goal == 'hypertrophy') {
      reasons.add('Moderate reps in the hypertrophy range');
    }
    
    return '${reasons.join('. ')}.';
  }

  String? _generateExerciseNotes(String exercise, String goal) {
    if (goal == 'strength' && exercise.contains('Press')) {
      return 'Focus on controlled movement and full range of motion';
    } else if (goal == 'hypertrophy') {
      return 'Squeeze at the peak contraction for maximum muscle activation';
    } else if (goal == 'endurance') {
      return 'Keep a steady pace with minimal rest between reps';
    }
    return null;
  }

  // Calculate readiness score
  ReadinessScore calculateReadiness(
    int recentWorkoutCount,
    DateTime? lastWorkoutDate,
    Map<String, DateTime> muscleGroupLastWorked,
  ) {
    double muscleRecovery = 100;
    double consistency = (recentWorkoutCount / 7) * 100;
    consistency = consistency > 100 ? 100 : consistency;
    
    // Calculate muscle recovery
    if (lastWorkoutDate != null) {
      final hoursSinceLastWorkout = DateTime.now().difference(lastWorkoutDate).inHours;
      if (hoursSinceLastWorkout < 24) {
        muscleRecovery = 50;
      } else if (hoursSinceLastWorkout < 48) {
        muscleRecovery = 75;
      }
    }
    
    final overallScore = (muscleRecovery * 0.5 + consistency * 0.3 + 70 * 0.2);
    
    String recommendation;
    if (overallScore >= 80) {
      recommendation = 'You\'re ready for an intense workout!';
    } else if (overallScore >= 60) {
      recommendation = 'Moderate intensity workout recommended';
    } else if (overallScore >= 40) {
      recommendation = 'Light workout or active recovery suggested';
    } else {
      recommendation = 'Rest day recommended';
    }
    
    _currentReadiness = ReadinessScore(
      overallScore: overallScore,
      muscleRecovery: muscleRecovery,
      motivationLevel: 70, // Could be enhanced with user input
      recentConsistency: consistency,
      calculatedAt: DateTime.now(),
      recommendation: recommendation,
      factors: ['Recovery: ${muscleRecovery.toStringAsFixed(0)}%', 'Consistency: ${consistency.toStringAsFixed(0)}%'],
    );
    
    notifyListeners();
    return _currentReadiness!;
  }

  // Smart Workout Recommendations based on history and recovery
  List<WorkoutRecommendation> _generateRecommendations({
    required int recentWorkoutCount,
    required List<String> recentMuscleGroups,
    required DateTime? lastWorkoutDate,
    required String userGoal,
    required int fitnessLevel,
    required int availableTime,
  }) {
    _recommendations.clear();
    
    // Calculate recovery status
    final readiness = calculateReadiness(recentWorkoutCount, lastWorkoutDate, {});
    
    // Get muscle recovery status
    final recoveryStatus = getMuscleGroupRecoveryStatus();
    final recoveredMuscles = recoveryStatus.where((m) => m.readyToTrain).map((m) => m.muscleGroup).toList();
    final fatiguedMuscles = recoveryStatus.where((m) => !m.readyToTrain).map((m) => m.muscleGroup).toList();
    
    // Calculate consecutive workout days for rest day check
    int consecutiveDays = 0;
    if (lastWorkoutDate != null) {
      final daysSinceLastWorkout = DateTime.now().difference(lastWorkoutDate).inDays;
      if (daysSinceLastWorkout == 0 || daysSinceLastWorkout == 1) {
        consecutiveDays = recentWorkoutCount;
      }
    }
    
    // Check if rest day is needed
    final restDayRec = getRestDayRecommendation(consecutiveDays, readiness.overallScore.toDouble());
    
    // Determine which muscle groups need work (least worked recently AND recovered)
    final allMuscles = ['Chest', 'Back', 'Legs', 'Shoulders', 'Arms', 'Core'];
    final musclesNeedingWork = allMuscles
        .where((muscle) => !recentMuscleGroups.contains(muscle) && recoveredMuscles.contains(muscle))
        .toList();
    
    // PRIORITY: Rest Day Recommendation if critical fatigue
    if (restDayRec.urgency == 'critical' || restDayRec.urgency == 'high') {
      _recommendations.add(WorkoutRecommendation(
        workoutId: 'rec_rest_day',
        workoutName: '🛌 REST DAY RECOMMENDED',
        estimatedDuration: 0,
        intensity: WorkoutIntensity.light,
        muscleGroups: [],
        estimatedCalories: 0,
        confidenceScore: 0.98,
        reasoning: 'RECOVERY ALERT: ${restDayRec.reasons.join(", ")}. Your body needs rest to prevent overtraining and injury.',
        benefits: ['Prevent overtraining', 'Reduce injury risk', 'Optimize recovery', 'Return stronger'],
        exerciseCount: 0,
      ));
      
      // If critical, only suggest rest
      if (restDayRec.urgency == 'critical') {
        notifyListeners();
        return _recommendations;
      }
    }
    
    // If many muscles fatigued, suggest light recovery workout
    if (fatiguedMuscles.length >= 3 && readiness.overallScore < 60) {
      _recommendations.add(WorkoutRecommendation(
        workoutId: 'rec_light_recovery',
        workoutName: 'Light Recovery Workout',
        estimatedDuration: 30,
        intensity: WorkoutIntensity.light,
        muscleGroups: recoveredMuscles.take(2).toList(),
        estimatedCalories: 150,
        confidenceScore: 0.92,
        reasoning: 'Multiple muscle groups are fatigued (${fatiguedMuscles.join(", ")}). Light work on recovered muscles: ${recoveredMuscles.take(2).join(", ")}.',
        benefits: ['Active recovery', 'Work recovered muscles', 'Maintain momentum'],
        exerciseCount: 4,
      ));
    }
    
    // Recommendation 1: Balanced Full Body (only if most muscles recovered)
    if (readiness.overallScore >= 60 && recoveredMuscles.length >= 4) {
      _recommendations.add(WorkoutRecommendation(
        workoutId: 'rec_full_body',
        workoutName: 'Balanced Full Body Workout',
        estimatedDuration: availableTime > 45 ? 60 : 45,
        intensity: readiness.overallScore >= 80 ? WorkoutIntensity.hard : WorkoutIntensity.moderate,
        muscleGroups: allMuscles,
        estimatedCalories: availableTime > 45 ? 360 : 270,
        confidenceScore: 0.9,
        reasoning: 'A balanced approach that targets all major muscle groups. ${readiness.recommendation}',
        benefits: ['Complete muscle coverage', 'Balanced development', 'Time efficient'],
        exerciseCount: availableTime > 45 ? 8 : 6,
      ));
    }
    
    // Recommendation 2: Focus on neglected AND recovered muscle groups
    if (musclesNeedingWork.isNotEmpty && readiness.overallScore >= 50) {
      final focusMuscle = musclesNeedingWork.first;
      final fatiguedText = fatiguedMuscles.isNotEmpty ? ' Avoiding fatigued: ${fatiguedMuscles.join(", ")}.' : '';
      _recommendations.add(WorkoutRecommendation(
        workoutId: 'rec_focus_$focusMuscle',
        workoutName: '$focusMuscle Focus Workout',
        estimatedDuration: 45,
        intensity: readiness.overallScore >= 70 ? WorkoutIntensity.hard : WorkoutIntensity.moderate,
        muscleGroups: [focusMuscle],
        estimatedCalories: 270,
        confidenceScore: 0.85,
        reasoning: 'Your $focusMuscle is recovered and hasn\'t been trained recently.$fatiguedText',
        benefits: ['Target neglected muscles', 'Prevent imbalances', 'Focused strength gains'],
        exerciseCount: 5,
      ));
    }
    
    // Recommendation 3: Active Recovery or Light Workout
    if (readiness.overallScore < 60) {
      _recommendations.add(WorkoutRecommendation(
        workoutId: 'rec_recovery',
        workoutName: 'Active Recovery Session',
        estimatedDuration: 30,
        intensity: WorkoutIntensity.light,
        muscleGroups: ['Core', 'Shoulders'],
        estimatedCalories: 150,
        confidenceScore: 0.95,
        reasoning: 'Your body needs recovery. Light movement will help with muscle repair.',
        benefits: ['Promote recovery', 'Maintain momentum', 'Reduce muscle soreness'],
        exerciseCount: 4,
      ));
    }
    
    // Recommendation 4: Goal-Specific Workout (only with recovered muscles)
    if (userGoal == 'strength' && readiness.overallScore >= 70 && recoveredMuscles.length >= 3) {
      final strengthMuscles = ['Chest', 'Back', 'Legs'].where((m) => recoveredMuscles.contains(m)).toList();
      if (strengthMuscles.length >= 2) {
        _recommendations.add(WorkoutRecommendation(
          workoutId: 'rec_strength',
          workoutName: 'Compound Strength Builder',
          estimatedDuration: 60,
          intensity: WorkoutIntensity.hard,
          muscleGroups: strengthMuscles,
          estimatedCalories: 400,
          confidenceScore: 0.88,
          reasoning: 'Big compound lifts aligned with your strength goals. ${strengthMuscles.join(", ")} are well-recovered for heavy work.',
          benefits: ['Build maximum strength', 'Improve power output', 'Boost testosterone'],
          exerciseCount: 6,
        ));
      }
    } else if (userGoal == 'weight_loss' && readiness.overallScore >= 60 && recoveredMuscles.contains('Legs')) {
      _recommendations.add(WorkoutRecommendation(
        workoutId: 'rec_fat_burn',
        workoutName: 'High-Intensity Fat Burner',
        estimatedDuration: 45,
        intensity: WorkoutIntensity.hard,
        muscleGroups: ['Legs', 'Core', 'Cardio'],
        estimatedCalories: 450,
        confidenceScore: 0.87,
        reasoning: 'Circuit-style workout optimized for calorie burn and fat loss.',
        benefits: ['Maximum calorie burn', 'Boost metabolism', 'Improve cardiovascular fitness'],
        exerciseCount: 7,
      ));
    } else if (userGoal == 'hypertrophy' && readiness.overallScore >= 65 && recoveredMuscles.length >= 2) {
      final hypertrophyMuscles = musclesNeedingWork.isNotEmpty 
          ? musclesNeedingWork.take(2).toList()
          : recoveredMuscles.take(2).toList();
      _recommendations.add(WorkoutRecommendation(
        workoutId: 'rec_muscle',
        workoutName: 'Hypertrophy Volume Training',
        estimatedDuration: 75,
        intensity: WorkoutIntensity.moderate,
        muscleGroups: hypertrophyMuscles,
        estimatedCalories: 380,
        confidenceScore: 0.86,
        reasoning: 'High-volume training on recovered muscles (${hypertrophyMuscles.join(", ")}) for optimal growth.',
        benefits: ['Maximize muscle growth', 'Increase muscle endurance', 'Build definition'],
        exerciseCount: 8,
      ));
    }
    
    // Recommendation 5: Quick and Efficient
    if (availableTime < 45) {
      _recommendations.add(WorkoutRecommendation(
        workoutId: 'rec_quick',
        workoutName: '30-Minute Express Workout',
        estimatedDuration: 30,
        intensity: WorkoutIntensity.moderate,
        muscleGroups: ['Chest', 'Back', 'Legs'],
        estimatedCalories: 200,
        confidenceScore: 0.82,
        reasoning: 'Short on time? This efficient workout hits all major muscle groups.',
        benefits: ['Time efficient', 'Full body coverage', 'Maintain consistency'],
        exerciseCount: 5,
      ));
    }
    
    // Sort by confidence score
    _recommendations.sort((a, b) => b.confidenceScore.compareTo(a.confidenceScore));
    
    // Keep top 4 recommendations
    if (_recommendations.length > 4) {
      _recommendations = _recommendations.sublist(0, 4);
    }
    
    notifyListeners();
    return _recommendations;
  }

  // Public method to generate recommendations
  List<WorkoutRecommendation> generateRecommendations({
    required int recentWorkoutCount,
    required List<String> recentMuscleGroups,
    required DateTime? lastWorkoutDate,
    required String userGoal,
    required int fitnessLevel,
    required int availableTime,
  }) {
    return _generateRecommendations(
      recentWorkoutCount: recentWorkoutCount,
      recentMuscleGroups: recentMuscleGroups,
      lastWorkoutDate: lastWorkoutDate,
      userGoal: userGoal,
      fitnessLevel: fitnessLevel,
      availableTime: availableTime,
    );
  }

  // Track exercise performance for adaptive difficulty
  void trackExercisePerformance(ExercisePerformance performance) {
    if (!_exerciseHistory.containsKey(performance.exerciseId)) {
      _exerciseHistory[performance.exerciseId] = [];
    }
    
    _exerciseHistory[performance.exerciseId]!.add(performance);
    
    // Keep only last 10 performances per exercise
    if (_exerciseHistory[performance.exerciseId]!.length > 10) {
      _exerciseHistory[performance.exerciseId]!.removeAt(0);
    }
    
    // Analyze and generate adjustment
    final adjustment = _analyzeAndAdjust(performance);
    if (adjustment != null) {
      _difficultyAdjustments[performance.exerciseId] = adjustment;
    }
    
    notifyListeners();
  }

  // Analyze performance and determine adjustment
  DifficultyAdjustment? _analyzeAndAdjust(ExercisePerformance current) {
    final history = _exerciseHistory[current.exerciseId] ?? [];
    
    // Need at least 2 sessions to compare
    if (history.length < 2) return null;
    
    final recentPerformances = history.length > 3 ? history.sublist(history.length - 3) : history;
    
    // Calculate metrics
    final completionRate = recentPerformances.where((p) => p.completedAllReps).length / recentPerformances.length;
    final avgRPE = _calculateAverageRPE(recentPerformances);
    final restTimeStable = _isRestTimeStable(recentPerformances);
    
    // Decision logic
    if (completionRate >= 0.9 && avgRPE != null && avgRPE < 7.0 && restTimeStable) {
      // Too easy - increase difficulty
      return _generateIncreaseAdjustment(current, avgRPE);
    } else if (completionRate < 0.5 || (avgRPE != null && avgRPE > 9.0)) {
      // Too hard - decrease difficulty
      return _generateDecreaseAdjustment(current, avgRPE);
    } else if (completionRate >= 0.7 && completionRate < 0.9) {
      // Perfect range - maintain
      return DifficultyAdjustment(
        exerciseName: current.exerciseName,
        adjustmentType: 'maintain',
        reasoning: 'You\'re in the optimal challenge zone. Keep it up!',
        confidenceScore: 0.9,
      );
    }
    
    return null;
  }

  DifficultyAdjustment _generateIncreaseAdjustment(ExercisePerformance current, double avgRPE) {
    final lastSet = current.sets.isNotEmpty ? current.sets.last : null;
    
    if (lastSet?.weight != null && lastSet!.weight! > 0) {
      // Increase weight by 5%
      final newWeight = (lastSet.weight! * 1.05).roundToDouble();
      return DifficultyAdjustment(
        exerciseName: current.exerciseName,
        adjustmentType: 'increase_weight',
        newWeight: newWeight,
        reasoning: 'Completing all reps easily (RPE: ${avgRPE.toStringAsFixed(1)}). Time to progress! Add ${(newWeight - lastSet.weight!).toStringAsFixed(1)} lbs.',
        confidenceScore: 0.85,
      );
    } else {
      // Increase reps by 2
      final newReps = lastSet!.targetReps + 2;
      return DifficultyAdjustment(
        exerciseName: current.exerciseName,
        adjustmentType: 'increase_reps',
        newReps: newReps,
        reasoning: 'You\'re crushing it! (RPE: ${avgRPE.toStringAsFixed(1)}). Increase to $newReps reps per set.',
        confidenceScore: 0.85,
      );
    }
  }

  DifficultyAdjustment _generateDecreaseAdjustment(ExercisePerformance current, double? avgRPE) {
    final lastSet = current.sets.isNotEmpty ? current.sets.last : null;
    
    if (lastSet?.weight != null && lastSet!.weight! > 0) {
      // Decrease weight by 10%
      final newWeight = (lastSet.weight! * 0.9).roundToDouble();
      return DifficultyAdjustment(
        exerciseName: current.exerciseName,
        adjustmentType: 'decrease_weight',
        newWeight: newWeight,
        reasoning: avgRPE != null 
            ? 'Too challenging (RPE: ${avgRPE.toStringAsFixed(1)}). Reduce weight by ${(lastSet.weight! - newWeight).toStringAsFixed(1)} lbs to maintain form.'
            : 'Struggling to complete sets. Reduce weight to focus on form and build back up.',
        confidenceScore: 0.88,
      );
    } else {
      // Decrease reps by 2
      final newReps = (lastSet!.targetReps - 2).clamp(5, 20);
      return DifficultyAdjustment(
        exerciseName: current.exerciseName,
        adjustmentType: 'decrease_reps',
        newReps: newReps,
        reasoning: 'Not completing all reps. Lower to $newReps reps to build strength.',
        confidenceScore: 0.88,
      );
    }
  }

  double? _calculateAverageRPE(List<ExercisePerformance> performances) {
    final rpeValues = performances
        .where((p) => p.averageRPE != null)
        .map((p) => p.averageRPE!)
        .toList();
    
    if (rpeValues.isEmpty) return null;
    
    return rpeValues.reduce((a, b) => a + b) / rpeValues.length;
  }

  bool _isRestTimeStable(List<ExercisePerformance> performances) {
    if (performances.length < 2) return true;
    
    final restTimes = performances.map((p) => p.totalRestTime).toList();
    final avgRestTime = restTimes.reduce((a, b) => a + b) / restTimes.length;
    
    // Check if rest times vary by less than 30%
    for (final restTime in restTimes) {
      if ((restTime - avgRestTime).abs() / avgRestTime > 0.3) {
        return false;
      }
    }
    
    return true;
  }

  // Get suggested adjustment for an exercise
  DifficultyAdjustment? getSuggestedAdjustment(String exerciseId) {
    return _difficultyAdjustments[exerciseId];
  }

  // Get performance history for an exercise
  List<ExercisePerformance> getExerciseHistory(String exerciseId) {
    return _exerciseHistory[exerciseId] ?? [];
  }

  // Demo function to generate sample performance data
  void generateDemoPerformanceData() {
    // Example 1: User completing all reps easily - should suggest increase
    trackExercisePerformance(ExercisePerformance(
      exerciseId: 'bench_press',
      exerciseName: 'Bench Press',
      sets: [
        SetPerformance(setNumber: 1, targetReps: 10, actualReps: 10, weight: 135, restTime: 90, rpe: 6),
        SetPerformance(setNumber: 2, targetReps: 10, actualReps: 10, weight: 135, restTime: 90, rpe: 6),
        SetPerformance(setNumber: 3, targetReps: 10, actualReps: 10, weight: 135, restTime: 90, rpe: 7),
      ],
      performedAt: DateTime.now().subtract(const Duration(days: 6)),
      averageRPE: 6.3,
      completedAllSets: true,
      completedAllReps: true,
      totalRestTime: 270,
    ));

    trackExercisePerformance(ExercisePerformance(
      exerciseId: 'bench_press',
      exerciseName: 'Bench Press',
      sets: [
        SetPerformance(setNumber: 1, targetReps: 10, actualReps: 10, weight: 135, restTime: 85, rpe: 6),
        SetPerformance(setNumber: 2, targetReps: 10, actualReps: 10, weight: 135, restTime: 85, rpe: 6),
        SetPerformance(setNumber: 3, targetReps: 10, actualReps: 10, weight: 135, restTime: 85, rpe: 6),
      ],
      performedAt: DateTime.now().subtract(const Duration(days: 3)),
      averageRPE: 6.0,
      completedAllSets: true,
      completedAllReps: true,
      totalRestTime: 255,
    ));

    trackExercisePerformance(ExercisePerformance(
      exerciseId: 'bench_press',
      exerciseName: 'Bench Press',
      sets: [
        SetPerformance(setNumber: 1, targetReps: 10, actualReps: 10, weight: 135, restTime: 80, rpe: 5),
        SetPerformance(setNumber: 2, targetReps: 10, actualReps: 10, weight: 135, restTime: 80, rpe: 6),
        SetPerformance(setNumber: 3, targetReps: 10, actualReps: 10, weight: 135, restTime: 80, rpe: 6),
      ],
      performedAt: DateTime.now(),
      averageRPE: 5.7,
      completedAllSets: true,
      completedAllReps: true,
      totalRestTime: 240,
    ));

    // Example 2: User struggling - should suggest decrease
    trackExercisePerformance(ExercisePerformance(
      exerciseId: 'squats',
      exerciseName: 'Squats',
      sets: [
        SetPerformance(setNumber: 1, targetReps: 12, actualReps: 10, weight: 185, restTime: 120, rpe: 9),
        SetPerformance(setNumber: 2, targetReps: 12, actualReps: 8, weight: 185, restTime: 140, rpe: 9),
        SetPerformance(setNumber: 3, targetReps: 12, actualReps: 7, weight: 185, restTime: 150, rpe: 10),
      ],
      performedAt: DateTime.now().subtract(const Duration(days: 4)),
      averageRPE: 9.3,
      completedAllSets: true,
      completedAllReps: false,
      totalRestTime: 410,
    ));

    trackExercisePerformance(ExercisePerformance(
      exerciseId: 'squats',
      exerciseName: 'Squats',
      sets: [
        SetPerformance(setNumber: 1, targetReps: 12, actualReps: 9, weight: 185, restTime: 130, rpe: 9),
        SetPerformance(setNumber: 2, targetReps: 12, actualReps: 7, weight: 185, restTime: 145, rpe: 10),
        SetPerformance(setNumber: 3, targetReps: 12, actualReps: 6, weight: 185, restTime: 160, rpe: 10),
      ],
      performedAt: DateTime.now(),
      averageRPE: 9.7,
      completedAllSets: true,
      completedAllReps: false,
      totalRestTime: 435,
    ));

    // Example 3: Bodyweight exercise doing well
    trackExercisePerformance(ExercisePerformance(
      exerciseId: 'push_ups',
      exerciseName: 'Push-ups',
      sets: [
        SetPerformance(setNumber: 1, targetReps: 15, actualReps: 15, restTime: 60, rpe: 6),
        SetPerformance(setNumber: 2, targetReps: 15, actualReps: 15, restTime: 60, rpe: 7),
        SetPerformance(setNumber: 3, targetReps: 15, actualReps: 15, restTime: 60, rpe: 7),
      ],
      performedAt: DateTime.now().subtract(const Duration(days: 5)),
      averageRPE: 6.7,
      completedAllSets: true,
      completedAllReps: true,
      totalRestTime: 180,
    ));

    trackExercisePerformance(ExercisePerformance(
      exerciseId: 'push_ups',
      exerciseName: 'Push-ups',
      sets: [
        SetPerformance(setNumber: 1, targetReps: 15, actualReps: 15, restTime: 55, rpe: 6),
        SetPerformance(setNumber: 2, targetReps: 15, actualReps: 15, restTime: 55, rpe: 6),
        SetPerformance(setNumber: 3, targetReps: 15, actualReps: 15, restTime: 55, rpe: 6),
      ],
      performedAt: DateTime.now(),
      averageRPE: 6.0,
      completedAllSets: true,
      completedAllReps: true,
      totalRestTime: 165,
    ));

    // Example 4: Perfect range - maintain
    trackExercisePerformance(ExercisePerformance(
      exerciseId: 'deadlift',
      exerciseName: 'Deadlifts',
      sets: [
        SetPerformance(setNumber: 1, targetReps: 8, actualReps: 8, weight: 225, restTime: 120, rpe: 8),
        SetPerformance(setNumber: 2, targetReps: 8, actualReps: 7, weight: 225, restTime: 120, rpe: 8),
        SetPerformance(setNumber: 3, targetReps: 8, actualReps: 7, weight: 225, restTime: 130, rpe: 9),
      ],
      performedAt: DateTime.now().subtract(const Duration(days: 3)),
      averageRPE: 8.3,
      completedAllSets: true,
      completedAllReps: false,
      totalRestTime: 370,
    ));

    trackExercisePerformance(ExercisePerformance(
      exerciseId: 'deadlift',
      exerciseName: 'Deadlifts',
      sets: [
        SetPerformance(setNumber: 1, targetReps: 8, actualReps: 8, weight: 225, restTime: 115, rpe: 8),
        SetPerformance(setNumber: 2, targetReps: 8, actualReps: 8, weight: 225, restTime: 115, rpe: 8),
        SetPerformance(setNumber: 3, targetReps: 8, actualReps: 7, weight: 225, restTime: 125, rpe: 8),
      ],
      performedAt: DateTime.now(),
      averageRPE: 8.0,
      completedAllSets: true,
      completedAllReps: false,
      totalRestTime: 355,
    ));

    notifyListeners();
  }

  void clearGeneratedWorkouts() {
    _generatedWorkouts.clear();
    notifyListeners();
  }

  // ============ RECOVERY & READINESS AI ============

  // Track muscle group recovery after workout
  void updateMuscleRecovery(String muscleGroup, double volumeLoad, WorkoutIntensity intensity) {
    final now = DateTime.now();
    final fatigueLevel = intensity == WorkoutIntensity.light ? 30.0 
        : intensity == WorkoutIntensity.moderate ? 50.0 
        : intensity == WorkoutIntensity.hard ? 75.0 
        : 90.0;

    _muscleRecovery[muscleGroup] = MuscleRecoveryStatus(
      muscleGroup: muscleGroup,
      fatigueLevel: fatigueLevel,
      lastWorked: now,
      readyToTrain: false,
      hoursSinceLastWorkout: 0,
      recommendation: 'Recently worked - recovering',
    );
    notifyListeners();
  }

  // Calculate comprehensive recovery status for all muscle groups
  List<MuscleGroupRecovery> getMuscleGroupRecoveryStatus() {
    final muscleGroups = ['Chest', 'Back', 'Legs', 'Shoulders', 'Arms', 'Core'];
    final now = DateTime.now();
    
    return muscleGroups.map((muscle) {
      final status = _muscleRecovery[muscle];
      
      if (status == null) {
        return MuscleGroupRecovery(
          muscleGroup: muscle,
          fatigueLevel: 0,
          lastWorked: now.subtract(const Duration(days: 7)),
          hoursUntilRecovered: 0,
          readyToTrain: true,
          recommendation: 'Ready for intense training',
          workoutsThisWeek: 0,
          weeklyVolumeLoad: 0,
        );
      }

      final hoursSinceWorkout = now.difference(status.lastWorked).inHours;
      final recoveryRate = status.fatigueLevel > 70 ? 72 : status.fatigueLevel > 40 ? 48 : 24;
      final hoursUntilRecovered = (recoveryRate - hoursSinceWorkout).clamp(0, 999);
      final currentFatigue = (status.fatigueLevel * (1 - (hoursSinceWorkout / recoveryRate))).clamp(0, 100);
      
      String recommendation;
      if (currentFatigue < 20) {
        recommendation = 'Ready for intense training';
      } else if (currentFatigue < 50) {
        recommendation = 'Light to moderate work recommended';
      } else if (currentFatigue < 75) {
        recommendation = 'Rest or very light activity only';
      } else {
        recommendation = 'Complete rest required';
      }

      return MuscleGroupRecovery(
        muscleGroup: muscle,
        fatigueLevel: currentFatigue.toDouble(),
        lastWorked: status.lastWorked,
        hoursUntilRecovered: hoursUntilRecovered,
        readyToTrain: currentFatigue < 40,
        recommendation: recommendation,
        workoutsThisWeek: 2, // This would be calculated from actual workout history
        weeklyVolumeLoad: 5000 + Random().nextInt(5000).toDouble(),
      );
    }).toList();
  }

  // Detect overtraining
  OvertrainingIndicators checkOvertraining(List<DateTime> recentWorkoutDates, List<double> recentRPEScores) {
    final indicators = <String>[];
    final symptoms = <String>[];
    
    // Check workout frequency
    final last7Days = recentWorkoutDates.where((date) => 
      DateTime.now().difference(date).inDays <= 7
    ).length;
    
    final consecutiveHighIntensityDays = _countConsecutiveHighIntensityDays(recentWorkoutDates);
    
    if (last7Days >= 6) {
      indicators.add('High workout frequency ($last7Days/7 days)');
      symptoms.add('Insufficient rest days');
    }
    
    if (consecutiveHighIntensityDays >= 4) {
      indicators.add('$consecutiveHighIntensityDays consecutive high-intensity days');
      symptoms.add('No recovery days between intense sessions');
    }

    // Check average RPE
    if (recentRPEScores.isNotEmpty) {
      final avgRPE = recentRPEScores.reduce((a, b) => a + b) / recentRPEScores.length;
      if (avgRPE >= 8.5) {
        indicators.add('Consistently high RPE (avg ${avgRPE.toStringAsFixed(1)})');
        symptoms.add('Extreme fatigue during workouts');
      }
    }

    // Calculate average recovery score
    final avgRecoveryScore = _calculateAverageRecoveryScore();
    if (avgRecoveryScore < 50) {
      indicators.add('Low recovery scores');
      symptoms.add('Poor sleep or muscle soreness');
    }

    final riskLevel = (last7Days / 7 * 30 + 
                      consecutiveHighIntensityDays / 7 * 40 + 
                      (avgRecoveryScore < 50 ? 30 : 0)).clamp(0, 100);
    
    final isOvertraining = riskLevel >= 60;
    final needsDeload = isOvertraining || riskLevel >= 50;

    String recommendation;
    if (isOvertraining) {
      recommendation = 'Immediate deload week required. Reduce volume by 50% and intensity by 20%.';
    } else if (needsDeload) {
      recommendation = 'Consider a deload week soon to prevent overtraining.';
    } else if (riskLevel >= 30) {
      recommendation = 'Add more rest days and monitor recovery closely.';
    } else {
      recommendation = 'Training load is well-managed. Keep up the good work!';
    }

    return OvertrainingIndicators(
      isOvertraining: isOvertraining,
      riskLevel: riskLevel.toDouble(),
      indicators: indicators,
      symptoms: symptoms,
      recommendation: recommendation,
      needsDeload: needsDeload,
      consecutiveHighIntensityDays: consecutiveHighIntensityDays,
      avgRecoveryScore: avgRecoveryScore,
    );
  }

  int _countConsecutiveHighIntensityDays(List<DateTime> workoutDates) {
    if (workoutDates.isEmpty) return 0;
    
    final sortedDates = workoutDates.toList()..sort((a, b) => b.compareTo(a));
    int count = 0;
    DateTime? lastDate;
    
    for (final date in sortedDates) {
      if (lastDate == null) {
        count = 1;
        lastDate = date;
      } else if (lastDate.difference(date).inDays == 1) {
        count++;
        lastDate = date;
      } else {
        break;
      }
    }
    return count;
  }

  double _calculateAverageRecoveryScore() {
    final recoveryStatuses = getMuscleGroupRecoveryStatus();
    if (recoveryStatuses.isEmpty) return 70;
    
    final avgFatigue = recoveryStatuses
        .map((r) => r.fatigueLevel)
        .reduce((a, b) => a + b) / recoveryStatuses.length;
    
    return (100 - avgFatigue).clamp(0, 100);
  }

  // Recommend deload week
  DeloadRecommendation getDeloadRecommendation(int weeksSinceLastDeload, OvertrainingIndicators overtraining) {
    final shouldDeload = weeksSinceLastDeload >= 6 || overtraining.needsDeload;
    
    String reason;
    if (overtraining.isOvertraining) {
      reason = 'Overtraining detected - immediate deload required';
    } else if (weeksSinceLastDeload >= 6) {
      reason = 'Planned deload - 6+ weeks of training completed';
    } else if (overtraining.riskLevel >= 50) {
      reason = 'Elevated overtraining risk - preventive deload recommended';
    } else {
      reason = 'No deload needed at this time';
    }

    final volumeReduction = overtraining.isOvertraining ? 50.0 : 40.0;
    final intensityReduction = overtraining.isOvertraining ? 20.0 : 10.0;

    return DeloadRecommendation(
      shouldDeload: shouldDeload,
      reason: reason,
      recommendedStartDate: DateTime.now().add(const Duration(days: 3)),
      durationDays: 7,
      volumeReduction: volumeReduction,
      intensityReduction: intensityReduction,
      guidelines: [
        'Reduce sets by ${volumeReduction.toInt()}% (e.g., 3 sets → ${(3 * (1 - volumeReduction / 100)).round()} sets)',
        'Lower weight by ${intensityReduction.toInt()}% but maintain good form',
        'Focus on technique and mind-muscle connection',
        'Increase rest time between sets',
        'Add extra sleep and focus on recovery activities',
        'Stay active with light cardio or mobility work',
      ],
      weeksSinceLastDeload: weeksSinceLastDeload,
    );
  }

  // Recommend rest day
  RestDayRecommendation getRestDayRecommendation(int consecutiveWorkoutDays, double readinessScore) {
    final fatiguedMuscles = getMuscleGroupRecoveryStatus()
        .where((m) => m.fatigueLevel > 60)
        .map((m) => m.muscleGroup)
        .toList();

    final reasons = <String>[];
    String urgency;
    
    if (consecutiveWorkoutDays >= 7) {
      reasons.add('7+ consecutive workout days');
      urgency = 'critical';
    } else if (consecutiveWorkoutDays >= 5) {
      reasons.add('$consecutiveWorkoutDays consecutive workout days');
      urgency = 'high';
    } else if (consecutiveWorkoutDays >= 3) {
      reasons.add('$consecutiveWorkoutDays workout days in a row');
      urgency = 'medium';
    } else {
      urgency = 'low';
    }

    if (readinessScore < 40) {
      reasons.add('Low readiness score (${readinessScore.toStringAsFixed(0)}/100)');
      if (urgency == 'low') urgency = 'high';
    } else if (readinessScore < 60) {
      reasons.add('Moderate readiness (${readinessScore.toStringAsFixed(0)}/100)');
      if (urgency == 'low') urgency = 'medium';
    }

    if (fatiguedMuscles.length >= 4) {
      reasons.add('${fatiguedMuscles.length} muscle groups highly fatigued');
      urgency = 'high';
    } else if (fatiguedMuscles.length >= 2) {
      reasons.add('Multiple muscle groups need recovery');
    }

    final needsRestDay = urgency == 'critical' || urgency == 'high' || 
                        (urgency == 'medium' && readinessScore < 60);

    String alternativeActivity;
    if (urgency == 'critical') {
      alternativeActivity = 'Complete rest - sleep and passive recovery';
    } else if (readinessScore < 50) {
      alternativeActivity = 'Light stretching or yoga (20-30 min)';
    } else {
      alternativeActivity = 'Light cardio or mobility work (30-40 min)';
    }

    if (reasons.isEmpty) {
      reasons.add('Maintaining good training frequency');
    }

    return RestDayRecommendation(
      needsRestDay: needsRestDay,
      urgency: urgency,
      reasons: reasons,
      fatigueMuscleGroups: fatiguedMuscles,
      alternativeActivity: alternativeActivity,
      consecutiveWorkoutDays: consecutiveWorkoutDays,
      currentReadinessScore: readinessScore,
    );
  }

  // ============ GOAL PREDICTION & FORECASTING ============

  // Predict goal completion
  GoalPrediction predictGoalCompletion({
    required String goalType,
    required double currentValue,
    required double targetValue,
    required List<GoalDataPoint> historicalData,
    required DateTime goalDeadline,
  }) {
    if (historicalData.length < 2) {
      // Not enough data for prediction
      return _createDefaultPrediction(goalType, currentValue, targetValue, goalDeadline);
    }

    // Calculate weekly progress rate using linear regression
    final weeklyRate = _calculateProgressRate(historicalData);
    final totalChange = targetValue - currentValue;
    final weeksNeeded = (totalChange / weeklyRate).abs();
    final daysToGoal = (weeksNeeded * 7).round();
    
    final estimatedCompletion = DateTime.now().add(Duration(days: daysToGoal));
    final predictedValue = currentValue + (weeklyRate * weeksNeeded);

    // Determine trajectory
    final daysUntilDeadline = goalDeadline.difference(DateTime.now()).inDays;
    String trajectory;
    if (daysToGoal < daysUntilDeadline * 0.9) {
      trajectory = 'ahead';
    } else if (daysToGoal <= daysUntilDeadline * 1.1) {
      trajectory = 'on_track';
    } else {
      trajectory = 'behind';
    }

    // Calculate confidence based on data consistency
    final confidence = _calculatePredictionConfidence(historicalData, weeklyRate);

    // Generate recommendations
    final recommendations = _generateGoalRecommendations(
      goalType: goalType,
      trajectory: trajectory,
      weeklyRate: weeklyRate,
      daysToGoal: daysToGoal,
      daysUntilDeadline: daysUntilDeadline,
    );

    // Generate projected data points
    final projectedData = _generateProjectedDataPoints(
      currentValue: currentValue,
      targetValue: targetValue,
      weeklyRate: weeklyRate,
      weeksToProject: weeksNeeded.ceil(),
    );

    return GoalPrediction(
      goalType: goalType,
      currentValue: currentValue,
      targetValue: targetValue,
      predictedValue: predictedValue,
      estimatedCompletionDate: estimatedCompletion,
      confidenceLevel: confidence,
      trajectory: trajectory,
      recommendations: recommendations,
      historicalData: historicalData,
      projectedData: projectedData,
      weeklyProgressRate: weeklyRate,
      daysToGoal: daysToGoal,
    );
  }

  double _calculateProgressRate(List<GoalDataPoint> data) {
    if (data.length < 2) return 0;

    // Sort by date
    final sorted = data.toList()..sort((a, b) => a.date.compareTo(b.date));
    
    // Simple linear regression
    final n = sorted.length;
    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;
    
    for (int i = 0; i < n; i++) {
      final x = i.toDouble();
      final y = sorted[i].value;
      sumX += x;
      sumY += y;
      sumXY += x * y;
      sumX2 += x * x;
    }
    
    final slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    
    // Convert to weekly rate (assuming data points are roughly weekly)
    final daysSpan = sorted.last.date.difference(sorted.first.date).inDays;
    final weeksSpan = daysSpan / 7;
    final ratePerDataPoint = slope;
    final weeklyRate = ratePerDataPoint * (n / weeksSpan);
    
    return weeklyRate;
  }

  double _calculatePredictionConfidence(List<GoalDataPoint> data, double expectedRate) {
    if (data.length < 3) return 0.5;

    // Calculate variance from expected trend
    double variance = 0;
    for (int i = 1; i < data.length; i++) {
      final actualChange = data[i].value - data[i - 1].value;
      final expectedChange = expectedRate / (data.length - 1);
      variance += (actualChange - expectedChange).abs();
    }
    
    final avgVariance = variance / (data.length - 1);
    final consistency = (1 - (avgVariance / expectedRate.abs())).clamp(0, 1);
    
    // More data points increase confidence
    final dataBonus = (data.length / 20).clamp(0, 0.3);
    
    return (consistency * 0.7 + dataBonus).clamp(0.4, 0.95);
  }

  List<String> _generateGoalRecommendations({
    required String goalType,
    required String trajectory,
    required double weeklyRate,
    required int daysToGoal,
    required int daysUntilDeadline,
  }) {
    final recommendations = <String>[];

    if (trajectory == 'ahead') {
      recommendations.add('Excellent progress! You\'re ahead of schedule.');
      recommendations.add('Maintain your current routine for continued success.');
      recommendations.add('Consider setting a more ambitious target.');
    } else if (trajectory == 'on_track') {
      recommendations.add('Great work! You\'re on track to reach your goal.');
      recommendations.add('Stay consistent with your current approach.');
      recommendations.add('Monitor progress weekly to stay on target.');
    } else {
      // Behind schedule
      if (goalType == 'weight_loss') {
        recommendations.add('Increase calorie deficit by 200-300 calories per day.');
        recommendations.add('Add 2 extra cardio sessions per week (30 min each).');
        recommendations.add('Track all meals meticulously to ensure calorie accuracy.');
      } else if (goalType == 'muscle_gain') {
        recommendations.add('Increase calorie surplus by 200-300 calories per day.');
        recommendations.add('Ensure hitting protein target daily (1g per lb bodyweight).');
        recommendations.add('Add an extra training session per week.');
      } else if (goalType == 'strength_increase') {
        recommendations.add('Increase training frequency for lagging lifts.');
        recommendations.add('Focus on progressive overload - add weight/reps weekly.');
        recommendations.add('Ensure adequate recovery between heavy sessions.');
      }
      recommendations.add('Consider adjusting your goal deadline if needed.');
    }

    return recommendations;
  }

  List<GoalDataPoint> _generateProjectedDataPoints({
    required double currentValue,
    required double targetValue,
    required double weeklyRate,
    required int weeksToProject,
  }) {
    final projected = <GoalDataPoint>[];
    final now = DateTime.now();
    
    for (int week = 1; week <= weeksToProject; week++) {
      final value = currentValue + (weeklyRate * week);
      // Cap at target value
      final cappedValue = weeklyRate > 0 
          ? value.clamp(currentValue, targetValue)
          : value.clamp(targetValue, currentValue);
      
      projected.add(GoalDataPoint(
        date: now.add(Duration(days: week * 7)),
        value: cappedValue,
        isProjected: true,
      ));
    }
    
    return projected;
  }

  GoalPrediction _createDefaultPrediction(String goalType, double currentValue, double targetValue, DateTime deadline) {
    final daysToDeadline = deadline.difference(DateTime.now()).inDays;
    final weeklyRate = (targetValue - currentValue) / (daysToDeadline / 7);
    
    return GoalPrediction(
      goalType: goalType,
      currentValue: currentValue,
      targetValue: targetValue,
      predictedValue: targetValue,
      estimatedCompletionDate: deadline,
      confidenceLevel: 0.3,
      trajectory: 'on_track',
      recommendations: ['More data needed for accurate prediction. Keep tracking!'],
      historicalData: [],
      projectedData: [],
      weeklyProgressRate: weeklyRate,
      daysToGoal: daysToDeadline,
    );
  }

  // Generate demo goal data for testing
  void generateDemoGoalData() {
    // This would create sample historical weight/strength data
    // For demonstration purposes
    notifyListeners();
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
