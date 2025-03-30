import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:judeh_accounting/shared/widgets/widgets.dart';

import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../models/company.dart'; // Import the Company model

class CompanySearch extends StatefulWidget {
  const CompanySearch({
    super.key,
    required this.onSearch,
    required this.onSelected,
    this.controller,
  });

  final Future<List<Company>> Function(String? search) onSearch;
  final void Function([Company? company]) onSelected;
  final TextEditingController? controller;

  @override
  State<CompanySearch> createState() => _CompanySearchState();
}

class _CompanySearchState extends State<CompanySearch> {
  late final companyController = widget.controller ?? TextEditingController();

  @override
  Widget build(BuildContext context) {
    return TypeAheadField<Company>(
      suggestionsCallback: widget.onSearch,
      controller: companyController,
      builder: (context, controller, focusNode) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الشركة',
              style: AppTextStyles.appTextFormFieldLabel,
            ),
            TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                suffix: GestureDetector(
                  onTap: () {
                    companyController.clear();
                    widget.onSelected();
                  },
                  child: Icon(
                    Icons.close,
                    color: AppColors.primary,
                  ),
                ),
                border: AppTextFormField.border(),
                enabledBorder: AppTextFormField.border(),
                focusedBorder: AppTextFormField.border(),
                disabledBorder: AppTextFormField.border(),
              ),
            ),
          ],
        );
      },
      emptyBuilder: (context) => Padding(
        padding: EdgeInsets.all(10.w),
        child: Text('لا يوجد أي نتائج'),
      ),
      itemBuilder: (context, company) {
        return ListTile(
          title: Text(company.name),
          subtitle: Text(company.description ?? ''),
        );
      },
      onSelected: (company) {
        companyController.text = company.name;
        widget.onSelected(company);
      },
    );
  }
}
