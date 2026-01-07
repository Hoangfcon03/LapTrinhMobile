import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/pantry_data.dart';

class PantryProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Ingredient> _ingredients = [];
  List<Ingredient> get ingredients => _ingredients;

  List<Ingredient> get expiredIngredients => _ingredients.where((i) => i.isExpired).toList();
  List<Ingredient> get expiringSoonIngredients => _ingredients.where((i) => i.isExpiringSoon).toList();

  // 1. TẢI DỮ LIỆU TỪ FIRESTORE
  Future<void> fetchIngredients() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('ingredients')
        .get();

    _ingredients = snapshot.docs.map((doc) {
      final data = doc.data();
      return Ingredient(
        id: doc.id,
        name: data['name'] ?? '',
        quantity: data['quantity'] ?? '',
        expiryDate: (data['expiryDate'] as Timestamp).toDate(),
        category: data['category'] ?? 'Chung',
        imageUrl: data['imageUrl'] ?? '', // THÊM DÒNG NÀY
      );
    }).toList();
    notifyListeners();
  }

  // 2. THÊM NGUYÊN LIỆU MỚI
  Future<void> addIngredient(Ingredient item) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).collection('ingredients').add({
      'name': item.name,
      'quantity': item.quantity,
      'expiryDate': Timestamp.fromDate(item.expiryDate),
      'category': item.category,
      'imageUrl': item.imageUrl, // THÊM DÒNG NÀY
    });
    fetchIngredients();
  }

  // 3. XÓA NGUYÊN LIỆU
  Future<void> removeIngredient(String id) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await _firestore.collection('users').doc(user.uid).collection('ingredients').doc(id).delete();
    _ingredients.removeWhere((i) => i.id == id);
    notifyListeners();
  }

  // 4. CẬP NHẬT SỐ LƯỢNG
  Future<void> updateQuantity(String id, String newQty) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (newQty.trim().toLowerCase() == 'hết' || newQty == '0') {
      await removeIngredient(id);
    } else {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('ingredients')
          .doc(id)
          .update({'quantity': newQty});
      fetchIngredients();
    }
  }

  // 5. KHỞI TẠO DỮ LIỆU MẪU (Bổ sung link ảnh Internet)
  Future<void> seedFullAppData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final batch = _firestore.batch();
    final now = DateTime.now();
    final pantryRef = _firestore.collection('users').doc(user.uid).collection('ingredients');

    final dummyIngredients = [
      // THỊT & HẢI SẢN
      {'name': 'Thịt bò thăn', 'quantity': '500g', 'expiryDate': now.subtract(const Duration(days: 1)), 'category': 'Thịt', 'imageUrl': 'https://images.unsplash.com/photo-1588168333986-5078d3ae3973?w=200'},
      {'name': 'Ức gà', 'quantity': '400g', 'expiryDate': now.add(const Duration(days: 5)), 'category': 'Thịt', 'imageUrl': 'https://images.unsplash.com/photo-1604503468506-a8da13d82791?w=200'},
      {'name': 'Tôm tươi', 'quantity': '300g', 'expiryDate': now.add(const Duration(days: 1)), 'category': 'Hải sản', 'imageUrl': 'https://images.unsplash.com/photo-1559742811-822873691df8?w=200'},

      // RAU CỦ
      {'name': 'Cà chua', 'quantity': '5 quả', 'expiryDate': now.add(const Duration(days: 4)), 'category': 'Rau củ', 'imageUrl': 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=200'},
      {'name': 'Bông cải xanh', 'quantity': '1 cây', 'expiryDate': now.subtract(const Duration(days: 2)), 'category': 'Rau củ', 'imageUrl': 'https://images.unsplash.com/photo-1584270354949-c26b0d5b4a0c?w=200'},
      {'name': 'Cà rốt', 'quantity': '3 củ', 'expiryDate': now.add(const Duration(days: 10)), 'category': 'Rau củ', 'imageUrl': 'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=200'},

      // TRỨNG & SỮA
      {'name': 'Trứng gà', 'quantity': '10 quả', 'expiryDate': now.add(const Duration(days: 7)), 'category': 'Trứng', 'imageUrl': 'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?w=200'},
      {'name': 'Sữa tươi', 'quantity': '1 lít', 'expiryDate': now.add(const Duration(days: 1)), 'category': 'Sữa', 'imageUrl': 'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=200'},

      // ĐỒ KHÔ
      {'name': 'Mì Ý (Spaghetti)', 'quantity': '500g', 'expiryDate': now.add(const Duration(days: 300)), 'category': 'Đồ khô', 'imageUrl': 'https://images.unsplash.com/photo-1551462147-37885abb3e4a?w=200'},
    ];

    for (var item in dummyIngredients) {
      batch.set(pantryRef.doc(), {
        'name': item['name'],
        'quantity': item['quantity'],
        'expiryDate': Timestamp.fromDate(item['expiryDate'] as DateTime),
        'category': item['category'],
        'imageUrl': item['imageUrl'], // THÊM DÒNG NÀY
      });
    }

    // 6. SINH CÔNG THỨC MẪU
    final recipeRef = _firestore.collection('recipes');
    final dummyRecipes = [
      {
        'title': 'Mì Ý sốt bò băm',
        'ingredients': ['Mì Ý (Spaghetti)', 'Thịt bò thăn', 'Cà chua', 'Hành tây'],
        'cookTime': 30, 'cuisine': 'Âu', 'mealType': 'Tối',
        'imageUrl': 'https://images.unsplash.com/photo-1510627489930-0c1b0ba9448f?w=400',
        'steps': ['Luộc mì', 'Làm sốt bò băm', 'Trộn mì với sốt']
      },
      // ... thêm các công thức khác nếu muốn
    ];

    for (var r in dummyRecipes) {
      batch.set(recipeRef.doc(), r);
    }

    await batch.commit();
    await fetchIngredients();
    notifyListeners();
  }
}