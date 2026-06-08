import 'package:daily_water_tracker/features/debug/cubit/debug_cubit.dart';
import 'package:daily_water_tracker/features/debug/cubit/debug_state.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TopicSubscriptionWidget extends StatelessWidget {
  const TopicSubscriptionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DebugCubit, DebugState>(
      buildWhen: (p, n) =>
          p.topicBusy != n.topicBusy ||
          p.reminderSubscribed != n.reminderSubscribed,
      builder: (context, state) {
        final isSubscribed = state.reminderSubscribed;

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: CircleAvatar(
            backgroundColor: isSubscribed
                ? Colors.green.withValues(alpha: 0.1)
                : Colors.grey.withValues(alpha: 0.1),
            child: Icon(
              isSubscribed
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_off_rounded,
              color: isSubscribed ? Colors.green : Colors.grey,
            ),
          ),
          title: Text(
            LocaleKeys.debug_topic_title.tr(),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            isSubscribed ? LocaleKeys.debug_topic_subscribed.tr() : LocaleKeys.debug_topic_not_subscribed.tr(),
            style: TextStyle(
              color: isSubscribed ? Colors.green : Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: state.topicBusy
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : CupertinoSwitch(
                  value: isSubscribed,
                  activeTrackColor: Colors.blueAccent,
                  onChanged: (value) {
                    if (value) {
                      context.read<DebugCubit>().subscribeReminder();
                    } else {
                      context.read<DebugCubit>().unsubscribeReminder();
                    }
                  },
                ),
        );
      },
    );
  }
}
