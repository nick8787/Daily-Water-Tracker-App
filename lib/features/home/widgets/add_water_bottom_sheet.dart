import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:daily_water_tracker/common/l10n/drink_type_l10n.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:daily_water_tracker/common/widgets/app_snackbar.dart';
import 'package:daily_water_tracker/features/home/cubit/home_cubit.dart';
import 'package:daily_water_tracker/features/home/widgets/water_progress_indicator.dart';
import 'package:daily_water_tracker/features/home/widgets/water_sheet_shared.dart';
import 'package:daily_water_tracker/features/theme/app_theme_extensions.dart';
import 'package:daily_water_tracker/features/theme/decorations.dart';
import 'package:daily_water_tracker/firebase/models/drink_type.dart';

const int _kVolumeStep = 50;
const int _kVolumeMin = 1;
const int _kVolumeMax = 20000;

Future<void> showAddWaterBottomSheet(BuildContext context) {
  final homeCubit = context.read<HomeCubit>();
  homeCubit.deferProgressUpdates(true);
  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    backgroundColor: AppDecorations.transparent,
    barrierColor: AppDecorations.modalBarrier(),
    builder: (ctx) {
      final maxH = MediaQuery.sizeOf(ctx).height * 0.92;
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
              child: BlocProvider.value(
                value: homeCubit,
                child: const AddWaterBottomSheet(),
              ),
            ),
          ),
        ],
      );
    },
  ).whenComplete(() => homeCubit.deferProgressUpdates(false));
}

class AddWaterBottomSheet extends StatefulWidget {
  const AddWaterBottomSheet({super.key});

  @override
  State<AddWaterBottomSheet> createState() => _AddWaterBottomSheetState();
}

class _AddWaterBottomSheetState extends State<AddWaterBottomSheet> {
  final TextEditingController _manualMlController = TextEditingController(
    text: '200',
  );
  final FocusNode _manualFocus = FocusNode();

  DrinkType _drinkType = DrinkType.water;
  int _volume = 200;
  bool _busy = false;
  bool _seededVolumeFromPresets = false;

