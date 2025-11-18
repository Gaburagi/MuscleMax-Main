class UserModel {
  final String? id;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final int? age;
  final double? height; // in cm
  final double? weight; // in kg
  final String? fitnessGoal;
  final List<String> selectedExercises;
  final MacronutrientGoals? macroGoals;

  UserModel({
    this.id,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.age,
    this.height,
    this.weight,
    this.fitnessGoal,
    this.selectedExercises = const [],
    this.macroGoals,
  });

  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phoneNumber,
    int? age,
    double? height,
    double? weight,
    String? fitnessGoal,
    List<String>? selectedExercises,
    MacronutrientGoals? macroGoals,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      age: age ?? this.age,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
      selectedExercises: selectedExercises ?? this.selectedExercises,
      macroGoals: macroGoals ?? this.macroGoals,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'age': age,
      'height': height,
      'weight': weight,
      'fitnessGoal': fitnessGoal,
      'selectedExercises': selectedExercises,
      'macroGoals': macroGoals?.toJson(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      fullName: json['fullName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      age: json['age'],
      height: json['height']?.toDouble(),
      weight: json['weight']?.toDouble(),
      fitnessGoal: json['fitnessGoal'],
      selectedExercises: json['selectedExercises'] != null
          ? List<String>.from(json['selectedExercises'])
          : [],
      macroGoals: json['macroGoals'] != null
          ? MacronutrientGoals.fromJson(json['macroGoals'])
          : null,
    );
  }
}

class MacronutrientGoals {
  final int protein; // grams per day
  final int carbs; // grams per day
  final int fat; // grams per day

  MacronutrientGoals({
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  Map<String, dynamic> toJson() {
    return {
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }

  factory MacronutrientGoals.fromJson(Map<String, dynamic> json) {
    return MacronutrientGoals(
      protein: json['protein'],
      carbs: json['carbs'],
      fat: json['fat'],
    );
  }
}
