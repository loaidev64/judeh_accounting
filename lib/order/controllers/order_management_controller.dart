import 'package:flutter/material.dart' hide Material;
import 'package:flutter/material.dart' as m show Material;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:judeh_accounting/customer/models/customer.dart';
import 'package:judeh_accounting/customer/models/debt.dart';
import 'package:judeh_accounting/customer/widgets/customer_search.dart';
import 'package:judeh_accounting/order/models/order.dart';
import 'package:judeh_accounting/order/models/order_item.dart';
import 'package:judeh_accounting/shared/extensions/double.dart';
import 'package:judeh_accounting/shared/extensions/order_item_list.dart';
import 'package:judeh_accounting/shared/helpers/database_helper.dart';
import 'package:judeh_accounting/shared/theme/app_colors.dart';
import 'package:just_audio/just_audio.dart';

import '../../company/models/company.dart';
import '../../company/widgets/company_search.dart';
import '../../material/models/material.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/widgets/widgets.dart';

final class OrderManagementController extends GetxController {
  final loading = false.obs;

  final addedNewItem = false.obs;

  Order? order;

  Debt? debt;

  Customer? customer;

  Company? company;

  late OrderType type;

  final items = <OrderItem>[].obs;

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
    final debtData = await DatabaseHelper.getDatabase().query(
      Debt.tableName,
      where: 'order_id = ?',
      whereArgs: [order.id],
    );

