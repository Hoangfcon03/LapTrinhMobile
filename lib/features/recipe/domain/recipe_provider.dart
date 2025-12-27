import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../pantry/data/pantry_data.dart';

class RecipeProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _allMatched = [];
  List<Map<String, dynamic>> _filtered = [];
  String _cuisine = 'Tất cả';

  List<Map<String, dynamic>> get matchedResults => _filtered;
  String get selectedCuisine => _cuisine;

  void filterByCuisine(String c) {
    _cuisine = c;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    _filtered = _cuisine == 'Tất cả'
        ? _allMatched
        : _allMatched.where((i) => (i['recipe'] as Recipe).cuisine == _cuisine).toList();
  }

  Future<void> fetchAndSuggest(List<Ingredient> pantry) async {
    final snapshot = await _firestore.collection('recipes').get();
    final recipes = snapshot.docs.map((doc) {
      final d = doc.data();
      return Recipe(
        id: doc.id, title: d['title'] ?? '',
        ingredients: List<String>.from(d['ingredients'] ?? []),
        steps: List<String>.from(d['steps'] ?? []),
        imageUrl: d['imageUrl'] ?? '', cookTime: d['cookTime'] ?? 30,
        cuisine: d['cuisine'] ?? 'Á', mealType: d['mealType'] ?? 'Trưa',
      );
    }).toList();

    final pantryNames = pantry.map((e) => e.name.toLowerCase()).toList();

    _allMatched = recipes.map((r) {
      List<String> missing = [];
      int match = 0;
      for (var ing in r.ingredients) {
        if (pantryNames.any((p) => p.contains(ing.toLowerCase()))) match++;
        else missing.add(ing);
      }
      return {'recipe': r, 'matchCount': match, 'totalCount': r.ingredients.length, 'missing': missing};
    }).toList();

    _allMatched.sort((a, b) => (b['matchCount'] as int).compareTo(a['matchCount'] as int));
    _applyFilter();
    notifyListeners();
  }
}