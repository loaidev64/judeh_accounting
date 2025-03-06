import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:judeh_accounting/shared/helpers/database_helper.dart';
import 'package:judeh_accounting/shared/theme/app_colors.dart';

import '../../shared/widgets/widgets.dart';
import '../models/company.dart';

final class CompanyController extends GetxController {
  final companies = <Company>[].obs;

  @override
  void onInit() async {
    final database = DatabaseHelper.getDatabase();

    final data = await database.query(Company.tableName, limit: 100);

    companies.addAll(data.map((e) => Company.fromDatabase(e)));
    super.onInit();
  }

  void create() async {
    await Get.bottomSheet(
      BottomSheet(
        onClosing: () => 0,
        builder: (context) => Material(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15.r),
                topRight: Radius.circular(15.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            height: 356.h,
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
            // constraints: BoxConstraints(maxHeight: 356.h),
            child: Form(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AppTextFormField(
                          label: 'المعرف',
                          readonly: true,
                        ),
                      ),
                      Spacer(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      // Material(
      //   child: Container(
      //     decoration: BoxDecoration(
      //       color: Colors.white,
      //       borderRadius: BorderRadius.only(
      //         topLeft: Radius.circular(15.r),
      //         topRight: Radius.circular(15.r),
      //       ),
      //       boxShadow: [
      //         BoxShadow(
      //           color: AppColors.primary,
      //           offset: Offset(0, 10),
      //         ),
      //       ],
      //     ),
      //     height: 356.h,
      //     width: double.infinity,
      //     // constraints: BoxConstraints(maxHeight: 356.h),
      //     child: Text('dsakopkdsao'),
      //   ),
      // ),
    );
  }
}
