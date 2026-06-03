import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:daily_water_tracker/common/widgets/app_snackbar.dart';
import 'package:daily_water_tracker/features/debug/cubit/debug_cubit.dart';
import 'package:daily_water_tracker/features/debug/cubit/debug_state.dart';

class FcmTokenWidget extends StatelessWidget {
  const FcmTokenWidget({super.key});

  String _maskToken(String token) {
    if (token.isEmpty) return LocaleKeys.debug_fcm_no_token.tr();
    if (token.length <= 16) return token;
    return '${token.substring(0, 8)}...${token.substring(token.length - 8)}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DebugCubit, DebugState>(
      buildWhen: (p, n) =>
          p.loadingToken != n.loadingToken || p.token != n.token,
      builder: (context, state) {
        final token = (state.token ?? '').trim();
        final maskedToken = _maskToken(token);

        if (state.loadingToken) {
          return const Padding(
            padding: EdgeInsets.all(24.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: CircleAvatar(
            backgroundColor: Colors.blueAccent.withValues(alpha: 0.1),
            child: const Icon(Icons.key, color: Colors.blueAccent),
          ),
          title: Text(
            LocaleKeys.debug_fcm_title.tr(),
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            maskedToken,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Refresh Token',
                icon: const Icon(Icons.refresh, color: Colors.grey),
                onPressed: () => context.read<DebugCubit>().load(),
              ),
              IconButton(
                tooltip: 'Copy Token',
                icon: const Icon(Icons.copy_rounded, color: Colors.blueAccent),
                onPressed: token.isEmpty
                    ? null
                    : () async {
                        await Clipboard.setData(ClipboardData(text: token));
                        if (context.mounted) {
                          AppSnackBar.showInfo(
                            context,
                            title: LocaleKeys.debug_fcm_copied_title.tr(),
                            message: LocaleKeys.debug_fcm_copied_message.tr(),
                          );
                        }
                      },
              ),
            ],
          ),
        );
      },
    );
  }
}
