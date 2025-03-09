import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:judeh_accounting/shared/theme/app_colors.dart';
import 'package:judeh_accounting/shared/theme/app_text_styles.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.title,
    required this.child,
    this.bottomNavBar,
  });

  final String title;

  final Widget child;

  final Widget? bottomNavBar;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        bottomNavigationBar: bottomNavBar,
        body: CustomScrollView(
          slivers: [
            // Add the app bar to the CustomScrollView.
            SliverPadding(
              padding: EdgeInsets.symmetric(vertical: 25.h, horizontal: 10.w),
              sliver: SliverAppBar(
                leading: !Navigator.of(context).canPop()
                    ? null
                    : Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(15.r),
                        ),
                        child: BackButton(
                          color: Colors.white,
                        )),
                // Provide a standard title.
                title: Text(
                  title,
                  style: AppTextStyles.appScaffoldAppBarText,
                ),
                centerTitle: true,
                actions: [
                  Padding(
                    padding: EdgeInsets.only(left: 15.w),
                    child: Image.asset('assets/logos/logo.png'),
                  ),
                ],
                // Allows the user to reveal the app bar if they begin scrolling
                // back up the list of items.
                floating: true,
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}
