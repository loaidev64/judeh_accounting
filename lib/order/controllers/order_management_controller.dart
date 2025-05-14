import 'package:flutter/material.dart' hide Material;
import 'package:flutter/material.dart' as m show Material;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:judeh_accounting/customer/models/customer.dart';
import 'package:judeh_accounting/customer/models/debt.dart';
import 'package:judeh_accounting/customer/widgets/customer_search.dart';
import 'package:judeh_accounting/order/models/order.dart';
import 'package:judeh_accounting/order/models/order_item.dart';
import 'package:judeh_accounting/pocketbase/constants/pocketbase_collections.dart';
import 'package:judeh_accounting/pocketbase/controllers/pocketbase_controller.dart';
import 'package:judeh_accounting/shared/extensions/double.dart';
import 'package:judeh_accounting/shared/extensions/order_item_list.dart';
import 'package:judeh_accounting/shared/helpers/database_helper.dart';
import 'package:judeh_accounting/shared/logger/app_logger.dart';
import 'package:judeh_accounting/shared/theme/app_colors.dart';
import 'package:just_audio/just_audio.dart';

import '../../company/models/company.dart';
import '../../company/widgets/company_search.dart';
import '../../material/models/material.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/widgets/widgets.dart';

class OrderManagementController extends GetxController {
  final loading = false.obs;

  final addedNewItem = false.obs;

  Order? order;

  Debt? debt;

  Customer? customer;

  Company? company;

  late OrderType type;

  final items = <OrderItem>[].obs;

  final _orderPocketbase = pocketbase().collection(PocketbaseCollections.orders);
  final _materialPocketbase = pocketbase().collection(PocketbaseCollections.materials);
  final _companyPocketbase = pocketbase().collection(PocketbaseCollections.companies);
  final _customersPocketbase = pocketbase().collection(PocketbaseCollections.customers);
  final _debtsPocketbase = pocketbase().collection(PocketbaseCollections.debts);

  final quantityController = TextEditingController();
  final priceController = TextEditingController();
  final materialController = TextEditingController();
  final debtController = TextEditingController();
  final customerController = TextEditingController();
  final companyController = TextEditingController();

  @override
  void onClose() {
    quantityController.dispose();
    priceController.dispose();
    materialController.dispose();
    debtController.dispose();
    customerController.dispose();
    companyController.dispose();

    super.onClose();
  }

  @override
  void onInit() {
    final (OrderType orderType, Order? order) = Get.arguments;
    type = orderType;
    this.order = order;

    if (order != null) {
      _loadItem(order);
      _loadDebtIfExsists(order);
      if (!type.canHaveCustomer) {
        _loadCompany(order);
      }
    }

    super.onInit();
  }

  void _loadDebtIfExsists(Order order) async {
    try{
      var response = await _debtsPocketbase.getFirstListItem('order_id="${order.id}"');
      AppLogger.info('data for debt is: ${response.data}');
      debt = Debt.fromDatabase(response.data);

      debtController.text = debt!.amount.toPriceTextFormField;

      if (!type.canHaveCustomer) return;

      response = await _customersPocketbase.getOne(debt!.customerId!);

      customer = Customer.fromDatabase(response.data);

      customerController.text = customer!.name;

    }catch(e, trace){
      AppLogger.exception(e, trace);
    }
  }

  void _loadItem(Order order) async {
    items.addAll(order.items);
  }

  void _loadCompany(Order order) async {
    final response = await _companyPocketbase.getOne(order.companyId!);

    company = Company.fromDatabase(response.data);

    companyController.text = company!.name;
  }

  Future<List<Material>> returnMaterials([String? search]) async {
    final response = await _materialPocketbase.getList(
      filter: search == null ? null : '(name~"%$search%" || barcode~"%$search%")',
      perPage: 25,
    );
    final data = response.items.map((e) => e.data);

    return data.map(Material.fromDatabase).toList();
  }

  Future<List<Customer>> returnCustomers([String? search]) async {
    final response = await _customersPocketbase.getList(
      filter: search == null ? null : '(name~"%$search%" || description~"%$search%")',
      perPage: 25,
    );
    final data = response.items.map((e) => e.data);

    return data.map(Customer.fromDatabase).toList();
  }

  Future<List<Company>> returnCompanies([String? search]) async {
    final response = await _companyPocketbase.getList(
      filter: search == null ? null : '(name~"%$search%" || description~"%$search%")',
      perPage: 25,
    );
    final data = response.items.map((e) => e.data);

    return data.map(Company.fromDatabase).toList();
  }

