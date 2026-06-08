import 'package:daily_water_tracker/common/widgets/dismiss_keyboard_on_tap.dart';
import 'package:daily_water_tracker/features/theme/app_theme_extensions.dart';
import 'package:daily_water_tracker/features/theme/theme_colors.dart';
import 'package:flutter/material.dart';

class AuthScaffold extends StatelessWidget {
  final Widget child;
  final String? title;
  final String? subtitle;
  final Widget? header;

  const AuthScaffold({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.header,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;
    final background = Theme.of(context).brightness == Brightness.light
        ? appBackground
        : colors.screenBackground;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(color: background),
            ),
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      header ??
                          _Header(
                            title: title,
                            subtitle: subtitle,
                            foreground: scheme.onSurface,
                          ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: DismissKeyboardOnTap(
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 450),
                            curve: Curves.easeOut,
                            opacity: 1,
                            child: child,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Color foreground;

  const _Header({
    required this.title,
    required this.subtitle,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final t = title;
    final s = subtitle;

    if (t == null && s == null) return const SizedBox.shrink();

    return Column(
      children: [
        if (t != null)
          Text(
            t,
            textAlign: TextAlign.center,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: foreground,
            ),
          ),
        if (s != null) ...[
          const SizedBox(height: 6),
          Text(
            s,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: foreground.withValues(alpha: 0.72),
              height: 1.2,
            ),
          ),
        ],
      ],
    );
  }
}
