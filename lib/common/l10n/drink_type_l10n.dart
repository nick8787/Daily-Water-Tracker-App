import 'package:easy_localization/easy_localization.dart';
import 'package:daily_water_tracker/firebase/models/drink_type.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';

extension DrinkTypeL10n on DrinkType {
  String get localizedLabel {
    switch (this) {
      case DrinkType.water:
        return LocaleKeys.drink_type_water.tr();
      case DrinkType.coffee:
        return LocaleKeys.drink_type_coffee.tr();
      case DrinkType.greenTea:
        return LocaleKeys.drink_type_green_tea.tr();
      case DrinkType.milk:
        return LocaleKeys.drink_type_milk.tr();
    }
  }
}
