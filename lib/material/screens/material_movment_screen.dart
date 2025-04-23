import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/material_movment_controller.dart';
import 'package:judeh_accounting/shared/widgets/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MaterialMovmentScreen extends StatefulWidget {
  static const routeName = '/materialMovment';

  const MaterialMovmentScreen({super.key});

  @override
  State<MaterialMovmentScreen> createState() => _MaterialMovmentScreenState();
}

class _MaterialMovmentScreenState extends State<MaterialMovmentScreen> {
  final controller = Get.put(MaterialMovmentController());

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'حركة المادة',
      child: SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          sliver: SliverToBoxAdapter(
        child: Text('materialMovment'),
      ),
      ),
    );
  }
}
