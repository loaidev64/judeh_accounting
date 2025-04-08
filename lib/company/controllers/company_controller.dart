import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:judeh_accounting/shared/helpers/database_helper.dart';
import 'package:judeh_accounting/shared/theme/app_colors.dart';

import '../../shared/widgets/widgets.dart';
import '../models/company.dart';

class CompanyController extends GetxController {
  final companies = <Company>[].obs;
  int selectedIndex = -1;

  final _idTextController = TextEditingController();
  final _nameTextController = TextEditingController();
  final _phoneNumberTextController = TextEditingController();
  final _descriptionTextController = TextEditingController();

  // Constants for repeated values
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

  /// Fetches company data from the database.
  Future<void> getData() async {
    final database = DatabaseHelper.getDatabase();
    final data = await database.query(Company.tableName, limit: 25);
    companies.assignAll(data.map((e) => Company.fromDatabase(e)));
  }

  /// Opens a bottom sheet to create or edit a company.
  Future<void> _showCompanyForm(Company company,
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
                _buildNameAndPhoneNumberFields(company, isEditing: isEditing),
                SizedBox(height: 5.h),
                _buildDescriptionField(company, isEditing: isEditing),
                SizedBox(height: 10.h),
                _buildActionButtons(company, isEditing: isEditing),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );

    await getData(); // Refresh the companies list
  }

  /// Builds the name and phone number fields.
  Widget _buildNameAndPhoneNumberFields(Company company,
      {required bool isEditing}) {
    return Row(
      children: [
        Expanded(
          child: AppTextFormField(
            label: 'الاسم',
            onSaved: (value) => company.name = value ?? '',
            isRequired: true,
            controller: isEditing ? _nameTextController : null,
          ),
        ),
        SizedBox(width: 5.w),
        Expanded(
          child: AppTextFormField(
            label: 'الرقم',
            onSaved: (value) => company.phoneNumber = value,
            controller: isEditing ? _phoneNumberTextController : null,
          ),
        ),
      ],
    );
  }

  /// Builds the description field.
  Widget _buildDescriptionField(Company company, {required bool isEditing}) {
    return AppTextFormField(
      label: 'ملاحظات',
      onSaved: (value) => company.description = value,
      controller: isEditing ? _descriptionTextController : null,
    );
  }

  /// Builds the action buttons (Add/Edit, Delete).
  Widget _buildActionButtons(Company company, {bool isEditing = false}) {
    return Row(
      children: [
        if (isEditing)
          Expanded(
            child: Builder(
              builder: (context) {
                return AppButton(
                  onTap: () async {
                    await DatabaseHelper.delete(
                      model: company,
                      tableName: Company.tableName,
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
                        model: company,
                        tableName: Company.tableName,
                      );
                    } else {
                      await DatabaseHelper.create(
                        model: company,
                        tableName: Company.tableName,
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

  /// Opens a bottom sheet to create a new company.
  Future<void> create() async {
    final company = Company.empty();
    await _showCompanyForm(company);
  }

  /// Opens a bottom sheet to edit an existing company.
  Future<void> edit() async {
    if (selectedIndex < 0) {
      Get.snackbar(
        'تحذير',
        'يجب عليك أولاً اختيار شركة',
        colorText: Colors.white,
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
        snackStyle: SnackStyle.GROUNDED,
      );
      return;
    }

    final company = companies[selectedIndex];
    _idTextController.text = company.id.toString();
    _nameTextController.text = company.name;
    _phoneNumberTextController.text = company.phoneNumber ?? '';
    _descriptionTextController.text = company.description ?? '';

    await _showCompanyForm(company, isEditing: true);
  }
}
