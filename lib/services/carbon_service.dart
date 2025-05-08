import 'dart:convert'; // Needed for jsonEncode/jsonDecode
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/carbon_activity.dart';

class CarbonService extends ChangeNotifier {
  List<CarbonActivity> _activities = [];
  double _dailyGoal = 5.0; // Default goal

  static const String _activitiesKey = 'carbon_activities';
  static const String _goalKey = 'daily_goal';

  CarbonService() {
    _loadData();
  }

  List<CarbonActivity> get activities => _activities;
  double get dailyGoal => _dailyGoal;
  double get todayTotal => _calculateTodayTotal();

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final goal = prefs.getDouble(_goalKey) ?? 5.0;
    final activitiesJson = prefs.getStringList(_activitiesKey) ?? [];

    _dailyGoal = goal;
    _activities = activitiesJson
        .map((json) => CarbonActivity.fromJson(jsonDecode(json)))
        .toList();

    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_goalKey, _dailyGoal);
    await prefs.setStringList(
      _activitiesKey,
      _activities.map((a) => jsonEncode(a.toJson())).toList(),
    );
  }

  void addActivity(CarbonActivity activity) {
    _activities.add(activity);
    _saveData();
    notifyListeners();
  }

  void removeActivity(String id) {
    _activities.removeWhere((activity) => activity.id == id);
    _saveData();
    notifyListeners();
  }

  void updateDailyGoal(double newGoal) {
    _dailyGoal = newGoal;
    _saveData();
    notifyListeners();
  }

  double _calculateTodayTotal() {
    final now = DateTime.now();
    return _activities
        .where((activity) =>
    activity.date.year == now.year &&
        activity.date.month == now.month &&
        activity.date.day == now.day)
        .fold(0.0, (sum, activity) => sum + activity.co2);
  }

  double calculateTransportFootprint(double distanceKm, String transportType) {
    const Map<String, double> emissionFactors = {
      'car': 0.12, // kg CO2 per km
      'bus': 0.06,
      'train': 0.05,
      'plane': 0.18,
      'bike': 0.0,
      'walk': 0.0,
    };
    return distanceKm * (emissionFactors[transportType] ?? 0.0);
  }

  double calculateFoodFootprint(String foodType, double quantityKg) {
    const Map<String, double> emissionFactors = {
      'beef': 27.0, // kg CO2 per kg
      'chicken': 6.9,
      'pork': 12.1,
      'fish': 6.1,
      'vegetables': 2.0,
      'fruits': 1.1,
    };
    return quantityKg * (emissionFactors[foodType] ?? 0.0);
  }
}
