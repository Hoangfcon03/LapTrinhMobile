import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// --- Import Tuyệt đối (Sửa lại cho đồng bộ) ---
import 'package:bepthongminh64pm1duchoang/features/pantry/domain/pantry_provider.dart';
import 'package:bepthongminh64pm1duchoang/features/pantry/presentation/screens/pantry_screen.dart';

import 'package:bepthongminh64pm1duchoang/features/recipe/domain/recipe_provider.dart';
import 'package:bepthongminh64pm1duchoang/features/recipe/presentation/screens/recipe_list_screen.dart';

import 'package:bepthongminh64pm1duchoang/features/planner/domain/planner_provider.dart';
import 'package:bepthongminh64pm1duchoang/features/planner/presentation/screens/planner_screen.dart';

import 'package:bepthongminh64pm1duchoang/features/auth/domain/auth_provider.dart';
import 'package:bepthongminh64pm1duchoang/features/auth/presentation/screens/auth_screen.dart';

import 'package:bepthongminh64pm1duchoang/features/profile/presentation/screens/profile_screen.dart';

// Thêm import cho module Alerts
import 'package:bepthongminh64pm1duchoang/features/alerts/domain/alerts_provider.dart';
import 'package:bepthongminh64pm1duchoang/features/alerts/domain/alert_model.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        // Chỉ khai báo MỖI PROVIDER MỘT LẦN duy nhất
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PantryProvider()),
        ChangeNotifierProvider(create: (_) => RecipeProvider()),
        ChangeNotifierProvider(create: (_) => PlannerProvider()),
        ChangeNotifierProvider(create: (_) => AlertsProvider()),
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
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50),
          primary: const Color(0xFF4CAF50),
          secondary: const Color(0xFFFF9800),
        ),
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0.5,
          titleTextStyle: TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold),
          iconTheme: IconThemeData(color: Colors.black87),
        ),
        useMaterial3: true,
      ),
      // LOGIC: Kiểm tra trạng thái đăng nhập để hiển thị màn hình phù hợp
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return auth.isLoggedIn ? const MainLayoutScreen() : const AuthScreen();
        },
      ),
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

  static final List<Widget> _widgetOptions = <Widget>[
    const PantryScreen(),      // Index 0: Kho
    const RecipeListScreen(),  // Index 1: Công thức
    const PlannerScreen(),     // Index 2: Kế hoạch
    const ProfileScreen(),     // Index 3: Hồ sơ
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
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ),
    );
  }
}
void _showExpiryDialogIfNeeded(BuildContext context) {
  final alertsProvider = Provider.of<AlertsProvider>(context, listen: false);
  final pantryProvider = Provider.of<PantryProvider>(context, listen: false);

  // 1. Quét kho để cập nhật danh sách cảnh báo mới nhất
  alertsProvider.checkExpirations(pantryProvider.ingredients);

  // 2. Nếu có thực phẩm hết hạn (Critical), hiển thị Popup
  if (alertsProvider.alerts.any((a) => a.severity == AlertSeverity.critical)) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 10),
            Text('Cảnh báo hết hạn!'),
          ],
        ),
        content: Text(
            'Bạn có ${alertsProvider.alerts.where((a) => a.severity == AlertSeverity.critical).length} thực phẩm đã hết hạn trong kho. Hãy kiểm tra ngay!'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ĐỂ SAU'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Chuyển hướng người dùng đến tab Kho hoặc màn hình Cảnh báo
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('KIỂM TRA', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}