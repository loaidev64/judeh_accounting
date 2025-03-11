import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:judeh_accounting/shared/theme/app_info.dart';
import 'package:judeh_accounting/shared/widgets/widgets.dart';

class HomeScreen extends StatelessWidget {
  static const routeName = '/home';

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: AppInfo.fullAppName,
      child: SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        sliver: SliverAnimatedGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, crossAxisSpacing: 10.w, mainAxisSpacing: 10.h),
          initialItemCount: ScreenCard.homeCards.length,
          itemBuilder: (context, index, animation) =>
              ScreenCard.homeCards[index],
        ),
      ),
    );
  }
}
