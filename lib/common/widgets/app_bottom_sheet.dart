import 'package:flutter/material.dart';
import 'package:daily_water_tracker/features/theme/app_theme_extensions.dart';
import 'package:daily_water_tracker/features/theme/decorations.dart';

Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required Widget child,
  bool useSafeArea = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    useSafeArea: useSafeArea,
    isScrollControlled: true,
    showDragHandle: false,
    backgroundColor: AppDecorations.transparent,
    builder: (context) => AppBottomSheet(child: child),
  );
}

class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final colors = context.appColors;
    return Padding(
      // No side margins — sheet spans full width.
      // Keep only bottom inset so it sits above keyboard / system UI.
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Material(
        color: colors.sheetSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        clipBehavior: Clip.antiAlias,
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: colors.sheetDragHandle,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class AppBottomSheetTitle extends StatelessWidget {
  const AppBottomSheetTitle(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            height: 1.05,
          ),
        ),
      ),
    );
  }
}

class AppBottomSheetDivider extends StatelessWidget {
  const AppBottomSheetDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 18),
      child: Container(
        height: 1,
        color: Theme.of(
          context,
        ).colorScheme.outlineVariant.withValues(alpha: 0.22),
      ),
    );
  }
}

class AppBottomSheetAction extends StatelessWidget {
  const AppBottomSheetAction({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.titleColor,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    final effectiveTitleColor =
        titleColor ?? Theme.of(context).colorScheme.onSurface;
    final iconColor =
        titleColor ??
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashFactory: InkRipple.splashFactory,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          child: Row(
            children: [
              Padding(
                // Optical alignment: icon glyphs sit slightly higher than text
                padding: const EdgeInsets.only(top: 5),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize:
                        (Theme.of(context).textTheme.titleLarge?.fontSize ??
                            0) -
                        2,
                    color: effectiveTitleColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
