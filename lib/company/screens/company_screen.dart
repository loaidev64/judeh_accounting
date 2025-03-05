import 'package:flutter/material.dart';
import 'package:judeh_accounting/shared/widgets/widgets.dart';

class CompanyScreen extends StatelessWidget {
  static const routeName = '/company';

  const CompanyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'company',
      child: SliverToBoxAdapter(
        child: Text('company'),
      ),
    );
  }
}
