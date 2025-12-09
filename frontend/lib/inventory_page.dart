import 'package:flutter/material.dart';

class InventoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inventory_2_rounded, size: 26),
            const SizedBox(width: 10),
            const Text(
              'Inventar',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFE64A19),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.3),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFE64A19).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warehouse_rounded,
                size: 80,
                color: const Color(0xFFE64A19),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Inventar',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE64A19),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Gestionarea inventarului va fi disponibilă în curând',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
