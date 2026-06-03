import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:daily_water_tracker/common/widgets/app_screen_title.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';
import '../cubit/achievements_cubit.dart';
import '../cubit/achievements_state.dart';
import '../widgets/badge_item_widget.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: AppScreenTitle.appBarLocalized(
          localeKey: LocaleKeys.account_menu_achievements,
        ),
      ),


      body: BlocBuilder<AchievementsCubit, AchievementsState>(
        builder: (context, state) {
          if (state is AchievementsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AchievementsFailure) {
            return Center(child: Text(state.message));
          }

          if (state is AchievementsLoaded) {
            return GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 0.8,
              ),
              itemCount: state.badges.length,
              itemBuilder: (context, index) {
                final badge = state.badges[index];
                return BadgeItemWidget(badge: badge);
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}