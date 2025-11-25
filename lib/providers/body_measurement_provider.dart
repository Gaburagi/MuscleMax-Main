import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/body_measurement.dart';

class BodyMeasurementProvider with ChangeNotifier {
  List<BodyMeasurement> _measurements = [];
  List<ProgressPhoto> _photos = [];
  List<PersonalRecord> _personalRecords = [];
  List<FitnessGoal> _goals = [];

  List<BodyMeasurement> get measurements => _measurements;
  List<ProgressPhoto> get photos => _photos;
  List<PersonalRecord> get personalRecords => _personalRecords;
  List<FitnessGoal> get goals => _goals;

  BodyMeasurement? get latestMeasurement => 
      _measurements.isNotEmpty ? _measurements.first : null;

  double? get currentWeight => latestMeasurement?.weight;
  double? get currentBodyFat => latestMeasurement?.bodyFat;

  Future<void> loadData() async {
    await Future.wait([
      _loadMeasurements(),
      _loadPhotos(),
      _loadPersonalRecords(),
      _loadGoals(),
    ]);
    notifyListeners();
  }

  Future<void> _loadMeasurements() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('body_measurements');
      if (data != null) {
        final List<dynamic> list = jsonDecode(data);
        _measurements = list.map((m) => BodyMeasurement.fromJson(m)).toList();
        _measurements.sort((a, b) => b.date.compareTo(a.date)); // Most recent first
      }
    } catch (e) {
      debugPrint('Error loading measurements: $e');
    }
  }

  Future<void> _loadPhotos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('progress_photos');
      if (data != null) {
        final List<dynamic> list = jsonDecode(data);
        _photos = list.map((p) => ProgressPhoto.fromJson(p)).toList();
        _photos.sort((a, b) => b.date.compareTo(a.date));
      }
    } catch (e) {
      debugPrint('Error loading photos: $e');
    }
  }

  Future<void> _loadPersonalRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('personal_records');
      if (data != null) {
        final List<dynamic> list = jsonDecode(data);
        _personalRecords = list.map((pr) => PersonalRecord.fromJson(pr)).toList();
      }
    } catch (e) {
      debugPrint('Error loading personal records: $e');
    }
  }

  Future<void> _loadGoals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('fitness_goals');
      if (data != null) {
        final List<dynamic> list = jsonDecode(data);
        _goals = list.map((g) => FitnessGoal.fromJson(g)).toList();
      }
    } catch (e) {
      debugPrint('Error loading goals: $e');
    }
  }

  // Measurements
  Future<void> addMeasurement(BodyMeasurement measurement) async {
    _measurements.insert(0, measurement);
    await _saveMeasurements();
    
    // Update goals if weight changed
    if (measurement.weight != null) {
      await _updateWeightGoals(measurement.weight!);
    }
    if (measurement.bodyFat != null) {
      await _updateBodyFatGoals(measurement.bodyFat!);
    }
    
    notifyListeners();
  }

  Future<void> updateMeasurement(BodyMeasurement measurement) async {
    final index = _measurements.indexWhere((m) => m.id == measurement.id);
    if (index != -1) {
      _measurements[index] = measurement;
      await _saveMeasurements();
      notifyListeners();
    }
  }

  Future<void> deleteMeasurement(String id) async {
    _measurements.removeWhere((m) => m.id == id);
    await _saveMeasurements();
    notifyListeners();
  }

  Future<void> _saveMeasurements() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(_measurements.map((m) => m.toJson()).toList());
    await prefs.setString('body_measurements', data);
  }

  // Photos
  Future<void> addPhoto(ProgressPhoto photo) async {
    _photos.insert(0, photo);
    await _savePhotos();
    notifyListeners();
  }

  Future<void> deletePhoto(String id) async {
    _photos.removeWhere((p) => p.id == id);
    await _savePhotos();
    notifyListeners();
  }

  Future<void> _savePhotos() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(_photos.map((p) => p.toJson()).toList());
    await prefs.setString('progress_photos', data);
  }

  // Personal Records
  Future<void> checkAndUpdatePersonalRecord({
    required String exerciseId,
    required String exerciseName,
    required double weight,
    required int reps,
  }) async {
    final volume = weight * reps;
    bool isNewRecord = false;

    // Check max weight
    final maxWeightRecord = _personalRecords.where((pr) => 
      pr.exerciseId == exerciseId && pr.recordType == 'max_weight'
    ).firstOrNull;
    
    if (maxWeightRecord == null || weight > maxWeightRecord.weight) {
      final record = PersonalRecord(
        id: 'pr_${DateTime.now().millisecondsSinceEpoch}_weight',
        exerciseId: exerciseId,
        exerciseName: exerciseName,
        weight: weight,
        reps: reps,
        achievedDate: DateTime.now(),
        recordType: 'max_weight',
      );
      
      if (maxWeightRecord != null) {
        _personalRecords.removeWhere((pr) => pr.id == maxWeightRecord.id);
      }
      _personalRecords.add(record);
      isNewRecord = true;
    }

    // Check max volume
    final maxVolumeRecord = _personalRecords.where((pr) => 
      pr.exerciseId == exerciseId && pr.recordType == 'max_volume'
    ).firstOrNull;
    
    if (maxVolumeRecord == null || volume > maxVolumeRecord.volume) {
      final record = PersonalRecord(
        id: 'pr_${DateTime.now().millisecondsSinceEpoch}_volume',
        exerciseId: exerciseId,
        exerciseName: exerciseName,
        weight: weight,
        reps: reps,
        achievedDate: DateTime.now(),
        recordType: 'max_volume',
      );
      
      if (maxVolumeRecord != null) {
        _personalRecords.removeWhere((pr) => pr.id == maxVolumeRecord.id);
      }
      _personalRecords.add(record);
      isNewRecord = true;
    }

    if (isNewRecord) {
      await _savePersonalRecords();
      notifyListeners();
    }
  }

  Future<void> addPersonalRecord(PersonalRecord record) async {
    // Remove any existing record of the same type for this exercise
    _personalRecords.removeWhere((pr) => 
      pr.exerciseId == record.exerciseId && pr.recordType == record.recordType
    );
    
    _personalRecords.add(record);
    await _savePersonalRecords();
    notifyListeners();
  }

  Future<void> _savePersonalRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(_personalRecords.map((pr) => pr.toJson()).toList());
    await prefs.setString('personal_records', data);
  }

  // Goals
  Future<void> addGoal(FitnessGoal goal) async {
    _goals.add(goal);
    await _saveGoals();
    notifyListeners();
  }

  Future<void> updateGoal(FitnessGoal goal) async {
    final index = _goals.indexWhere((g) => g.id == goal.id);
    if (index != -1) {
      _goals[index] = goal;
      await _saveGoals();
      notifyListeners();
    }
  }

  Future<void> deleteGoal(String id) async {
    _goals.removeWhere((g) => g.id == id);
    await _saveGoals();
    notifyListeners();
  }

  Future<void> _updateWeightGoals(double currentWeight) async {
    bool updated = false;
    for (int i = 0; i < _goals.length; i++) {
      if (_goals[i].type == 'weight' && !_goals[i].isCompleted) {
        _goals[i] = _goals[i].copyWith(currentValue: currentWeight);
        
        // Check if goal is completed
        if ((_goals[i].targetValue >= _goals[i].currentValue && 
             currentWeight <= _goals[i].targetValue) ||
            (_goals[i].targetValue <= _goals[i].currentValue && 
             currentWeight >= _goals[i].targetValue)) {
          _goals[i] = _goals[i].copyWith(isCompleted: true);
        }
        updated = true;
      }
    }
    
    if (updated) {
      await _saveGoals();
    }
  }

  Future<void> _updateBodyFatGoals(double currentBodyFat) async {
    bool updated = false;
    for (int i = 0; i < _goals.length; i++) {
      if (_goals[i].type == 'body_fat' && !_goals[i].isCompleted) {
        _goals[i] = _goals[i].copyWith(currentValue: currentBodyFat);
        
        if (currentBodyFat <= _goals[i].targetValue) {
          _goals[i] = _goals[i].copyWith(isCompleted: true);
        }
        updated = true;
      }
    }
    
    if (updated) {
      await _saveGoals();
    }
  }

  Future<void> _saveGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(_goals.map((g) => g.toJson()).toList());
    await prefs.setString('fitness_goals', data);
  }

  // Analytics
  List<BodyMeasurement> getMeasurementsForPeriod(DateTime start, DateTime end) {
    return _measurements.where((m) => 
      m.date.isAfter(start.subtract(const Duration(seconds: 1))) &&
      m.date.isBefore(end.add(const Duration(seconds: 1)))
    ).toList();
  }

  double? getWeightChange(Duration period) {
    if (_measurements.length < 2) return null;
    
    final now = DateTime.now();
    final startDate = now.subtract(period);
    final recentMeasurements = getMeasurementsForPeriod(startDate, now)
        .where((m) => m.weight != null)
        .toList();
    
    if (recentMeasurements.length < 2) return null;
    
    final latest = recentMeasurements.first.weight!;
    final oldest = recentMeasurements.last.weight!;
    
    return latest - oldest;
  }
}
