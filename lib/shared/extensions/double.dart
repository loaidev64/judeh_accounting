extension PriceDouble on double {
  String get toPriceString {
    String s = '';
    final reversedStringList = toInt().toString().split('').reversed.toList();
    for (var i = 0; i < reversedStringList.length; i++) {
      if (i % 3 == 0 && i != 0) {
        s += ',';
      }
      s += reversedStringList[i];
    }

    return s.split('').reversed.join();
  }
}

extension IfIsIntDouble on double {
  bool get isInt => toString().endsWith('.0');

  String get asIntIfItIsAnInt => (isInt ? toInt() : this).toString();
}
