import 'package:flutter/material.dart';

class PurchaseItem extends StatelessWidget {
  final String store;
  final String amount;
  final IconData icon;
  final VoidCallback onPressed;

  const PurchaseItem({
    super.key,
    required this.store,
    required this.amount,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey.shade100,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(35),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey.shade200,
            child: Icon(icon, color: Colors.red.shade400),
          ),
          title: Text(store, style: const TextStyle(fontWeight: FontWeight.w500)),
          trailing: Text(
            amount,
            style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 16),
          ),
        ),
      ),
    );
  }
}