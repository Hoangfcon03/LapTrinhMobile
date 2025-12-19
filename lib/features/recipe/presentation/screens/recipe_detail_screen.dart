import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// 1. Lấy Provider và Model Ingredient
// Đảm bảo tên package chính xác là 'bepthongminh64pm1duchoang'
import 'package:bepthongminh64pm1duchoang/features/pantry/domain/pantry_provider.dart';

// 2. Lấy Model Recipe
import 'package:bepthongminh64pm1duchoang/features/recipe/domain/recipe_model.dart';
import 'package:flutter/material.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;

  // Bỏ 'const' khỏi constructor
  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    // Lấy danh sách nguyên liệu hiện tại từ Provider (không lắng nghe)
    // CẦN ĐẢM BẢO PantryProvider VÀ Ingredient ĐÃ ĐƯỢC IMPORT THÀNH CÔNG
    final currentPantry = Provider.of<PantryProvider>(context, listen: false).ingredients;

    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.name),
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: Center(
                      child: recipe.name.contains('Trứng')
                          ? const Icon(Icons.egg, size: 80, color: Colors.white)
                          : const Icon(Icons.kitchen, size: 80, color: Colors.white)
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.name,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      // ... (Phần hiển thị thời gian nấu)

                      const Divider(height: 30),

                      Text(
                        '🛒 Nguyên liệu Cần thiết',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      // Truyền currentPantry vào method build
                      ...recipe.requiredIngredients.map((ing) =>
                          _buildIngredientItem(context, ing, currentPantry)).toList(),
                      const Divider(height: 30),

                      // ... (Phần Các bước thực hiện)

                      _buildStep(context, 1, 'Sơ chế: Rửa sạch các nguyên liệu cần thiết.'),
                      _buildStep(context, 2, 'Chuẩn bị gia vị: Ướp thịt (nếu có) với một chút muối, tiêu trong 5 phút.'),
                      _buildStep(context, 3, 'Chế biến: Xào (hoặc nấu) nguyên liệu theo thứ tự cứng trước mềm sau.'),
                      _buildStep(context, 4, 'Hoàn thành: Dọn ra đĩa và thưởng thức món ăn của bạn!'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ... (Phần Nút hành động nổi FAB)
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: recipe.missingIngredients.isNotEmpty
                ? ElevatedButton.icon(
              onPressed: () {
                // ... (Xử lý Thêm nguyên liệu thiếu vào Danh sách Mua sắm)
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Đã thêm ${recipe.missingIngredients.length} món vào Danh sách Mua sắm!')),
                );
              },
              icon: const Icon(Icons.shopping_cart, color: Colors.white),
              label: Text('Thêm ${recipe.missingIngredients.length} món còn thiếu vào Danh sách Mua sắm'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).hintColor,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  // Sửa lỗi Null Safety: Dùng p.name?.toLowerCase()
  Widget _buildIngredientItem(BuildContext context, String ing, List<Ingredient> currentPantry) {
    // Kiểm tra xem nguyên liệu này có trong kho hiện tại không (So sánh không phân biệt chữ hoa/thường)
    final isHave = currentPantry.any((p) => p.name?.toLowerCase() == ing.toLowerCase());

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        // ... (UI hiển thị icon và text)
        children: [
          Icon(
            isHave ? Icons.check_circle : Icons.warning_amber_rounded,
            color: isHave ? Theme.of(context).primaryColor : Theme.of(context).hintColor,
            size: 20,
          ),
          const SizedBox(width: 10),
          Text(
            ing,
            style: TextStyle(
              fontSize: 16,
              decoration: isHave ? TextDecoration.none : TextDecoration.underline,
              color: isHave ? Colors.black : Theme.of(context).hintColor,
              fontWeight: isHave ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const Spacer(),
          Text(
            isHave ? 'ĐÃ CÓ' : 'CẦN MUA',
            style: TextStyle(
              fontSize: 14,
              color: isHave ? Theme.of(context).primaryColor : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Phương thức cho các bước
  Widget _buildStep(BuildContext context, int number, String instruction) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      // ... (UI cho từng bước)
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$number',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              instruction,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}