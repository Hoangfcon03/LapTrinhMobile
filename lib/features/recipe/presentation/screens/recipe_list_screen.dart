import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'recipe_detail_screen.dart';
import 'package:bepthongminh64pm1duchoang/features/pantry/domain/pantry_provider.dart';
import 'package:bepthongminh64pm1duchoang/features/recipe/domain/recipe_provider.dart';
import 'package:bepthongminh64pm1duchoang/features/recipe/domain/recipe_model.dart';


class RecipeListScreen extends StatefulWidget {
  const RecipeListScreen({super.key});

  @override
  State<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  // Biến để theo dõi lần đầu tiên gọi API
  bool _isInitialLoad = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_isInitialLoad) {
      // Lấy PantryProvider và RecipeProvider (listen: false)
      final pantryProvider = Provider.of<PantryProvider>(context, listen: false);
      final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);

      // Lấy danh sách tên nguyên liệu để truyền cho API
      final ingredientNames = pantryProvider.ingredients.map((i) => i.name.toString().toLowerCase()).toList();

      // Gọi API để tải công thức dựa trên kho nguyên liệu khi màn hình khởi tạo
      recipeProvider.loadRecipesFromApi(ingredientNames);

      _isInitialLoad = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Lắng nghe PantryProvider (chủ yếu để khi pantry thay đổi, màn hình tự rebuild)
    final pantryProvider = Provider.of<PantryProvider>(context);
    final currentPantry = pantryProvider.ingredients;

    // 2. Lắng nghe RecipeProvider (để lấy danh sách công thức và trạng thái loading)
    return Consumer<RecipeProvider>(
      builder: (context, recipeProvider, child) {

        // Logic lọc công thức theo kho hiện tại
        final List<Recipe> filteredRecipes = recipeProvider.getRecipesBasedOnPantry(currentPantry);

        // Hiển thị trạng thái Loading (NFR3)
        if (recipeProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Giao diện chính của màn hình
        return Scaffold(
          appBar: AppBar(
            title: const Text('Gợi ý Công thức AI'),
            actions: [
              IconButton(
                icon: const Icon(Icons.tune),
                onPressed: () {
                  _showFilterSheet(context);
                },
              ),
            ],
          ),
          body: filteredRecipes.isEmpty
              ? _buildEmptyState(context, currentPantry.isEmpty)
              : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${filteredRecipes.length} Công thức Gợi ý Dựa trên Kho Nguyên liệu (${currentPantry.length} món)',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),

                // Hiển thị danh sách công thức đã lọc
                ...filteredRecipes.map((recipe) => _buildRecipeCard(context, recipe)).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- Các Widgets con (giữ nguyên logic) ---

  Widget _buildEmptyState(BuildContext context, bool isPantryEmpty) {
    // ... (logic Empty State giữ nguyên)
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 80, color: Colors.grey),
            const SizedBox(height: 20),
            Text(
              isPantryEmpty
                  ? 'Kho Nguyên liệu Rỗng'
                  : 'Không tìm thấy công thức phù hợp!',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              isPantryEmpty
                  ? 'Hãy thêm nguyên liệu để bắt đầu nhận gợi ý.'
                  : 'Hãy thêm hoặc mua thêm nguyên liệu còn thiếu.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeCard(BuildContext context, Recipe recipe) {
    // ... (logic Card hiển thị công thức giữ nguyên)
    Color matchColor = recipe.isPerfectMatch ? Theme.of(context).primaryColor : Theme.of(context).hintColor;

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecipeDetailScreen(recipe: recipe),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                recipe.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text('${recipe.cookingTime} phút nấu'),
                ],
              ),
              const SizedBox(height: 10),
              // Trạng thái khớp (Perfect Match hay Flexible Match)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: matchColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  recipe.isPerfectMatch
                      ? '🎯 Khớp Hoàn hảo!'
                      : '⚠️ Gần đủ (${recipe.requiredIngredients.length - recipe.missingIngredients.length}/${recipe.requiredIngredients.length})',
                  style: TextStyle(color: matchColor, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              if (!recipe.isPerfectMatch)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Cần mua thêm: ${recipe.missingIngredients.join(', ')}',
                    style: TextStyle(color: Theme.of(context).hintColor, fontSize: 14),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    // ... (Code cho BottomSheet lọc giữ nguyên)
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bộ lọc Công thức',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Divider(),
              const SizedBox(height: 10),

              _buildFilterSection(context, 'Thời gian nấu', ['Dưới 15 phút', '15-30 phút', 'Trên 30 phút']),
              _buildFilterSection(context, 'Loại bữa ăn', ['Sáng', 'Trưa', 'Tối', 'Ăn nhẹ']),
              _buildFilterSection(context, 'Ẩm thực', ['Việt', 'Âu', 'Á', 'Chay']),

              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Áp dụng', style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterSection(BuildContext context, String title, List<String> options) {
    // ... (logic _buildFilterSection giữ nguyên)
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: options.map((option) => Chip(
              label: Text(option),
              backgroundColor: Colors.grey[200],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            )).toList(),
          ),
        ],
      ),
    );
  }
}