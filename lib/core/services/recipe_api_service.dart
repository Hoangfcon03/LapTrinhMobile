import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../features/recipe/domain/recipe_model.dart'; // Định nghĩa Recipe Model chi tiết hơn
import '../../features/recipe/data/recipe_data.dart'; // Thêm import cho mock data

class RecipeApiService {
  // Thay thế bằng API Key thực tế của bạn
  static const String API_KEY = 'YOUR_SPOONACULAR_API_KEY';
  static const String BASE_URL = 'https://api.spoonacular.com/recipes';

  // Logic gọi API dựa trên danh sách nguyên liệu
  Future<List<Recipe>> fetchRecipesByIngredients(List<String> ingredients) async {
    // Chuyển danh sách nguyên liệu thành chuỗi (ví dụ: apple,flour,sugar)
    final String ingredientString = ingredients.join(',');

    final Uri uri = Uri.parse(
        '$BASE_URL/findByIngredients?ingredients=$ingredientString&number=10&apiKey=$API_KEY'
    );

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        // Đây là nơi bạn cần Map JSON Data về Recipe Model
        // return data.map((json) => Recipe.fromJson(json)).toList();

        // Vì đây là giả lập, chúng ta sẽ trả về mock data
        return mockRecipes;
      } else {
        // Xử lý lỗi API
        throw Exception('Failed to load recipes: ${response.statusCode}');
      }
    } catch (e) {
      // Xử lý lỗi mạng
      print('API Error: $e');
      return mockRecipes; // Trả về mock data nếu lỗi
    }
  }
}