    if (debtData.isNotEmpty) {
      debt = Debt.fromDatabase(debtData.first);

      debtController.text = debt!.amount.toPriceString;

      if (!type.canHaveCustomer) return;

      final customerData = await DatabaseHelper.getDatabase().query(
        Customer.tableName,
        where: 'id = ?',
        whereArgs: [debt!.customerId],
      );

      customer = Customer.fromDatabase(customerData.first);

      customerController.text = customer!.name;
    }
  }

  void _loadItem(Order order) async {
    final materialsData = await DatabaseHelper.getDatabase().query(
      Material.tableName,
      columns: [
        'id',
        'name',
        'unit',
      ],
      distinct: true,
      where:
          'id in (${List.generate(order.items.length, (_) => '?').join(',')})',
      whereArgs: order.items.map((e) => e.materialId).toList(),
    );

    items.addAll(order.items.map((item) => item.copyWith(
          materialName: materialsData.firstWhere(
              (element) => element['id'] == item.materialId)['name'] as String,
          materialUnit: Unit.values[materialsData.firstWhere(
              (element) => element['id'] == item.materialId)['unit'] as int],
        )));
  }

  void _loadCompany(Order order) async {
    final companyData = await DatabaseHelper.getDatabase().query(
      Company.tableName,
      where: 'id = ?',
      whereArgs: [order.companyId],
    );

    company = Company.fromDatabase(companyData.first);

    companyController.text = company!.name;
  }

  Future<List<Material>> returnMaterials([String? search]) async {
    final database = DatabaseHelper.getDatabase();
    final List<Map<String, Object?>> data;
    if (search == null) {
      data = await database.query(Material.tableName, limit: 25);
    } else {
      data = await database.query(
        Material.tableName,
        where: 'name LIKE ? OR barcode LIKE ?',
        whereArgs: ['%$search%', '%$search%'],
        limit: 25,
      );
    }

    return data.map(Material.fromDatabase).toList();
  }

  Future<List<Customer>> returnCustomers([String? search]) async {
    final database = DatabaseHelper.getDatabase();
    final List<Map<String, Object?>> data;
    if (search == null) {
      data = await database.query(Customer.tableName, limit: 25);
    } else {
      data = await database.query(
        Customer.tableName,
        where: 'name LIKE ? OR description LIKE ?',
        whereArgs: ['%$search%', '%$search%'],
        limit: 25,
      );
    }

    return data.map(Customer.fromDatabase).toList();
  }

  Future<List<Company>> returnCompanies([String? search]) async {
    final database = DatabaseHelper.getDatabase();
    final List<Map<String, Object?>> data;
    if (search == null) {
      data = await database.query(Company.tableName, limit: 25);
    } else {
      data = await database.query(
        Company.tableName,
        where: 'name LIKE ? OR description LIKE ?',
        whereArgs: ['%$search%', '%$search%'],
        limit: 25,
      );
    }

    return data.map(Company.fromDatabase).toList();
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
                          label: 'الكمية',
                          isRequired: true,
                          autofocus: true,
                          controller: quantityController,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value != null &&
                                !value.isNumericOnly &&
                                item.materialUnit! == Unit.amount) {
                              return 'يجب ان يكون بلا فاصلة';
                            }

                            return null;
                          },
                          suffix: item.materialUnit != null
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
          orderId: 0));
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
                                    onSaved: (value) => debt.amount =
                                        double.tryParse(value ?? '') ?? 0,
                                    isRequired: true,
                                  ),
                              ],
                            ),
                        false.obs),
                    SizedBox(height: 5.h),
                    Builder(builder: (context) {
                      return AppButton(
                        onTap: () async {
                          if (Form.of(context).validate()) {
                            Form.of(context).save();

                            final database = DatabaseHelper.getDatabase();

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
                              final customerData = await database.query(
                                Customer.tableName,
                                where: 'name = ?',
                                whereArgs: [customerController.text],
                              );
                              if (customerData.isNotEmpty) {
                                final cust =
                                    Customer.fromDatabase(customerData.first);
                                customer = cust;
                                order.customerId = cust.id;
                                debt.customerId = cust.id;
                              } else {
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

                                  // Create the category and get its ID
                                  final cust = await DatabaseHelper.create(
                                    model: newCustomer,
                                    tableName: Customer.tableName,
                                  );

                                  customer = cust;
                                  order.customerId = cust.id;
                                  debt.customerId = cust.id;
                                }
                              }
                            }

                            if (this.order != null) {
                              order = await DatabaseHelper.update(
                                  model: order, tableName: Order.tableName);
                            } else {
                              order = await DatabaseHelper.create(
                                  model: order, tableName: Order.tableName);
                            }

                            if (this.order != null) {
                              await this
                                  .order!
                                  .items
                                  .delete(type); // delete old items
                            }

                            for (final item in items) {
                              await DatabaseHelper.create(
                                  model: item.copyWith(orderId: order.id),
                                  tableName: OrderItem.tableName);

                              if (type == OrderType.sell) {
                                await database.rawUpdate('''
                                  UPDATE ${Material.tableName} SET quantity = quantity - ? WHERE id = ?
                                  ''', [item.quantity, item.materialId]);
                              } else {
                                // it will be sell Refund
                                await database.rawUpdate('''
                                  UPDATE ${Material.tableName} SET quantity = quantity + ? WHERE id = ?
                                  ''', [item.quantity, item.materialId]);
                              }
                            }

                            if (customer != null) {
                              if (this.debt != null) {
                                await DatabaseHelper.update(
                                    model: debt, tableName: Debt.tableName);
                              } else {
                                debt.orderId = order.id;
                                await DatabaseHelper.create(
                                    model: debt, tableName: Debt.tableName);
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

                                        final database =
                                            DatabaseHelper.getDatabase();

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

                                            // Create the category and get its ID
                                            company =
                                                await DatabaseHelper.create(
                                              model: newCompany,
                                              tableName: Company.tableName,
                                            );
                                          }
                                        }

                                        Order order = Order(
                                          type: type,
                                          total: items.total,
                                          items: items,
                                          companyId: company.id,
                                        );
                                        debt.companyId = company.id;

                                        order = await DatabaseHelper.create(
                                            model: order,
                                            tableName: Order.tableName);

                                        for (final item in items) {
                                          await DatabaseHelper.create(
                                              model: item.copyWith(
                                                  orderId: order.id),
                                              tableName: OrderItem.tableName);

                                          if (type == OrderType.buy) {
                                            await database.rawUpdate('''
                                  UPDATE ${Material.tableName} SET quantity = quantity + ? WHERE id = ?
                                  ''', [item.quantity, item.materialId]);
                                          } else {
                                            // it will be buy Refund
                                            await database.rawUpdate('''
                                  UPDATE ${Material.tableName} SET quantity = quantity - ? WHERE id = ?
                                  ''', [item.quantity, item.materialId]);
                                          }
                                        }

                                        if (haveDebt.value) {
                                          debt.orderId = order.id;
                                          await DatabaseHelper.create(
                                              model: debt,
                                              tableName: Debt.tableName);
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
                    'السعر: ${materials[index].price.toPriceString}'), // Material price as the description),),
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
          materialUnit: material.unit,
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
    beepSound();
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
    await DatabaseHelper.delete(
      model: order!,
      tableName: Order.tableName,
    );

    await order!.items.delete(type);

    if (debt != null) {
      await DatabaseHelper.delete(
        model: debt!,
        tableName: Debt.tableName,
      );
    }

    Get.back();
  }

  void addQuickItem() async{
    
  }
}
