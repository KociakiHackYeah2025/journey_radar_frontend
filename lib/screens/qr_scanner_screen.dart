import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerScreen extends StatefulWidget {
  final Function(String) onQRScanned;

  const QRScannerScreen({super.key, required this.onQRScanned});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController controller = MobileScannerController();
  bool _isDetected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skanuj QR kod'),
        backgroundColor: const Color(0xFF4A90E2),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                MobileScanner(
                  controller: controller,
                  onDetect: _onDetect,
                ),
                // Overlay z ramką skanowania
                Center(
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFF4A90E2),
                        width: 4,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              color: Colors.black87,
              child: const Center(
                child: Text(
                  'Zeskanuj QR kod z biletu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _onDetect(BarcodeCapture capture) {
    if (!_isDetected && mounted) {
      final List<Barcode> barcodes = capture.barcodes;
      if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
        setState(() {
          _isDetected = true;
        });
        controller.stop();
        widget.onQRScanned(barcodes.first.rawValue!);
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}