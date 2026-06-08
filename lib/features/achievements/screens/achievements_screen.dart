import 'package:daily_water_tracker/common/widgets/app_screen_title.dart';
import 'package:daily_water_tracker/features/achievements/cubit/achievements_cubit.dart';
import 'package:daily_water_tracker/features/achievements/cubit/achievements_state.dart';
import 'package:daily_water_tracker/features/achievements/models/badge_model.dart';
import 'package:daily_water_tracker/features/achievements/models/rank_condition.dart';
import 'package:daily_water_tracker/features/achievements/models/rank_condition_type.dart';
import 'package:daily_water_tracker/features/theme/theme_info.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  static const _carouselHeight = 248.0;
  static const _rankAvatarSize = 136.0;

  late final PageController _pageController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.62);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          LocaleKeys.account_menu_achievements.tr(),
          style: AppScreenTitle.headerStyle(context),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<AchievementsCubit, AchievementsState>(
          builder: (context, state) {
            return switch (state) {
              AchievementsInitial() || AchievementsLoading() => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: scheme.primary),
                    const SizedBox(height: 16),
                    Text(
                      LocaleKeys.achievements_loading.tr(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),
              AchievementsFailure(:final messageKey) => _ErrorBody(
                message: messageKey.tr(),
                onRetry: () =>
                    context.read<AchievementsCubit>().loadAchievements(),
              ),
              AchievementsLoaded(:final badges) => _LoadedBody(
                badges: badges,
                pageController: _pageController,
                selectedIndex: _selectedIndex,
                onPageChanged: (index) => setState(() => _selectedIndex = index),
                highestUnlocked: _highestUnlockedRank(badges),
                carouselHeight: _carouselHeight,
                rankAvatarSize: _rankAvatarSize,
              ),
            };
          },
        ),
      ),
    );
  }

  BadgeModel? _highestUnlockedRank(List<BadgeModel> badges) {
    BadgeModel? highest;
    for (final badge in badges) {
      if (!badge.isUnlocked) continue;
      if (highest == null || badge.tierOrder > highest.tierOrder) {
        highest = badge;
      }
    }
    return highest;
  }
}

class _LoadedBody extends StatelessWidget {
  const _LoadedBody({
    required this.badges,
    required this.pageController,
    required this.selectedIndex,
    required this.onPageChanged,
    required this.highestUnlocked,
    required this.carouselHeight,
    required this.rankAvatarSize,
  });

