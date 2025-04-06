import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:judeh_accounting/shared/helpers/database_helper.dart';
import 'package:judeh_accounting/shared/theme/app_colors.dart';

import '../../shared/widgets/widgets.dart';
import '../models/customer.dart';

class CustomerController extends GetxController {
  final customers = <Customer>[].obs;
  int selectedIndex = -1;

  final _idTextController = TextEditingController();
  final _nameTextController = TextEditingController();
  final _phoneNumberTextController = TextEditingController();
  final _descriptionTextController = TextEditingController();

  static const _bottomSheetBorderRadius = BorderRadius.only(
    topLeft: Radius.circular(15),
    topRight: Radius.circular(15),
  );
  static const _bottomSheetBoxShadow = BoxShadow(
    color: AppColors.primary,
    offset: Offset(0, -10),
  );
  static const _bottomSheetPadding = EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 10,
  );

  @override
  void onClose() {
    _idTextController.dispose();
    _nameTextController.dispose();
    _phoneNumberTextController.dispose();
    _descriptionTextController.dispose();
    super.onClose();
  }

  @override
  void onInit() async {
    await getData();
    super.onInit();
  }

  Future<void> getData() async {
    final database = DatabaseHelper.getDatabase();
    final data = await database.query(Customer.tableName, limit: 25);
    customers.assignAll(data.map((e) => Customer.fromDatabase(e)));
  }

  Future<void> _showCustomerForm(Customer customer,
      {bool isEditing = false}) async {
    await Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: _bottomSheetBorderRadius,
          boxShadow: [_bottomSheetBoxShadow],
        ),
        height: 356.h,
        width: double.infinity,
        padding: _bottomSheetPadding,
        child: Material(
          child: Form(
            child: Column(
              children: [
                _buildNameAndPhoneNumberFields(customer, isEditing: isEditing),
                SizedBox(height: 5.h),
                _buildDescriptionField(customer, isEditing: isEditing),
                SizedBox(height: 10.h),
                _buildActionButtons(customer, isEditing: isEditing),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
    await getData();
  }

  Widget _buildNameAndPhoneNumberFields(Customer customer,
      {required bool isEditing}) {
    return Row(
      children: [
        Expanded(
          child: AppTextFormField(
            label: 'الاسم',
            onSaved: (value) => customer.name = value ?? '',
            isRequired: true,
            controller: isEditing ? _nameTextController : null,
          ),
        ),
        SizedBox(width: 5.w),
        Expanded(
          child: AppTextFormField(
            label: 'الرقم',
            onSaved: (value) => customer.phoneNumber = value,
            controller: isEditing ? _phoneNumberTextController : null,
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField(Customer customer, {required bool isEditing}) {
    return AppTextFormField(
      label: 'ملاحظات',
      onSaved: (value) => customer.description = value,
      controller: isEditing ? _descriptionTextController : null,
    );
  }

  Widget _buildActionButtons(Customer customer, {bool isEditing = false}) {
    return Row(
      children: [
        if (isEditing)
          Expanded(
            child: Builder(
              builder: (context) {
                return AppButton(
                  onTap: () async {
                    await DatabaseHelper.delete(
                      model: customer,
                      tableName: Customer.tableName,
                    );
                    Get.back();
                  },
                  text: 'حذف',
                  color: Colors.red,
                  icon: 'assets/svgs/delete.svg',
                );
              },
            ),
          ),
        if (isEditing) SizedBox(width: 5.w),
        Expanded(
          child: Builder(
            builder: (context) {
              return AppButton(
                onTap: () async {
                  if (Form.of(context).validate()) {
                    Form.of(context).save();
                    if (isEditing) {
                      await DatabaseHelper.update(
                        model: customer,
                        tableName: Customer.tableName,
                      );
                    } else {
                      await DatabaseHelper.create(
                        model: customer,
                        tableName: Customer.tableName,
                      );
                    }
                    Get.back();
                  }
                },
                text: isEditing ? 'تعديل' : 'إضافة',
                icon:
                    isEditing ? 'assets/svgs/edit.svg' : 'assets/svgs/plus.svg',
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> create() async {
    final customer = Customer.empty();
    await _showCustomerForm(customer);
  }

  Future<void> edit() async {
    if (selectedIndex < 0) {
      Get.snackbar(
        'تحذير',
        'يجب عليك أولاً اختيار عميل',
        colorText: Colors.white,
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
        snackStyle: SnackStyle.GROUNDED,
      );
      return;
    }

    final customer = customers[selectedIndex];
    _idTextController.text = customer.id.toString();
    _nameTextController.text = customer.name;
    _phoneNumberTextController.text = customer.phoneNumber ?? '';
    _descriptionTextController.text = customer.description ?? '';

    await _showCustomerForm(customer, isEditing: true);
  }
}
