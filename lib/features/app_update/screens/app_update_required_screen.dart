import 'dart:io';

import 'package:daily_water_tracker/features/app_update/cubit/app_version_cubit.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppUpdateRequiredScreen extends StatelessWidget {
  const AppUpdateRequiredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(LocaleKeys.app_update_title.tr()),
            const SizedBox(height: 5),
            Text(LocaleKeys.app_update_message.tr()),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.read<AppVersionCubit>().updateApp(),
              child: Text(Platform.isAndroid ? LocaleKeys.app_update_button_android.tr() : LocaleKeys.app_update_button_ios.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
