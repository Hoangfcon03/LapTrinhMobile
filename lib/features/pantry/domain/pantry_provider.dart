import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/pantry_data.dart';

class PantryProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Ingredient> _ingredients = [];

  // Getter cho tất cả nguyên liệu
  List<Ingredient> get ingredients => _ingredients;

  // Getter cho đồ ĐÃ hết hạn
  List<Ingredient> get expiredIngredients =>
      _ingredients.where((item) => item.isExpired).toList();

  // GIẢI QUYẾT LỖI: Thêm getter cho đồ SẮP hết hạn
  List<Ingredient> get expiringSoonIngredients =>
      _ingredients.where((item) => item.isExpiringSoon).toList();
  // FR1.1 & FR1.2: Thêm nguyên liệu
  Future<void> addIngredient(Ingredient item) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = await _firestore
        .collection('users').doc(user.uid).collection('ingredients').add({
      'name': item.name,
      'quantity': item.quantity,
      'expiryDate': Timestamp.fromDate(item.expiryDate),
      'category': item.category,
    });

    _ingredients.add(Ingredient(
      id: docRef.id,
      name: item.name,
      quantity: item.quantity,
      expiryDate: item.expiryDate,
      category: item.category,
    ));
    notifyListeners();
  }

  // FR1.3: Cập nhật số lượng hoặc xóa nếu dùng hết
  Future<void> updateQuantity(String id, String newQuantity) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (newQuantity.trim().toLowerCase() == 'hết' || newQuantity == '0') {
      await removeIngredient(id);
    } else {
      await _firestore.collection('users').doc(user.uid)
          .collection('ingredients').doc(id).update({'quantity': newQuantity});
      await fetchIngredients();
    }
  }

  Future<void> removeIngredient(String id) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await _firestore.collection('users').doc(user.uid)
        .collection('ingredients').doc(id).delete();
    _ingredients.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  Future<void> fetchIngredients() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final snapshot = await _firestore.collection('users').doc(user.uid)
        .collection('ingredients').orderBy('expiryDate').get();

    _ingredients = snapshot.docs.map((doc) {
      final data = doc.data();
      return Ingredient(
        id: doc.id,
        name: data['name'] ?? '',
        quantity: data['quantity'] ?? '',
        expiryDate: (data['expiryDate'] as Timestamp).toDate(),
        category: data['category'] ?? '',
      );
    }).toList();
    notifyListeners();
  }

  // HÀM SEEDING: Sinh dữ liệu mẫu toàn bộ App
  Future<void> seedFullAppData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final batch = _firestore.batch();

    // Seed Kho
    final pantryRef = _firestore.collection('users').doc(user.uid).collection('ingredients');
    batch.set(pantryRef.doc(), {
      'name': 'Thịt bò', 'quantity': '500g',
      'expiryDate': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 1))),
      'category': 'Thịt'
    });

    // Seed Công thức
    final recipeRef = _firestore.collection('recipes');
    batch.set(recipeRef.doc(), {
      'title': 'Bò xào cần tây',
      'ingredients': ['Thịt bò', 'Cần tây'],
      'steps': ['Thái bò', 'Xào nhanh với cần'],
      'imageUrl': 'https://picsum.photos/200'
    });

    await batch.commit();
    await fetchIngredients();
  }
}