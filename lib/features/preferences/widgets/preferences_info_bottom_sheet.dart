import 'package:flutter/material.dart';
import 'package:daily_water_tracker/features/home/widgets/water_progress_indicator.dart';
import 'package:daily_water_tracker/features/theme/app_theme_extensions.dart';
import 'package:daily_water_tracker/features/theme/decorations.dart';

Future<void> showPreferencesInfoSheet(
  BuildContext context, {
  required Widget body,
}) {
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
              child: _PreferencesInfoShell(child: body),
            ),
          ),
        ],
      );
    },
  );
}

class _PreferencesInfoShell extends StatelessWidget {
  const _PreferencesInfoShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: Material(
        color: context.appColors.sheetSurface,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _SheetDragHandle(),
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(22, 4, 22, 22),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetDragHandle extends StatelessWidget {
  const _SheetDragHandle();

  @override
  Widget build(BuildContext context) {
    const muted = WaterProgressIndicator.labelMuted;
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 6),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: muted.withValues(alpha: 0.42),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}
