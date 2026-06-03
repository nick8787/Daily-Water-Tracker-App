import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:daily_water_tracker/common/widgets/app_snackbar.dart';
import 'package:daily_water_tracker/common/router.dart';
import 'package:daily_water_tracker/features/deep_links/cubit/deep_link_cubit.dart';
import 'package:daily_water_tracker/features/deep_links/cubit/deep_link_state.dart';
import 'package:daily_water_tracker/features/deep_links/models/water_link_purpose.dart';

class DeepLinkListeners extends StatelessWidget {
  const DeepLinkListeners({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<DeepLinkCubit, DeepLinkState>(
      listenWhen: (prev, next) => prev.purpose != next.purpose,
      listener: (context, state) {
        final purpose = state.purpose;
        if (purpose is WaterLinkPurposeShareProgress) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showWithRetry(context, ml: purpose.ml);
          });
        }
      },
      child: child,
    );
  }

  static Future<void> _showWithRetry(
    BuildContext context, {
    required int ml,
  }) async {
    const attempts = 6;
    const baseDelay = Duration(milliseconds: 120);

    for (var i = 0; i < attempts; i++) {
      await Future<void>.delayed(baseDelay * (i + 1));
      if (!context.mounted) return;

      final overlayContext = rootNavigatorKey.currentContext ?? context;
      final shown = AppSnackBar.showInfo(
        overlayContext,
        title: LocaleKeys.deep_link_shared_title.tr(),
        message: LocaleKeys.deep_link_shared_message.tr(namedArgs: {'ml': '$ml'}),
      );

      if (shown) {
        context.read<DeepLinkCubit>().resetPurpose();
        return;
      }
    }
  }
}
