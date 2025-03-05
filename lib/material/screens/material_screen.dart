import 'package:flutter/material.dart';
import 'package:judeh_accounting/shared/widgets/widgets.dart';

class MaterialScreen extends StatelessWidget {
  static const routeName = '/material';

  const MaterialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'material',
      child: SliverToBoxAdapter(
        child: Text('material'),
      ),
    );
  }
}
