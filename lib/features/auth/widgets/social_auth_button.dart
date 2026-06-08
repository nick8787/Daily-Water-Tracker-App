import 'package:daily_water_tracker/common/assets.dart';
import 'package:daily_water_tracker/features/theme/theme_colors.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:daily_water_tracker/features/vibration/vibration_feedback.dart';
import 'package:flutter/material.dart';

enum SocialBrand { google, facebook, apple }

class SocialAuthButton extends StatelessWidget {
  final SocialBrand brand;
  final VoidCallback? onPressed;

  const SocialAuthButton({
    super.key,
    required this.brand,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final spec = _specFor(brand);
    final scheme = Theme.of(context).colorScheme;

    final buttonStyle =
        FilledButton.styleFrom(
          backgroundColor: spec.background ?? scheme.surface,
          foregroundColor: spec.foreground ?? scheme.onSurface,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ).copyWith(
          elevation: const WidgetStatePropertyAll(0),
          overlayColor: WidgetStatePropertyAll(
            (spec.foreground ?? scheme.onSurface).withValues(alpha: 0.10),
          ),
          side: spec.outline == null
              ? null
              : WidgetStatePropertyAll(BorderSide(color: spec.outline!)),
        );

    return FilledButton(
      onPressed: onPressed == null
          ? null
          : () => VibrationFeedback.run(context, onPressed!),
      style: buttonStyle,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _BrandMark(brand: brand),
          const SizedBox(width: 10),
          Text(spec.label, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _BrandSpec {
  final String label;
  final Color? background;
  final Color? foreground;
  final Color? outline;

  const _BrandSpec({
    required this.label,
    this.background,
    this.foreground,
    this.outline,
  });
}

_BrandSpec _specFor(SocialBrand brand) {
  switch (brand) {
    case SocialBrand.google:
      return _BrandSpec(
        label: LocaleKeys.auth_social_google.tr(),
        background: SocialAuthColors.googleBackground,
        foreground: SocialAuthColors.googleForeground,
        outline: SocialAuthColors.googleOutline,
      );
    case SocialBrand.facebook:
      return _BrandSpec(
        label: LocaleKeys.auth_social_facebook.tr(),
        background: SocialAuthColors.facebookBackground,
        foreground: SocialAuthColors.facebookForeground,
      );
    case SocialBrand.apple:
      return _BrandSpec(
        label: LocaleKeys.auth_social_apple.tr(),
        background: SocialAuthColors.appleBackground,
        foreground: SocialAuthColors.appleForeground,
      );
  }
}

class _BrandMark extends StatelessWidget {
  final SocialBrand brand;

  const _BrandMark({required this.brand});

  @override
  Widget build(BuildContext context) {
    final assetPath = switch (brand) {
      SocialBrand.apple => appleMark,
      SocialBrand.google => googleMark,
      SocialBrand.facebook => facebookMark,
    };
    final tint = switch (brand) {
      SocialBrand.apple => SocialAuthColors.appleForeground,
      SocialBrand.google => null,
      SocialBrand.facebook => null,
    };

    return SizedBox(
      width: 28,
      height: 28,
      child: Center(
        child: Image.asset(
          assetPath,
          width: 20,
          height: 20,
          fit: BoxFit.contain,
          color: tint,
        ),
      ),
    );
  }
}
