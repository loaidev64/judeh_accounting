import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:judeh_accounting/shared/theme/app_text_styles.dart';

import '../theme/app_colors.dart';

class AppTextFormField extends StatelessWidget {
  const AppTextFormField({
    super.key,
    required this.label,
    this.readonly = false,
    this.controller,
  });

  final TextEditingController? controller;

  final String label;

  final bool readonly;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label :',
          style: AppTextStyles.appTextFormFieldLabel,
        ),
        TextFormField(
          readOnly: readonly,
          controller: controller,
          textAlign: TextAlign.center,
          onEditingComplete: FocusScope.of(context).nextFocus,
          style: AppTextStyles.appTextFormFieldText
              .copyWith(color: readonly ? AppColors.orange : AppColors.primary),
          decoration: InputDecoration(
            border: _border(),
            enabledBorder: _border(),
            focusedBorder: _border(),
            disabledBorder: _border(),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _border() {
    return OutlineInputBorder(
      borderSide: BorderSide(
        color: AppColors.primary,
        width: 3,
      ),
      borderRadius: BorderRadius.circular(15.r),
    );
  }
}
