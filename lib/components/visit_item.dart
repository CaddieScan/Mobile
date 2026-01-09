import 'package:flutter/material.dart';

class VisitItem extends StatelessWidget {
  final String location;
  final String visits;
  final IconData icon;

  const VisitItem({
    super.key,
    required this.location,
    required this.visits,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey.shade100,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey.shade200,
          child: Icon(icon, color: Colors.red.shade400),
        ),
        title: Text(location, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: Text(visits, style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 14)),
      ),
    );
  }
}
