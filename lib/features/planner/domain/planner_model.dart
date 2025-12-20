import 'package:bepthongminh64pm1duchoang/features/recipe/domain/recipe_model.dart';

class MealPlan {
  final DateTime date;
  final List<Recipe> recipes; // Các món ăn được lên kế hoạch cho ngày này

  MealPlan({required this.date, required this.recipes});
}