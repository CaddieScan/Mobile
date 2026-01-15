import 'package:flutter/material.dart';

class ShopMap extends StatelessWidget {
  const ShopMap({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.7,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.network(
          'https://picsum.photos/250?image=1',
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
