// lib/features/recipe/data/recipe_data.dart

import '../domain/recipe_model.dart';

final List<Recipe> mockRecipes = [
  Recipe(
    id: '1',
    name: 'Thịt bò xào cà rốt',
    cookingTime: 15,
    requiredIngredients: ['Thịt bò', 'Cà rốt', 'Tỏi'],
    missingIngredients: ['Tỏi'],
  ),
  Recipe(
    id: '2',
    name: 'Trứng ốp la',
    cookingTime: 5,
    requiredIngredients: ['Trứng gà', 'Dầu ăn'],
    missingIngredients: [],
  ),
  // ... thêm các công thức giả khác
];