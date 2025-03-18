import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:judeh_accounting/customer/controllers/customer_controller.dart';
import 'package:judeh_accounting/shared/widgets/widgets.dart';

class CustomerScreen extends StatefulWidget {
  static const routeName = '/customer';

  const CustomerScreen({super.key});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  final controller = Get.put(CustomerController());

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'الزبائن',
      bottomNavBar: AddEditBottomNavBar(
        onAdd: controller.create,
        onEdit: controller.edit,
        resourceName: 'زبون',
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
              itemsCount: controller.customers.length,
              getData: (index) => [
                controller.customers[index].id.toString(),
                controller.customers[index].name,
                controller.customers[index].phoneNumber ?? '',
                controller.customers[index].description ?? '',
              ],
            ),
          ),
        ),
      ),
    );
  }
}
