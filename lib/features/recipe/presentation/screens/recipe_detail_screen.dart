import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../planner/domain/planner_provider.dart';

class RecipeDetailScreen extends StatelessWidget {
  final dynamic recipe; // Nhận đối tượng Recipe từ màn hình Gợi ý

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(recipe.imageUrl, fit: BoxFit.cover),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(recipe.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.timer, size: 18, color: Colors.orange),
                        Text(' ${recipe.cookTime} phút'),
                        const SizedBox(width: 16),
                        const Icon(Icons.restaurant, size: 18, color: Colors.blue),
                        Text(' ${recipe.cuisine}'),
                      ],
                    ),
                    const Divider(height: 32),
                    const Text("Nguyên liệu", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ...recipe.ingredients.map((ing) => ListTile(
                      leading: const Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
                      title: Text(ing),
                    )),
                    const Divider(height: 32),
                    const Text("Các bước thực hiện", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ...recipe.steps.asMap().entries.map((entry) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text("${entry.key + 1}. ${entry.value}"),
                    )),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _showDatePicker(context),
                        icon: const Icon(Icons.calendar_month),
                        label: const Text("LÊN KẾ HOẠCH NẤU MÓN NÀY"),
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  void _showDatePicker(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (date != null && context.mounted) {
      Provider.of<PlannerProvider>(context, listen: false).addToPlan(date, recipe);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã thêm ${recipe.title} vào kế hoạch ngày ${date.day}/${date.month}'))
      );
    }
  }
}