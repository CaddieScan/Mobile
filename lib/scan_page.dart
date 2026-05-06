import 'dart:async';
import 'dart:convert';

import 'package:caddiescan/models/product.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'components/section_header.dart';
import 'services/cart_service.dart';
import 'models/promotions.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => ScanPageState();
}

class ScanPageState extends State<ScanPage> {
  CameraController? controller;
  final BarcodeScanner barcodeScanner = BarcodeScanner();
  bool isProcessing = false;

  final TextEditingController searchController = TextEditingController();
  List<Product> allProducts = [];
  List<Product> searchResults = [];

  String? scanErrorMessage;

  final List<Promotion> promotions = [
    Promotion(
      id: 1,
      magasinId: 1,
      libelle: '2x Kinder Bueno',
      dateHeureDebut: DateTime.now(),
      dateHeureFin: DateTime.now(),
      modePromotion: 'réduction',
      caniotteImmediate: true,
      pourcentageReduction: 20,
    ),
    Promotion(
      id: 2,
      magasinId: 1,
      libelle: 'Pack de 6 Oeufs',
      dateHeureDebut: DateTime.now(),
      dateHeureFin: DateTime.now(),
      modePromotion: 'lot',
      caniotteImmediate: false,
      quantiteAcheter: 1,
      quantiteOffert: 1,
    ),
    Promotion(
      id: 3,
      magasinId: 1,
      libelle: "Jus d'orange 1L",
      dateHeureDebut: DateTime.now(),
      dateHeureFin: DateTime.now(),
      modePromotion: 'remise',
      caniotteImmediate: true,
      reductionFixe: 0.50,
    ),
    Promotion(
      id: 4,
      magasinId: 1,
      libelle: 'Tablette de chocolat',
      dateHeureDebut: DateTime.now(),
      dateHeureFin: DateTime.now(),
      modePromotion: 'cagnotte',
      caniotteImmediate: true,
      pourcentageReduction: 15,
    ),
  ];

  late Product scannedProductDatas;
  int? currentCartId;
  int? currentShopId = 1;

  @override
  void initState() {
    super.initState();
    initializeCamera();
    loadShopId();
    fetchProducts();
    loadCartId();
  }

  void showToast(String message) {
    print(message);
    if (!mounted) return;
    setState(() {
      scanErrorMessage = message;
    });
  }

