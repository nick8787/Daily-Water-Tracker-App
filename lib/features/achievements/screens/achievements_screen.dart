import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:daily_water_tracker/common/widgets/app_screen_title.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';
import 'package:daily_water_tracker/features/achievements/cubit/achievements_cubit.dart';
import 'package:daily_water_tracker/features/achievements/cubit/achievements_state.dart';
import 'package:daily_water_tracker/features/achievements/widgets/badge_item_widget.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  static const double _gridSpacing = 16;
  static const double _gridAspectRatio = 0.72;

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
          return switch (state) {
            AchievementsLoading() => const _AchievementsLoadingBody(),
            AchievementsFailure(:final messageKey) => _AchievementsFailureBody(
              messageKey: messageKey,
            ),
            AchievementsLoaded(:final badges) => GridView.builder(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: _gridSpacing,
                mainAxisSpacing: _gridSpacing,
                childAspectRatio: _gridAspectRatio,
              ),
              itemCount: badges.length,
              itemBuilder: (context, index) {
                return _StaggeredBadgeEntrance(
                  index: index,
                  child: BadgeItemWidget(badge: badges[index]),
                );
              },
            ),
            _ => const SizedBox.shrink(),
          };
        },
      ),
    );
  }
}

/// Fade + slide-up on first paint; delay scales with grid index.
class _StaggeredBadgeEntrance extends StatefulWidget {
  const _StaggeredBadgeEntrance({
    required this.index,
    required this.child,
  });

  final int index;
  final Widget child;

  static const Duration _itemDelay = Duration(milliseconds: 100);
  static const Duration _animDuration = Duration(milliseconds: 520);
  static const double _slideOffset = 18;

  @override
  State<_StaggeredBadgeEntrance> createState() =>
      _StaggeredBadgeEntranceState();
}

class _StaggeredBadgeEntranceState extends State<_StaggeredBadgeEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _curve;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _StaggeredBadgeEntrance._animDuration,
    );
    _curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    final delay = _StaggeredBadgeEntrance._itemDelay * widget.index;
    Future<void>.delayed(delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curve,
      builder: (context, child) {
        final t = _curve.value;
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(
              0,
              _StaggeredBadgeEntrance._slideOffset * (1 - t),
            ),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

class _AchievementsLoadingBody extends StatelessWidget {
  const _AchievementsLoadingBody();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: scheme.primary,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            LocaleKeys.achievements_loading.tr(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.55),
              fontWeight: FontWeight.w600,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementsFailureBody extends StatelessWidget {
  const _AchievementsFailureBody({required this.messageKey});

  final String messageKey;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scheme.error.withValues(alpha: isDark ? 0.14 : 0.1),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 36,
                color: scheme.error.withValues(alpha: 0.88),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              messageKey.tr(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: scheme.onSurface.withValues(alpha: 0.78),
                height: 1.35,
              ),
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: () =>
                  context.read<AchievementsCubit>().loadAchievements(),
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: Text(LocaleKeys.common_retry.tr()),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
