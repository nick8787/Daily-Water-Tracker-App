import 'package:hive_flutter/hive_flutter.dart';

class ThemeBox {
  static const String name = 'theme';
  static const String themeModeKey = 'themeMode';

  Future<void> initialize() async {
    await Hive.initFlutter();
    await Hive.openBox<dynamic>(name);
  }
}
