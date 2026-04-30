import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'services/cart_service.dart';
import 'components/section_header.dart';
import 'components/fidelity_card.dart';
import 'components/purchase_item.dart';
import 'components/visit_item.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  late Future<List<Map<String, dynamic>>> purchasesFuture;
  late Future<List<Map<String, dynamic>>> visitsFuture;

  @override
  void initState() {
    super.initState();
    CartService.clearCartId();
    purchasesFuture = fetchUserCarts();
    visitsFuture = fetchUserVisits();
  }

  // on récupère les paniers de l'utilisateur
  Future<List<Map<String, dynamic>>> fetchUserCarts() async {
    try {
      final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://127.0.0.1:8000';
      final response = await http.get(Uri.parse('$baseUrl/cart/user/1'));
      if (response.statusCode != 200) return [];
      return (jsonDecode(response.body) as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // on récupère le nombre de visites de l'utilisateur par magasin (via le nombre de paniers par magasin)
  Future<List<Map<String, dynamic>>> fetchUserVisits() async {
    try {
      final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://127.0.0.1:8000';
      final response = await http.get(Uri.parse('$baseUrl/cart/user/1/visites'));
      if (response.statusCode != 200) return [];
      return (jsonDecode(response.body) as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF007AFF)),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'Bienvenue, Bob le bricoleur',
          style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, color: Color(0xFF007AFF), size: 36),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(title: 'Cartes de fidélité', onAdd: () {}),
            const FidelityCard(),
            const SizedBox(height: 24),
            const SectionHeader(title: 'Derniers achats'),
            buildPurchaseList(),
            const SizedBox(height: 24),
            const SectionHeader(title: 'Dernières visites'),
            buildVisitList(),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/shop_choice'),
        label: const Text(
          'Choisir un magasin',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget buildPurchaseList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: purchasesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final purchases = snapshot.data ?? [];
        if (purchases.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text('Aucun achat pour le moment.'),
          );
        }
        return Column(
          children: purchases.take(3).map((p) {
            final store = p['magasin_libelle']?.toString() ?? '';
            final total = (p['total_ttc'] as num?)?.toDouble() ?? 0;
            return PurchaseItem(
              store: store,
              amount: '${total.toStringAsFixed(2)}€',
              icon: Icons.storefront,
            );
          }).toList(),
        );
      },
    );
  }

  Widget buildVisitList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: visitsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final visits = snapshot.data ?? [];
        if (visits.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text('Aucune visite pour le moment.'),
          );
        }
        return Column(
          children: visits.take(3).map((v) {
            final location = v['magasin_libelle']?.toString() ?? '';
            final count = (v['nombre_visites'] as num?)?.toInt() ?? 0;
            final label = count == 1 ? '1 visite' : '$count visites';

            return VisitItem(
              location: location,
              visits: label,
              icon: Icons.storefront,
            );
          }).toList(),
        );
      },
    );
  }
}