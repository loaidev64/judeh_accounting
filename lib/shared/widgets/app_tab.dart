import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:judeh_accounting/shared/theme/app_colors.dart';
import 'package:judeh_accounting/shared/theme/app_text_styles.dart';

class AppTab extends StatelessWidget {
  const AppTab({
    super.key,
    required this.selected,
    required this.onTap,
    required this.text,
    this.icon,
  });

  final bool selected;

  final Function() onTap;

  final String text;

  final String? icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.secondary,
          borderRadius: BorderRadius.circular(15.r),
          border: selected ? Border.all(color: AppColors.orange) : null,
        ),
        padding: EdgeInsets.symmetric(
            vertical: icon != null ? 5.h : 10.h,
            horizontal: icon != null ? 12.w : 15.w),
        child: Column(
          children: [
            if (icon != null) SvgPicture.asset(icon!),
            Text(
              text,
              style: AppTextStyles.appTab.copyWith(
                  color: selected ? Colors.white : AppColors.primary,
                  fontSize: icon != null ? 16.sp : null),
            ),
          ],
        ),
      ),
    );
  }
}
