import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:judeh_accounting/order/models/order.dart';
import 'package:judeh_accounting/shared/extensions/datetime.dart';
import 'package:judeh_accounting/shared/extensions/double.dart';
import 'package:judeh_accounting/shared/theme/app_text_styles.dart';

import '../../shared/theme/app_colors.dart';
import '../../shared/widgets/widgets.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.order,
    this.borderColor = AppColors.primary,
    this.onSelect,
    this.onDelete,
    this.height,
  });

  final Order order;

  final Color borderColor;

  final void Function(int)? onSelect;

  final double? height;

  final void Function(int index)? onDelete;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // onTap: () => context.pushNamed(AddOrderScreen.endpoint),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(color: borderColor, width: 3),
        ),
        height: height ?? 178.h,
        padding: EdgeInsets.all(5),
        margin: EdgeInsets.only(bottom: 5.h),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _headerSection(context),
              SizedBox(height: 5.h),
              AppTable(
                headers: [
                  Header(label: 'الرقم', width: 59.w),
                  Header(label: 'التفاصيل', width: 187.w),
                  Header(label: 'السعر', width: 70.w),
                ],
                onDelete: onDelete,
                onSelect: onSelect,
                itemsCount: order.items.length,
                getData: (index) => [
                  (index + 1).toString(),
                  order.items[index].description,
                  order.items[index].subTotal.toPriceString,
                ],
              ),
              SizedBox(height: 5.h),
              //TODO:: make an expanded functionallity
              // if (!expanded.value)
              GestureDetector(
                // onTap: () => expanded.value = true,
                child: Column(
                  children: [
                    _dot(),
                    _dot(),
                    _dot(),
                  ],
                ),
              ),
              SizedBox(height: 5.h),
              _total(context),
              SizedBox(height: 5.h),
            ],
          ),
        ),
      ),
    );
  }

  Container _total(BuildContext context) {
    return Container(
      width: 96.w,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(15.r),
      ),
      padding: EdgeInsets.all(10.h),
      child: Center(
        child: Column(
          children: [
            Text(
              'المجموع النهائي',
              style: AppTextStyles.orderCardTotal,
            ),
            Text(
              order.total.toPriceString,
              style: AppTextStyles.orderCardTotal,
            ),
          ],
        ),
      ),
    );
  }

  Container _dot() {
    return Container(
      width: 5.w,
      height: 5.w,
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: AppColors.orange,
        shape: BoxShape.circle,
      ),
    );
  }

  Row _headerSection(BuildContext context) {
    return Row(
      children: [
        Text(
          '${order.createdAt.dayName} \n ${order.createdAt.toDateString}',
          style: AppTextStyles.orderCardDateTime,
        ),
        Spacer(flex: 3),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.r),
            color: AppColors.primary,
          ),
          child: Text(
            order.id.toString(),
            style: AppTextStyles.orderCardId,
          ),
        ),
        Spacer(flex: 4),
        Text(
          order.createdAt.toTimeString,
          style: AppTextStyles.orderCardDateTime,
        ),
      ],
    );
  }
}
