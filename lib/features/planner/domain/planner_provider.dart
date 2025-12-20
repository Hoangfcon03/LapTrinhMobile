import 'package:flutter/material.dart';
import 'package:bepthongminh64pm1duchoang/features/recipe/domain/recipe_model.dart';
import 'package:bepthongminh64pm1duchoang/features/planner/domain/planner_model.dart';

class PlannerProvider with ChangeNotifier {
  final List<MealPlan> _mealPlans = [];

  List<MealPlan> get mealPlans => _mealPlans;

  void addRecipeToPlan(DateTime date, Recipe recipe) {
    // Chuẩn hóa chỉ lấy ngày/tháng/năm để tránh lệch giờ
    final dateOnly = DateTime(date.year, date.month, date.day);

    final existingPlanIndex = _mealPlans.indexWhere(
            (plan) => plan.date.year == dateOnly.year &&
            plan.date.month == dateOnly.month &&
            plan.date.day == dateOnly.day
    );

    if (existingPlanIndex != -1) {
      // Nếu ngày này đã có trong lịch, thêm món mới vào list
      _mealPlans[existingPlanIndex].recipes.add(recipe);
    } else {
      // Nếu chưa có, tạo mới một MealPlan cho ngày đó
      _mealPlans.add(MealPlan(date: dateOnly, recipes: [recipe]));
    }

    // Sắp xếp lịch trình theo thời gian tăng dần
    _mealPlans.sort((a, b) => a.date.compareTo(b.date));

    notifyListeners(); // Bắt buộc để cập nhật giao diện
  }

  List<String> get shoppingList {
    final List<String> items = [];
    for (var plan in _mealPlans) {
      for (var recipe in plan.recipes) {
        items.addAll(recipe.missingIngredients);
      }
    }
    return items.toSet().toList();
  }
}