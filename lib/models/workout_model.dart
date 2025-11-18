class WorkoutProgram {
  final String id;
  final String name;
  final String difficulty; // Beginner, Intermediate, Advanced
  final int durationMinutes;
  final String? imageAsset;
  final String? description;
  final List<Exercise> exercises;
  final bool isFavorite;

  WorkoutProgram({
    required this.id,
    required this.name,
    required this.difficulty,
    required this.durationMinutes,
    this.imageAsset,
    this.description,
    this.exercises = const [],
    this.isFavorite = false,
  });

  // Calculate estimated calories burned (rough estimate: 5 cal/min)
  int get estimatedCalories => durationMinutes * 5;

  WorkoutProgram copyWith({
    String? id,
    String? name,
    String? difficulty,
    int? durationMinutes,
    String? imageAsset,
    String? description,
    List<Exercise>? exercises,
    bool? isFavorite,
  }) {
    return WorkoutProgram(
      id: id ?? this.id,
      name: name ?? this.name,
      difficulty: difficulty ?? this.difficulty,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      imageAsset: imageAsset ?? this.imageAsset,
      description: description ?? this.description,
      exercises: exercises ?? this.exercises,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'difficulty': difficulty,
      'durationMinutes': durationMinutes,
      'imageAsset': imageAsset,
      'description': description,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'isFavorite': isFavorite,
    };
  }

  factory WorkoutProgram.fromJson(Map<String, dynamic> json) {
    return WorkoutProgram(
      id: json['id'],
      name: json['name'],
      difficulty: json['difficulty'],
      durationMinutes: json['durationMinutes'],
      imageAsset: json['imageAsset'],
      description: json['description'],
      exercises: json['exercises'] != null
          ? (json['exercises'] as List)
              .map((e) => Exercise.fromJson(e))
              .toList()
          : [],
      isFavorite: json['isFavorite'] ?? false,
    );
  }
}

class Exercise {
  final String id;
  final String name;
  final int sets;
  final int reps;
  final int? restSeconds;
  final String? instructions;
  final String? videoUrl;
  final String? imageAsset;

  Exercise({
    required this.id,
    required this.name,
    required this.sets,
    required this.reps,
    this.restSeconds,
    this.instructions,
    this.videoUrl,
    this.imageAsset,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sets': sets,
      'reps': reps,
      'restSeconds': restSeconds,
      'instructions': instructions,
      'videoUrl': videoUrl,
      'imageAsset': imageAsset,
    };
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      name: json['name'],
      sets: json['sets'],
      reps: json['reps'],
      restSeconds: json['restSeconds'],
      instructions: json['instructions'],
      videoUrl: json['videoUrl'],
      imageAsset: json['imageAsset'],
    );
  }
}

class WorkoutSession {
  final String id;
  final String workoutProgramId;
  final DateTime startTime;
  final DateTime? endTime;
  final List<ExerciseLog> exerciseLogs;
  final bool isCompleted;

  WorkoutSession({
    required this.id,
    required this.workoutProgramId,
    required this.startTime,
    this.endTime,
    this.exerciseLogs = const [],
    this.isCompleted = false,
  });

  Duration? get duration {
    if (endTime != null) {
      return endTime!.difference(startTime);
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workoutProgramId': workoutProgramId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'exerciseLogs': exerciseLogs.map((e) => e.toJson()).toList(),
      'isCompleted': isCompleted,
    };
  }

  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    return WorkoutSession(
      id: json['id'],
      workoutProgramId: json['workoutProgramId'],
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      exerciseLogs: json['exerciseLogs'] != null
          ? (json['exerciseLogs'] as List)
              .map((e) => ExerciseLog.fromJson(e))
              .toList()
          : [],
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}

class ExerciseLog {
  final String exerciseId;
  final List<SetLog> sets;

  ExerciseLog({
    required this.exerciseId,
    this.sets = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'exerciseId': exerciseId,
      'sets': sets.map((s) => s.toJson()).toList(),
    };
  }

  factory ExerciseLog.fromJson(Map<String, dynamic> json) {
    return ExerciseLog(
      exerciseId: json['exerciseId'],
      sets: json['sets'] != null
          ? (json['sets'] as List).map((s) => SetLog.fromJson(s)).toList()
          : [],
    );
  }
}

class SetLog {
  final int setNumber;
  final int reps;
  final double? weight;
  final bool isCompleted;

  SetLog({
    required this.setNumber,
    required this.reps,
    this.weight,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'setNumber': setNumber,
      'reps': reps,
      'weight': weight,
      'isCompleted': isCompleted,
    };
  }

  factory SetLog.fromJson(Map<String, dynamic> json) {
    return SetLog(
      setNumber: json['setNumber'],
      reps: json['reps'],
      weight: json['weight']?.toDouble(),
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}
