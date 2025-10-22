import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/localization/app_localization.dart';

import '../../../enums/processing/process_state_enum.dart';
import '../../../widgets/dialog/information_dialog.dart';
import '../../../widgets/general/gradient_text.dart';
import '../../../widgets/general/app_logo.dart';
import '../../../widgets/general/field_with_icon.dart';
import 'sign_up_cubit.dart';
import 'sign_up_state.dart';

class SignUpWebView extends StatefulWidget {
  const SignUpWebView({super.key});

  @override
  State<SignUpWebView> createState() => _SignUpWebViewState();
}

class _SignUpWebViewState extends State<SignUpWebView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  SignUpCubit get cubit => context.read<SignUpCubit>();

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() {
      cubit.updateEmail(_emailController.text);
    });
    _passwordController.addListener(() {
      cubit.updatePassword(_passwordController.text);
    });
    _confirmPasswordController.addListener(() {
      cubit.updateConfirmPassword(_confirmPasswordController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Section
              const AppLogo(
                alignment: Alignment.centerRight,
                height: 80,
              ),
              const SizedBox(height: 32),

              // Header
              Align(
                alignment: Alignment.centerLeft,
                child: GradientText(
                  text: S.of(context).createNewAccount,
                  fontSize: 32,
                ),
              ),
              const SizedBox(height: 32),

              // Form Section
              Column(
                children: [
                  // Email Field
                  FieldWithIcon(
                    controller: _emailController,
                    hintText: S.of(context).email,
                    fillColor: Theme.of(context).colorScheme.surface,
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    textColor: Theme.of(context).colorScheme.onSurface,
                    hintTextColor: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                    prefixIcon: Icon(
                      Icons.mail_outline,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                      size: 20,
                    ),
                    onChanged: (value) {
                      cubit.updateEmail(value);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  FieldWithIcon(
                    controller: _passwordController,
                    hintText: S.of(context).password,
                    fillColor: Theme.of(context).colorScheme.surface,
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    obscureText: true,
                    textColor: Theme.of(context).colorScheme.onSurface,
                    hintTextColor: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                      size: 20,
                    ),
                    onChanged: (value) {
                      cubit.updatePassword(value);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Confirm Password Field
                  FieldWithIcon(
                    controller: _confirmPasswordController,
                    hintText: S.of(context).passwordConfirmation,
                    fillColor: Theme.of(context).colorScheme.surface,
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    obscureText: true,
                    textColor: Theme.of(context).colorScheme.onSurface,
                    hintTextColor: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                      size: 20,
                    ),
                    onChanged: (value) {
                      cubit.updateConfirmPassword(value);
                    },
                  ),
                  const SizedBox(height: 32),

                  // Sign Up Button with BLoC integration
                  BlocConsumer<SignUpCubit, SignUpState>(
                    listener: (context, state) {
                      if (state.processState == ProcessState.success) {
                        showDialog(
                          context: context,
                          builder: (context) => InformationDialog(
                            title: state.dialogName.getLocalizedName(context),
                            content: state.message.getLocalizedMessage(context),
                            onPressed: () {
                              Navigator.pushReplacementNamed(
                                  context, '/sign-in');
                            },
                          ),
                        );
                      }

                      if (state.processState == ProcessState.failure) {
                        showDialog(
                          context: context,
                          builder: (context) => InformationDialog(
                            title: state.dialogName.getLocalizedName(context),
                            content: state.message.getLocalizedMessage(context),
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      return SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: state.processState == ProcessState.loading
                              ? null
                              : () {
                                  cubit.signUp();
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: state.processState == ProcessState.loading
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Creating account...',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  S.of(context).createNewAccount,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Back to Sign In
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        S.of(context).alreadyHaveAccount,
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/sign-in');
                        },
                        child: Text(
                          S.of(context).signIn,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
