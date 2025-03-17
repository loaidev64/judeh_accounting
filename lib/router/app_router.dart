import 'package:get/get.dart';
import 'package:judeh_accounting/company/screens/company_screen.dart';
import 'package:judeh_accounting/customer/screens/customer_screen.dart';
import 'package:judeh_accounting/expense/screens/expense_screen.dart';
import 'package:judeh_accounting/home/screens/home_screen.dart';
import 'package:judeh_accounting/order/screens/order_screen.dart';
import 'package:judeh_accounting/order/screens/order_management_screen.dart';
import 'package:judeh_accounting/other/screens/other_screen.dart';
import 'package:judeh_accounting/report/screens/report_screen.dart';

import '../material/screens/material_movment_screen.dart';
import '../material/screens/material_screen.dart';

abstract class AppRouter {
  static final routes = <GetPage>[
    GetPage(name: HomeScreen.routeName, page: () => HomeScreen()),
    GetPage(name: ExpenseScreen.routeName, page: () => ExpenseScreen()),
    GetPage(
        name: MaterialMovmentScreen.routeName,
        page: () => MaterialMovmentScreen()),
    GetPage(name: DebtScreen.routeName, page: () => DebtScreen()),
    GetPage(name: OrderScreen.routeName, page: () => OrderScreen()),
    GetPage(name: CompanyScreen.routeName, page: () => CompanyScreen()),
    GetPage(name: MaterialScreen.routeName, page: () => MaterialScreen()),
    GetPage(name: OtherScreen.routeName, page: () => OtherScreen()),
    GetPage(name: ReportScreen.routeName, page: () => ReportScreen()),
    GetPage(
        name: OrderManagementScreen.routeName,
        page: () => OrderManagementScreen()),
  ];

  static const initialRoute = HomeScreen.routeName;
}
