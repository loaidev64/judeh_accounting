import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:judeh_accounting/shared/theme/app_text_styles.dart';

import '../theme/app_colors.dart';
import 'app_loading.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.onTap,
    required this.text,
    this.submit = false,
    this.icon,
    this.color = AppColors.primary,
  });

  final Future<void> Function()? onTap;

  final String text;

  final bool submit;

  final String? icon;

  final Color color;

  @override
  Widget build(BuildContext context) {
    return ObxValue(
        (loading) => GestureDetector(
              onTap: loading.value
                  ? null
                  : () async {
                      loading.toggle();
                      await onTap?.call();
                      loading.toggle();
                    },
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(5.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 10.h),
                child: loading.value
                    ? AppLoading()
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            text,
                            style: AppTextStyles.appButton,
                          ),
                          if (icon != null) ...[
                            SizedBox(width: 10.w),
                            SvgPicture.asset(
                              icon!,
                              height: 24.sp,
                            ),
                          ]
                        ],
                      ),
              ),
            ),
        false.obs);
  }
}
