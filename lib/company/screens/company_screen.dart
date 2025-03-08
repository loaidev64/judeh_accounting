import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:judeh_accounting/company/controllers/company_controller.dart';
import 'package:judeh_accounting/shared/widgets/widgets.dart';

class CompanyScreen extends StatefulWidget {
  static const routeName = '/company';

  const CompanyScreen({super.key});

  @override
  State<CompanyScreen> createState() => _CompanyScreenState();
}

class _CompanyScreenState extends State<CompanyScreen> {
  final controller = Get.put(CompanyController());

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'الشركات',
      bottomNavBar: Container(
        color: Colors.white,
        constraints: BoxConstraints(maxHeight: 75.h),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        child: Row(
          children: [
            Expanded(
              child: AppButton(
                onTap: controller.edit,
                text: 'التعديل على السطر',
              ),
            ),
            SizedBox(width: 5.w),
            Expanded(
              child: AppButton(
                onTap: controller.create,
                text: 'إضافة شركة',
                icon: 'assets/svgs/plus.svg',
              ),
            ),
          ],
        ),
      ),
      child: Obx(
        () => SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          sliver: SliverToBoxAdapter(
            child: AppTable(
              headers: [
                Header(label: 'المعرف', width: 59.w),
                Header(label: 'الاسم', width: 65.w),
                Header(label: 'الرقم', width: 66.w),
                Header(label: 'ملاحظات', width: 133.w),
              ],
              onSelect: (index) => controller.selectedIndex = index,
              itemsCount: controller.companies.length,
              getData: (index) => [
                controller.companies[index].id.toString(),
                controller.companies[index].name,
                controller.companies[index].phoneNumber ?? '',
                controller.companies[index].description ?? '',
              ],
            ),
          ),
        ),
      ),
    );
  }
}
