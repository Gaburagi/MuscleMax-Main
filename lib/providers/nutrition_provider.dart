import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/nutrition_model.dart';

class NutritionProvider with ChangeNotifier {
  DailyNutrition? _todayNutrition;
  final Map<String, DailyNutrition> _nutritionHistory = {};

  // Getters
  DailyNutrition? get todayNutrition => _todayNutrition;
  Map<String, DailyNutrition> get nutritionHistory => _nutritionHistory;

  // Common food database (in a real app, this would come from an API)
  List<Food> get commonFoods => _commonFoodDatabase;

  NutritionProvider() {
    _initializeToday();
  }

  void _initializeToday() {
    final today = DateTime.now();
    final dateKey = _getDateKey(today);
    
    // Default nutrition goals (these can be customized based on user profile)
    final goals = NutritionGoals(
      calorieGoal: 2000,
      proteinGoal: 150,
      carbsGoal: 200,
      fatGoal: 65,
      waterGoal: 2000,
    );

    _todayNutrition = DailyNutrition(
      date: today,
      goals: goals,
      meals: [],
      waterIntake: 0,
    );
    _nutritionHistory[dateKey] = _todayNutrition!;
  }

  // Load nutrition data from storage
  Future<void> loadNutritionData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final nutritionData = prefs.getString('nutrition_data');
      
