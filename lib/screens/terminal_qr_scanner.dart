import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/qr_service.dart';

class TerminalQRScanner extends StatefulWidget {
  const TerminalQRScanner({super.key});

  @override
  State<TerminalQRScanner> createState() => _TerminalQRScannerState();
}

class _TerminalQRScannerState extends State<TerminalQRScanner> {
  final QRService _qrService = QRService();
  bool _isScanning = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify Ticket")),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) async {
              if (!_isScanning) return;
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  setState(() => _isScanning = false);
                  _handleScan(barcode.rawValue!);
                  break;
                }
              }
            },
          ),
          Center(
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleScan(String data) async {
    final result = await _qrService.verifyTicket(data);
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(result['success'] ? "Ticket Valid" : "Invalid Ticket"),
        content: Text(result['message']),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _isScanning = true);
            },
            child: const Text("Scan Next"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Done"),
          ),
        ],
      ),
    );
  }
}