  Future<void> loadShopId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final shopIdStr = prefs.getString('current_shop_id_scan');
      if (shopIdStr != null) {
        currentShopId = int.tryParse(shopIdStr);
      }
      print("Loaded shop ID: $currentShopId");
    } catch (e) {
      showToast('Erreur chargement du magasin: $e');
    }
  }

  Future<void> loadCartId() async {
    try {
      final savedId = await CartService.getCartId();
      if (savedId != null) {
        setState(() {
          currentCartId = savedId;
        });
      }
    } catch (e) {
      showToast('Erreur chargement panier: $e');
    }
  }

  Future<void> saveCartId(int id) async {
    await CartService.setCartId(id);
  }

  Future<void> fetchProducts() async {
    try {
      String baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://127.0.0.1:8000';
      final response = await http.get(
        Uri.parse('$baseUrl/product/get_products_by_shopid?shop_id=1'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        setState(() {
          allProducts = jsonData.map((data) => Product.fromJson(data)).toList();
          scanErrorMessage = null;
        });
      } else {
        showToast('Erreur chargement produits (${response.statusCode})');
      }
    } catch (e) {
      showToast('Erreur réseau: $e');
    }
  }

  void updateSearchResults(String query) {
    if (query.isEmpty) {
      setState(() => searchResults = []);
      return;
    }
    setState(() {
      searchResults = allProducts
          .where((p) => p.libelle.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<http.Response> fetchScan(String barcode) {
    String baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://127.0.0.1:8000';
    return http.get(
      Uri.parse('$baseUrl/product/get_product_by_barcode?barcode=$barcode'),
    );
  }

  Future<http.Response> addProductToCartInDB(Product product, int cartId) {
    String baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://127.0.0.1:8000';
    return http.post(
      Uri.parse('$baseUrl/cart/product/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'cart_id': cartId,
        'produit_id': product.barcode,
        'quantity': 1,
      }),
    );
  }

  Future<int?> createCart(int userId, int shopId) async {
    print("Creating cart for user $userId in shop $shopId");
    String baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://127.0.0.1:8000';
    try {
      final response = await http
          .post(
        Uri.parse('$baseUrl/cart/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId, 'shop_id': shopId}),
      )
          .timeout(const Duration(seconds: 60));

      print("createCart status: ${response.statusCode}");
      print("createCart body: ${response.body}");

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        return (data['id'] as num).toInt();
      }
      showToast('Erreur création panier (${response.statusCode})');
    } on TimeoutException {
      showToast('Serveur indisponible, réessaie dans quelques secondes');
    } catch (e, stack) {
      print("Exception createCart: $e\n$stack");
      showToast('Erreur création panier: $e');
    }
    return null;
  }

  Future<void> scannedProduct(String barcode) async {
    try {
      final response = await fetchScan(barcode);
      print("fetchScan status: ${response.statusCode}");

      if (response.statusCode != 200) {
        showToast('Produit non trouvé');
        return;
      }

      final product = Product.fromJson(jsonDecode(response.body));
      setState(() {
        scannedProductDatas = product;
      });

      // Créer un panier si on n'en a pas
      if (currentCartId == null) {
        print("Pas de panier, création...");
        final newCartId = await createCart(1, currentShopId!);
        if (newCartId == null) {
          showToast('Impossible de créer un panier');
          return;
        }
        currentCartId = newCartId;
        await saveCartId(currentCartId!);
      }

      // Ajouter le produit au panier
      final cartResponse = await addProductToCartInDB(product, currentCartId!);
      print("addProduct status: ${cartResponse.statusCode}");
      print("addProduct body: ${cartResponse.body}");

      if (cartResponse.statusCode == 200) {
        setState(() => scanErrorMessage = null);
      } else if (cartResponse.statusCode == 404 ||
          cartResponse.statusCode == 422) {
        // Le panier n'existe plus en base, on recrée
        print("Panier introuvable en base, recréation...");
        currentCartId = null;
        await CartService.setCartId(null);
        await scannedProduct(barcode); // relance récursive
      } else {
        showToast(
          'Erreur ajout produit (${cartResponse.statusCode}): ${cartResponse.body}',
        );
      }
    } catch (e, stack) {
      print("Erreur scannedProduct: $e\n$stack");
      showToast('Erreur réseau: $e');
    }
  }

  Future<void> initializeCamera() async {
    final cameras = await availableCameras();
    controller = CameraController(
      cameras.first,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    await controller!.initialize();
    if (mounted) setState(() {});
  }

  Future<void> processImageStream(CameraImage image) async {
    if (isProcessing) return;
    isProcessing = true;

    try {
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      final metadata = InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: InputImageRotation.rotation0deg,
        format: InputImageFormat.nv21,
        bytesPerRow: image.planes.first.bytesPerRow,
      );

      final inputImage = InputImage.fromBytes(bytes: bytes, metadata: metadata);
      final barcodes = await barcodeScanner.processImage(inputImage);

      for (final barcode in barcodes) {
        if (barcode.rawValue != null) {
          await scannedProduct(barcode.rawValue.toString());
          if (controller?.value.isStreamingImages == true) {
            controller?.stopImageStream();
          }
        }
      }
    } catch (e) {
      showToast('Erreur scan image: $e');
    }

    isProcessing = false;
  }

  void scanOnce() async {
    if (controller?.value.isStreamingImages == true) return;
    setState(() => scanErrorMessage = null);

    controller?.startImageStream(processImageStream);
    await Future.delayed(const Duration(seconds: 5));

    if (controller?.value.isStreamingImages == true) {
      controller?.stopImageStream();
    }
  }

  @override
  void dispose() {
    if (controller?.value.isStreamingImages == true) {
      controller?.stopImageStream();
    }
    controller?.dispose();
    barcodeScanner.close();
    searchController.dispose();
    super.dispose();
  }

  Widget buildCameraPreview() {
    if (controller == null || !controller!.value.isInitialized) {
      return const SizedBox(
        height: 220,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: AspectRatio(
        aspectRatio: controller!.value.aspectRatio,
        child: CameraPreview(controller!),
      ),
    );
  }

  Widget buildPromotionsGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        childAspectRatio: 1.5,
      ),
      itemCount: promotions.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final p = promotions[index];
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.campaign, size: 40, color: Colors.blueAccent),
              const SizedBox(height: 8),
              Text(
                p.libelle,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                "-${p.pourcentageReduction ?? 0}%",
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildDisplayLastProduct(BuildContext context) {
    try {
      return Text("Dernier produit : ${scannedProductDatas.libelle}");
    } catch (e) {
      return const Text("Dernier produit :");
    }
  }

  Widget buildSearchResultsList() {
    return Container(
      color: Colors.white,
      child: ListView.builder(
        itemCount: searchResults.length,
        itemBuilder: (context, index) {
          final product = searchResults[index];
          return ListTile(
            title: Text(product.libelle),
            onTap: () {
              Navigator.pushNamed(context, '/map');
              searchController.clear();
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: searchController,
          onChanged: updateSearchResults,
          decoration: const InputDecoration(
            hintText: 'Rechercher un produit...',
            border: InputBorder.none,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () => searchController.clear(),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                buildCameraPreview(),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: scanOnce,
                  child: const Text("Scanner"),
                ),
                if (scanErrorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    scanErrorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 24),
                Row(
                  children: [buildDisplayLastProduct(context), const Spacer()],
                ),
                const SectionHeader(title: 'Promotions suggérées'),
                const SizedBox(height: 16),
                buildPromotionsGrid(),
                const SizedBox(height: 90),
              ],
            ),
          ),
          if (searchResults.isNotEmpty) buildSearchResultsList(),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton.extended(
            heroTag: 'scan_cart',
            onPressed: () => Navigator.pushNamed(context, '/cart_list'),
            icon: const Icon(Icons.shopping_cart_checkout),
            label: const Text("Panier"),
          ),
          FloatingActionButton.extended(
            heroTag: 'scan_validate',
            onPressed: () => Navigator.pushNamed(context, '/validation'),
            icon: const Icon(Icons.check),
            label: const Text("Valider"),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}