  final List<BadgeModel> badges;
  final PageController pageController;
  final int selectedIndex;
  final ValueChanged<int> onPageChanged;
  final BadgeModel? highestUnlocked;
  final double carouselHeight;
  final double rankAvatarSize;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final selected = badges[selectedIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CurrentRankBanner(highestUnlocked: highestUnlocked),
          const SizedBox(height: 28),
          SizedBox(
            height: carouselHeight,
            child: PageView.builder(
              controller: pageController,
              itemCount: badges.length,
              onPageChanged: onPageChanged,
              itemBuilder: (context, index) {
                return AnimatedBuilder(
                  animation: pageController,
                  builder: (context, child) {
                    final page = pageController.hasClients
                        ? (pageController.page ?? selectedIndex.toDouble())
                        : selectedIndex.toDouble();
                    final delta = (page - index).abs().clamp(0.0, 1.0);
                    final scale = _lerp(0.7, 1.0, 1 - delta);
                    final opacity = _lerp(0.5, 1.0, 1 - delta);

                    return Opacity(
                      opacity: opacity,
                      child: Transform.scale(scale: scale, child: child),
                    );
                  },
                  child: _RankCarouselItem(
                    badge: badges[index],
                    avatarSize: rankAvatarSize,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          _CarouselPageDots(
            count: badges.length,
            selectedIndex: selectedIndex,
          ),
          const SizedBox(height: 24),
          Text(
            selected.nameKey.tr(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.3,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            selected.isUnlocked
                ? LocaleKeys.achievements_status_unlocked.tr()
                : LocaleKeys.achievements_status_locked_hint.tr(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: selected.isUnlocked
                  ? scheme.primary
                  : scheme.onSurface.withValues(alpha: 0.5),
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 24),
          _ConditionCardsRow(conditions: selected.conditions),
        ],
      ),
    );
  }

  static double _lerp(double begin, double end, double t) {
    return begin + (end - begin) * t.clamp(0.0, 1.0);
  }
}

class _CurrentRankBanner extends StatelessWidget {
  const _CurrentRankBanner({required this.highestUnlocked});

  final BadgeModel? highestUnlocked;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final rankTitle = highestUnlocked?.nameKey.tr() ??
        LocaleKeys.achievements_banner_no_rank_title.tr();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primaryContainer.withValues(alpha: 0.72),
            Color.lerp(
              scheme.primaryContainer,
              scheme.surface,
              0.55,
            )!,
          ],
        ),
        border: Border.all(
          color: scheme.primary.withValues(alpha: 0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            LocaleKeys.achievements_banner_achieved_rank_label.tr(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.55),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            rankTitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _RankCarouselItem extends StatelessWidget {
  const _RankCarouselItem({
    required this.badge,
    required this.avatarSize,
  });

  final BadgeModel badge;
  final double avatarSize;

  static const _badgeSize = 34.0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final locked = !badge.isUnlocked;

    Widget icon = Icon(
      badge.placeholderIcon,
      size: avatarSize * 0.38,
      color: locked
          ? scheme.onSurface.withValues(alpha: 0.45)
          : scheme.primary,
    );

    if (locked) {
      icon = ColorFiltered(
        colorFilter: const ColorFilter.matrix(<double>[
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0, 0, 0, 1, 0,
        ]),
        child: icon,
      );
    }

    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            width: avatarSize,
            height: avatarSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scheme.surface,
              border: Border.all(
                color: locked
                    ? scheme.outline.withValues(alpha: 0.45)
                    : scheme.primary,
                width: locked ? 2.5 : 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: scheme.shadow.withValues(alpha: locked ? 0.06 : 0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(child: icon),
          ),
          Positioned(
            right: 2,
            bottom: 2,
            child: _RankStatusBadge(locked: locked),
          ),
        ],
      ),
    );
  }
}

class _RankStatusBadge extends StatelessWidget {
  const _RankStatusBadge({required this.locked});

  final bool locked;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: _RankCarouselItem._badgeSize,
      height: _RankCarouselItem._badgeSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: scheme.surface,
        border: Border.all(
          color: scheme.outline.withValues(alpha: 0.22),
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        locked ? Icons.lock_outline : Icons.check,
        size: 17,
        color: locked
            ? scheme.onSurface.withValues(alpha: 0.45)
            : successGreen,
      ),
    );
  }
}

class _CarouselPageDots extends StatelessWidget {
  const _CarouselPageDots({
    required this.count,
    required this.selectedIndex,
  });

  final int count;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final active = index == selectedIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 18 : 7,
          height: 7,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: active
                ? scheme.primary
                : scheme.onSurface.withValues(alpha: 0.18),
          ),
        );
      }),
    );
  }
}

class _ConditionCardsRow extends StatelessWidget {
  const _ConditionCardsRow({required this.conditions});

  final List<RankCondition> conditions;

  @override
  Widget build(BuildContext context) {
    if (conditions.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final multi = conditions.length > 1;
        final cardWidth = multi
            ? (constraints.maxWidth - 12) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: [
            for (final condition in conditions)
              SizedBox(
                width: cardWidth,
                child: _ConditionCard(condition: condition),
              ),
          ],
        );
      },
    );
  }
}

class _ConditionCard extends StatelessWidget {
  const _ConditionCard({required this.condition});

  final RankCondition condition;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: scheme.outline.withValues(alpha: 0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _progressText(condition),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            condition.labelKey.tr(),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.55),
              fontWeight: FontWeight.w500,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: condition.progressFraction,
              minHeight: 6,
              backgroundColor: scheme.surfaceContainerHighest.withValues(
                alpha: 0.9,
              ),
              color: condition.isComplete
                  ? scheme.primary
                  : scheme.primary.withValues(alpha: 0.72),
            ),
          ),
        ],
      ),
    );
  }

  String _progressText(RankCondition condition) {
    return switch (condition.type) {
      RankConditionType.logEntries ||
      RankConditionType.goalDays =>
        '${condition.currentValue.toInt()} / ${condition.targetValue.toInt()}',
      RankConditionType.totalVolumeMl => _volumeProgressText(condition),
    };
  }

  String _volumeProgressText(RankCondition condition) {
    final currentL = condition.currentValue / 1000;
    final targetL = condition.targetValue / 1000;
    final currentStr = currentL >= 10
        ? currentL.toStringAsFixed(0)
        : currentL.toStringAsFixed(1);
    final targetStr = targetL >= 10
        ? targetL.toStringAsFixed(0)
        : targetL.toStringAsFixed(1);
    return '$currentStr / $targetStr L';
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: Text(LocaleKeys.common_retry.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
