import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:judeh_accounting/shared/widgets/widgets.dart';
import 'package:qr_mobile_vision/qr_camera.dart';

class AppBarcodeQrcodeScanner extends StatefulWidget {
  const AppBarcodeQrcodeScanner({
    super.key,
    required this.onScan,
  });

  final void Function(String? barcode) onScan;

  @override
  State<AppBarcodeQrcodeScanner> createState() =>
      _AppBarcodeQrcodeScannerState();
}

class _AppBarcodeQrcodeScannerState extends State<AppBarcodeQrcodeScanner> {
  bool canScan = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 150.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: QrCamera(
        notStartedBuilder: (context) => AppLoading(),
        qrCodeCallback: (code) async {
          if (canScan) {
            widget.onScan(code);
            canScan = false;
            Future.delayed(Duration(seconds: 1)).then((_) => canScan = true);
          }
        },
      ),
    );
  }
}
