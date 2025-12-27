import 'package:flutter/material.dart';

class PlannerProvider with ChangeNotifier {
  // Lưu trữ dưới dạng: { "2024-05-20": [Recipe1, Recipe2] }
  final Map<String, List<dynamic>> _plan = {};

  Map<String, List<dynamic>> get plan => _plan;

  void addToPlan(DateTime date, dynamic recipe) {
    String dateStr = "${date.year}-${date.month}-${date.day}";
    if (_plan[dateStr] == null) {
      _plan[dateStr] = [];
    }
    _plan[dateStr]!.add(recipe);
    notifyListeners();
  }

  void removeFromPlan(DateTime date, String recipeId) {
    String dateStr = "${date.year}-${date.month}-${date.day}";
    _plan[dateStr]?.removeWhere((r) => r.id == recipeId);
    notifyListeners();
  }
}