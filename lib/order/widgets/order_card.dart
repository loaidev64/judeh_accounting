import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:judeh_accounting/order/models/order.dart';
import 'package:judeh_accounting/shared/extensions/datetime.dart';
import 'package:judeh_accounting/shared/extensions/double.dart';
import 'package:judeh_accounting/shared/theme/app_text_styles.dart';

import '../../shared/theme/app_colors.dart';
import '../../shared/widgets/widgets.dart';

class OrderCard extends StatefulWidget {
  const OrderCard({
    super.key,
    required this.order,
    this.borderColor = AppColors.primary,
    this.onSelectRow,
    this.onSelect,
    this.onDelete,
    this.haveFixedHeight = true,
  });

  final Order order;

  final Color borderColor;

  final void Function(int)? onSelectRow;

  final void Function()? onSelect;

  final bool haveFixedHeight;

  final void Function(int index)? onDelete;

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  bool expanded = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onSelect,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(color: widget.borderColor, width: 3),
        ),
        height: widget.haveFixedHeight ? 300.h : null,
        padding: EdgeInsets.all(5),
        margin: EdgeInsets.only(bottom: 5.h),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _headerSection(context),
              SizedBox(height: 5.h),
              if (expanded)
                AppTable(
                  headers: [
                    Header(label: 'الرقم', width: 59.w),
                    Header(label: 'التفاصيل', width: 187.w),
                    Header(label: 'السعر', width: 70.w),
                  ],
                  onDelete: widget.onDelete,
                  onSelect: widget.onSelectRow,
                  itemsCount: widget.order.items.length,
                  getData: (index) => [
                    (index + 1).toString(),
                    widget.order.items[index].description,
                    widget.order.items[index].subTotal.toPriceString,
                  ],
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

  Widget _total(BuildContext context) {
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
              widget.order.total.toPriceString,
              style: AppTextStyles.orderCardTotal,
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerSection(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() {
        expanded = !expanded;
      }),
      child: Row(
        children: [
          Text(
            '${widget.order.createdAt.dayName} \n ${widget.order.createdAt.toDateString}',
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
              widget.order.id.toString(),
              style: AppTextStyles.orderCardId,
            ),
          ),
          Spacer(flex: 4),
          Text(
            widget.order.createdAt.toTimeString,
            style: AppTextStyles.orderCardDateTime,
          ),
        ],
      ),
    );
  }
}
