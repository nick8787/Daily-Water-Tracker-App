import 'package:hive_flutter/hive_flutter.dart';

class VibrationBox {
  static const String name = 'vibration';
  static const String enabledKey = 'enabled';

  Future<void> initialize() async {
    await Hive.openBox<dynamic>(name);
  }
}
