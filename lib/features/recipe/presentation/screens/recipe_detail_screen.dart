//CÔng thức nấu ăn

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// --- IMPORT TUYỆT ĐỐI ---
import 'package:bepthongminh64pm1duchoang/features/recipe/domain/recipe_model.dart';
import 'package:bepthongminh64pm1duchoang/features/pantry/domain/pantry_provider.dart';
import 'package:bepthongminh64pm1duchoang/features/planner/domain/planner_provider.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  Future<void> _selectDateAndPlan(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      helpText: 'Chọn ngày nấu món này',
    );

    if (picked != null) {
      Provider.of<PlannerProvider>(context, listen: false)
          .addRecipeToPlan(picked, recipe);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã thêm "${recipe.name}" vào ngày ${picked.day}/${picked.month}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.name),
        actions: [
          // SỬA LỖI: Dùng IconButton trên AppBar sẽ đẹp và chuẩn hơn là nhét ElevatedButton vào đây
          IconButton(
            onPressed: () => _selectDateAndPlan(context),
            icon: const Icon(Icons.calendar_month), // Đổi icon để tránh lỗi 'undefined'
            tooltip: 'Lên lịch bữa ăn',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Container giả lập ảnh món ăn để giao diện không bị trống
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.grey[200],
              child: const Icon(Icons.restaurant, size: 100, color: Colors.grey),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _selectDateAndPlan(context),
                  // SỬA LỖI: Xóa 'const' trước Icon nếu bạn vẫn gặp lỗi,
                  // nhưng dùng Icons.event thì 'const' sẽ hoạt động bình thường
                  icon: const Icon(Icons.event),
                  label: const Text('Lên lịch nấu món này'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}