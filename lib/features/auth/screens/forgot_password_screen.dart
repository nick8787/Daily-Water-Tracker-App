import 'package:daily_water_tracker/common/di/injector_module.dart';
import 'package:daily_water_tracker/common/router.dart';
import 'package:daily_water_tracker/common/widgets/app_loader.dart';
import 'package:daily_water_tracker/common/widgets/dismiss_keyboard_on_tap.dart';
import 'package:daily_water_tracker/features/auth/cubit/forgot_password_cubit.dart';
import 'package:daily_water_tracker/features/auth/cubit/forgot_password_state.dart';
import 'package:daily_water_tracker/features/auth/widgets/auth_card.dart';
import 'package:daily_water_tracker/features/auth/widgets/auth_text_field.dart';
import 'package:daily_water_tracker/features/theme/decorations.dart';
import 'package:daily_water_tracker/features/theme/theme_colors.dart';
import 'package:daily_water_tracker/firebase/services/auth_service.dart';
import 'package:daily_water_tracker/features/vibration/vibration_feedback.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({
    super.key,
    this.initialEmail = '',
  });

  final String initialEmail;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ForgotPasswordCubit(
        authService: InjectorModule.locator<AuthService>(),
      ),
      child: BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
        listener: (context, state) {
          if (state is ForgotPasswordLoading) {
            AppLoader.show(
              context,
              message: LocaleKeys.loader_sending_reset_link.tr(),
            );
          } else if (AppLoader.isShowing) {
            AppLoader.hide();
          }
        },
        builder: (context, state) {
          final successEmail =
              state is ForgotPasswordSuccess ? state.email : null;

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
                      child: AuthCard(
                        child: successEmail != null
                            ? _buildSuccessContent(context, successEmail)
                            : _buildFormContent(context),
                      ),
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

  Widget _buildFormContent(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(
            context,
            title: LocaleKeys.auth_forgot_password_title.tr(),
            subtitle: LocaleKeys.auth_forgot_password_subtitle.tr(),
          ),
          const SizedBox(height: 18),
          AuthTextField(
            controller: _emailController,
            label: LocaleKeys.auth_field_email.tr(),
            hint: LocaleKeys.auth_field_email_hint.tr(),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            prefixIcon: const Icon(Icons.mail_outline),
            validator: (value) {
              final email = (value ?? '').trim();
              if (email.isEmpty) {
                return LocaleKeys.auth_validation_email_required.tr();
              }
              if (!email.contains('@')) {
                return LocaleKeys.auth_validation_email_invalid.tr();
              }
              return null;
            },
            onFieldSubmitted: (_) => _onSendPressed(context),
          ),
          const SizedBox(height: 16),
          BlocBuilder<ForgotPasswordCubit, ForgotPasswordState>(
            builder: (context, state) {
              final isLoading = state is ForgotPasswordLoading;
              return FilledButton(
                onPressed: isLoading
                    ? null
                    : () => VibrationFeedback.run(
                        context,
                        () => _onSendPressed(context),
                      ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  LocaleKeys.auth_forgot_password_button_send.tr(),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              );
            },
          ),
          BlocBuilder<ForgotPasswordCubit, ForgotPasswordState>(
            builder: (context, state) {
              if (state is! ForgotPasswordFailure) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  state.localizedMessage(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessContent(BuildContext context, String email) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(
          context,
          title: LocaleKeys.auth_forgot_password_success_title.tr(),
          subtitle: LocaleKeys.auth_forgot_password_success_message.tr(
            namedArgs: {'email': email},
          ),
          icon: Icons.mark_email_read_outlined,
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: () => VibrationFeedback.run(context, () => context.go(loginRoute)),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text(
            LocaleKeys.auth_forgot_password_button_back_to_sign_in.tr(),
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
            boxShadow: const [
              BoxShadow(
                color: AppPalette.authLogoShadow,
                blurRadius: 18,
                offset: Offset(0, 10),
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

  void _onSendPressed(BuildContext context) {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    context.read<ForgotPasswordCubit>().sendResetLink(
      email: _emailController.text,
    );
  }
}
