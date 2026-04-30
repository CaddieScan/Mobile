import 'package:flutter/material.dart';
import 'services/cart_service.dart';

class ValidationPage extends StatelessWidget {
  const ValidationPage({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Validation')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 36,
                backgroundColor: Colors.green,
                child: Icon(Icons.check, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 16),
              const Text(
                'Panier valide',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Rendez-vous sur une caisse Scan rapide,\net scannez ce code depuis la caisse',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                height: 90,
                width: double.infinity,
                color: Colors.black12,
                alignment: Alignment.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/scan');
                },
                child: const Text('Retour au scan d\'articles'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  await CartService.clearCartId();
                  if (!context.mounted) return;
                  Navigator.pushReplacementNamed(context, '/home');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                ),
                child: const Text('Retour à l\'accueil'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

