import 'package:flutter/material.dart' hide Material;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:judeh_accounting/shared/extensions/double.dart';
import 'package:judeh_accounting/shared/theme/app_colors.dart';
import 'package:judeh_accounting/shared/theme/app_text_styles.dart';
import 'package:judeh_accounting/shared/widgets/widgets.dart';

import '../models/material.dart';

class MaterialSearch extends StatefulWidget {
  const MaterialSearch({
    super.key,
    required this.onSearch,
    required this.onSelected,
  });

  final Future<List<Material>> Function(String? search) onSearch;

  final void Function([Material? material]) onSelected;

  @override
  State<MaterialSearch> createState() => _MaterialSearchState();
}

class _MaterialSearchState extends State<MaterialSearch> {
  final materialController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return TypeAheadField<Material>(
      suggestionsCallback: widget.onSearch,
      controller: materialController,
      builder: (context, controller, focusNode) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'المنتج',
              style: AppTextStyles.appTextFormFieldLabel,
            ),
            TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                suffix: GestureDetector(
                  onTap: () {
                    materialController.clear();
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
      itemBuilder: (context, material) {
        return ListTile(
          title: Text(material.name),
          subtitle: Text('السعر: ${material.price.toPriceString}'),
        );
      },
      onSelected: (material) {
        materialController.text = material.name;
        widget.onSelected(material);
      },
    );
  }
}
