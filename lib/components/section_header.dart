import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onAdd;

  const SectionHeader({super.key, required this.title, this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        if (onAdd != null)
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black, size: 28),
            onPressed: onAdd,
          ),
      ],
    );
  }
}
