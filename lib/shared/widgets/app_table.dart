import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:judeh_accounting/shared/theme/app_text_styles.dart';
import '../theme/app_colors.dart';

class AppTable extends StatefulWidget {
  const AppTable({
    super.key,
    required this.headers,
    required this.itemsCount,
    required this.getData,
    this.onSelect,
    this.onDelete,
  });

  final List<Header> headers;

  final int itemsCount;

  final List<String> Function(int index) getData;

  final void Function(int index)? onSelect;

  final void Function(int index)? onDelete;

  @override
  State<AppTable> createState() => _AppTableState();
}

class _AppTableState extends State<AppTable> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 5.h),
          child: Row(
            children: widget.headers
                .map((header) => _columnHeader(header, context))
                .toList(),
          ),
        ),
        ...List.generate(
          widget.itemsCount,
          (index) => GestureDetector(
            onTap: () {
              if (widget.onSelect != null) {
                _selectedIndex = index;
                setState(() {});
                widget.onSelect!.call(index);
              }
            },
            child: _row(index, context, _selectedIndex),
          ),
        ),
      ],
    );
  }

  Widget _columnHeader(Header header, BuildContext context) => Container(
        width: header.width,
        margin: EdgeInsets.symmetric(horizontal: 2.w),
        padding: EdgeInsets.symmetric(vertical: 5.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.r),
          color: AppColors.primary,
        ),
        child: Center(
          child: Text(
            header.label,
            style: AppTextStyles.appTableHeader,
          ),
        ),
      );

  Widget _row(int index, BuildContext context, int? selectedIndex) {
    final data = widget.getData(index);
    final longestString = data.longestString;
    return Padding(
      padding: EdgeInsets.only(bottom: 5.h),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: longestString.contains('\n')
              ? (longestString.split('\n').length * 30).h
              : longestString.length > 20
                  ? (longestString.length.toDouble() * 2.5).h
                  : 30.h,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.onDelete != null)
              GestureDetector(
                child: Icon(Icons.close),
                onTap: () => widget.onDelete!(index),
              ),
            for (int i = 0; i < widget.headers.length; i++)
              _cell(widget.headers[i].width, data[i], context,
                  index == selectedIndex),
          ],
        ),
      ),
    );
  }

  Widget _cell(
          double width, String text, BuildContext context, bool selected) =>
      Container(
        width: width,
        margin: EdgeInsets.symmetric(horizontal: 2.w),
        padding: EdgeInsets.symmetric(vertical: 5.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.r),
          color: selected ? Colors.green : AppColors.secondary,
        ),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
            style: AppTextStyles.appTableCell,
          ),
        ),
      );
}

extension NewListOfString on List<String> {
  String get longestString {
    String longest = '';

    forEach((element) {
      if (element.length > longest.length) {
        longest = element;
      }
    });

    return longest;
  }
}

final class Header {
  final String label;

  final double width;

  Header({required this.label, required this.width});
}
