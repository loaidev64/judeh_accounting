import 'package:flutter/material.dart';
import 'package:judeh_accounting/shared/widgets/widgets.dart';

class OrderScreen extends StatelessWidget {
  static const routeName = '/order';

  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'order',
      child: SliverToBoxAdapter(
        child: Text('order'),
      ),
    );
  }
}
