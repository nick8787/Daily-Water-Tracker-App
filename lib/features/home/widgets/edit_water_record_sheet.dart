import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:daily_water_tracker/common/di/injector_module.dart';
import 'package:daily_water_tracker/common/services/logger.dart';
import 'package:daily_water_tracker/common/services/analytics_service.dart';
import 'package:daily_water_tracker/common/widgets/app_confirm_dialog.dart';
import 'package:daily_water_tracker/features/home/cubit/home_cubit.dart';
import 'package:daily_water_tracker/features/home/widgets/water_progress_indicator.dart';
import 'package:daily_water_tracker/features/home/widgets/water_sheet_shared.dart';
import 'package:daily_water_tracker/features/theme/app_theme_extensions.dart';
import 'package:daily_water_tracker/features/theme/decorations.dart';
import 'package:daily_water_tracker/firebase/models/drink_type.dart';
import 'package:daily_water_tracker/firebase/models/water_record_model.dart';
import 'package:daily_water_tracker/data/repositories/firestore_repository.dart';

const int _kVolumeStep = 50;
const int _kVolumeMin = 1;
const int _kVolumeMax = 15000;

Future<void> showEditWaterRecordSheet(
  BuildContext context, {
  required WaterRecordModel record,
  HomeCubit? homeCubit,
}) {
  final hc = homeCubit ?? _tryReadHomeCubit(context);
  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    backgroundColor: AppDecorations.transparent,
    barrierColor: AppDecorations.modalBarrier(),
    builder: (ctx) {
      final maxH = MediaQuery.sizeOf(ctx).height * 0.92;
      final sheet = EditWaterRecordSheet(
        record: record,
        homeCubit: hc,
      );
      return Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(ctx).pop(),
            child: const SizedBox.expand(),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxH),
              child: hc != null
                  ? BlocProvider.value(value: hc, child: sheet)
                  : sheet,
            ),
          ),
        ],
      );
    },
  );
}

HomeCubit? _tryReadHomeCubit(BuildContext context) {
  try {
    return context.read<HomeCubit>();
  } catch (e, st) {
    logCaughtWarning('EditWaterRecordSheet: HomeCubit not in tree', e, st);
    return null;
  }
}

class EditWaterRecordSheet extends StatefulWidget {
  const EditWaterRecordSheet({
    super.key,
    required this.record,
    this.homeCubit,
  });

  final WaterRecordModel record;
  final HomeCubit? homeCubit;

  @override
  State<EditWaterRecordSheet> createState() => _EditWaterRecordSheetState();
}

