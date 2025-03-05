import 'package:flutter/material.dart';
import 'package:judeh_accounting/shared/widgets/widgets.dart';

class OtherScreen extends StatelessWidget {
  static const routeName = '/other';

  const OtherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'other',
      child: SliverToBoxAdapter(
        child: Text('other'),
      ),
    );
  }
}
