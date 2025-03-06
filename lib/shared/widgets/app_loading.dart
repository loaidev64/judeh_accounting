import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AppLoading extends StatelessWidget {
  const AppLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator.adaptive(),
    );
  }
}
