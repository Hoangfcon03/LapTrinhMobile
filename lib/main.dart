import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// --- Modules Cốt lõi (FRs) ---
// FR1: Kho Nguyên liệu
import 'features/pantry/presentation/screens/pantry_screen.dart';
import 'features/pantry/domain/pantry_provider.dart';

// FR2: Gợi ý Công thức
import 'features/recipe/presentation/screens/recipe_list_screen.dart';
import 'features/recipe/domain/recipe_provider.dart';

// FR4: Kế hoạch & Mua sắm
import 'features/planner/presentation/screens/planner_screen.dart';

// Module Hồ sơ (Placeholder)
import 'features/profile/presentation/screens/profile_screen.dart';


void main() {
  // Bọc toàn bộ ứng dụng trong MultiProvider để quản lý trạng thái
  runApp(
    MultiProvider(
      providers: [
        // Khởi tạo các Provider (State Management)
        ChangeNotifierProvider(create: (_) => PantryProvider()),
        ChangeNotifierProvider(create: (_) => RecipeProvider()),
        // Thêm PlannerProvider, ShoppingListProvider sau này
      ],
      child: const KitchenAssistantApp(),
    ),
  );
}

class KitchenAssistantApp extends StatelessWidget {
  const KitchenAssistantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bếp Trợ Lý Thông Minh',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Chủ đề màu sắc chính: Xanh lá cây (Fresh/Healthy)
        primarySwatch: Colors.green,
        primaryColor: const Color(0xFF4CAF50),
        hintColor: const Color(0xFFFF9800), // Màu cam làm điểm nhấn/cảnh báo
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0.5,
          iconTheme: IconThemeData(color: Colors.black87),
        ),
        useMaterial3: true,
      ),
      home: const MainLayoutScreen(),
    );
  }
}

class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  int _selectedIndex = 0;

  // Danh sách các màn hình tương ứng với BottomNavigationBar
  // Đã sắp xếp lại để khớp chính xác 4 items
  static final List<Widget> _widgetOptions = <Widget>[
    const PantryScreen(), // Index 0: Kho (FR1)
    const RecipeListScreen(), // Index 1: Công thức (FR2)
    const PlannerScreen(), // Index 2: Kế hoạch (FR4)
    const ProfileScreen(), // Index 3: Hồ sơ
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: 'Kho',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu_outlined),
            activeIcon: Icon(Icons.restaurant_menu),
            label: 'Công thức',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Kế hoạch',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Hồ sơ',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed, // Giúp các tab không bị dịch chuyển
        onTap: _onItemTapped,
      ),
    );
  }
}