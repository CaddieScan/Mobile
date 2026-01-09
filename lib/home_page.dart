import 'package:flutter/material.dart';
import 'components/section_header.dart';
import 'components/fidelity_card.dart';
import 'components/purchase_item.dart';
import 'components/visit_item.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF007AFF)),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: const Text(
          'Bienvenue, Bob le bricoleur',
          style: TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, color: Color(0xFF007AFF), size: 36),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(title: 'Cartes de fidélité', onAdd: () {}),
            const FidelityCard(),
            const SizedBox(height: 24),

            const SectionHeader(title: 'Derniers achats'),
            const PurchaseItem(store: 'Auchan', amount: '10,59€', icon: Icons.storefront),
            const PurchaseItem(store: 'Intermarché', amount: '58,37€', icon: Icons.storefront),
            Center(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade300,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(35),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: const Text('3 autres ...', style: TextStyle(fontWeight: FontWeight.w500)),
              ),
            ),
            const SizedBox(height: 24),

            const SectionHeader(title: 'Dernières visites'),
            const VisitItem(location: 'Auchan - Cergy 3 fontaines', visits: '3 visites', icon: Icons.storefront),
            const VisitItem(location: 'Intermarché - Paris', visits: '1 visite', icon: Icons.storefront),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/shop_choice');
        },
        label: const Text('Choisir un magasin', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white)),
        backgroundColor: Colors.blue,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
