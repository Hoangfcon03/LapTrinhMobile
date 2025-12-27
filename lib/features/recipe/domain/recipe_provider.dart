import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bepthongminh64pm1duchoang/features/pantry/data/pantry_data.dart';

class RecipeProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Recipe> _allRecipes = [];
  List<Recipe> _suggestedRecipes = [];

  List<Recipe> get suggestedRecipes => _suggestedRecipes;

  Future<void> fetchAndSuggest(List<Ingredient>? pantryItems) async {
    // XỬ LÝ LỖI NULL: Nếu pantryItems chưa có dữ liệu thì không làm gì cả
    if (pantryItems == null || pantryItems.isEmpty) {
      _suggestedRecipes = [];
      notifyListeners();
      return;
    }

    try {
      // 1. Tải toàn bộ công thức từ Firebase
      final snapshot = await _firestore.collection('recipes').get();
      _allRecipes = snapshot.docs.map((doc) {
        final data = doc.data();
        return Recipe(
          id: doc.id,
          title: data['title'] ?? 'Không tên',
          ingredients: List<String>.from(data['ingredients'] ?? []),
          steps: List<String>.from(data['steps'] ?? []),
          imageUrl: data['imageUrl'] ?? 'https://picsum.photos/200',
        );
      }).toList();

      // 2. Lọc gợi ý
      final pantryNames = pantryItems.map((e) => e.name.toLowerCase()).toList();

      _suggestedRecipes = _allRecipes.where((recipe) {
        return recipe.ingredients.any((ing) =>
            pantryNames.any((pName) => pName.contains(ing.toLowerCase())));
      }).toList();

      notifyListeners();
    } catch (e) {
      debugPrint("Lỗi tải công thức: $e");
    }
  }
}