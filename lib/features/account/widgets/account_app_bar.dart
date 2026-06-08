import 'package:daily_water_tracker/common/router.dart';
import 'package:daily_water_tracker/common/services/app_bootstrapper.dart';
import 'package:daily_water_tracker/common/widgets/app_screen_title.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AccountAppBar extends StatelessWidget {
  const AccountAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 2, 20, 10),
      child: SizedBox(
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AppScreenTitle.localized(
              localeKey: LocaleKeys.account_title,
              centered: true,
            ),
            Positioned(
              right: 0,
              child: flutterFlavor.isDev
                  ? IconButton(
                      tooltip: LocaleKeys.account_tooltip_debug.tr(),
                      onPressed: () => context.push(debugRoute),
                      icon: const Icon(Icons.bug_report_outlined),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
