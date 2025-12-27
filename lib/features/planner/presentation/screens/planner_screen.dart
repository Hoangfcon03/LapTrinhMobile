import 'package:flutter/material.dart'; // BẮT BUỘC: Thêm import này
import 'package:provider/provider.dart';
import '../../domain/planner_provider.dart';

class PlannerScreen extends StatelessWidget {
  const PlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch nấu ăn'),
        centerTitle: true,
      ),
      body: Consumer<PlannerProvider>(
        builder: (context, planner, child) {
          // Kiểm tra nếu kế hoạch trống
          if (planner.plan.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("Chưa có kế hoạch nấu ăn nào.",
                      style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          // Hiển thị danh sách kế hoạch theo ngày
          return ListView(
            children: planner.plan.entries.map((entry) {
              final String dateKey = entry.key;
              final List<dynamic> recipes = entry.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header hiển thị ngày
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    color: Colors.orange.withAlpha(30),
                    width: double.infinity,
                    child: Text(
                      "Ngày: $dateKey",
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                    ),
                  ),
                  // Danh sách các món ăn trong ngày đó
                  ...recipes.map((recipe) => ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        recipe.imageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.restaurant),
                      ),
                    ),
                    title: Text(recipe.title, style: const TextStyle(fontWeight: FontWeight.w500)),
                    subtitle: Text("${recipe.cookTime} phút"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () {
                        // SỬA LỖI: Thêm logic xóa thực tế
                        _confirmDelete(context, planner, dateKey, recipe);
                      },
                    ),
                  )),
                  const Divider(height: 1),
                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }

  // Hàm xác nhận xóa món ăn
  void _confirmDelete(BuildContext context, PlannerProvider planner, String dateKey, dynamic recipe) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa khỏi kế hoạch?'),
        content: Text('Bạn có chắc muốn xóa món "${recipe.title}" khỏi ngày $dateKey?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('HỦY')),
          TextButton(
            onPressed: () {
              // Parse ngược lại dateKey thành DateTime (giả định dateKey là YYYY-MM-DD)
              final parts = dateKey.split('-');
              final date = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));

              planner.removeFromPlan(date, recipe.id);
              Navigator.pop(ctx);
            },
            child: const Text('XÓA', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}