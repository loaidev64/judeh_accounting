import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:judeh_accounting/shared/widgets/widgets.dart';

class AddEditBottomNavBar extends StatelessWidget {
  const AddEditBottomNavBar({
    super.key,
    required this.onAdd,
    this.onEdit,
    required this.resourceName,
  });

  final Future Function()? onEdit;

  final Future Function() onAdd;

  final String resourceName;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      constraints: BoxConstraints(maxHeight: 75.h),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      child: Row(
        children: [
          Expanded(
            child: AppButton(
              onTap: onEdit,
              text: 'التعديل على السطر',
            ),
          ),
          SizedBox(width: 5.w),
          Expanded(
            child: AppButton(
              onTap: onAdd,
              text: 'إضافة $resourceName',
              icon: 'assets/svgs/plus.svg',
            ),
          ),
        ],
      ),
    );
  }
}
