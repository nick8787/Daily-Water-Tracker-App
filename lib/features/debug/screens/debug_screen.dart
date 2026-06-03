import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:daily_water_tracker/common/widgets/app_screen_title.dart';
import 'package:daily_water_tracker/common/services/app_bootstrapper.dart';
import 'package:daily_water_tracker/features/debug/cubit/debug_cubit.dart';
import 'package:daily_water_tracker/features/locale/widgets/locale_rebuild.dart';
import 'package:daily_water_tracker/data/repositories/messaging_repository.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';

import '../widgets/debug_section_card.dart';
import '../widgets/debug_locale_switcher.dart';
import '../widgets/fcm_token_widget.dart';
import '../widgets/reminders_debug_panel.dart';
import '../widgets/topic_subscription_widget.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          DebugCubit(messaging: context.read<MessagingRepository>())..load(),
      child: LocaleRebuild(
        builder: (context) => const _DebugScreenContent(),
      ),
    );
  }
}

class _DebugScreenContent extends StatelessWidget {
  const _DebugScreenContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppScreenTitle.appBarLocalized(
          localeKey: LocaleKeys.debug_title,
        ),
        elevation: 0,
        centerTitle: true,
        actions: const [DebugLocaleSwitcher()],
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                _SectionHeader(titleKey: LocaleKeys.debug_section_device_id),
                const DebugSectionCard(child: FcmTokenWidget()),
                const SizedBox(height: 24),
                _SectionHeader(titleKey: LocaleKeys.debug_section_subscriptions),
                const DebugSectionCard(child: TopicSubscriptionWidget()),
                if (flutterFlavor.isDev) ...[
                  const SizedBox(height: 24),
                  _SectionHeader(titleKey: LocaleKeys.debug_section_reminders),
                  const DebugSectionCard(child: RemindersDebugPanel()),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.titleKey});

  final String titleKey;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        titleKey.tr(),
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
