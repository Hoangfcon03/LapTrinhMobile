import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/pantry_data.dart';

class PantryProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Ingredient> _ingredients = [];

  List<Ingredient> get ingredients => _ingredients;

  // Lấy đồ sắp hết hạn để hiện cảnh báo
  List<Ingredient> get expiringIngredients =>
      _ingredients.where((item) => item.isExpiringSoon || item.isExpired).toList();

  // Tải dữ liệu từ Firestore
  Future<void> fetchIngredients() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('ingredients')
        .orderBy('expiryDate')
        .get();

    _ingredients = snapshot.docs.map((doc) {
      final data = doc.data();
      return Ingredient(
        id: doc.id,
        name: data['name'] ?? '',
        quantity: data['quantity'] ?? '',
        expiryDate: (data['expiryDate'] as Timestamp).toDate(),
        category: data['category'] ?? 'Khác',
      );
    }).toList();
    notifyListeners();
  }

  // Thêm mới lên Firebase
  Future<void> addIngredient(Ingredient item) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('ingredients')
        .add({
      'name': item.name,
      'quantity': item.quantity,
      'expiryDate': Timestamp.fromDate(item.expiryDate),
      'category': item.category,
    });

    _ingredients.add(Ingredient(
      id: docRef.id, name: item.name, quantity: item.quantity,
      expiryDate: item.expiryDate, category: item.category,
    ));
    _ingredients.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
    notifyListeners();
  }

  // Xóa khỏi Firebase
  Future<void> removeIngredient(String id) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('ingredients')
        .doc(id)
        .delete();

    _ingredients.removeWhere((i) => i.id == id);
    notifyListeners();
  }
}