import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'components/section_header.dart';
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

  final List<Promotion> promotions = [
    Promotion(id: 1, magasinId: 1, libelle: '2x Kinder Bueno', dateHeureDebut: DateTime.now(), dateHeureFin: DateTime.now(), modePromotion: 'réduction', caniotteImmediate: true, pourcentageReduction: 20),
    Promotion(id: 2, magasinId: 1, libelle: 'Pack de 6 Oeufs', dateHeureDebut: DateTime.now(), dateHeureFin: DateTime.now(), modePromotion: 'lot', caniotteImmediate: false, quantiteAcheter: 1, quantiteOffert: 1),
    Promotion(id: 3, magasinId: 1, libelle: "Jus d'orange 1L", dateHeureDebut: DateTime.now(), dateHeureFin: DateTime.now(), modePromotion: 'remise', caniotteImmediate: true, reductionFixe: 0.50),
    Promotion(id: 4, magasinId: 1, libelle: 'Tablette de chocolat', dateHeureDebut: DateTime.now(), dateHeureFin: DateTime.now(), modePromotion: 'cagnotte', caniotteImmediate: true, pourcentageReduction: 15),
  ];

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    final cameras = await availableCameras();
    controller = CameraController(cameras.first, ResolutionPreset.medium, enableAudio: false);
    await controller!.initialize();
    if (mounted) {
      controller!.startImageStream(processImageStream);
    }
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

      final inputImage = InputImage.fromBytes(
        bytes: bytes,
        metadata: metadata,
      );

      final barcodes = await barcodeScanner.processImage(inputImage);

      for (final barcode in barcodes) {
        if (barcode.rawValue != null) {
          print('--- CODE-BARRES TROUVÉ --- : ${barcode.rawValue}');
          // controller?.stopImageStream();
        }
      }
    } catch (e) {
      print("Erreur lors de l'analyse de l'image: $e");
    }

    isProcessing = false;
  }

  // on arrête le flux
  @override
  void dispose() {
    controller?.stopImageStream();
    controller?.dispose();
    barcodeScanner.close();
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.campaign, size: 40, color: Colors.blueAccent),
              const SizedBox(height: 8),
              Text(p.libelle, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text("-\${p.pourcentageReduction ?? 0}%", style: const TextStyle(color: Colors.red)),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        title: const Text('Rechercher le produit'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildCameraPreview(),
            const SizedBox(height: 24),
            // Le bouton n'est plus nécessaire car le scan est automatique
            // ElevatedButton(onPressed: scanOnce, child: const Text("Scanner")),
            const SectionHeader(title: 'Promotions suggérées'),
            const SizedBox(height: 16),
            buildPromotionsGrid(),
            const SizedBox(height: 90),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton.extended(onPressed: () {}, icon: const Icon(Icons.shopping_cart_checkout), label: const Text("Panier")),
          FloatingActionButton.extended(onPressed: () {}, icon: const Icon(Icons.check), label: const Text("Valider")),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
