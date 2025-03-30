import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:judeh_accounting/shared/widgets/widgets.dart';

import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../models/customer.dart'; // Import the Customer model

class CustomerSearch extends StatefulWidget {
  const CustomerSearch({
    super.key,
    required this.onSearch,
    required this.onSelected,
    this.controller,
  });

  final Future<List<Customer>> Function(String? search) onSearch;

  final void Function([Customer? customer]) onSelected;

  final TextEditingController? controller;

  @override
  State<CustomerSearch> createState() => _CustomerSearchState();
}

class _CustomerSearchState extends State<CustomerSearch> {
  late final customerController = widget.controller ?? TextEditingController();

  @override
  Widget build(BuildContext context) {
    return TypeAheadField<Customer>(
      suggestionsCallback: widget.onSearch,
      controller: customerController,
      builder: (context, controller, focusNode) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الزبون',
              style: AppTextStyles.appTextFormFieldLabel,
            ),
            TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                suffix: GestureDetector(
                  onTap: () {
                    customerController.clear();
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
      itemBuilder: (context, customer) {
        return ListTile(
          title: Text(customer.name),
          subtitle: Text(customer.phoneNumber ?? 'لا يوجد رقم هاتف'),
        );
      },
      onSelected: (customer) {
        customerController.text = customer.name;
        widget.onSelected(customer);
      },
    );
  }
}
