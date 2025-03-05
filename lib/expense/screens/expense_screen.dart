import 'package:flutter/material.dart';
import 'package:judeh_accounting/shared/widgets/widgets.dart';

class ExpenseScreen extends StatelessWidget {
  static const routeName = '/expense';

  const ExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'المصاريف',
      child: SliverToBoxAdapter(
        child: Text('data'),
      ),
    );
  }
}
