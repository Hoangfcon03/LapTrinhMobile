import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bepthongminh64pm1duchoang/features/planner/domain/planner_provider.dart';
import 'package:bepthongminh64pm1duchoang/features/recipe/domain/recipe_model.dart';

class PlannerScreen extends StatelessWidget {
  const PlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kế hoạch Bữa ăn')),
      body: Consumer<PlannerProvider>(
        builder: (context, planner, child) {
          final shoppingList = planner.shoppingList;

          return Column(
            children: [
              // Phần danh sách mua sắm (Shopping List)
              if (shoppingList.isNotEmpty)
                _buildShoppingList(context, shoppingList),

              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Lịch trình tuần này', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),

              // Danh sách các ngày đã lên kế hoạch
              Expanded(
                child: ListView.builder(
                  itemCount: planner.mealPlans.length,
                  itemBuilder: (context, index) {
                    final plan = planner.mealPlans[index];
                    return ListTile(
                      title: Text('Ngày ${plan.date.day}/${plan.date.month}'),
                      subtitle: Text(plan.recipes.map((r) => r.name).join(', ')),
                      leading: const Icon(Icons.calendar_today),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildShoppingList(BuildContext context, List<String> items) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🛒 Cần mua cho kế hoạch:', style: TextStyle(fontWeight: FontWeight.bold)),
          Text(items.join(', ')),
        ],
      ),
    );
  }
}