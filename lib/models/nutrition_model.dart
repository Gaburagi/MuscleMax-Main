class Food {
  final String id;
  final String name;
  final double servingSize; // in grams
  final double calories;
  final double protein; // grams
  final double carbs; // grams
  final double fat; // grams

  Food({
    required this.id,
    required this.name,
    required this.servingSize,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'servingSize': servingSize,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }

  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      id: json['id'],
      name: json['name'],
      servingSize: json['servingSize'],
      calories: json['calories'],
      protein: json['protein'],
      carbs: json['carbs'],
      fat: json['fat'],
    );
  }

  Food copyWith({
    String? id,
    String? name,
    double? servingSize,
    double? calories,
    double? protein,
    double? carbs,
    double? fat,
  }) {
    return Food(
      id: id ?? this.id,
      name: name ?? this.name,
      servingSize: servingSize ?? this.servingSize,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
    );
  }
}

class Meal {
  final String id;
  final String name;
  final String type; // breakfast, lunch, dinner, snack
  final DateTime dateTime;
  final List<FoodEntry> foods;

  Meal({
    required this.id,
    required this.name,
    required this.type,
    required this.dateTime,
    this.foods = const [],
  });

  // Calculate total nutrition for this meal
  double get totalCalories => foods.fold(0, (sum, entry) => sum + entry.calories);
  double get totalProtein => foods.fold(0, (sum, entry) => sum + entry.protein);
  double get totalCarbs => foods.fold(0, (sum, entry) => sum + entry.carbs);
  double get totalFat => foods.fold(0, (sum, entry) => sum + entry.fat);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'dateTime': dateTime.toIso8601String(),
      'foods': foods.map((e) => e.toJson()).toList(),
    };
  }

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      dateTime: DateTime.parse(json['dateTime']),
      foods: json['foods'] != null
          ? (json['foods'] as List).map((e) => FoodEntry.fromJson(e)).toList()
          : [],
    );
  }

  Meal copyWith({
    String? id,
    String? name,
    String? type,
    DateTime? dateTime,
    List<FoodEntry>? foods,
  }) {
    return Meal(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      dateTime: dateTime ?? this.dateTime,
      foods: foods ?? this.foods,
    );
  }
}

class FoodEntry {
  final Food food;
  final double servings; // number of servings consumed

  FoodEntry({
    required this.food,
    required this.servings,
  });

  // Calculated nutrition based on servings
  double get calories => food.calories * servings;
  double get protein => food.protein * servings;
  double get carbs => food.carbs * servings;
  double get fat => food.fat * servings;

  Map<String, dynamic> toJson() {
    return {
      'food': food.toJson(),
      'servings': servings,
    };
  }

  factory FoodEntry.fromJson(Map<String, dynamic> json) {
    return FoodEntry(
      food: Food.fromJson(json['food']),
      servings: json['servings'],
    );
  }
}

class DailyNutrition {
  final DateTime date;
  final List<Meal> meals;
  final int waterIntake; // in ml
  final NutritionGoals goals;

  DailyNutrition({
    required this.date,
    this.meals = const [],
    this.waterIntake = 0,
    required this.goals,
  });

  // Calculate totals for the day
  double get totalCalories => meals.fold(0, (sum, meal) => sum + meal.totalCalories);
  double get totalProtein => meals.fold(0, (sum, meal) => sum + meal.totalProtein);
  double get totalCarbs => meals.fold(0, (sum, meal) => sum + meal.totalCarbs);
  double get totalFat => meals.fold(0, (sum, meal) => sum + meal.totalFat);

  // Progress percentages
  double get caloriesProgress => goals.calorieGoal > 0 ? totalCalories / goals.calorieGoal : 0;
  double get proteinProgress => goals.proteinGoal > 0 ? totalProtein / goals.proteinGoal : 0;
  double get carbsProgress => goals.carbsGoal > 0 ? totalCarbs / goals.carbsGoal : 0;
  double get fatProgress => goals.fatGoal > 0 ? totalFat / goals.fatGoal : 0;
  double get waterProgress => goals.waterGoal > 0 ? waterIntake / goals.waterGoal : 0;

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'meals': meals.map((e) => e.toJson()).toList(),
      'waterIntake': waterIntake,
      'goals': goals.toJson(),
    };
  }

  factory DailyNutrition.fromJson(Map<String, dynamic> json) {
    return DailyNutrition(
      date: DateTime.parse(json['date']),
      meals: json['meals'] != null
          ? (json['meals'] as List).map((e) => Meal.fromJson(e)).toList()
          : [],
      waterIntake: json['waterIntake'] ?? 0,
      goals: NutritionGoals.fromJson(json['goals']),
    );
  }

  DailyNutrition copyWith({
    DateTime? date,
    List<Meal>? meals,
    int? waterIntake,
    NutritionGoals? goals,
  }) {
    return DailyNutrition(
      date: date ?? this.date,
      meals: meals ?? this.meals,
      waterIntake: waterIntake ?? this.waterIntake,
      goals: goals ?? this.goals,
    );
  }
}

class NutritionGoals {
  final double calorieGoal; // kcal per day
  final double proteinGoal; // grams per day
  final double carbsGoal; // grams per day
  final double fatGoal; // grams per day
  final int waterGoal; // ml per day

  NutritionGoals({
    required this.calorieGoal,
    required this.proteinGoal,
    required this.carbsGoal,
    required this.fatGoal,
    this.waterGoal = 2000, // Default 2L per day
  });

  Map<String, dynamic> toJson() {
    return {
      'calorieGoal': calorieGoal,
      'proteinGoal': proteinGoal,
      'carbsGoal': carbsGoal,
      'fatGoal': fatGoal,
      'waterGoal': waterGoal,
    };
  }

  factory NutritionGoals.fromJson(Map<String, dynamic> json) {
    return NutritionGoals(
      calorieGoal: json['calorieGoal'],
      proteinGoal: json['proteinGoal'],
      carbsGoal: json['carbsGoal'],
      fatGoal: json['fatGoal'],
      waterGoal: json['waterGoal'] ?? 2000,
    );
  }

  NutritionGoals copyWith({
    double? calorieGoal,
    double? proteinGoal,
    double? carbsGoal,
    double? fatGoal,
    int? waterGoal,
  }) {
    return NutritionGoals(
      calorieGoal: calorieGoal ?? this.calorieGoal,
      proteinGoal: proteinGoal ?? this.proteinGoal,
      carbsGoal: carbsGoal ?? this.carbsGoal,
      fatGoal: fatGoal ?? this.fatGoal,
      waterGoal: waterGoal ?? this.waterGoal,
    );
  }
}
