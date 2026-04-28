import 'package:flutter/material.dart';

class ShopChoiceCard extends StatelessWidget {
  final String location;
  final double km;
  final double latitude;
  final double longitude;
  final IconData icon;
  final bool isFavorite;
  final VoidCallback onFavoritePressed;
  final VoidCallback onPressed;

  const ShopChoiceCard({
    super.key,
    required this.location,
    required this.km,
    required this.latitude,
    required this.longitude,
    required this.icon,
    required this.isFavorite,
    required this.onFavoritePressed,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey.shade100,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.grey.shade200,
                    child: Icon(icon, color: Colors.red.shade400),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    location,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    "${km.toStringAsFixed(2)}km",
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  IconButton(
                    onPressed: onFavoritePressed,
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      size: 24,
                      color: isFavorite ? Colors.red : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
