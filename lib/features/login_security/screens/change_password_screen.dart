import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:daily_water_tracker/common/di/injector_module.dart';
import 'package:daily_water_tracker/common/widgets/app_primary_button.dart';
import 'package:daily_water_tracker/common/widgets/app_loader.dart';
import 'package:daily_water_tracker/common/widgets/app_screen_title.dart';
import 'package:daily_water_tracker/common/widgets/app_snackbar.dart';
import 'package:daily_water_tracker/common/widgets/dismiss_keyboard_on_tap.dart';
import 'package:daily_water_tracker/features/auth/widgets/auth_card.dart';
import 'package:daily_water_tracker/features/auth/widgets/auth_text_field.dart';
import 'package:daily_water_tracker/features/login_security/cubit/change_password_cubit.dart';
import 'package:daily_water_tracker/features/login_security/cubit/change_password_state.dart';
import 'package:daily_water_tracker/firebase/services/auth_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  bool _isOldPasswordVisible = false;
  bool _isNewPasswordVisible = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChangePasswordCubit(
        authService: InjectorModule.locator<AuthService>(),
      ),
      child: BlocListener<ChangePasswordCubit, ChangePasswordState>(
        listener: (context, state) {
          if (state is ChangePasswordLoading) {
            AppLoader.show(
              context,
              message: LocaleKeys.loader_updating_password.tr(),
            );
          } else {
            if (AppLoader.isShowing) AppLoader.hide();
          }

          if (state is ChangePasswordSuccess) {
            AppSnackBar.showSuccess(
              context,
              title: LocaleKeys.login_security_success_title.tr(),
              message: LocaleKeys.login_security_success_message.tr(),
            );
            context.pop();
          } else if (state is ChangePasswordFailure) {
            AppSnackBar.showError(context, state.localizedMessage());
          }
        },
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
            shadowColor: Colors.transparent,
            centerTitle: true,
            title: AppScreenTitle.appBarLocalized(
              localeKey: LocaleKeys.login_security_change_password_title,
            ),
          ),
          body: SafeArea(
            child: DismissKeyboardOnTap(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                    children: [
                      AuthCard(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AuthTextField(
                                controller: _oldPasswordController,
                                label: LocaleKeys.login_security_field_old_password
                                    .tr(),
                                hint: LocaleKeys
                                    .login_security_field_old_password_hint
                                    .tr(),
                                textInputAction: TextInputAction.next,
                                obscureText: !_isOldPasswordVisible,
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  onPressed: () => setState(
                                    () => _isOldPasswordVisible =
                                        !_isOldPasswordVisible,
                                  ),
                                  icon: Icon(
                                    _isOldPasswordVisible
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                ),
                                validator: (value) {
                                  if ((value ?? '').isEmpty) {
                                    return LocaleKeys
                                        .auth_validation_password_required
                                        .tr();
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              AuthTextField(
                                controller: _newPasswordController,
                                label: LocaleKeys.login_security_field_new_password
                                    .tr(),
                                hint: LocaleKeys
                                    .login_security_field_new_password_hint
                                    .tr(),
                                textInputAction: TextInputAction.done,
                                obscureText: !_isNewPasswordVisible,
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  onPressed: () => setState(
                                    () => _isNewPasswordVisible =
                                        !_isNewPasswordVisible,
                                  ),
                                  icon: Icon(
                                    _isNewPasswordVisible
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                ),
                                validator: (value) {
                                  final password = value ?? '';
                                  if (password.isEmpty) {
                                    return LocaleKeys
                                        .auth_validation_password_required
                                        .tr();
                                  }
                                  if (password.length < 6) {
                                    return LocaleKeys
                                        .auth_validation_password_min_length
                                        .tr();
                                  }
                                  return null;
                                },
                                onFieldSubmitted: (_) => _onSavePressed(context),
                              ),
                              const SizedBox(height: 16),
                              BlocBuilder<ChangePasswordCubit, ChangePasswordState>(
                                builder: (context, state) {
                                  final isLoading =
                                      state is ChangePasswordLoading;
                                  return AppGradientButton(
                                    label: LocaleKeys
                                        .login_security_button_save_changes
                                        .tr(),
                                    busy: isLoading,
                                    onTap: () => _onSavePressed(context),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onSavePressed(BuildContext context) {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    context.read<ChangePasswordCubit>().submit(
      currentPassword: _oldPasswordController.text,
      newPassword: _newPasswordController.text,
    );
  }
}
