import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SeedingService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<void> seedAppData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final batch = _db.batch();
    final now = DateTime.now();

    // --- 1. SEED NGUYÊN LIỆU (PANTRY) ---
    // Thêm imageUrl để hiển thị trong Kho đồ
    final pantryRef = _db.collection('users').doc(user.uid).collection('ingredients');

    final ingredients = [
      {
        'name': 'Thịt bò',
        'quantity': '500g',
        'category': 'Thịt',
        'imageUrl': 'https://images.unsplash.com/photo-1588168333986-5078d3ae3973?w=400',
        'expiryDate': Timestamp.fromDate(now.add(const Duration(days: 5)))
      },
      {
        'name': 'Trứng gà',
        'quantity': '10 quả',
        'category': 'Trứng',
        'imageUrl': 'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?w=400',
        'expiryDate': Timestamp.fromDate(now.subtract(const Duration(days: 1))) // Đã hết hạn
      },
      {
        'name': 'Cà chua',
        'quantity': '4 quả',
        'category': 'Rau củ',
        'imageUrl': 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=400',
        'expiryDate': Timestamp.fromDate(now.add(const Duration(days: 2))) // Sắp hết hạn
      },
      {
        'name': 'Hành tây',
        'quantity': '2 củ',
        'category': 'Rau củ',
        'imageUrl': 'https://images.unsplash.com/photo-1508747703725-719777637510?w=400',
        'expiryDate': Timestamp.fromDate(now.add(const Duration(days: 10)))
      },
      {
        'name': 'Mì Ý',
        'quantity': '1 gói',
        'category': 'Đồ khô',
        'imageUrl': 'https://images.unsplash.com/photo-1551462147-37885abb3e4a?w=400',
        'expiryDate': Timestamp.fromDate(now.add(const Duration(days: 180)))
      },
    ];

    for (var ing in ingredients) {
      batch.set(pantryRef.doc(), ing);
    }

    // --- 2. SEED CÔNG THỨC (RECIPES) ---
    // Cập nhật cấu trúc đầy đủ để hiển thị màn hình Chi tiết công thức
    final recipeRef = _db.collection('recipes');

    final recipes = [
      {
        'title': 'Mì Ý sốt bò băm',
        'cookTime': 30,
        'cuisine': 'Âu',
        'mealType': 'Tối',
        'imageUrl': 'https://images.unsplash.com/photo-1510627489930-0c1b0ba9448f?w=600',
        'ingredients': ['Mì Ý', 'Thịt bò', 'Cà chua', 'Hành tây'],
        'steps': [
          'Luộc mì Ý trong nước sôi khoảng 8-10 phút.',
          'Băm nhỏ thịt bò và hành tây.',
          'Xào thịt bò với sốt cà chua và hành tây.',
          'Trộn mì vào sốt và thưởng thức.'
        ]
      },
      {
        'title': 'Trứng xào cà chua',
        'cookTime': 15,
        'cuisine': 'Á',
        'mealType': 'Sáng',
        'imageUrl': 'https://images.unsplash.com/photo-1525351484163-7529414344d8?w=600',
        'ingredients': ['Trứng gà', 'Cà chua'],
        'steps': [
          'Rửa sạch và cắt cà chua thành miếng nhỏ.',
          'Đánh tan trứng với một chút gia vị.',
          'Xào cà chua cho đến khi mềm.',
          'Đổ trứng vào đảo đều cho đến khi chín.'
        ]
      }
    ];

    for (var recipe in recipes) {
      batch.set(recipeRef.doc(), recipe);
    }

    await batch.commit();
  }
}