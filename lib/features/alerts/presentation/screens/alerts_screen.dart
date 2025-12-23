import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bepthongminh64pm1duchoang/features/alerts/domain/alerts_provider.dart';
import 'package:bepthongminh64pm1duchoang/features/alerts/domain/alert_model.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cảnh báo hết hạn'),
        centerTitle: true,
      ),
      body: Consumer<AlertsProvider>(
        builder: (context, alertsProv, child) {
          // Trạng thái khi không có cảnh báo
          if (alertsProv.alerts.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
                  SizedBox(height: 16),
                  Text('Tất cả thực phẩm đều an toàn!',
                      style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: alertsProv.alerts.length,
            itemBuilder: (context, index) {
              final alert = alertsProv.alerts[index];
              final isCritical = alert.severity == AlertSeverity.critical;

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: isCritical ? Colors.red[50] : Colors.orange[50],
                    child: Icon(
                      Icons.warning_amber_rounded,
                      color: isCritical ? Colors.red : Colors.orange,
                    ),
                  ),
                  title: Text(
                    alert.ingredientName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Text(
                    'Hết hạn: ${alert.expiryDate.day}/${alert.expiryDate.month}/${alert.expiryDate.year}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isCritical ? Colors.red : Colors.orange,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isCritical ? 'ĐÃ HẾT HẠN' : 'SẮP HẾT HẠN',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}