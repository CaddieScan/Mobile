import 'dart:convert';

import 'package:caddiescan/models/product.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:http/http.dart' as http;
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

  @override
  void initState() {
    super.initState();
    initializeCamera();
    fetchProducts();
    loadCartId();
  }

  // charger l'id du panier depuis le stockage local
  Future<void> loadCartId() async {
    try {
      final savedId = await CartService.getCartId();
      if (savedId != null) {
        setState(() {
          currentCartId = savedId;
        });
        print('ID panier chargé depuis SharedPreferences: $currentCartId');
      } else {
        print('Aucun ID panier trouvé en local');
      }
    } catch (e) {
      print('Erreur lors du chargement de l\'ID panier: $e');
    }
  }

  Future<void> _saveCartId(int id) async {
    await CartService.setCartId(id);
    if (mounted) {
      print('ID panier enregistré en local: $id');
    }
  }

  // récupérer les produits du magasin
  Future<void> fetchProducts() async {
    print("Récupération des produits en cours...");
    try {
      String baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://127.0.0.1:8000';
      final response = await http.get(
        Uri.parse(
          '$baseUrl/product/get_products_by_shopid?shop_id=1',
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        setState(() {
          allProducts = jsonData.map((data) => Product.fromJson(data)).toList();
          print("Produits récupérés : ${allProducts.length}");
        });
      } else {
        print("Erreur HTTP ${response.statusCode}");
      }
    } catch (e) {
      print("Erreur lors de la récupération des produits: $e");
    }
  }

  // filtrer les produits de la recherche
  void updateSearchResults(String query) {
    print("Recherche : $query");
    print("Produits : ${allProducts}");
    if (query.isEmpty) {
      setState(() => searchResults = []);
      return;
    }
    setState(() {
      searchResults = allProducts
          .where(
            (product) =>
                product.libelle.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    });
    print("Produits trouvés : ${searchResults.length}");
  }

  // requête de recherche du produit par son code-barre
  Future<http.Response> fetchScan(barcode) {
    String baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://127.0.0.1:8000';
    return http.get(
      Uri.parse(
        '$baseUrl/product/get_product_by_barcode?barcode=${barcode}',
      ),
    );
  }

  // requête d'ajout du produit dans le panier
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

  // création d'un nouveau panier
  Future<int?> createCart(int userId, int shopId) async {
    String baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://127.0.0.1:8000';
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/cart/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'shop_id': shopId,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['id'] as int;
      }
    } catch (e) {
      print("Erreur création panier dynamique: $e");
    }
    return null;
  }

  void scannedProduct(String barcode) async {
    try {
      final response = await fetchScan(barcode);

      if (response.statusCode == 200) {
        // décoder le json
        final product = Product.fromJson(jsonDecode(response.body));
        setState(() {
          scannedProductDatas = product;
        });
        print("PRODUIT SCANNE : ${product.libelle} - ${product.price}");
        
        http.Response? cartResponse;

        // on tente d'ajouter au panier courant s'il existe déjà
        if (currentCartId != null) {
          cartResponse = await addProductToCartInDB(product, currentCartId!);
        }

        // si pas de panier courant ou si ajout en échec, on crée un nouveau panier
        if (cartResponse == null || cartResponse.statusCode != 200) {
          if (cartResponse != null) {
            print("Panier inexistant ou erreur (${cartResponse.statusCode}). Création d'un nouveau panier...");
          } else {
            print("Aucun panier courant. Création d'un nouveau panier...");
          }

          final newCartId = await createCart(1, 1); // Pour le test : u:1, shop:1

          if (newCartId != null) {
            currentCartId = newCartId;
            await _saveCartId(currentCartId!);
            print("Nouveau panier créé avec l'ID: $currentCartId");

            // on ajoute le produit avec le nouveau panier
            cartResponse = await addProductToCartInDB(product, currentCartId!);
            if (cartResponse.statusCode == 200) {
              print("Produit ajouté avec succès au nouveau panier !");
            } else {
              print("Echec final de l'ajout au panier.");
            }
          }
        } else {
          print("Produit ajouté avec succès au panier courant !");
        }
      } else {
        print("Produit non trouvé, status: ${response.statusCode}");
      }
    } catch (e) {
      print("Erreur réseau: $e");
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

  // analyse du flux image pour détecter un barcode
  Future<void> processImageStream(CameraImage image) async {
    // si c'est déja en process, ignorer
    if (isProcessing) return;

    isProcessing = true;

    try {
      // on gère le scan via les images
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
          // on mets le bar code dans notre fonction pour le gérer
          scannedProduct(barcode.rawValue.toString());
          //on arrête la détection de barcode
          if (controller?.value.isStreamingImages == true) {
            controller?.stopImageStream();
          }
        }
      }
    } catch (e) {
      print("Erreur lors de l'analyse de l'image: $e");
    }

    isProcessing = false;
  }

  // on déclenche la détection du barcode, via le bouton
  void scanOnce() async {
    if (controller?.value.isStreamingImages == true) return;

    controller?.startImageStream(processImageStream);
    await Future.delayed(const Duration(seconds: 5));

    if (controller?.value.isStreamingImages == true) {
      controller?.stopImageStream();
    }
  }

  // on arrête le flux
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

  // composant de la preview de la caméra
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

  // composant des promotions
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
      return Text("Dernier produit :");
    }
  }

  // composant pour la liste des résultats de recherche
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
        // l'input de recherche
        title: TextField(
          controller: searchController,
          onChanged: updateSearchResults,
          decoration: const InputDecoration(
            hintText: 'Rechercher un produit...',
            border: InputBorder.none,
          ),
        ),
        actions: [
          // bouton qui efface la recherche
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
            onPressed: () {
              Navigator.pushNamed(context, '/cart_list');
            },
            icon: const Icon(Icons.shopping_cart_checkout),
            label: const Text("Panier"),
          ),
          FloatingActionButton.extended(
            onPressed: () {
              Navigator.pushNamed(context, '/validation');
            },
            icon: const Icon(Icons.check),
            label: const Text("Valider"),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
