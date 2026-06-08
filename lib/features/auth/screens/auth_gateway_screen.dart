import 'package:daily_water_tracker/common/assets.dart';
import 'package:daily_water_tracker/common/di/injector_module.dart';
import 'package:daily_water_tracker/common/router.dart';
import 'package:daily_water_tracker/common/screens/splash_screen.dart';
import 'package:daily_water_tracker/common/services/app_bootstrapper.dart';
import 'package:daily_water_tracker/common/widgets/app_loader.dart';
import 'package:daily_water_tracker/common/widgets/app_snackbar.dart';
import 'package:daily_water_tracker/common/widgets/delayed_entrance.dart';
import 'package:daily_water_tracker/data/repositories/firestore_repository.dart';
import 'package:daily_water_tracker/data/repositories/messaging_repository.dart';
import 'package:daily_water_tracker/features/auth/cubit/login_cubit.dart';
import 'package:daily_water_tracker/features/auth/cubit/login_state.dart';
import 'package:daily_water_tracker/features/auth/cubit/signup_cubit.dart';
import 'package:daily_water_tracker/features/auth/cubit/signup_state.dart';
import 'package:daily_water_tracker/features/auth/widgets/widgets.dart';
import 'package:daily_water_tracker/features/vibration/vibration_feedback.dart';
import 'package:daily_water_tracker/features/theme/decorations.dart';
import 'package:daily_water_tracker/features/theme/theme_colors.dart';
import 'package:daily_water_tracker/firebase/services/auth_service.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Single auth screen: fixed header, Sign In / Sign Up cards swap in place.
class AuthGatewayScreen extends StatefulWidget {
  const AuthGatewayScreen({super.key, this.initialSignUp = false});

  final bool initialSignUp;

  @override
  State<AuthGatewayScreen> createState() => _AuthGatewayScreenState();
}

