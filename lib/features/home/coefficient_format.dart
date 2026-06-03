String formatCoefficientUi(double c) {
  final rounded = (c * 100).round() / 100;
  final s = rounded.toStringAsFixed(2);
  if (s.endsWith('00')) return rounded.toStringAsFixed(1);
  if (s.endsWith('0')) return s.substring(0, s.length - 1);
  return s;
}
