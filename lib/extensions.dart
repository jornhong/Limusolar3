extension NumberRounding on num {
  num toPrecision(int precision) {
    return num.parse((this).toStringAsFixed(precision));
  }
}

extension DoubleRounding on double {
  double toPrecision(int precision) {
    return double.parse((this).toStringAsFixed(precision));
  }
}