class _AuthGatewayScreenState extends State<AuthGatewayScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _loginFormKey = GlobalKey<FormState>();
  final _signUpFormKey = GlobalKey<FormState>();

  late bool _isSignUp;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _isSignUp = widget.initialSignUp;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _goToSignUp() {
    if (_isSignUp) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _isSignUp = true);
  }

  void _goToSignIn() {
    if (!_isSignUp) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _isSignUp = false);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => LoginCubit(
            authService: InjectorModule.locator<AuthService>(),
            firestoreRepository: context.read<FirestoreRepository>(),
          ),
        ),
        BlocProvider(
          create: (context) => SignUpCubit(
            authService: InjectorModule.locator<AuthService>(),
            firestoreRepository: context.read<FirestoreRepository>(),
          ),
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<LoginCubit, LoginState>(
            listener: (context, state) {
              if (state is LoginLoading) {
                AppLoader.show(context, message: LocaleKeys.loader_signing_in.tr());
              } else {
                if (AppLoader.isShowing) AppLoader.hide();
              }

              if (state is LoginSuccess) {
                final pending =
                    context.read<MessagingRepository>().consumePendingRoute();
                if ((pending ?? '').trim() == 'account') {
                  context.go(accountRoute);
                } else {
                  context.go(homeRoute);
                }
              } else if (state is LoginFailure) {
                AppSnackBar.showError(context, state.localizedMessage());
              }
            },
          ),
          BlocListener<SignUpCubit, SignUpState>(
            listener: (context, state) {
              if (state is SignUpLoading) {
                AppLoader.show(context, message: LocaleKeys.loader_creating_account.tr());
              } else {
                if (AppLoader.isShowing) AppLoader.hide();
              }

              if (state is SignUpSuccess) {
                final pending =
                    context.read<MessagingRepository>().consumePendingRoute();
                if ((pending ?? '').trim() == 'account') {
                  context.go(accountRoute);
                } else {
                  context.go(homeRoute);
                }
              } else if (state is SignUpFailure) {
                AppSnackBar.showError(context, state.localizedMessage());
              }
            },
          ),
        ],
        child: AuthScaffold(
          header: const Column(
            children: [
              Hero(
                tag: splashLoginHeroTag,
                child: Image(
                  image: AssetImage(splashWordmark),
                  width: 360,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
          child: DelayedEntrance(
            delay: const Duration(milliseconds: 220),
            duration: const Duration(milliseconds: 260),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              clipBehavior: Clip.none,
              child: Column(
                children: [
                  const SizedBox(height: 4),
                  AuthCardSwitcher(
                    showSignUp: _isSignUp,
                    signInBuilder: _buildSignInCard,
                    signUpBuilder: _buildSignUpCard,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignInCard(BuildContext context) {
    return AuthCard(
      child: Form(
        key: _loginFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildAuthHeader(
              context,
              title: LocaleKeys.auth_sign_in_title.tr(),
              subtitle: LocaleKeys.auth_sign_in_subtitle.tr(),
            ),
            const SizedBox(height: 18),
            AuthTextField(
              controller: _emailController,
              label: LocaleKeys.auth_field_email.tr(),
              hint: LocaleKeys.auth_field_email_hint.tr(),
              keyboardType: TextInputType.emailAddress,
              prefixIcon: const Icon(Icons.mail_outline),
              validator: (v) {
                final value = (v ?? '').trim();
                if (value.isEmpty) return LocaleKeys.auth_validation_email_required.tr();
                if (!value.contains('@')) return LocaleKeys.auth_validation_email_invalid.tr();
                return null;
              },
            ),
            const SizedBox(height: 12),
            AuthTextField(
              controller: _passwordController,
              label: LocaleKeys.auth_field_password.tr(),
              textInputAction: TextInputAction.done,
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
              validator: (v) {
                final value = v ?? '';
                if (value.isEmpty) return LocaleKeys.auth_validation_password_required.tr();
                return null;
              },
              onFieldSubmitted: (_) => _onSignInPressed(context),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _onForgotPasswordPressed,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  LocaleKeys.auth_forgot_password_link.tr(),
                  style: const TextStyle(
                    color: brandBlue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            BlocBuilder<LoginCubit, LoginState>(
              builder: (context, state) {
                return FilledButton(
                  onPressed: () => VibrationFeedback.run(
                    context,
                    () => _onSignInPressed(context),
                  ),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    LocaleKeys.auth_button_sign_in.tr(),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                );
              },
            ),
            const SizedBox(height: 14),
            AuthDivider(label: LocaleKeys.auth_divider_or.tr()),
            const SizedBox(height: 14),
            BlocBuilder<LoginCubit, LoginState>(
              builder: (context, state) {
                return _buildSocialButtons(
                  context,
                  onApple: () => context.read<LoginCubit>().signInWithApple(),
                  onGoogle: () => context.read<LoginCubit>().signInWithGoogle(),
                  onFacebook: () =>
                      context.read<LoginCubit>().signInWithFacebook(),
                );
              },
            ),
            const SizedBox(height: 6),
            TextButton(
              onPressed: _goToSignUp,
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: LocaleKeys.auth_link_no_account.tr(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    TextSpan(
                      text: LocaleKeys.auth_link_sign_up.tr(),
                      style: const TextStyle(
                        color: brandBlue,
                        fontWeight: FontWeight.w800,
                      ),
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

  Widget _buildSignUpCard(BuildContext context) {
    return AuthCard(
      child: Form(
        key: _signUpFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildAuthHeader(
              context,
              title: LocaleKeys.auth_sign_up_title.tr(),
              subtitle: LocaleKeys.auth_sign_up_subtitle.tr(),
            ),
            const SizedBox(height: 18),
            AuthTextField(
              controller: _emailController,
              label: LocaleKeys.auth_field_email.tr(),
              hint: LocaleKeys.auth_field_email_hint.tr(),
              keyboardType: TextInputType.emailAddress,
              prefixIcon: const Icon(Icons.mail_outline),
              validator: (v) {
                final value = (v ?? '').trim();
                if (value.isEmpty) {
                  return LocaleKeys.auth_validation_email_required.tr();
                }
                if (!value.contains('@')) {
                  return LocaleKeys.auth_validation_email_invalid.tr();
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            AuthTextField(
              controller: _passwordController,
              label: LocaleKeys.auth_field_password.tr(),
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
              validator: (v) {
                final value = v ?? '';
                if (value.isEmpty) {
                  return LocaleKeys.auth_validation_password_required.tr();
                }
                if (value.length < 6) {
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
              validator: (v) {
                final value = v ?? '';
                if (value.isEmpty) return LocaleKeys.auth_validation_confirm_password_required.tr();
                if (value != _passwordController.text) {
                  return LocaleKeys.auth_validation_passwords_mismatch.tr();
                }
                return null;
              },
              onFieldSubmitted: (_) => _onSignUpPressed(context),
            ),
            const SizedBox(height: 16),
            BlocBuilder<SignUpCubit, SignUpState>(
              builder: (context, state) {
                return FilledButton(
                  onPressed: () => VibrationFeedback.run(
                    context,
                    () => _onSignUpPressed(context),
                  ),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    LocaleKeys.auth_button_create_account.tr(),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                );
              },
            ),
            const SizedBox(height: 14),
            AuthDivider(label: LocaleKeys.auth_divider_or.tr()),
            const SizedBox(height: 14),
            BlocBuilder<SignUpCubit, SignUpState>(
              builder: (context, state) {
                return _buildSocialButtons(
                  context,
                  onApple: () => context.read<SignUpCubit>().signInWithApple(),
                  onGoogle: () =>
                      context.read<SignUpCubit>().signInWithGoogle(),
                  onFacebook: () =>
                      context.read<SignUpCubit>().signInWithFacebook(),
                );
              },
            ),
            const SizedBox(height: 6),
            TextButton(
              onPressed: _goToSignIn,
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: LocaleKeys.auth_link_have_account.tr(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    TextSpan(
                      text: LocaleKeys.auth_button_sign_in.tr(),
                      style: const TextStyle(
                        color: brandBlue,
                        fontWeight: FontWeight.w800,
                      ),
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

  Widget _buildAuthHeader(
    BuildContext context, {
    required String title,
    required String subtitle,
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
          child: const Icon(Icons.water_drop, color: AppPalette.white),
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

  Widget _buildSocialButtons(
    BuildContext context, {
    required VoidCallback onApple,
    required VoidCallback onGoogle,
    required VoidCallback onFacebook,
  }) {
    final showApple = defaultTargetPlatform == TargetPlatform.iOS;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showApple) ...[
          SocialAuthButton(brand: SocialBrand.apple, onPressed: onApple),
          const SizedBox(height: 10),
        ],
        SocialAuthButton(brand: SocialBrand.google, onPressed: onGoogle),
        if (flutterFlavor.isDev) ...[
          const SizedBox(height: 10),
          SocialAuthButton(brand: SocialBrand.facebook, onPressed: onFacebook),
        ],
      ],
    );
  }

  void _onSignInPressed(BuildContext context) {
    final isValid = _loginFormKey.currentState?.validate() ?? false;
    if (!isValid) return;

    context.read<LoginCubit>().signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  void _onSignUpPressed(BuildContext context) {
    final isValid = _signUpFormKey.currentState?.validate() ?? false;
    if (!isValid) return;

    context.read<SignUpCubit>().signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  void _onForgotPasswordPressed() {
    FocusManager.instance.primaryFocus?.unfocus();
    final email = _emailController.text.trim();
    final destination = email.isEmpty
        ? forgotPasswordRoute
        : '$forgotPasswordRoute?email=${Uri.encodeComponent(email)}';
    context.push(destination);
  }
}
