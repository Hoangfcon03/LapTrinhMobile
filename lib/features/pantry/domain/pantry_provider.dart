import 'package:flutter/material.dart';
// Lỗi này đã được giải quyết sau khi bạn tạo file
import '../data/pantry_data.dart';
export '../data/pantry_data.dart' show Ingredient;
// Lỗi này cũng tự động biến mất vì Ingredient và mockIngredients
// đã được định nghĩa trong pantry_data.dart

class PantryProvider with ChangeNotifier {
  // Khởi tạo với dữ liệu giả đã import
  List<Ingredient> _ingredients = mockIngredients;

  List<Ingredient> get ingredients => _ingredients;

  // Logic thêm nguyên liệu (FR1.1)
  void addIngredient(Ingredient ingredient) {
    _ingredients.add(ingredient);
    notifyListeners();
  }

  // Logic dùng hết/xóa nguyên liệu (FR1.3)
  void removeIngredient(Ingredient ingredient) {
    _ingredients.remove(ingredient);
    notifyListeners();
  }

  // Logic cập nhật số lượng/HSD (FR1.2)
  void updateIngredient(Ingredient oldIng, Ingredient newIng) {
    final index = _ingredients.indexOf(oldIng);
    if (index != -1) {
      _ingredients[index] = newIng;
      notifyListeners();
    }
  }

  // --- Logic Cảnh báo Hết hạn (FR3) ---
  // Sử dụng thuộc tính isExpiringSoon đã định nghĩa trong class Ingredient
  List<Ingredient> get expiringIngredients {
    return _ingredients.where((i) => i.isExpiringSoon).toList();
  }
}