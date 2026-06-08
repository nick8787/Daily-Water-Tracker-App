import 'package:daily_water_tracker/common/widgets/app_snackbar.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum MainTab { statistics, home, account }

class MainNavState extends Equatable {
  const MainNavState({
    required this.tab,
    this.accountSigningOutMask = false,
  });

  final MainTab tab;
  final bool accountSigningOutMask;

  @override
  List<Object?> get props => [tab, accountSigningOutMask];
}

class MainNavCubit extends Cubit<MainNavState> {
  MainNavCubit({MainTab initialTab = MainTab.home})
    : super(MainNavState(tab: initialTab));

  void select(MainTab tab) {
    emit(MainNavState(tab: tab));
  }

  void setAccountSigningOutMask(bool value) {
    emit(MainNavState(tab: state.tab, accountSigningOutMask: value));
  }

  void showAddComingSoon(BuildContext context) {
    AppSnackBar.showInfo(
      context,
      title: LocaleKeys.common_coming_soon_title.tr(),
      message: LocaleKeys.main_nav_coming_soon_add_drink.tr(),
    );
  }
}
