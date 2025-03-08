import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:judeh_accounting/shared/helpers/database_helper.dart';
import 'package:judeh_accounting/shared/theme/app_colors.dart';

import '../../shared/widgets/widgets.dart';
import '../models/company.dart';

final class CompanyController extends GetxController {
  final companies = <Company>[].obs;

  int selectedIndex = -1;

  final _idTextController = TextEditingController();
  final _nameTextController = TextEditingController();
  final _phoneNumberTextController = TextEditingController();
  final _descriptionTextController = TextEditingController();

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

  Future<void> create() async {
    final company = Company.empty();
    await Get.bottomSheet(
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15.r),
              topRight: Radius.circular(15.r),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary,
                offset: Offset(0, -10),
              ),
            ],
          ),
          height: 356.h,
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
          child: Material(
            child: Form(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AppTextFormField(
                          label: 'الاسم',
                          onSaved: (value) => company.name = value ?? '',
                          isRequired: true,
                        ),
                      ),
                      SizedBox(width: 5.w),
                      Expanded(
                        child: AppTextFormField(
                          label: 'الرقم',
                          onSaved: (value) => company.phoneNumber = value,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5.h),
                  AppTextFormField(
                    label: 'ملاحظات',
                    onSaved: (value) => company.description = value,
                  ),
                  SizedBox(height: 10.h),
                  Builder(builder: (context) {
                    return AppButton(
                      onTap: () async {
                        if (Form.of(context).validate()) {
                          Form.of(context).save();
                          await DatabaseHelper.create(
                              model: company, tableName: Company.tableName);

                          if (context.mounted) Navigator.of(context).pop();
                        }
                      },
                      text: 'إضافة',
                      icon: 'assets/svgs/plus.svg',
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
        isScrollControlled: true);

    await getData();
  }

  Future<void> edit() async {
    if (selectedIndex < 0) {
      Get.snackbar(
        'تحذير',
        'يجب عليك اولاً اختيار شركة',
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
    await Get.bottomSheet(
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15.r),
              topRight: Radius.circular(15.r),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary,
                offset: Offset(0, -10),
              ),
            ],
          ),
          height: 356.h,
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
          child: Material(
            child: Form(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AppTextFormField(
                          label: 'الاسم',
                          onSaved: (value) => company.name = value ?? '',
                          isRequired: true,
                          controller: _nameTextController,
                        ),
                      ),
                      SizedBox(width: 5.w),
                      Expanded(
                        child: AppTextFormField(
                          label: 'الرقم',
                          onSaved: (value) => company.phoneNumber = value,
                          controller: _phoneNumberTextController,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5.h),
                  AppTextFormField(
                    label: 'ملاحظات',
                    onSaved: (value) => company.description = value,
                    controller: _descriptionTextController,
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      Expanded(child: Builder(builder: (context) {
                        return AppButton(
                          onTap: () async {
                            await DatabaseHelper.delete(
                                model: company, tableName: Company.tableName);
                            if (context.mounted) Navigator.of(context).pop();
                          },
                          text: 'حذف',
                          color: Colors.red,
                          icon: 'assets/svgs/delete.svg',
                        );
                      })),
                      SizedBox(width: 5.w),
                      Expanded(
                        child: Builder(builder: (context) {
                          return AppButton(
                            onTap: () async {
                              if (Form.of(context).validate()) {
                                Form.of(context).save();
                                await DatabaseHelper.update(
                                    model: company,
                                    tableName: Company.tableName);

                                if (context.mounted)
                                  Navigator.of(context).pop();
                              }
                            },
                            text: 'تعديل',
                            icon: 'assets/svgs/edit.svg',
                          );
                        }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        isScrollControlled: true);

    await getData();
  }

  Future<void> getData({bool paginate = false}) async {
    final database = DatabaseHelper.getDatabase();

    final data = await database.query(Company.tableName, limit: 100);
    if (!paginate) {
      companies.clear();
    }
    companies.addAll(data.map((e) => Company.fromDatabase(e)));
  }
}
