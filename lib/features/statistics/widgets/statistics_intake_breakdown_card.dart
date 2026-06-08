import 'package:daily_water_tracker/common/l10n/drink_type_l10n.dart';
import 'package:daily_water_tracker/features/home/widgets/drink_type_svgs.dart';
import 'package:daily_water_tracker/features/home/widgets/water_sheet_shared.dart';
import 'package:daily_water_tracker/features/statistics/models/statistics_presentation.dart';
import 'package:daily_water_tracker/features/statistics/widgets/statistics_summary_metric_card.dart';
import 'package:daily_water_tracker/features/theme/app_theme_extensions.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

const double _kBreakdownIcon = 24;
const double _kBarHeight = 6;
const int _kMaxVisibleRows = 2;
const double _kRowBlockHeight = _kBreakdownIcon + 7 + _kBarHeight;
const double _kRowSpacing = 11;

double get _kRowsViewportHeight =>
    _kMaxVisibleRows * _kRowBlockHeight +
    (_kMaxVisibleRows - 1) * _kRowSpacing;

const double _kScrollHintBand = 26;

enum StatisticsBreakdownLayoutMode {
  /// 0–1 drink types: wrap content, no internal empty space.
  compact,

  /// Exactly 2 drink types: fill expanded slot from parent flex.
  balanced,

  /// 3+ drink types: fixed 2-row viewport + scroll hint band below rows.
  scrollable,
}

class StatisticsIntakeBreakdownCard extends StatelessWidget {
  const StatisticsIntakeBreakdownCard({
    super.key,
    required this.rows,
    required this.layoutMode,
  });

  final List<IntakeBreakdownRowVm> rows;
  final StatisticsBreakdownLayoutMode layoutMode;

  static StatisticsBreakdownLayoutMode layoutModeFor(int rowCount) {
    if (rowCount <= 1) return StatisticsBreakdownLayoutMode.compact;
    if (rowCount == 2) return StatisticsBreakdownLayoutMode.balanced;
    return StatisticsBreakdownLayoutMode.scrollable;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w800,
      letterSpacing: -0.2,
    );
    final captionStyle = theme.textTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.w500,
      fontSize: 11,
      height: 1.25,
      color: theme.colorScheme.onSurface.withValues(alpha: 0.36),
    );
    final nameStyle =
        theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.15,
        ) ??
        const TextStyle(fontWeight: FontWeight.w700, fontSize: 14);
    final pctStyle =
        theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.2,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
        ) ??
        TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 14,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
        );

    final cardSurface = context.appColors.cardSurface;

    final header = [
      Text(LocaleKeys.statistics_breakdown_title.tr(), style: titleStyle),
      const SizedBox(height: 4),
      Text(LocaleKeys.statistics_breakdown_caption.tr(), style: captionStyle),
      const SizedBox(height: 12),
    ];

    final rowsBody = rows.isEmpty
        ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              LocaleKeys.statistics_breakdown_empty.tr(),
              style: theme.textTheme.bodySmall?.copyWith(
                height: 1.4,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.42),
              ),
            ),
          )
        : layoutMode == StatisticsBreakdownLayoutMode.scrollable
        ? _ScrollableBreakdownRows(
            rows: rows,
            nameStyle: nameStyle,
            pctStyle: pctStyle,
            cardSurface: cardSurface,
          )
        : _StaticBreakdownRows(
            rows: rows,
            nameStyle: nameStyle,
            pctStyle: pctStyle,
          );

    final decoration = StatisticsSummaryMetricCard.tileDecoration(context);
    const padding = StatisticsSummaryMetricCard.tilePadding;

    if (layoutMode == StatisticsBreakdownLayoutMode.balanced) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        padding: padding,
        decoration: decoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ...header,
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: rowsBody,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: padding,
      decoration: decoration,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...header,
          rowsBody,
        ],
      ),
    );
  }
}

class _StaticBreakdownRows extends StatelessWidget {
  const _StaticBreakdownRows({
    required this.rows,
    required this.nameStyle,
    required this.pctStyle,
  });

  final List<IntakeBreakdownRowVm> rows;
  final TextStyle nameStyle;
  final TextStyle pctStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0) const SizedBox(height: _kRowSpacing),
          _BreakdownRow(
            row: rows[i],
            nameStyle: nameStyle,
            pctStyle: pctStyle,
          ),
        ],
      ],
    );
  }
}

