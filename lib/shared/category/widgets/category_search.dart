import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:judeh_accounting/shared/widgets/widgets.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../models/category.dart';

class CategorySearch extends StatefulWidget {
  const CategorySearch({
    super.key,
    required this.onSearch,
    required this.onSelected,
    this.controller,
  });

  final Future<List<Category>> Function(String? search) onSearch;

  final void Function([Category? category]) onSelected;

  final TextEditingController? controller;

  @override
  State<CategorySearch> createState() => _CategorySearchState();
}

class _CategorySearchState extends State<CategorySearch> {
  late final categoryController = widget.controller ?? TextEditingController();

  @override
  Widget build(BuildContext context) {
    return TypeAheadField<Category>(
      suggestionsCallback: widget.onSearch,
      controller: categoryController,
      builder: (context, controller, focusNode) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'التصنيف',
              style: AppTextStyles.appTextFormFieldLabel,
            ),
            TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                suffix: GestureDetector(
                  onTap: () {
                    categoryController.clear();
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
      itemBuilder: (context, category) {
        return ListTile(
          title: Text(category.name),
          subtitle: Text(category.description ?? ''),
        );
      },
      onSelected: (category) {
        categoryController.text = category.name;
        widget.onSelected(category);
      },
    );
  }
}
