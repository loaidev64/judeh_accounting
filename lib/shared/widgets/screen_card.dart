import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../company/screens/company_screen.dart';
import '../../customer/screens/customer_screen.dart';
import '../../expense/screens/expense_screen.dart';
import '../../material/screens/material_movment_screen.dart';
import '../../material/screens/material_screen.dart';
import '../../order/screens/order_screen.dart';
import '../../other/screens/other_screen.dart';
import '../../report/screens/report_screen.dart';
import '../theme/app_colors.dart';

class ScreenCard extends StatelessWidget {
  final String icon;

  final String label;

  final String routeName;

  const ScreenCard({
    super.key,
    required this.icon,
    required this.label,
    required this.routeName,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(routeName),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(icon),
            SizedBox(height: 5.h),
            Text(
              label,
              style: context.textTheme.bodyLarge?.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  static List<ScreenCard> get otherCards => [
        ScreenCard(
          icon: 'assets/svgs/expenses.svg',
          label: 'المصاريف',
          routeName: ExpenseScreen.routeName,
        ),
        ScreenCard(
          icon: 'assets/svgs/material_movment.svg',
          label: 'حركة المادة',
          routeName: MaterialMovmentScreen.routeName,
        ),
      ];

  static List<ScreenCard> get homeCards => [
        ScreenCard(
          icon: 'assets/svgs/bills.svg',
          label: 'الفواتير',
          routeName: OrderScreen.routeName,
        ),
        ScreenCard(
          icon: 'assets/svgs/company.svg',
          label: 'الشركات',
          routeName: CompanyScreen.routeName,
        ),
        ScreenCard(
          icon: 'assets/svgs/material.svg',
          label: 'المنتجات',
          routeName: MaterialScreen.routeName,
        ),
        ScreenCard(
          icon: 'assets/svgs/other.svg',
          label: 'أخرى',
          routeName: OtherScreen.routeName,
        ),
        ScreenCard(
          icon: 'assets/svgs/report.svg',
          label: 'الجرد',
          routeName: ReportScreen.routeName,
        ),
        ScreenCard(
          icon: 'assets/svgs/debt.svg',
          label: 'الزبائن',
          routeName: CustomerScreen.routeName,
        ),
      ];
}
