import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

MobileScannerController cameraController = MobileScannerController();

class QRScanner extends StatefulWidget {
  const QRScanner({super.key});
  @override
  State<QRScanner> createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  String data="";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mobile Scanner')),
      body: Column(
        children: [
          Container(width: double.infinity, height: 600,
            child: Center(
              child: MobileScanner(
                fit: BoxFit.contain,
                //scanWindow: Rect.fromCenter(center: Offset.zero, width: 600, height: 200),
                overlay: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.teal,width: 3),
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(2), bottomRight: Radius.circular(2) ),
                  ),
                ),
                controller: MobileScannerController(
                  // facing: CameraFacing.back,
                  // torchEnabled: false,
                  returnImage: true,
                ),
                onDetect: (capture) {
                  final List<Barcode> barcodes = capture.barcodes;
                  final Uint8List? image = capture.image;
                  for (final barcode in barcodes) {
                    setState(() {
                      data = barcode.rawValue.toString();
                    });
                    debugPrint('Barcode found! ${barcode.rawValue}');
                  }
                  if (image != null) {
                    // showDialog(
                    //   context: context,
                    //   builder: (context) =>
                    //       Image(image: MemoryImage(image)),
                    // );
                    // Future.delayed(const Duration(seconds: 5), () {
                    //   Navigator.pop(context);
                    // });
                  }
                },
              ),
            ),
          ),
          Padding(padding: const EdgeInsets.all(8), child: Text(data),)
        ],
      ),
    );
  }
}
