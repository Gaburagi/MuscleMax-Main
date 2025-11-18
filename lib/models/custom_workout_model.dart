class ExerciseTemplate {
  final String id;
  final String name;
  final String category; // strength, cardio, flexibility
  final String muscleGroup;
  final String? description;
  final String? videoUrl;
  final String? imageUrl;

  ExerciseTemplate({
    required this.id,
    required this.name,
    required this.category,
    required this.muscleGroup,
    this.description,
    this.videoUrl,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'muscleGroup': muscleGroup,
        'description': description,
        'videoUrl': videoUrl,
        'imageUrl': imageUrl,
      };

  factory ExerciseTemplate.fromJson(Map<String, dynamic> json) {
    return ExerciseTemplate(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      muscleGroup: json['muscleGroup'],
      description: json['description'],
      videoUrl: json['videoUrl'],
      imageUrl: json['imageUrl'],
    );
  }
}

class CustomExerciseSet {
  final int reps;
  final double? weight; // in kg
  final int? duration; // in seconds for timed exercises
  final bool isCompleted;

  CustomExerciseSet({
    required this.reps,
    this.weight,
    this.duration,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() => {
        'reps': reps,
        'weight': weight,
        'duration': duration,
        'isCompleted': isCompleted,
      };

  factory CustomExerciseSet.fromJson(Map<String, dynamic> json) {
    return CustomExerciseSet(
      reps: json['reps'],
      weight: json['weight'],
      duration: json['duration'],
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  CustomExerciseSet copyWith({
    int? reps,
    double? weight,
    int? duration,
    bool? isCompleted,
  }) {
    return CustomExerciseSet(
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      duration: duration ?? this.duration,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class WorkoutExercise {
  final String id;
  final ExerciseTemplate template;
  final List<CustomExerciseSet> sets;
  final int restTime; // in seconds
  final String? notes;
  final bool isSuperset; // If true, next exercise is part of same superset
  final int orderIndex;

  WorkoutExercise({
    required this.id,
    required this.template,
    required this.sets,
    this.restTime = 60,
    this.notes,
    this.isSuperset = false,
    required this.orderIndex,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'template': template.toJson(),
        'sets': sets.map((s) => s.toJson()).toList(),
        'restTime': restTime,
        'notes': notes,
        'isSuperset': isSuperset,
        'orderIndex': orderIndex,
      };

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) {
    return WorkoutExercise(
      id: json['id'],
      template: ExerciseTemplate.fromJson(json['template']),
      sets: (json['sets'] as List)
          .map((s) => CustomExerciseSet.fromJson(s))
          .toList(),
      restTime: json['restTime'] ?? 60,
      notes: json['notes'],
      isSuperset: json['isSuperset'] ?? false,
      orderIndex: json['orderIndex'],
    );
  }

  WorkoutExercise copyWith({
    String? id,
    ExerciseTemplate? template,
    List<CustomExerciseSet>? sets,
    int? restTime,
    String? notes,
    bool? isSuperset,
    int? orderIndex,
  }) {
    return WorkoutExercise(
      id: id ?? this.id,
      template: template ?? this.template,
      sets: sets ?? this.sets,
      restTime: restTime ?? this.restTime,
      notes: notes ?? this.notes,
      isSuperset: isSuperset ?? this.isSuperset,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }

  int get totalSets => sets.length;
  int get completedSets => sets.where((s) => s.isCompleted).length;
  bool get isComplete => sets.isNotEmpty && sets.every((s) => s.isCompleted);
  double get totalVolume => sets
      .where((s) => s.weight != null)
      .fold(0.0, (sum, s) => sum + (s.weight! * s.reps));
}

class CustomWorkout {
  final String id;
  final String name;
  final String? description;
  final List<WorkoutExercise> exercises;
  final String category; // strength, cardio, hiit, etc
  final int estimatedDuration; // in minutes
  final DateTime createdAt;
  final DateTime? lastPerformed;
  final int timesPerformed;
  final bool isFavorite;

  CustomWorkout({
    required this.id,
    required this.name,
    this.description,
    required this.exercises,
    this.category = 'strength',
    this.estimatedDuration = 60,
    required this.createdAt,
    this.lastPerformed,
    this.timesPerformed = 0,
    this.isFavorite = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'exercises': exercises.map((e) => e.toJson()).toList(),
        'category': category,
        'estimatedDuration': estimatedDuration,
        'createdAt': createdAt.toIso8601String(),
        'lastPerformed': lastPerformed?.toIso8601String(),
        'timesPerformed': timesPerformed,
        'isFavorite': isFavorite,
      };

  factory CustomWorkout.fromJson(Map<String, dynamic> json) {
    return CustomWorkout(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      exercises: (json['exercises'] as List)
          .map((e) => WorkoutExercise.fromJson(e))
          .toList(),
      category: json['category'] ?? 'strength',
      estimatedDuration: json['estimatedDuration'] ?? 60,
      createdAt: DateTime.parse(json['createdAt']),
      lastPerformed: json['lastPerformed'] != null
          ? DateTime.parse(json['lastPerformed'])
          : null,
      timesPerformed: json['timesPerformed'] ?? 0,
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  CustomWorkout copyWith({
    String? id,
    String? name,
    String? description,
    List<WorkoutExercise>? exercises,
    String? category,
    int? estimatedDuration,
    DateTime? createdAt,
    DateTime? lastPerformed,
    int? timesPerformed,
    bool? isFavorite,
  }) {
    return CustomWorkout(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      exercises: exercises ?? this.exercises,
      category: category ?? this.category,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      createdAt: createdAt ?? this.createdAt,
      lastPerformed: lastPerformed ?? this.lastPerformed,
      timesPerformed: timesPerformed ?? this.timesPerformed,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  int get totalExercises => exercises.length;
  int get completedExercises => exercises.where((e) => e.isComplete).length;
  bool get isComplete =>
      exercises.isNotEmpty && exercises.every((e) => e.isComplete);
  double get completionPercentage =>
      totalExercises > 0 ? (completedExercises / totalExercises) * 100 : 0;
}

class ScheduledWorkout {
  final String id;
  final CustomWorkout workout;
  final DateTime scheduledDate;
  final bool isCompleted;
  final DateTime? completedAt;

  ScheduledWorkout({
    required this.id,
    required this.workout,
    required this.scheduledDate,
    this.isCompleted = false,
    this.completedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'workout': workout.toJson(),
        'scheduledDate': scheduledDate.toIso8601String(),
        'isCompleted': isCompleted,
        'completedAt': completedAt?.toIso8601String(),
      };

  factory ScheduledWorkout.fromJson(Map<String, dynamic> json) {
    return ScheduledWorkout(
      id: json['id'],
      workout: CustomWorkout.fromJson(json['workout']),
      scheduledDate: DateTime.parse(json['scheduledDate']),
      isCompleted: json['isCompleted'] ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
    );
  }

  ScheduledWorkout copyWith({
    String? id,
    CustomWorkout? workout,
    DateTime? scheduledDate,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return ScheduledWorkout(
      id: id ?? this.id,
      workout: workout ?? this.workout,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
