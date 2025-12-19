// lib/features/recipe/domain/recipe_model.dart

class Recipe {
  final String id;
  final String name;
  final int cookingTime;
  final List<String> requiredIngredients;
  final List<String> missingIngredients;

  Recipe({
    required this.id,
    required this.name,
    required this.cookingTime,
    required this.requiredIngredients,
    required this.missingIngredients,
  });
  bool get isPerfectMatch => missingIngredients.isEmpty;

  // Constructor giả để map từ JSON (nếu dùng API thật)
  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id']?.toString() ?? '0',
      name: json['title'] ?? 'Công thức không tên',
      cookingTime: 20, // Giả định
      requiredIngredients: [], // Cần map chi tiết hơn nếu dùng API
      missingIngredients: [],
    );
  }
}