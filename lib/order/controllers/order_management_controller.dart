import 'package:flutter/material.dart' hide Material;
import 'package:flutter/material.dart' as m show Material;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:judeh_accounting/order/models/order.dart';
import 'package:judeh_accounting/order/models/order_item.dart';
import 'package:judeh_accounting/shared/extensions/double.dart';
import 'package:judeh_accounting/shared/helpers/database_helper.dart';
import 'package:judeh_accounting/shared/theme/app_colors.dart';
import 'package:vibration/vibration.dart';

import '../../material/models/material.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/widgets/widgets.dart';

final class OrderManagementController extends GetxController {
  final loading = false.obs;

  final addedNewItem = false.obs;

  Order? order;

  late OrderType type;

  final items = <OrderItem>[].obs;

  final material = Material.empty().obs;

  final materialController = TextEditingController();
  final quantityController = TextEditingController();
  final priceController = TextEditingController();

  @override
  void onClose() {
    materialController.dispose();
    quantityController.dispose();
    priceController.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    final (OrderType orderType, Order? order) = Get.arguments;
    type = orderType;
    this.order = order;

    super.onInit();
  }

  void _reset() {
    material.value = Material.empty();
    materialController.clear();
    quantityController.clear();
    priceController.clear();

    Get.printInfo(info: 'reseting...');
  }

  Future<List<Material>> returnMaterials([String? search]) async {
    final database = DatabaseHelper.getDatabase();
    final List<Map<String, Object?>> data;
    if (search == null) {
      data = await database.query(Material.tableName, limit: 25);
    } else {
      data = await database.query(
        Material.tableName,
        where: 'name LIKE ?',
        whereArgs: ['%$search%'],
        limit: 25,
      );
    }

    return data.map(Material.fromDatabase).toList();
  }

