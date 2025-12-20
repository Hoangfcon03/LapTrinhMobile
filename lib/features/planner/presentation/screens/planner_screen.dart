import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bepthongminh64pm1duchoang/features/planner/domain/planner_provider.dart';

class PlannerScreen extends StatelessWidget {
  const PlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kế hoạch Bữa ăn'),
        centerTitle: true,
      ),
      body: Consumer<PlannerProvider>(
        builder: (context, planner, child) {
          // TRƯỜNG HỢP CHƯA CÓ DỮ LIỆU
          if (planner.mealPlans.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today_outlined, size: 100, color: Colors.grey[300]),
                  const SizedBox(height: 20),
                  const Text('Lịch trình của bạn đang trống', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  const Text('Hãy chọn món ăn từ danh sách gợi ý!', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          // TRƯỜNG HỢP ĐÃ CÓ DỮ LIỆU
          return Column(
            children: [
              if (planner.shoppingList.isNotEmpty)
                _buildShoppingList(context, planner.shoppingList),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Thực đơn tuần này', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
              ),

              Expanded(
                child: ListView.builder(
                  itemCount: planner.mealPlans.length,
                  itemBuilder: (context, index) {
                    final plan = planner.mealPlans[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Text('${plan.date.day}', style: const TextStyle(color: Colors.white)),
                        ),
                        title: Text('Thứ ..., ngày ${plan.date.day}/${plan.date.month}'),
                        subtitle: Text(
                          plan.recipes.map((r) => r.name).join(', '),
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                      ),
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
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.shopping_basket, color: Colors.orange),
              SizedBox(width: 8),
              Text('Cần mua cho kế hoạch:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 8),
          Text(items.join(' • ')),
        ],
      ),
    );
  }
}