class _ScrollableBreakdownRows extends StatefulWidget {
  const _ScrollableBreakdownRows({
    required this.rows,
    required this.nameStyle,
    required this.pctStyle,
    required this.cardSurface,
  });

  final List<IntakeBreakdownRowVm> rows;
  final TextStyle nameStyle;
  final TextStyle pctStyle;
  final Color cardSurface;

  @override
  State<_ScrollableBreakdownRows> createState() =>
      _ScrollableBreakdownRowsState();
}

class _ScrollableBreakdownRowsState extends State<_ScrollableBreakdownRows> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollHint = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_syncScrollHint);
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncScrollHint());
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_syncScrollHint)
      ..dispose();
    super.dispose();
  }

  void _syncScrollHint() {
    if (!mounted || !_scrollController.hasClients) return;

    final position = _scrollController.position;
    final atBottom = position.pixels >= position.maxScrollExtent - 2;
    final show = !atBottom;

    if (show != _showScrollHint) {
      setState(() => _showScrollHint = show);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _kRowsViewportHeight + _kScrollHintBand,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: _kRowsViewportHeight,
            child: ListView.separated(
              controller: _scrollController,
              padding: EdgeInsets.zero,
              physics: const BouncingScrollPhysics(),
              itemCount: widget.rows.length,
              separatorBuilder: (_, _) => const SizedBox(height: _kRowSpacing),
              itemBuilder: (context, index) => _BreakdownRow(
                row: widget.rows[index],
                nameStyle: widget.nameStyle,
                pctStyle: widget.pctStyle,
              ),
            ),
          ),
          SizedBox(
            height: _kScrollHintBand,
            child: AnimatedOpacity(
              opacity: _showScrollHint ? 1 : 0,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              child: _BreakdownScrollHint(
                cardSurface: widget.cardSurface,
                visible: _showScrollHint,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BreakdownScrollHint extends StatefulWidget {
  const _BreakdownScrollHint({
    required this.cardSurface,
    required this.visible,
  });

  final Color cardSurface;
  final bool visible;

  @override
  State<_BreakdownScrollHint> createState() => _BreakdownScrollHintState();
}

class _BreakdownScrollHintState extends State<_BreakdownScrollHint>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounceController;
  late final Animation<double> _bounce;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _bounce = Tween<double>(begin: 0, end: 3).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant _BreakdownScrollHint oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.visible != widget.visible) {
      _syncAnimation();
    }
  }

  void _syncAnimation() {
    if (widget.visible) {
      _bounceController.repeat(reverse: true);
    } else {
      _bounceController
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hintColor = theme.colorScheme.onSurface.withValues(alpha: 0.38);
    final hintStyle = theme.textTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.w600,
      fontSize: 10,
      height: 1,
      letterSpacing: 0.1,
      color: hintColor,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0, 0.55, 1],
          colors: [
            widget.cardSurface.withValues(alpha: 0),
            widget.cardSurface.withValues(alpha: 0.65),
            widget.cardSurface,
          ],
        ),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _bounce,
              builder: (context, child) => Transform.translate(
                offset: Offset(0, _bounce.value),
                child: child,
              ),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 15,
                color: hintColor,
              ),
            ),
            const SizedBox(width: 2),
            Text(
              LocaleKeys.statistics_breakdown_scroll_hint.tr(),
              style: hintStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({
    required this.row,
    required this.nameStyle,
    required this.pctStyle,
  });

  final IntakeBreakdownRowVm row;
  final TextStyle nameStyle;
  final TextStyle pctStyle;

  @override
  Widget build(BuildContext context) {
    final lineColor = waterSheetHydrationLineColor(row.drinkType);
    final track = Theme.of(context).colorScheme.surfaceContainerHighest;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            SvgPicture.asset(
              drinkTypeRowSvgAsset(row.drinkType),
              width: _kBreakdownIcon,
              height: _kBreakdownIcon,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                row.drinkType.localizedLabel,
                style: nameStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 10),
            Text('${row.percent}%', style: pctStyle),
          ],
        ),
        const SizedBox(height: 7),
        SizedBox(
          height: _kBarHeight,
          width: double.infinity,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: track,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const SizedBox.expand(),
              ),
              FractionallySizedBox(
                widthFactor: row.share01.clamp(0.0, 1.0),
                alignment: Alignment.centerLeft,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  height: _kBarHeight,
                  decoration: BoxDecoration(
                    color: lineColor,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: lineColor.withValues(alpha: 0.28),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