      if (nutritionData != null) {
        final Map<String, dynamic> data = json.decode(nutritionData);
        _nutritionHistory.clear();
        
        data.forEach((key, value) {
          _nutritionHistory[key] = DailyNutrition.fromJson(value);
        });
        
        // Set today's nutrition or initialize if not found
        final today = DateTime.now();
        final dateKey = _getDateKey(today);
        if (_nutritionHistory.containsKey(dateKey)) {
          _todayNutrition = _nutritionHistory[dateKey];
        } else {
          _initializeToday();
        }
      } else {
        // No saved data, initialize today
        _initializeToday();
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading nutrition data: $e');
      // On error, still initialize today
      _initializeToday();
      notifyListeners();
    }
  }

  // Save nutrition data to storage
  Future<void> _saveNutritionData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, dynamic> data = {};
      
      _nutritionHistory.forEach((key, value) {
        data[key] = value.toJson();
      });
      
      await prefs.setString('nutrition_data', json.encode(data));
    } catch (e) {
      debugPrint('Error saving nutrition data: $e');
    }
  }

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Add a meal to today
  Future<void> addMeal(Meal meal) async {
    if (_todayNutrition == null) return;
    
    final updatedMeals = List<Meal>.from(_todayNutrition!.meals)..add(meal);
    _todayNutrition = _todayNutrition!.copyWith(meals: updatedMeals);
    
    final dateKey = _getDateKey(_todayNutrition!.date);
    _nutritionHistory[dateKey] = _todayNutrition!;
    
    await _saveNutritionData();
    notifyListeners();
  }

  // Remove a meal
  Future<void> removeMeal(String mealId) async {
    if (_todayNutrition == null) return;
    
    final updatedMeals = _todayNutrition!.meals.where((m) => m.id != mealId).toList();
    _todayNutrition = _todayNutrition!.copyWith(meals: updatedMeals);
    
    final dateKey = _getDateKey(_todayNutrition!.date);
    _nutritionHistory[dateKey] = _todayNutrition!;
    
    await _saveNutritionData();
    notifyListeners();
  }

  // Update water intake
  Future<void> addWaterIntake(int ml) async {
    if (_todayNutrition == null) return;
    
    final newWaterIntake = _todayNutrition!.waterIntake + ml;
    _todayNutrition = _todayNutrition!.copyWith(waterIntake: newWaterIntake);
    
    final dateKey = _getDateKey(_todayNutrition!.date);
    _nutritionHistory[dateKey] = _todayNutrition!;
    
    await _saveNutritionData();
    notifyListeners();
  }

  // Get meals by type for today
  List<Meal> getMealsByType(String type) {
    if (_todayNutrition == null) return [];
    return _todayNutrition!.meals.where((m) => m.type == type).toList();
  }

  // Update nutrition goals
  Future<void> updateNutritionGoals(NutritionGoals newGoals) async {
    if (_todayNutrition == null) return;
    
    _todayNutrition = _todayNutrition!.copyWith(goals: newGoals);
    
    final dateKey = _getDateKey(_todayNutrition!.date);
    _nutritionHistory[dateKey] = _todayNutrition!;
    
    await _saveNutritionData();
    notifyListeners();
  }

  // Get nutrition data for a specific date
  DailyNutrition? getNutritionForDate(DateTime date) {
    final dateKey = _getDateKey(date);
    return _nutritionHistory[dateKey];
  }

  // Common food database
  static final List<Food> _commonFoodDatabase = [
    // Protein sources
    Food(
      id: '1',
      name: 'Chicken Breast',
      servingSize: 100,
      calories: 165,
      protein: 31,
      carbs: 0,
      fat: 3.6,
    ),
    Food(
      id: '2',
      name: 'Salmon',
      servingSize: 100,
      calories: 208,
      protein: 20,
      carbs: 0,
      fat: 13,
    ),
    Food(
      id: '3',
      name: 'Eggs',
      servingSize: 50,
      calories: 78,
      protein: 6.3,
      carbs: 0.6,
      fat: 5.3,
    ),
    Food(
      id: '4',
      name: 'Greek Yogurt',
      servingSize: 170,
      calories: 100,
      protein: 17,
      carbs: 6,
      fat: 0.7,
    ),
    // Carbs
    Food(
      id: '5',
      name: 'White Rice',
      servingSize: 100,
      calories: 130,
      protein: 2.7,
      carbs: 28,
      fat: 0.3,
    ),
    Food(
      id: '6',
      name: 'Brown Rice',
      servingSize: 100,
      calories: 111,
      protein: 2.6,
      carbs: 23,
      fat: 0.9,
    ),
    Food(
      id: '7',
      name: 'Oatmeal',
      servingSize: 40,
      calories: 150,
      protein: 5,
      carbs: 27,
      fat: 3,
    ),
    Food(
      id: '8',
      name: 'Whole Wheat Bread',
      servingSize: 30,
      calories: 80,
      protein: 4,
      carbs: 14,
      fat: 1,
    ),
    Food(
      id: '9',
      name: 'Sweet Potato',
      servingSize: 100,
      calories: 86,
      protein: 1.6,
      carbs: 20,
      fat: 0.1,
    ),
    // Vegetables
    Food(
      id: '10',
      name: 'Broccoli',
      servingSize: 100,
      calories: 34,
      protein: 2.8,
      carbs: 7,
      fat: 0.4,
    ),
    Food(
      id: '11',
      name: 'Spinach',
      servingSize: 100,
      calories: 23,
      protein: 2.9,
      carbs: 3.6,
      fat: 0.4,
    ),
    // Fruits
    Food(
      id: '12',
      name: 'Banana',
      servingSize: 118,
      calories: 105,
      protein: 1.3,
      carbs: 27,
      fat: 0.4,
    ),
    Food(
      id: '13',
      name: 'Apple',
      servingSize: 182,
      calories: 95,
      protein: 0.5,
      carbs: 25,
      fat: 0.3,
    ),
    // Fats
    Food(
      id: '14',
      name: 'Avocado',
      servingSize: 100,
      calories: 160,
      protein: 2,
      carbs: 8.5,
      fat: 15,
    ),
    Food(
      id: '15',
      name: 'Almonds',
      servingSize: 28,
      calories: 164,
      protein: 6,
      carbs: 6,
      fat: 14,
    ),
    Food(
      id: '16',
      name: 'Peanut Butter',
      servingSize: 32,
      calories: 190,
      protein: 8,
      carbs: 7,
      fat: 16,
    ),
    Food(
      id: '17',
      name: 'Olive Oil',
      servingSize: 14,
      calories: 119,
      protein: 0,
      carbs: 0,
      fat: 14,
    ),
    // Dairy
    Food(
      id: '18',
      name: 'Whole Milk',
      servingSize: 240,
      calories: 149,
      protein: 7.7,
      carbs: 11.7,
      fat: 7.9,
    ),
    Food(
      id: '19',
      name: 'Cheddar Cheese',
      servingSize: 28,
      calories: 114,
      protein: 7,
      carbs: 0.4,
      fat: 9.4,
    ),
    Food(
      id: '20',
      name: 'Protein Shake',
      servingSize: 30,
      calories: 120,
      protein: 24,
      carbs: 3,
      fat: 1.5,
    ),
  ];
}
