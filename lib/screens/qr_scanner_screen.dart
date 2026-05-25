import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/customer.dart';
import '../database/database_helper.dart';
import 'customer_detail_screen.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _isScanned = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleBarcode(BarcodeCapture capture) async {
    if (_isScanned) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final String? code = barcode.rawValue;
      if (code != null) {
        setState(() {
          _isScanned = true;
        });

        // The QR code contains either an integer SQLite id or a String email
        final customerId = int.tryParse(code);
        Customer? matchedCustomer;

        if (customerId != null) {
          final customers = await DatabaseHelper.instance.getCustomers();
          for (var c in customers) {
            if (c.id == customerId) {
              matchedCustomer = c;
              break;
            }
          }
        } else {
          // Try lookup by email
          final customers = await DatabaseHelper.instance.getCustomers();
          for (var c in customers) {
            if (c.email?.toLowerCase().trim() == code.toLowerCase().trim()) {
              matchedCustomer = c;
              break;
            }
          }
        }

        if (mounted) {
          if (matchedCustomer != null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => CustomerDetailScreen(customer: matchedCustomer!),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("No customer found matching code: $code"),
                backgroundColor: Colors.red,
              ),
            );
            Navigator.pop(context);
          }
        }
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan Customer QR"),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _controller,
              builder: (context, state, child) {
                switch (state.torchState) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off_rounded);
                  case TorchState.on:
                    return const Icon(Icons.flash_on_rounded);
                }
              },
            ),
            onPressed: () => _controller.toggleTorch(),
          ),
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _controller,
              builder: (context, state, child) {
                switch (state.cameraFacingState) {
                  case CameraFacing.front:
                    return const Icon(Icons.camera_front_rounded);
                  case CameraFacing.back:
                    return const Icon(Icons.camera_rear_rounded);
                }
              },
            ),
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _handleBarcode,
          ),
          // QR scanner crosshair overlay
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).primaryColor, width: 4),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          const Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "Align customer QR code inside the frame",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, backgroundColor: Colors.black54),
              ),
            ),
          )
        ],
      ),
    );
  }
}
