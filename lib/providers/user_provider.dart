import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  bool get isProfileComplete =>
      _user != null &&
      _user!.age != null &&
      _user!.height != null &&
      _user!.weight != null;

  Future<void> loadUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');
      if (userJson != null) {
        _user = UserModel.fromJson(json.decode(userJson));
        debugPrint('Loaded user - age: ${_user!.age}, height: ${_user!.height}, weight: ${_user!.weight}');
        debugPrint('isProfileComplete: $isProfileComplete');
      } else {
        debugPrint('No user data found in SharedPreferences');
      }
    } catch (e) {
      debugPrint('Error loading user: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveUser(UserModel user) async {
    _user = user;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', json.encode(user.toJson()));
    } catch (e) {
      debugPrint('Error saving user: $e');
    }
  }

  Future<void> updateProfile({
    int? age,
    double? height,
    double? weight,
    String? fitnessGoal,
    List<String>? selectedExercises,
    MacronutrientGoals? macroGoals,
  }) async {
    if (_user == null) return;

    _user = _user!.copyWith(
      age: age ?? _user!.age,
      height: height ?? _user!.height,
      weight: weight ?? _user!.weight,
      fitnessGoal: fitnessGoal ?? _user!.fitnessGoal,
      selectedExercises: selectedExercises ?? _user!.selectedExercises,
      macroGoals: macroGoals ?? _user!.macroGoals,
    );

    debugPrint('Updating profile - age: ${_user!.age}, height: ${_user!.height}, weight: ${_user!.weight}');
    debugPrint('Profile complete check: ${isProfileComplete}');
    
    await saveUser(_user!);
  }

  Future<void> logout() async {
    _user = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user');
    } catch (e) {
      debugPrint('Error logging out: $e');
    }
  }
}
