import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:daily_water_tracker/common/di/injector_module.dart';
import 'package:daily_water_tracker/common/router.dart';
import 'package:daily_water_tracker/common/widgets/app_loader.dart';
import 'package:daily_water_tracker/common/widgets/app_primary_button.dart';
import 'package:daily_water_tracker/common/widgets/app_snackbar.dart';
import 'package:daily_water_tracker/common/widgets/dismiss_keyboard_on_tap.dart';
import 'package:daily_water_tracker/features/auth/cubit/complete_password_reset_cubit.dart';
import 'package:daily_water_tracker/features/auth/cubit/complete_password_reset_state.dart';
import 'package:daily_water_tracker/features/auth/widgets/auth_card.dart';
import 'package:daily_water_tracker/features/auth/widgets/auth_text_field.dart';
import 'package:daily_water_tracker/features/theme/decorations.dart';
import 'package:daily_water_tracker/features/theme/theme_colors.dart';
import 'package:daily_water_tracker/firebase/services/auth_service.dart';

class CompletePasswordResetScreen extends StatefulWidget {
  const CompletePasswordResetScreen({
    super.key,
    required this.oobCode,
  });

  final String oobCode;

  @override
  State<CompletePasswordResetScreen> createState() =>
      _CompletePasswordResetScreenState();
}

class _CompletePasswordResetScreenState
    extends State<CompletePasswordResetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CompletePasswordResetCubit(
        authService: InjectorModule.locator<AuthService>(),
      )..verifyCode(widget.oobCode),
      child: BlocConsumer<CompletePasswordResetCubit, CompletePasswordResetState>(
        listener: (context, state) {
          if (state is CompletePasswordResetVerifying ||
              state is CompletePasswordResetSubmitting) {
            AppLoader.show(
              context,
              message: state is CompletePasswordResetSubmitting
                  ? LocaleKeys.loader_saving.tr()
                  : LocaleKeys.loader_verifying_reset_link.tr(),
            );
          } else if (AppLoader.isShowing) {
            AppLoader.hide();
          }

          if (state is CompletePasswordResetSuccess) {
            AppSnackBar.showSuccess(
              context,
              title: LocaleKeys.auth_complete_password_reset_success_title.tr(),
              message:
                  LocaleKeys.auth_complete_password_reset_success_message.tr(),
            );
            context.go(loginRoute);
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              elevation: 0,
              scrolledUnderElevation: 0,
              surfaceTintColor: Colors.transparent,
              shadowColor: Colors.transparent,
            ),
            body: SafeArea(
              child: DismissKeyboardOnTap(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                      child: AuthCard(child: _buildBody(context, state)),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, CompletePasswordResetState state) {
    if (state is CompletePasswordResetVerifying ||
        state is CompletePasswordResetInitial) {
      return const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state is CompletePasswordResetInvalidCode) {
      return _buildMessageContent(
        context,
        title: LocaleKeys.auth_complete_password_reset_error_title.tr(),
        subtitle: state.localizedMessage(),
        icon: Icons.link_off_outlined,
        actionLabel:
            LocaleKeys.auth_forgot_password_button_back_to_sign_in.tr(),
        onAction: () => context.go(loginRoute),
      );
    }

    if (state is CompletePasswordResetReady ||
        state is CompletePasswordResetSubmitting ||
        state is CompletePasswordResetFailure) {
      final email = switch (state) {
        CompletePasswordResetReady(:final email) => email,
        CompletePasswordResetSubmitting(:final email) => email,
        CompletePasswordResetFailure(:final email) => email,
        _ => '',
      };
      final oobCode = switch (state) {
        CompletePasswordResetReady(:final oobCode) => oobCode,
        CompletePasswordResetSubmitting(:final oobCode) => oobCode,
        CompletePasswordResetFailure(:final oobCode) => oobCode,
        _ => widget.oobCode,
      };
      final isSubmitting = state is CompletePasswordResetSubmitting;
      final failureMessage = state is CompletePasswordResetFailure
          ? state.localizedMessage()
          : null;

      return Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(
              context,
              title: LocaleKeys.auth_complete_password_reset_title.tr(),
              subtitle: LocaleKeys.auth_complete_password_reset_subtitle.tr(
                namedArgs: {'email': email},
              ),
            ),
            const SizedBox(height: 18),
            AuthTextField(
              controller: _passwordController,
              label: LocaleKeys.auth_complete_password_reset_field_new_password
                  .tr(),
              hint: LocaleKeys
                  .auth_complete_password_reset_field_new_password_hint
                  .tr(),
              textInputAction: TextInputAction.next,
              obscureText: !_isPasswordVisible,
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                onPressed: () => setState(
                  () => _isPasswordVisible = !_isPasswordVisible,
                ),
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                ),
              ),
              validator: (value) {
                final password = value ?? '';
                if (password.isEmpty) {
                  return LocaleKeys.auth_validation_password_required.tr();
                }
                if (password.length < 6) {
                  return LocaleKeys.auth_validation_password_min_length.tr();
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            AuthTextField(
              controller: _confirmPasswordController,
              label: LocaleKeys.auth_field_confirm_password.tr(),
              textInputAction: TextInputAction.done,
              obscureText: !_isConfirmPasswordVisible,
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                onPressed: () => setState(
                  () => _isConfirmPasswordVisible = !_isConfirmPasswordVisible,
                ),
                icon: Icon(
                  _isConfirmPasswordVisible
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
              ),
              validator: (value) {
                final password = value ?? '';
                if (password.isEmpty) {
                  return LocaleKeys.auth_validation_confirm_password_required
                      .tr();
                }
                if (password != _passwordController.text) {
                  return LocaleKeys.auth_validation_passwords_mismatch.tr();
                }
                return null;
              },
              onFieldSubmitted: (_) => _onSavePressed(
                context,
                email: email,
                oobCode: oobCode,
                isSubmitting: isSubmitting,
              ),
            ),
            if (failureMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                failureMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
            const SizedBox(height: 16),
            AppGradientButton(
              label: LocaleKeys.auth_complete_password_reset_button_save.tr(),
              busy: isSubmitting,
              onTap: () => _onSavePressed(
                context,
                email: email,
                oobCode: oobCode,
                isSubmitting: isSubmitting,
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildMessageContent(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(
          context,
          title: title,
          subtitle: subtitle,
          icon: icon,
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: onAction,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text(
            actionLabel,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(
    BuildContext context, {
    required String title,
    required String subtitle,
    IconData icon = Icons.water_drop,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: AppDecorations.authLogo,
            boxShadow: [
              BoxShadow(
                color: AppPalette.authLogoShadow,
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(icon, color: AppPalette.white),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.65),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _onSavePressed(
    BuildContext context, {
    required String email,
    required String oobCode,
    required bool isSubmitting,
  }) {
    if (isSubmitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    context.read<CompletePasswordResetCubit>().submit(
      email: email,
      oobCode: oobCode,
      newPassword: _passwordController.text,
    );
  }
}
