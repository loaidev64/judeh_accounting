import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:judeh_accounting/shared/theme/app_colors.dart';

const appFontFamily = 'Mirza';

abstract interface class AppTextStyles {
  static final appScaffoldAppBarText = TextStyle(
    fontFamily: appFontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 32.sp,
    color: AppColors.primary,
  );

  static final appTextFormFieldText = TextStyle(
    fontFamily: appFontFamily,
    fontSize: 18.sp,
    color: AppColors.primary,
  );

  static final appTextFormFieldLabel = TextStyle(
    fontFamily: appFontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 20.sp,
    color: AppColors.primary,
  );

  static final appTableHeader = TextStyle(
    fontFamily: appFontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 13.sp,
    color: Colors.white,
  );

  static final appTableCell = TextStyle(
    fontFamily: appFontFamily,
    fontSize: 10.sp,
    color: AppColors.primary,
  );

  static final appButton = TextStyle(
    fontFamily: appFontFamily,
    fontSize: 24.sp,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  static final appTab = TextStyle(
    fontFamily: appFontFamily,
    fontSize: 18.sp,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  static final orderCardTotal = TextStyle(
    fontFamily: appFontFamily,
    fontSize: 10.sp,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  static final orderCardDateTime = TextStyle(
    fontFamily: appFontFamily,
    fontSize: 13.sp,
    color: AppColors.orange,
  );

  static final orderCardId = TextStyle(
    fontFamily: appFontFamily,
    fontSize: 16.sp,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );
}
