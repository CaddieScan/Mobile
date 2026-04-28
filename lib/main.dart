import 'package:caddiescan/scan_page.dart';
import 'package:caddiescan/shop_choice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'cart_list_page.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'map_page.dart';
import 'profile_page.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Outfit'),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/profile': (context) => const ProfilePage(),
        '/shop_choice': (context) => const ShopChoicePage(),
        '/scan': (context) => const ScanPage(),
        '/cart_list': (context) => const CartListPage(),
        '/map': (context) => const MapPage(),
      },
    );
  }
}
