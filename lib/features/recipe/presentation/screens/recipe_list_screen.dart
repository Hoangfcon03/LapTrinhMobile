import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// SỬA LỖI IMPORT TUYỆT ĐỐI
import 'package:bepthongminh64pm1duchoang/features/pantry/domain/pantry_provider.dart';
import 'package:bepthongminh64pm1duchoang/features/recipe/domain/recipe_provider.dart';

class RecipeListScreen extends StatefulWidget {
  const RecipeListScreen({super.key});

  @override
  State<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  @override
  void initState() {
    super.initState();
    // Tự động gợi ý dựa trên kho đồ hiện tại khi vào màn hình
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pantryProv = Provider.of<PantryProvider>(context, listen: false);
      final recipeProv = Provider.of<RecipeProvider>(context, listen: false);

      // Gọi hàm fetch dữ liệu từ Firebase
      recipeProv.fetchAndSuggest(pantryProv.ingredients);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gợi ý món ngon'),
        centerTitle: true,
      ),
      body: Consumer<RecipeProvider>(
        builder: (context, recipeProv, child) {
          // XỬ LÝ LỖI NULL: Kiểm tra danh sách suggestedRecipes
          final recipes = recipeProv.suggestedRecipes;

          if (recipes.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.flatware, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Chưa có món phù hợp. Hãy thêm đồ vào kho!'),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: 2,
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      recipe.imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.restaurant, size: 40),
                    ),
                  ),
                  title: Text(recipe.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Nguyên liệu: ${recipe.ingredients.join(", ")}'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Logic chuyển trang chi tiết sau này
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}