class _EditWaterRecordSheetState extends State<EditWaterRecordSheet> {
  late DrinkType _drink;
  late int _volume;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _drink = widget.record.drinkType;
    _volume = widget.record.volumeMl;
  }

  bool get _dirty =>
      _drink != widget.record.drinkType || _volume != widget.record.volumeMl;

  DateTime get _calendarDay => DateTime(
    widget.record.timestamp.year,
    widget.record.timestamp.month,
    widget.record.timestamp.day,
  );

  Future<void> _save() async {
    if (!_dirty || _busy) return;
    setState(() => _busy = true);
    try {
      final hc = widget.homeCubit;
      if (hc != null) {
        await hc.updateWaterRecord(
          recordKey: widget.record.recordKey,
          volumeMl: _volume,
          drinkType: _drink,
          timestamp: widget.record.timestamp,
          calendarDay: _calendarDay,
        );
      } else {
        await context.read<FirestoreRepository>().updateDayWaterEntry(
              calendarDay: _calendarDay,
              recordKey: widget.record.recordKey,
              volumeMl: _volume,
              drinkType: _drink,
              timestamp: widget.record.timestamp,
            );
        unawaited(
          InjectorModule.locator<AnalyticsService>().logWaterRecordUpdated(
            volumeMl: _volume,
            drinkTypeWire: _drink.wireName,
          ),
        );
      }
      if (mounted) Navigator.of(context).pop();
    } on FirebaseException catch (e, st) {
      logCaughtError('EditWaterRecordSheet._save: FirebaseException', e, st);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? LocaleKeys.home_snackbar_save_failed.tr())),
        );
      }
    } catch (e, st) {
      logCaughtError('EditWaterRecordSheet._save', e, st);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(LocaleKeys.home_snackbar_save_failed.tr())),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _confirmDelete() async {
    final ok = await showAppConfirmDialog(
      context: context,
      title: LocaleKeys.home_dialog_delete_title.tr(),
      message:
          LocaleKeys.home_dialog_delete_message.tr(),
      icon: Icons.delete_outline_rounded,
    );
    if (ok != true || !mounted) return;

    setState(() => _busy = true);
    try {
      final hc = widget.homeCubit;
      if (hc != null) {
        await hc.deleteWaterRecord(
          widget.record.recordKey,
          calendarDay: _calendarDay,
        );
      } else {
        await context.read<FirestoreRepository>().deleteDayWaterEntry(
              calendarDay: _calendarDay,
              recordKey: widget.record.recordKey,
            );
        unawaited(
          InjectorModule.locator<AnalyticsService>().logWaterRecordDeleted(),
        );
      }
      if (mounted) Navigator.of(context).pop();
    } on FirebaseException catch (e, st) {
      logCaughtError('EditWaterRecordSheet._confirmDelete: FirebaseException', e, st);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? LocaleKeys.home_snackbar_delete_failed.tr())),
        );
      }
    } catch (e, st) {
      logCaughtError('EditWaterRecordSheet._confirmDelete', e, st);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(LocaleKeys.home_snackbar_delete_failed.tr())),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _nudgeVolume(int delta) {
    setState(() {
      _volume = (_volume + delta).clamp(_kVolumeMin, _kVolumeMax);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final graphite = colors.progressValueText;
    final muted = colors.progressLabelMuted;

    final theme = Theme.of(context).textTheme;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: Material(
        color: colors.sheetSurface,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const WaterSheetHandle(),
            AbsorbPointer(
              absorbing: _busy,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 22),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      LocaleKeys.home_sheet_edit_title.tr(),
                      textAlign: TextAlign.center,
                      style: theme.titleLarge?.copyWith(
                        color: graphite,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
                      decoration: BoxDecoration(
                        color: context.appColors.waterSheetCardBg,
                        borderRadius: BorderRadius.circular(
                          kWaterSheetCardRadius,
                        ),
                      ),
                      child: Row(
                        children: [
                          for (var i = 0; i < DrinkType.values.length; i++) ...[
                            if (i != 0) const SizedBox(width: 8),
                            Expanded(
                              child: WaterDrinkChoiceChip(
                                type: DrinkType.values[i],
                                selected: DrinkType.values[i] == _drink,
                                onTap: () => setState(
                                  () => _drink = DrinkType.values[i],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: context.appColors.waterSheetCardBg,
                        borderRadius: BorderRadius.circular(
                          kWaterSheetCardRadius,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            height: 3,
                            color: waterSheetHydrationLineColor(_drink),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    WaterSpringStepButton(
                                      icon: Icons.remove_rounded,
                                      enabled: _volume > _kVolumeMin && !_busy,
                                      onTap: () => _nudgeVolume(-_kVolumeStep),
                                    ),
                                    const SizedBox(width: 16),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '$_volume',
                                          style: TextStyle(
                                            fontSize: 52,
                                            height: 1.0,
                                            fontWeight: FontWeight.w200,
                                            letterSpacing: -1.2,
                                            color: graphite,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          LocaleKeys.common_ml.tr(),
                                          style: theme.titleSmall?.copyWith(
                                            color: muted,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.6,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 16),
                                    WaterSpringStepButton(
                                      icon: Icons.add_rounded,
                                      enabled: _volume < _kVolumeMax && !_busy,
                                      onTap: () => _nudgeVolume(_kVolumeStep),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: [50, 100, 250].map((add) {
                                    return WaterCapsuleButton(
                                      label: LocaleKeys.home_sheet_nudge_ml.tr(namedArgs: {'amount': '$add'}),
                                      enabled:
                                          !_busy &&
                                          _volume <= _kVolumeMax - add,
                                      onTap: () => _nudgeVolume(add),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    WaterGradientCtaButton(
                      enabled: _dirty,
                      busy: _busy,
                      onTap: _save,
                      label: LocaleKeys.home_sheet_button_save_changes.tr(),
                    ),
                    const SizedBox(height: 10),
                    _MinimalDeleteRow(
                      enabled: !_busy,
                      onTap: _confirmDelete,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MinimalDeleteRow extends StatelessWidget {
  const _MinimalDeleteRow({
    required this.enabled,
    required this.onTap,
  });

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final muted = WaterProgressIndicator.labelMuted.withValues(alpha: 0.88);
    return Center(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(8),
          splashColor: muted.withValues(alpha: 0.12),
          highlightColor: muted.withValues(alpha: 0.06),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.delete_outline_rounded,
                  size: 19,
                  color: enabled ? muted : muted.withValues(alpha: 0.4),
                ),
                const SizedBox(width: 8),
                Text(
                  LocaleKeys.home_sheet_button_delete_entry.tr(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: enabled ? muted : muted.withValues(alpha: 0.4),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
