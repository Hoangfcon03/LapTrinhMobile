import 'package:flutter/material.dart';
import 'package:bepthongminh64pm1duchoang/features/recipe/domain/recipe_model.dart';
import 'planner_model.dart';

class PlannerProvider with ChangeNotifier {
  // Lưu trữ kế hoạch theo ngày
  final List<MealPlan> _mealPlans = [];

  List<MealPlan> get mealPlans => _mealPlans;

  // Lên kế hoạch cho một ngày
  void addRecipeToPlan(DateTime date, Recipe recipe) {
    // Tìm xem ngày đó đã có kế hoạch chưa
    final existingPlanIndex = _mealPlans.indexWhere(
            (plan) => plan.date.day == date.day && plan.date.month == date.month
    );

    if (existingPlanIndex != -1) {
      _mealPlans[existingPlanIndex].recipes.add(recipe);
    } else {
      _mealPlans.add(MealPlan(date: date, recipes: [recipe]));
    }
    notifyListeners();
  }

  // --- FR4.2: Tự động tổng hợp Danh sách mua sắm ---
  List<String> get shoppingList {
    final List<String> items = [];
    for (var plan in _mealPlans) {
      for (var recipe in plan.recipes) {
        items.addAll(recipe.missingIngredients);
      }
    }
    return items.toSet().toList(); // Loại bỏ trùng lặp
  }
}