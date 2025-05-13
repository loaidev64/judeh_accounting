import 'package:intl/intl.dart';

extension PriceDouble on double {
  String get toPriceString =>  NumberFormat.simpleCurrency(
    name: ' ل.س',
    locale: 'ar',
    decimalDigits: 0,
  ).format(this);

  String get toPriceTextFormField =>  NumberFormat(
    '#,###'
  ).format(this);
}

extension IfIsIntDouble on double {
  bool get isInt => toString().endsWith('.0');

  String get asIntIfItIsAnInt => (isInt ? toInt() : this).toString();
}
