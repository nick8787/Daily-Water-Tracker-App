import 'package:daily_water_tracker/common/constants/hydration_defaults.dart';

List<int> normalizeDrinkPresetsMl(List<int> raw) {
  final list = List<int>.from(raw);
  while (list.length < 3) {
    list.add(kDefaultDrinkPresetsMl[list.length]);
  }
  if (list.length > 3) {
    list.removeRange(3, list.length);
  }
  return List<int>.generate(
    3,
    (i) => list[i] > 0 ? list[i] : kDefaultDrinkPresetsMl[i],
  );
}
