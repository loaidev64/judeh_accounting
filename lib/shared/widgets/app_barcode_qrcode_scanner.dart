import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:judeh_accounting/shared/theme/app_colors.dart';
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
      child: Stack(
        children: [
          QrCamera(
            notStartedBuilder: (context) => AppLoading(),
            qrCodeCallback: (code) async {
              if (canScan) {
                widget.onScan(code);
                canScan = false;
                Future.delayed(Duration(seconds: 1)).then((_) => canScan = true);
              }
            },
          ),
          Positioned(child: IconButton(onPressed: QrCamera.toggleFlash, icon: Container(child: Icon(Icons.flash_on, color: Colors.white,), padding: EdgeInsets.all(8), decoration: BoxDecoration(
            color: AppColors.orange,
            borderRadius: BorderRadius.circular(15.r),
          ),),), bottom: 0, right: 0,),
        ],
      ),
    );
  }
}