  @override
  void initState() {
    super.initState();
    _manualFocus.addListener(_onManualFocusChange);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_seededVolumeFromPresets) return;
    final presets = context.read<HomeCubit>().state.drinkPresetsMl;
    if (presets.isEmpty) return;
    _seededVolumeFromPresets = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _setVolume(presets.first);
    });
  }

  void _onManualFocusChange() {
    if (!_manualFocus.hasFocus) _syncManualFieldFromVolume();
  }

  @override
  void dispose() {
    _manualFocus.removeListener(_onManualFocusChange);
    _manualFocus.dispose();
    _manualMlController.dispose();
    super.dispose();
  }

  void _setVolume(int ml) {
    final v = ml.clamp(_kVolumeMin, _kVolumeMax);
    setState(() {
      _volume = v;
      _manualMlController.text = '$v';
      _manualMlController.selection = TextSelection.collapsed(
        offset: _manualMlController.text.length,
      );
    });
  }

  void _nudgeVolume(int delta) {
    _setVolume(_volume + delta);
  }

  void _syncManualFieldFromVolume() {
    final parsed = int.tryParse(_manualMlController.text.trim());
    if (parsed == null) {
      _manualMlController.text = '$_volume';
      return;
    }
    _setVolume(parsed);
  }

  static String _formatCoefficient(double c) {
    final rounded = (c * 100).round() / 100;
    final s = rounded.toStringAsFixed(2);
    if (s.endsWith('00')) return rounded.toStringAsFixed(1);
    if (s.endsWith('0')) return s.substring(0, s.length - 1);
    return s;
  }

  Future<void> _onAdd(BuildContext context) async {
    _syncManualFieldFromVolume();
    final ml = _volume;
    if (ml <= 0) {
      AppSnackBar.showError(context, LocaleKeys.home_error_invalid_amount.tr());
      return;
    }
    if (ml > _kVolumeMax) {
      AppSnackBar.showError(context, LocaleKeys.home_error_amount_too_large.tr(namedArgs: {'max': '$_kVolumeMax'}));
      return;
    }

    final navigator = Navigator.of(context, rootNavigator: true);
    final drinkType = _drinkType;
    final coeff = drinkType.defaultCoefficient;
    final effectiveRounded = (ml * coeff).round();

    setState(() => _busy = true);
    try {
      await context.read<HomeCubit>().addWaterRecord(
        volumeMl: ml,
        drinkType: drinkType,
      );

      if (!context.mounted) return;
      navigator.pop();

      final title = LocaleKeys.home_success_added_title.tr(namedArgs: {'drink': drinkType.localizedLabel});
      final coeffLabel = _formatCoefficient(coeff);
      final message = LocaleKeys.home_success_added_message.tr(
        namedArgs: {
          'ml': '$ml',
          'coeff': coeffLabel,
          'effective': '$effectiveRounded',
        },
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!navigator.context.mounted) return;
        AppSnackBar.showSuccess(
          navigator.context,
          title: title,
          message: message,
        );
      });
    } on FirebaseException catch (e, st) {
      debugPrint(
        'AddWaterBottomSheet: FirebaseException: ${e.code} ${e.message}',
      );
      debugPrintStack(stackTrace: st);
      if (context.mounted) {
        AppSnackBar.showError(
          context,
          LocaleKeys.home_error_add_failed_code.tr(namedArgs: {'code': e.code}),
        );
      }
    } catch (e, st) {
      debugPrint('AddWaterBottomSheet: error: $e');
      debugPrintStack(stackTrace: st);
      if (context.mounted) {
        AppSnackBar.showError(context, LocaleKeys.home_error_add_failed.tr());
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final graphite = colors.progressValueText;
    final muted = colors.progressLabelMuted;
    final theme = Theme.of(context).textTheme;
    final coeffLabel = _formatCoefficient(_drinkType.defaultCoefficient);
    final presetVolumes = context.watch<HomeCubit>().state.drinkPresetsMl;

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
                padding: EdgeInsets.fromLTRB(
                  18,
                  0,
                  18,
                  22 + MediaQuery.viewInsetsOf(context).bottom,
                ),
                physics: const BouncingScrollPhysics(),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      LocaleKeys.home_sheet_add_title.tr(),
                      textAlign: TextAlign.center,
                      style: theme.titleLarge?.copyWith(
                        color: graphite,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
                      decoration: BoxDecoration(
                        color: context.appColors.waterSheetCardBg,
                        borderRadius: BorderRadius.circular(
                          kWaterSheetCardRadius,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              for (
                                var i = 0;
                                i < DrinkType.values.length;
                                i++
                              ) ...[
                                if (i != 0) const SizedBox(width: 8),
                                Expanded(
                                  child: WaterDrinkChoiceChip(
                                    type: DrinkType.values[i],
                                    selected: DrinkType.values[i] == _drinkType,
                                    onTap: () => setState(
                                      () => _drinkType = DrinkType.values[i],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            LocaleKeys.home_sheet_hydration_coefficient.tr(namedArgs: {'coeff': coeffLabel}),
                            textAlign: TextAlign.center,
                            style: theme.labelSmall?.copyWith(
                              color: muted,
                              fontWeight: FontWeight.w600,
                              height: 1.25,
                            ),
                          ),
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
                            color: waterSheetHydrationLineColor(_drinkType),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
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
                                const SizedBox(height: 16),
                                Text(
                                  LocaleKeys.home_sheet_quick_presets.tr(),
                                  style: theme.labelMedium?.copyWith(
                                    color: muted,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: [
                                    for (final v in presetVolumes)
                                      WaterCapsuleButton(
                                        label: LocaleKeys.home_sheet_preset_ml.tr(namedArgs: {'value': '$v'}),
                                        selected: _volume == v,
                                        enabled: !_busy,
                                        onTap: () => _setVolume(v),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 18),
                                Text(
                                  LocaleKeys.home_sheet_manual_entry.tr(),
                                  textAlign: TextAlign.center,
                                  style: theme.labelMedium?.copyWith(
                                    color: muted,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: _manualMlController,
                                  focusNode: _manualFocus,
                                  enabled: !_busy,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  style: theme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: graphite,
                                    letterSpacing: -0.2,
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(5),
                                  ],
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: colors.chipUnselectedBg,
                                    hintText: LocaleKeys.home_sheet_hint_volume.tr(),
                                    hintStyle: theme.bodyMedium?.copyWith(
                                      color: muted,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                        color: muted.withValues(alpha: 0.25),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                        color: muted.withValues(alpha: 0.22),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(
                                        color: WaterProgressIndicator
                                            .gradientTailSoft,
                                        width: 1.6,
                                      ),
                                    ),
                                  ),
                                  onEditingComplete: () {
                                    _syncManualFieldFromVolume();
                                    FocusScope.of(context).unfocus();
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    WaterGradientCtaButton(
                      enabled: true,
                      busy: _busy,
                      onTap: () => _onAdd(context),
                      label: LocaleKeys.home_sheet_button_add.tr(),
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
