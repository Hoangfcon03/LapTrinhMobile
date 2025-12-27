import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bepthongminh64pm1duchoang/main.dart';

void main() {
  testWidgets('Kiểm tra giao diện đăng nhập khi mới mở app', (WidgetTester tester) async {
    // 1. Khởi chạy ứng dụng (Sử dụng đúng tên class trong main.dart của bạn)
    // Ở đây là MultiProviderWrapper vì nó chứa các Provider cần thiết
    await tester.pumpWidget(const MultiProviderWrapper());

    // 2. Vì app có Firebase và Provider, chúng ta đợi một chút để các frame ổn định
    await tester.pumpAndSettle();

    // 3. Kiểm tra xem có chữ 'ĐĂNG NHẬP' (đặc trưng của AuthScreen) hay không
    // Thay vì kiểm tra counter (không tồn tại), ta kiểm tra giao diện thực tế
    expect(find.text('ĐĂNG NHẬP'), findsWidgets);
    expect(find.byIcon(Icons.restaurant_menu), findsOneWidget);
  });
}