  void editItem(int index, {bool withoutQuantity = false}) async {
    final item = items[index];
    if (item.materialId.isEmpty) {
      withoutQuantity = true;
      quantityController.text = item.description;
    } else {
      quantityController.text = item.quantity.asIntIfItIsAnInt;
    }
    priceController.text = item.price.toInt().toString();
    await Get.bottomSheet(
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: _bottomSheetBorderRadius,
            boxShadow: [_bottomSheetBoxShadow],
          ),
          height: 200.h,
          width: double.infinity,
          padding: _bottomSheetPadding,
          child: m.Material(
            child: Form(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AppTextFormField(
                          label: !withoutQuantity ? 'الكمية' : 'الوصف',
                          isRequired: true,
                          autofocus: true,
                          controller: quantityController,
                          keyboardType:
                              !withoutQuantity ? TextInputType.number : null,
                          validator: (value) {
                            if (!withoutQuantity) {
                              if (value != null &&
                                  !value.isNumericOnly &&
                                  item.materialUnit! == Unit.amount) {
                                return 'يجب ان يكون بلا فاصلة';
                              }
                            }

                            return null;
                          },
                          suffix: withoutQuantity
                              ? null
                              : item.materialUnit != null
                                  ? Text(
                                      item.materialUnit!.name,
                                      style: AppTextStyles.appTextFormFieldText
                                          .copyWith(color: AppColors.orange),
                                    )
                                  : null,
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
                                quantity: !withoutQuantity
                                    ? double.tryParse(quantityController.text)
                                    : 1,
                                description: !withoutQuantity
                                    ? null
                                    : quantityController.text,
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

  Future<void> addItem(Material material) async {
    if (material.isEmpty) {
      Get.snackbar(
        'تحذير',
        'يجب عليك اختيار منتج اولاً',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final item =
        items.where((element) => element.materialId == material.id).firstOrNull;
    if (item == null) {
      items.add(OrderItem(
          materialId: material.id,
          materialName: material.name,
          materialUnit: material.unit,
          price: material.price,
          quantity: 1,
          orderId: ''));
    } else {
      final index =
          items.indexWhere((element) => element.materialId == material.id);
      items.removeAt(index);
      items.insert(index, item.increaseQuantity());
    }
    toggleAddedNewItem();

    materialController.clear();

    editItem(items.length - 1);
  }

  Future<void> save() async {
    final debt = this.debt ?? Debt.empty();
    bool successful = false;
    if (this.debt == null) debtController.text = 0.toString();
    if (type.canHaveCustomer) {
      await Get.bottomSheet(
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: _bottomSheetBorderRadius,
              boxShadow: [_bottomSheetBoxShadow],
            ),
            height: 256.h,
            width: double.infinity,
            padding: _bottomSheetPadding,
            child: m.Material(
              child: Form(
                child: Column(
                  children: [
                    ObxValue(
                        (haveCustomer) => Column(
                              children: [
                                CustomerSearch(
                                  controller: customerController,
                                  onChanged: (value) => haveCustomer.value =
                                      value.trim().isNotEmpty,
                                  onSearch: returnCustomers,
                                  onSelected: ([cust]) {
                                    haveCustomer.value = cust != null;
                                    customer = cust;
                                  },
                                ),
                                SizedBox(height: 5.h),
                                if (haveCustomer.value)
                                  AppTextFormField(
                                    controller: debtController,
                                    label: 'مقبوض',
                                    keyboardType: TextInputType.number,
                                    isPrice: true,
                                    onSaved: (value) => debt.amount =
                                        double.tryParse(value ?? '') ?? 0,
                                    isRequired: true,
                                    suffix: Text(
                                      'المجموع النهائي: ${items.total.toPriceString}',
                                      style: AppTextStyles.appTextFormFieldText
                                          .copyWith(color: AppColors.orange),
                                    ),
                                  ),
                              ],
                            ),
                        (this.debt != null).obs),
                    SizedBox(height: 5.h),
                    Builder(builder: (context) {
                      return AppButton(
                        onTap: () async {
                          if (Form.of(context).validate()) {
                            Form.of(context).save();

                            Order order = this.order?.copyWith(
                                      total: items.total,
                                      items: items,
                                    ) ??
                                Order(
                                    type: type,
                                    total: items.total,
                                    items: items);
                            if (customer != null) {
                              order.customerId = customer!.id;
                              debt.customerId = customer!.id;
                            } else if (customerController.text.isNotEmpty) {
                              try{
                                final response = await _customersPocketbase.getFirstListItem('name="${customerController.text}"');
                                  final cust =
                                  Customer.fromDatabase(response.data);
                                  customer = cust;
                                  order.customerId = cust.id;
                                  debt.customerId = cust.id;
                              }catch(e, trace){
                               AppLogger.exception(e, trace);
                               final bool result = await Get.dialog(
                                 AlertDialog.adaptive(
                                   title: Text(
                                     'تحذير',
                                     style: TextStyle(
                                       color: AppColors.orange,
                                       fontSize: 24.sp,
                                       fontFamily: appFontFamily,
                                     ),
                                   ),
                                   content: Text(
                                     'لا يوجد لديك هذا الزبون "${customerController.text}"، هل تريد إضافته إلى الزبائن؟',
                                     style:
                                     TextStyle(fontFamily: appFontFamily),
                                   ),
                                   actions: [
                                     TextButton(
                                       onPressed: () =>
                                           Get.back(result: false),
                                       child: Text('إلغاء'),
                                     ),
                                     TextButton(
                                       onPressed: () => Get.back(result: true),
                                       child: Text('موافق'),
                                     ),
                                   ],
                                 ),
                               );

                               if (result) {
                                 final newCustomer = Customer(
                                   name: customerController.text,
                                 );
                                 final response = await _customersPocketbase.create(body: newCustomer.toDatabase);

                                 // Create the category and get its ID
                                 final cust = Customer.fromDatabase(response.data);

                                 customer = cust;
                                 order.customerId = cust.id;
                                 debt.customerId = cust.id;
                               }
                              }
                            }

                            if (this.order != null) {
                              final response = await _orderPocketbase.update(order.id, body: order.toDatabase);
                              order = Order.fromDatabase(response.data);
                            } else {
                              final response = await _orderPocketbase.create(body: order.toDatabase);
                              order = Order.fromDatabase(response.data);
                            }

                            if (this.order != null) {
                              await this
                                  .order!
                                  .items
                                  .delete(type); // delete old items
                            }
                            final orderItemBatch = pocketbase().createBatch();
                            for (final item in items) {
                              orderItemBatch.collection(PocketbaseCollections.orderItems).create(body: item.copyWith(orderId: order.id).toDatabase);
                              // await DatabaseHelper.create(
                              //     model: item.copyWith(orderId: order.id),
                              //     tableName: OrderItem.tableName);
                              //
                              // if (type == OrderType.sell) {
                              //   await database.rawUpdate('''
                              //     UPDATE ${Material.tableName} SET quantity = quantity - ? WHERE id = ?
                              //     ''', [item.quantity, item.materialId]);
                              // } else {
                              //   // it will be sell Refund
                              //   await database.rawUpdate('''
                              //     UPDATE ${Material.tableName} SET quantity = quantity + ? WHERE id = ?
                              //     ''', [item.quantity, item.materialId]);
                              // }
                            }
                            await orderItemBatch.send();

                            if (customer != null) {
                              if (this.debt != null) {
                                await _debtsPocketbase.update(debt.id, body: debt.toDatabase);
                              } else {
                                debt.orderId = order.id;
                                await _debtsPocketbase.create(body: debt.toDatabase);
                              }
                            }
                            successful = true;
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
    } else {
      Company company = this.company ?? Company.empty();
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
                    ObxValue(
                        (haveDebt) => Column(
                              children: [
                                CompanySearch(
                                  controller: companyController,
                                  onSearch:
                                      returnCompanies, // Changed to use new method
                                  onSelected: ([comp]) {
                                    if (comp != null) {
                                      company = comp;
                                    }
                                  },
                                ),
                                SizedBox(height: 5.h),
                                TextButton(
                                  onPressed: () =>
                                      haveDebt.value = !haveDebt.value,
                                  child: Text('لديه آجل؟'),
                                ),
                                SizedBox(height: 5.h),
                                if (haveDebt.value)
                                  AppTextFormField(
                                    label: 'آجل',
                                    keyboardType: TextInputType.number,
                                    onSaved: (value) => debt.amount =
                                        double.tryParse(value ?? '') ?? 0,
                                    isRequired: true,
                                  ),
                                SizedBox(height: 5.h),
                                Builder(builder: (context) {
                                  return AppButton(
                                    onTap: () async {
                                      if (Form.of(context).validate()) {
                                        Form.of(context).save();

                                        if (company.isEmpty &&
                                            companyController.text.isNotEmpty) {
                                          final bool result = await Get.dialog(
                                            AlertDialog.adaptive(
                                              title: Text(
                                                'تحذير',
                                                style: TextStyle(
                                                  color: AppColors.orange,
                                                  fontSize: 24.sp,
                                                  fontFamily: appFontFamily,
                                                ),
                                              ),
                                              content: Text(
                                                'لا يوجد لديك هذه الشركة "${companyController.text}"، هل تريد إضافته إلى الشركات؟',
                                                style: TextStyle(
                                                    fontFamily: appFontFamily),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Get.back(result: false),
                                                  child: Text('إلغاء'),
                                                ),
                                                TextButton(
                                                  onPressed: () =>
                                                      Get.back(result: true),
                                                  child: Text('موافق'),
                                                ),
                                              ],
                                            ),
                                          );

                                          if (result) {
                                            final newCompany = Company(
                                              name: companyController.text,
                                            );

                                            final response = await _companyPocketbase.create(body: newCompany.toDatabase);

                                            // Create the category and get its ID
                                            company =
                                                Company.fromDatabase(response.data);
                                          }
                                        }

                                        Order order = Order(
                                          type: type,
                                          total: items.total,
                                          items: items,
                                          companyId: company.id,
                                        );
                                        debt.companyId = company.id;

                                        final response = await _orderPocketbase.create(body: order.toDatabase);
                                        order = Order.fromDatabase(response.data);

                                        final batch = pocketbase().createBatch();

                                        for (final item in items) {
                                          batch.collection(PocketbaseCollections.orderItems).create(body: item.copyWith(orderId: order.id).toDatabase);

                                  //         if (type == OrderType.buy) {
                                  //           await database.rawUpdate('''
                                  // UPDATE ${Material.tableName} SET quantity = quantity + ? WHERE id = ?
                                  // ''', [item.quantity, item.materialId]);
                                  //         } else {
                                  //           // it will be buy Refund
                                  //           await database.rawUpdate('''
                                  // UPDATE ${Material.tableName} SET quantity = quantity - ? WHERE id = ?
                                  // ''', [item.quantity, item.materialId]);
                                  //         }
                                        }
                                        await batch.send();

                                        if (haveDebt.value) {
                                          debt.orderId = order.id;
                                          _debtsPocketbase.create(body: debt.toDatabase);
                                        }

                                        successful = true;
                                        Get.back();
                                      }
                                    },
                                    text: 'تم',
                                  );
                                }),
                              ],
                            ),
                        false.obs),
                  ],
                ),
              ),
            ),
          ),
          isScrollControlled: true);
    }
    if (successful) Get.back();
  }

  void onScanBarcode(String? barcode) async {
    if (barcode == null) {
      return;
    }

    try{
      final response =
          await _materialPocketbase.getList(filter: 'barcode="$barcode"', perPage: 100,);
      final Material material;
      if (response.items.length == 1) {
        material = Material.fromDatabase(response.items.first.data);
      } else {
        final data = response.items.map((e) => e.data);
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
                  title: Text(materials[index].name),
                  // Material name as the title
                  subtitle:
                      Text('السعر: ${materials[index].price.toPriceString}'),
                  // Material price as the description),),
                  onTap: () => Get.back(result: materials[index]),
                ),
              ),
            ),
          ),
          barrierDismissible: false,
        );
      }

      beepSound();
      final item = items
          .where((element) => element.materialId == material.id)
          .firstOrNull;
      if (item == null) {
        items.add(OrderItem(
            materialId: material.id,
            materialName: material.name,
            materialUnit: material.unit,
            price: material.price,
            quantity: 1,
            orderId: ''));
      } else {
        final index =
            items.indexWhere((element) => element.materialId == material.id);
        items.removeAt(index);
        items.insert(index, item.increaseQuantity());
      }
      toggleAddedNewItem();
    }catch(e, trace){
      Get.snackbar(
        'تحذير',
        'لا يوجد منتج يملك الباركود هذا',
        colorText: Colors.white,
        backgroundColor: Colors.red,
      );
      AppLogger.exception(e, trace);
      AppLogger.exception('the scanned barcode is $barcode and didn\'t find it');
      return;
    }
  }

  void removeItem(int index) => items.removeAt(index);

  void toggleAddedNewItem() async {
    addedNewItem.value = true;
    await Future.delayed(Duration(milliseconds: 500));
    addedNewItem.value = false;
  }

  void beepSound() async {
    final player = AudioPlayer();
    await player.setAsset('assets/audio/barcode-scanner-beep.mp3');
    await player.play();
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

  Future<void> delete() async {
    await _orderPocketbase.delete(order!.id);

    if (debt != null) {
      await DatabaseHelper.delete(
        model: debt!,
        tableName: Debt.tableName,
      );
    }

    Get.back();
  }

  void addQuickItem() async {
    if (materialController.text.isNotEmpty) {
      if (items
          .where((item) => item.description == materialController.text)
          .isEmpty) {
        items.add(OrderItem(
          description: materialController.text,
          materialId: '',
          orderId: '',
          quantity: 1,
          price: 0,
        ));
      } else {
        final index = items
            .indexWhere((item) => item.description == materialController.text);
        items.insert(index, items[index].increaseQuantity());
        items.removeAt(index);
      }

      materialController.clear();

      editItem(items.length - 1);
    }
  }
}
