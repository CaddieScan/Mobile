import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:caddiescan/services/api_service.dart';

void main() {

  test('Scan du produit', () async {

    // ARRANGE
    final fakeClient = MockClient((request) async {
      if (request.url.queryParameters['barcode'] == '123456789') {
        return http.Response(
          jsonEncode({'id': 101, 'libelle': 'Chocolat', 'price': 2.50, 'barcode': '123456789'}),
          200,
        );
      }
      return http.Response('Produit non trouvé', 404);
    });
    final apiService = ApiService(client: fakeClient);

    // ACT
    final response = await apiService.scanProduct('123456789');

    // ASSERT
    expect(response['libelle'], 'Chocolat');
    expect(response['price'], 2.50);

  });

  test('Scan du produit mais echec', () async {

    // ARRANGE
    final fakeClient = MockClient((request) async {
      return http.Response(
        jsonEncode({'detail': 'Produit non trouvé'}),
        404,
      );
    });
    final apiService = ApiService(client: fakeClient);

    // ACT
    final call = () => apiService.scanProduct('000000000');

    // ASSERT
    expect(call, throwsException);

  });

  test('Ajout d un produit dans le panier', () async {

    // ARRANGE
    final fakeClient = MockClient((request) async {
      return http.Response(
        jsonEncode({
          'id': 1,
          'cart_id': 1,
          'produit_id': '123456789',
          'quantity': 1
        }),
        200,
      );
    });
    final apiService = ApiService(client: fakeClient);

    // ACT
    final response = await apiService.addToCart('123456789', 1);

    // ASSERT
    expect(response['produit_id'], '123456789');
    expect(response['quantity'], 1);

  });

  test('Ajout d un produit dans le panier mais echec', () async {

    // ARRANGE
    final fakeClient = MockClient((request) async {
      return http.Response(
        jsonEncode({'detail': "Une erreur s'est produite."}),
        500,
      );
    });
    final apiService = ApiService(client: fakeClient);

    // ACT
    final call = () => apiService.addToCart('000000000', 1);

    // ASSERT
    expect(call, throwsException);

  });

  test('Liste de magasins proches', () async {

    // ARRANGE
    final fakeClient = MockClient((request) async {
      return http.Response(
        jsonEncode([
          {'id': 1, 'location': 'Leclerc Paris',   'km': 2.5},
          {'id': 2, 'location': 'Carrefour Lyon',  'km': 15.0},
        ]),
        200,
      );
    });
    final apiService = ApiService(client: fakeClient);

    // ACT
    final response = await apiService.getProximityShops(1, 48.8566, 2.3522);

    // ASSERT
    expect(response.length, 2);
    expect(response[0]['location'], 'Leclerc Paris');

  });

  test('Liste de magasins proches mais echec', () async {

    // ARRANGE
    final fakeClient = MockClient((request) async {
      return http.Response(
        jsonEncode({'detail': 'Coordonnées GPS invalides'}),
        400,
      );
    });
    final apiService = ApiService(client: fakeClient);

    // ACT
    final response = () => apiService.getProximityShops(1, 999.0, 999.0);

    // ASSERT
    expect(response, throwsException);

  });

}