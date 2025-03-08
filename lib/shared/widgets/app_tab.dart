import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:judeh_accounting/shared/theme/app_colors.dart';
import 'package:judeh_accounting/shared/theme/app_text_styles.dart';

class AppTab extends StatelessWidget {
  const AppTab({
    super.key,
    required this.selected,
    required this.onTap,
    required this.text,
  });

  final bool selected;

  final Function() onTap;

  final String text;

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
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w),
        child: Text(
          text,
          style: AppTextStyles.appTab
              .copyWith(color: selected ? Colors.white : AppColors.primary),
        ),
      ),
    );
  }
}
