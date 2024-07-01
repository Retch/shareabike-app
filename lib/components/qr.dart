import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:share_a_bike/type/string_callback.dart';

class QrScannerComponent extends StatefulWidget {
  final StringCallback callback;

  const QrScannerComponent({super.key, required this.callback});

  @override
  State<QrScannerComponent> createState() => _QrScannerComponentState();
}

class _QrScannerComponentState extends State<QrScannerComponent> {
  @override
  Widget build(BuildContext context) {
    return MobileScanner(
      controller: MobileScannerController(
        detectionSpeed: DetectionSpeed.normal,
        facing: CameraFacing.back,
        torchEnabled: true,
      ),
      onDetect: (capture) {
        final List<Barcode> barcodes = capture.barcodes;
        for (final barcode in barcodes) {
          widget.callback(barcode.rawValue ?? "");
        }
      },
    );
  }
}
