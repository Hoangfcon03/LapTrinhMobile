import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bepthongminh64pm1duchoang/features/pantry/domain/pantry_provider.dart';
import 'package:bepthongminh64pm1duchoang/features/recipe/domain/recipe_provider.dart';
import 'package:bepthongminh64pm1duchoang/features/pantry/data/pantry_data.dart';

class RecipeListScreen extends StatefulWidget {
  const RecipeListScreen({super.key});

  @override
  State<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pantry = Provider.of<PantryProvider>(context, listen: false);
      Provider.of<RecipeProvider>(context, listen: false).fetchAndSuggest(pantry.ingredients);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gợi ý hôm nay'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(context),
          )
        ],
      ),
      body: Consumer<RecipeProvider>(
        builder: (context, recipeProv, child) {
          final results = recipeProv.matchedResults;
          if (results.isEmpty) return const Center(child: Text('Hãy thêm đồ vào kho để nhận gợi ý!'));

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final item = results[index];
              final Recipe recipe = item['recipe'];
              final List<String> missing = item['missing'];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Column(
                  children: [
                    ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(recipe.imageUrl, width: 60, height: 60, fit: BoxFit.cover),
                      ),
                      title: Text(recipe.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${recipe.cookTime} phút | ${recipe.cuisine}'),
                      trailing: _buildMatchBadge(item['matchCount'], item['totalCount']),
                    ),
                    if (missing.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text("🛒 Thiếu: ${missing.join(', ')}",
                              style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
                        ),
                      )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Consumer<RecipeProvider>(
        builder: (context, prov, _) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Lọc theo ẩm thực', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              Wrap(
                spacing: 10,
                children: ['Tất cả', 'Á', 'Âu', 'Chay'].map((c) => ChoiceChip(
                  label: Text(c),
                  selected: prov.selectedCuisine == c,
                  onSelected: (s) => prov.filterByCuisine(c),
                )).toList(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMatchBadge(int match, int total) {
    bool isFull = match == total;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isFull ? Colors.green : Colors.orange.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text("$match/$total", style: TextStyle(
          color: isFull ? Colors.white : Colors.orange.shade900, fontWeight: FontWeight.bold)),
    );
  }
}