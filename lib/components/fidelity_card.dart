import 'package:flutter/material.dart';

class FidelityCard extends StatelessWidget {
  const FidelityCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.green,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.shopping_basket, color: Colors.red, size: 30),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Auchan', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('1.34€', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ],
                ),
              ],
            ),
            // j'ai mis l'icone de qr code car je n'avais pas le logo auchan
            const Icon(Icons.qr_code_scanner, color: Colors.white, size: 60),
          ],
        ),
      ),
    );
  }
}
