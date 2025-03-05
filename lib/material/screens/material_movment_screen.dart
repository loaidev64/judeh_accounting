import 'package:flutter/material.dart';
import 'package:judeh_accounting/shared/widgets/widgets.dart';

class MaterialMovmentScreen extends StatelessWidget {
  static const routeName = '/materialMovment';

  const MaterialMovmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'materialMovment',
      child: SliverToBoxAdapter(
        child: Text('materialMovment'),
      ),
    );
  }
}
