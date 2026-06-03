import 'package:daily_water_tracker/firebase/models/drink_type.dart';

const String kDrinkListInfoSvg = 'assets/svgs/info.svg';

String drinkTypeRowSvgAsset(DrinkType type) => switch (type) {
  DrinkType.water => 'assets/svgs/water.svg',
  DrinkType.coffee => 'assets/svgs/coffee.svg',
  DrinkType.greenTea => 'assets/svgs/tea.svg',
  DrinkType.milk => 'assets/svgs/milk.svg',
};
