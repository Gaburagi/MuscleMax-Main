class BodyMeasurement {
  final String id;
  final DateTime date;
  final double? weight; // in kg
  final double? bodyFat; // percentage
  final double? chest; // in cm
  final double? waist; // in cm
  final double? hips; // in cm
  final double? bicepsLeft; // in cm
  final double? bicepsRight; // in cm
  final double? thighLeft; // in cm
  final double? thighRight; // in cm
  final double? calfLeft; // in cm
  final double? calfRight; // in cm
  final String? notes;

  BodyMeasurement({
    required this.id,
    required this.date,
    this.weight,
    this.bodyFat,
    this.chest,
    this.waist,
    this.hips,
    this.bicepsLeft,
    this.bicepsRight,
    this.thighLeft,
    this.thighRight,
    this.calfLeft,
    this.calfRight,
    this.notes,
  });

  BodyMeasurement copyWith({
    String? id,
    DateTime? date,
    double? weight,
    double? bodyFat,
    double? chest,
    double? waist,
    double? hips,
    double? bicepsLeft,
    double? bicepsRight,
    double? thighLeft,
    double? thighRight,
    double? calfLeft,
    double? calfRight,
    String? notes,
  }) {
    return BodyMeasurement(
      id: id ?? this.id,
      date: date ?? this.date,
      weight: weight ?? this.weight,
      bodyFat: bodyFat ?? this.bodyFat,
      chest: chest ?? this.chest,
      waist: waist ?? this.waist,
      hips: hips ?? this.hips,
      bicepsLeft: bicepsLeft ?? this.bicepsLeft,
      bicepsRight: bicepsRight ?? this.bicepsRight,
      thighLeft: thighLeft ?? this.thighLeft,
      thighRight: thighRight ?? this.thighRight,
      calfLeft: calfLeft ?? this.calfLeft,
      calfRight: calfRight ?? this.calfRight,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'weight': weight,
    'bodyFat': bodyFat,
    'chest': chest,
    'waist': waist,
    'hips': hips,
    'bicepsLeft': bicepsLeft,
    'bicepsRight': bicepsRight,
    'thighLeft': thighLeft,
    'thighRight': thighRight,
    'calfLeft': calfLeft,
    'calfRight': calfRight,
    'notes': notes,
  };

  factory BodyMeasurement.fromJson(Map<String, dynamic> json) {
    return BodyMeasurement(
      id: json['id'],
      date: DateTime.parse(json['date']),
      weight: json['weight']?.toDouble(),
      bodyFat: json['bodyFat']?.toDouble(),
      chest: json['chest']?.toDouble(),
      waist: json['waist']?.toDouble(),
      hips: json['hips']?.toDouble(),
      bicepsLeft: json['bicepsLeft']?.toDouble(),
      bicepsRight: json['bicepsRight']?.toDouble(),
      thighLeft: json['thighLeft']?.toDouble(),
      thighRight: json['thighRight']?.toDouble(),
      calfLeft: json['calfLeft']?.toDouble(),
      calfRight: json['calfRight']?.toDouble(),
      notes: json['notes'],
    );
  }
}

class ProgressPhoto {
  final String id;
  final DateTime date;
  final String photoPath; // Local file path
  final String type; // 'front', 'side', 'back'
  final double? weight;
  final String? notes;

  ProgressPhoto({
    required this.id,
    required this.date,
    required this.photoPath,
    required this.type,
    this.weight,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'photoPath': photoPath,
    'type': type,
    'weight': weight,
    'notes': notes,
  };

  factory ProgressPhoto.fromJson(Map<String, dynamic> json) {
    return ProgressPhoto(
      id: json['id'],
      date: DateTime.parse(json['date']),
      photoPath: json['photoPath'],
      type: json['type'],
      weight: json['weight']?.toDouble(),
      notes: json['notes'],
    );
  }
}

class PersonalRecord {
  final String id;
  final String exerciseId;
  final String exerciseName;
  final double weight; // Max weight lifted
  final int reps;
  final DateTime achievedDate;
  final String recordType; // 'max_weight', 'max_reps', 'max_volume'

  PersonalRecord({
    required this.id,
    required this.exerciseId,
    required this.exerciseName,
    required this.weight,
    required this.reps,
    required this.achievedDate,
    required this.recordType,
  });

  double get volume => weight * reps;

  Map<String, dynamic> toJson() => {
    'id': id,
    'exerciseId': exerciseId,
    'exerciseName': exerciseName,
    'weight': weight,
    'reps': reps,
    'achievedDate': achievedDate.toIso8601String(),
    'recordType': recordType,
  };

  factory PersonalRecord.fromJson(Map<String, dynamic> json) {
    return PersonalRecord(
      id: json['id'],
      exerciseId: json['exerciseId'],
      exerciseName: json['exerciseName'],
      weight: json['weight']?.toDouble() ?? 0.0,
      reps: json['reps'] ?? 0,
      achievedDate: DateTime.parse(json['achievedDate']),
      recordType: json['recordType'],
    );
  }
}

class FitnessGoal {
  final String id;
  final String title;
  final String type; // 'weight', 'strength', 'frequency', 'body_fat'
  final double targetValue;
  final double currentValue;
  final DateTime startDate;
  final DateTime targetDate;
  final bool isCompleted;

  FitnessGoal({
    required this.id,
    required this.title,
    required this.type,
    required this.targetValue,
    required this.currentValue,
    required this.startDate,
    required this.targetDate,
    this.isCompleted = false,
  });

  double get progress => (currentValue / targetValue * 100).clamp(0, 100);
  
  int get daysRemaining => targetDate.difference(DateTime.now()).inDays;

  FitnessGoal copyWith({
    String? id,
    String? title,
    String? type,
    double? targetValue,
    double? currentValue,
    DateTime? startDate,
    DateTime? targetDate,
    bool? isCompleted,
  }) {
    return FitnessGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      startDate: startDate ?? this.startDate,
      targetDate: targetDate ?? this.targetDate,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'type': type,
    'targetValue': targetValue,
    'currentValue': currentValue,
    'startDate': startDate.toIso8601String(),
    'targetDate': targetDate.toIso8601String(),
    'isCompleted': isCompleted,
  };

  factory FitnessGoal.fromJson(Map<String, dynamic> json) {
    return FitnessGoal(
      id: json['id'],
      title: json['title'],
      type: json['type'],
      targetValue: json['targetValue']?.toDouble() ?? 0.0,
      currentValue: json['currentValue']?.toDouble() ?? 0.0,
      startDate: DateTime.parse(json['startDate']),
      targetDate: DateTime.parse(json['targetDate']),
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}
