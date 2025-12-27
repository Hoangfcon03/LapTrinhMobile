import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

// --- IMPORT CÁC PROVIDERS ---
import 'package:bepthongminh64pm1duchoang/features/auth/domain/auth_provider.dart';
import 'package:bepthongminh64pm1duchoang/features/pantry/domain/pantry_provider.dart';
import 'package:bepthongminh64pm1duchoang/features/recipe/domain/recipe_provider.dart';
import 'package:bepthongminh64pm1duchoang/features/planner/domain/planner_provider.dart';
import 'package:bepthongminh64pm1duchoang/features/alerts/domain/alerts_provider.dart';

// --- IMPORT CÁC SCREENS ---
import 'package:bepthongminh64pm1duchoang/features/auth/presentation/screens/auth_screen.dart';
import 'package:bepthongminh64pm1duchoang/features/pantry/presentation/screens/pantry_screen.dart';
import 'package:bepthongminh64pm1duchoang/features/recipe/presentation/screens/recipe_list_screen.dart';
import 'package:bepthongminh64pm1duchoang/features/planner/presentation/screens/planner_screen.dart';
import 'package:bepthongminh64pm1duchoang/features/profile/presentation/screens/profile_screen.dart';
import 'package:bepthongminh64pm1duchoang/features/pantry/data/pantry_data.dart'; // Đảm bảo import để dùng Ingredient

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MultiProviderWrapper());
}

class MultiProviderWrapper extends StatelessWidget {
  const MultiProviderWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PantryProvider()),
        ChangeNotifierProvider(create: (_) => RecipeProvider()),
        ChangeNotifierProvider(create: (_) => PlannerProvider()),
        ChangeNotifierProvider(create: (_) => AlertsProvider()),
      ],
      child: MaterialApp(
        title: 'Bếp Trợ Lý Thông Minh',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4CAF50)),
        ),
        home: const AuthCheck(),
      ),
    );
  }
}

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return auth.isLoggedIn ? const MainLayout() : const AuthScreen();
  }
}

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const PantryScreen(),
    const RecipeListScreen(),
    const PlannerScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Tự động kiểm tra hạn sử dụng khi vừa vào app
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final pantry = Provider.of<PantryProvider>(context, listen: false);
      await pantry.fetchIngredients();

      // Tính tổng thực phẩm cần chú ý (Hết hạn + Sắp hết hạn)
      int totalAlerts = pantry.expiredIngredients.length + pantry.expiringSoonIngredients.length;

      if (mounted && totalAlerts > 0) {
        _showExpiryDialog(context, totalAlerts);
      }
    });
  }

  void _showExpiryDialog(BuildContext context, int count) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.notification_important, color: Colors.orange),
            SizedBox(width: 10),
            Text('Thông báo kho đồ'),
          ],
        ),
        content: Text('Bạn có $count thực phẩm đã hết hạn hoặc sắp hết hạn. Hãy kiểm tra ngay!'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('ĐỂ SAU')
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () {
              Navigator.pop(ctx);
              // ĐIỀU HƯỚNG SANG AlertsScreen (Màn hình liệt kê cả 2 loại)
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AlertsScreen()),
              );
            },
            child: const Text('XEM NGAY', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: 'Kho'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: 'Công thức'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Kế hoạch'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Hồ sơ'),
        ],
      ),
    );
  }
}

// --- MÀN HÌNH ALERTS SCREEN (Nên để ở file riêng, nhưng mình gộp đây để bạn dễ copy) ---
class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách Cảnh báo'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: Consumer<PantryProvider>(
        builder: (context, pantry, child) {
          final expired = pantry.expiredIngredients;
          final soon = pantry.expiringSoonIngredients;

          if (expired.isEmpty && soon.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
                  SizedBox(height: 16),
                  Text('Tất cả thực phẩm đều an toàn!',
                      style: TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (expired.isNotEmpty) ...[
                const Text("❌ ĐÃ HẾT HẠN (CẦN LOẠI BỎ)",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 14)),
                ...expired.map((item) => _buildAlertCard(context, item, Colors.red, true)),
                const SizedBox(height: 20),
              ],
              if (soon.isNotEmpty) ...[
                const Text("⚠️ SẮP HẾT HẠN (ƯU TIÊN SỬ DỤNG)",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 14)),
                ...soon.map((item) => _buildAlertCard(context, item, Colors.orange, false)),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildAlertCard(BuildContext context, Ingredient item, Color color, bool isExpired) {
    return Card(
      elevation: 0,
      color: color.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.3)),
      ),
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: const Icon(Icons.priority_high, color: Colors.white, size: 20),
        ),
        title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('HSD: ${item.expiryDate.day}/${item.expiryDate.month}/${item.expiryDate.year}'),
        trailing: isExpired
            ? IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () {
            Provider.of<PantryProvider>(context, listen: false).removeIngredient(item.id);
          },
        )
            : const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }
}