  void editItem(int index) async {
    final item = items[index];
    quantityController.text = item.quantity.asIntIfItIsAnInt;
    priceController.text = item.price.toInt().toString();
    await Get.bottomSheet(
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: _bottomSheetBorderRadius,
            boxShadow: [_bottomSheetBoxShadow],
          ),
          height: 356.h,
          width: double.infinity,
          padding: _bottomSheetPadding,
          child: m.Material(
            child: Form(
              child: Column(
                children: [
                  // Builder(builder: (context) {
                  //   return TypeAheadField<Material>(
                  //     controller: materialController,
                  //     emptyBuilder: (context) => Padding(
                  //       padding: EdgeInsets.all(10.w),
                  //       child: Text('لا يوجد أي نتائج'),
                  //     ),
                  //     itemBuilder: (context, material) {
                  //       return ListTile(
                  //         title: Text(material.name),
                  //         subtitle: Text(material.price.toPriceString),
                  //       );
                  //     },
                  //     onSelected: (material) {
                  //       materialController.text = material.name;
                  //       this.material.value = material;
                  //       priceController.text = material.price.toInt().toString();
                  //       quantityController.text = 1.toString();
                  //       FocusScope.of(context).nextFocus();
                  //     },
                  //     suggestionsCallback: returnMaterials,
                  //     builder: (context, controller, focusNode) => Column(
                  //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //         Text(
                  //           'المنتج',
                  //           style: AppTextStyles.appTextFormFieldLabel,
                  //         ),
                  //         TextFormField(
                  //           controller: controller,
                  //           focusNode: focusNode,
                  //           decoration: InputDecoration(
                  //             suffix: GestureDetector(
                  //               onTap: () {
                  //                 controller.clear();
                  //               },
                  //               child: Icon(
                  //                 Icons.close,
                  //                 color: AppColors.primary,
                  //               ),
                  //             ),
                  //             border: AppTextFormField.border(),
                  //             enabledBorder: AppTextFormField.border(),
                  //             focusedBorder: AppTextFormField.border(),
                  //             disabledBorder: AppTextFormField.border(),
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   );
                  // }),

                  // SizedBox(height: 5.h),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextFormField(
                          label: 'الكمية',
                          isRequired: true,
                          autofocus: true,
                          controller: quantityController,
                          keyboardType: TextInputType.number,
                          suffix: Text(
                            material.value.unit.name,
                            style: AppTextStyles.appTextFormFieldText
                                .copyWith(color: AppColors.orange),
                          ),
                          // counter: Text(
                          //   'العدد المتبقي ${material.value.quantity.toInt()}',
                          //   style: AppTextStyles.appTextFormFieldText
                          //       .copyWith(color: AppColors.orange),
                          // ),
                        ),
                      ),
                      SizedBox(width: 5.w),
                      Expanded(
                        child: AppTextFormField(
                          label: 'سعر المستهلك',
                          controller: priceController,
                          keyboardType: TextInputType.number,
                          // counter: Text(
                          //   'العدد المتبقي ${material.value.quantity.toInt()}',
                          //   style: AppTextStyles.appTextFormFieldText
                          //       .copyWith(color: Colors.white),
                          // ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5.h),
                  Builder(builder: (context) {
                    return AppButton(
                      onTap: () async {
                        if (Form.of(context).validate()) {
                          Form.of(context).save();
                          items.removeAt(index);
                          items.insert(
                              index,
                              item.copyWith(
                                quantity:
                                    double.tryParse(quantityController.text),
                                price: double.tryParse(priceController.text),
                              ));
                          Get.back();
                        }
                      },
                      text: 'تم',
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
        isScrollControlled: true);
  }

  Future<void> addItem() async {
    if (material.value.isEmpty) {
      Get.snackbar(
        'تحذير',
        'يجب عليك اختيار منتج اولاً',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    items.add(OrderItem(
      materialId: material.value.id,
      materialName: material.value.name,
      price: double.parse(priceController.text),
      quantity: double.parse(quantityController.text),
      orderId: 0, // just for now and later will change it
    ));
    _reset();
  }

  Future<void> create() async {}

  void onScanBarcode(String? barcode) async {
    if (barcode == null) {
      return;
    }

    final database = DatabaseHelper.getDatabase();
    final data = await database
        .query(Material.tableName, where: 'barcode = ?', whereArgs: [barcode]);
    if (data.isEmpty) {
      Get.snackbar(
        'تحذير',
        'لا يوجد منتج يملك الباركود هذا',
        colorText: Colors.white,
        backgroundColor: Colors.red,
      );
      return;
    }
    final Material material;
    if (data.length == 1) {
      material = Material.fromDatabase(data.first);
    } else {
      // this will be called when the barcode is used for more than 1 material
      final materials = data.map((e) => Material.fromDatabase(e)).toList();

      material = await Get.dialog(
        AlertDialog.adaptive(
          title: Text('اختر المنتج'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: materials.length,
              itemBuilder: (context, index) => ListTile(
                title:
                    Text(materials[index].name), // Material name as the title
                subtitle: Text(
                    'السعر: ${materials[index].price.toString()}'), // Material price as the description),),
                onTap: () => Get.back(result: materials[index]),
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );
    }

    final item =
        items.where((element) => element.materialId == material.id).firstOrNull;
    if (item == null) {
      items.add(OrderItem(
          materialId: material.id,
          materialName: material.name,
          price: material.price,
          quantity: 1,
          orderId: 0));
    } else {
      final index =
          items.indexWhere((element) => element.materialId == material.id);
      items.removeAt(index);
      items.insert(index, item.increaseQuantity());
    }
    toggleAddedNewItem();
  }

  void toggleAddedNewItem() async {
    addedNewItem.value = true;
    await Future.delayed(Duration(milliseconds: 500));
    addedNewItem.value = false;
  }

  // Constants for repeated values
  static const _bottomSheetBorderRadius = BorderRadius.only(
    topLeft: Radius.circular(15),
    topRight: Radius.circular(15),
  );
  static const _bottomSheetBoxShadow = BoxShadow(
    color: AppColors.primary,
    offset: Offset(0, -10),
  );
  static const _bottomSheetPadding = EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 10,
  );
}
