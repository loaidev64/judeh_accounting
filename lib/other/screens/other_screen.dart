import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:judeh_accounting/shared/widgets/widgets.dart';

class OtherScreen extends StatelessWidget {
  static const routeName = '/other';

  const OtherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'أخرى',
      child: SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        sliver: SliverAnimatedGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, crossAxisSpacing: 10.w, mainAxisSpacing: 10.h),
          initialItemCount: ScreenCard.otherCards.length,
          itemBuilder: (context, index, animation) =>
              ScreenCard.otherCards[index],
        ),
      ),
    );
  }
}
