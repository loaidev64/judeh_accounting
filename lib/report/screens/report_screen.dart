import 'package:flutter/material.dart';
import 'package:judeh_accounting/shared/widgets/widgets.dart';

class ReportScreen extends StatelessWidget {
  static const routeName = '/report';

  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'report',
      child: SliverToBoxAdapter(
        child: Text('report'),
      ),
    );
  }
}
