import 'package:flutter/material.dart';
// Sửa: Chỉ import Model Ingredient từ file Data gốc của nó
import 'package:bepthongminh64pm1duchoang/features/pantry/data/pantry_data.dart' show Ingredient;

// --- IMPORTS CẦN THIẾT ---
// 1. Service API
import '../../../core/services/recipe_api_service.dart';

// 2. Model Recipe
import 'recipe_model.dart';

// 3. Ingredient Model (KHÔNG import PantryProvider ở đây nếu chỉ cần Model)
// Lệnh import này KHÔNG CẦN THIẾT và gây xung đột, hãy xóa nó:
// import '../../pantry/domain/pantry_provider.dart'; // Đã bị xóa

// 4. Mock Data (Công thức giả)
import '../data/recipe_data.dart' show mockRecipes;


class RecipeProvider with ChangeNotifier {
  final RecipeApiService _apiService = RecipeApiService();
  List<Recipe> _allRecipes = mockRecipes;
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  List<Recipe> get allRecipes => _allRecipes;

  // --- FR2.1 & FR2.2: Lọc Công thức dựa trên Kho Nguyên liệu ---

  // Bây giờ List<Ingredient> sử dụng kiểu dữ liệu đã import (từ pantry_data.dart)
  List<Recipe> getRecipesBasedOnPantry(List<Ingredient> pantryItems) {
    if (_allRecipes.isEmpty) {
      return [];
    }

    // Sửa: Sử dụng name an toàn (Giả định name là non-nullable String trong model Pantry)
    // Nếu name là String? trong model, sử dụng: .map((i) => i.name?.toLowerCase() ?? '')
    final List<String> pantryNames = pantryItems
        .map((i) => i.name.toLowerCase())
        .toList();

    return _allRecipes.where((recipe) {
      int matchCount = 0;
      int requiredCount = recipe.requiredIngredients.length;

      // Đếm số nguyên liệu khớp
      for (String requiredIng in recipe.requiredIngredients) {
        if (pantryNames.contains(requiredIng.toLowerCase())) {
          matchCount++;
        }
      }

      // Áp dụng Flexible Match (FR2.2)
      return requiredCount == 0
          ? false
          : (matchCount / requiredCount) >= 0.5;

    }).toList();
  }

  // --- Logic Tải dữ liệu từ API ---

  Future<void> loadRecipesFromApi(List<String> ingredientNames) async {
    _isLoading = true;
    notifyListeners();

    final List<String> names = ingredientNames.map((e) => e.toLowerCase()).toList();

    try {
      _allRecipes = await _apiService.fetchRecipesByIngredients(names);
    } catch (e) {
      print('Failed to load recipes from API: $e');
      _allRecipes = mockRecipes;
    }

    _isLoading = false;
    notifyListeners();
  }
}