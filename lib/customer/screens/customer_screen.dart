import 'package:flutter/material.dart';
import 'package:judeh_accounting/shared/widgets/widgets.dart';

class DebtScreen extends StatelessWidget {
  static const routeName = '/debt';

  const DebtScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'debt',
      child: SliverToBoxAdapter(
        child: Text('debt'),
      ),
    );
  }
}
