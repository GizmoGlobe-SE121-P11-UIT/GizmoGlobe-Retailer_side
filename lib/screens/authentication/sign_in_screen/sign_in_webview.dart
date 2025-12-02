import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/localization/app_localization.dart';

import '../../../enums/processing/process_state_enum.dart';
import '../../../widgets/dialog/information_dialog.dart';
import '../../../widgets/general/gradient_text.dart';
import '../../../widgets/snackbar/snackbar_service.dart';
import '../../../widgets/general/app_logo.dart';
import '../../../widgets/general/field_with_icon.dart';
import 'sign_in_cubit.dart';
import 'sign_in_state.dart';

class SignInWebView extends StatefulWidget {
  const SignInWebView({super.key});

  @override
  State<SignInWebView> createState() => _SignInWebViewState();
}

class _SignInWebViewState extends State<SignInWebView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  SignInCubit get cubit => context.read<SignInCubit>();

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
              const SizedBox(height: 40),
              const AppLogo(
                alignment: Alignment.centerRight,
                height: 80,
              ),
              const SizedBox(height: 32),

              // Header
              Align(
                alignment: Alignment.centerLeft,
                child: GradientText(
                  text: S.of(context).signIn,
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
                    hintText: S.of(context).yourEmail,
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
                      cubit.emailChanged(value);
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
                      cubit.passwordChanged(value);
                    },
                  ),

                  // Forgot Password Link
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/forget-password');
                      },
                      child: Text(
                        S.of(context).forgotPassword,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Sign In Button with BLoC integration
                  BlocConsumer<SignInCubit, SignInState>(
                    listener: (context, state) {
                      if (state.processState == ProcessState.failure) {
                        showDialog(
                          context: context,
                          builder: (context) => InformationDialog(
                            title: state.dialogName.toString(),
                            content: state.message.getLocalizedMessage(context),
                          ),
                        );
                      } else if (state.processState == ProcessState.success) {
                        SnackbarService.showSuccess(
                          context,
                          state.dialogName.getLocalizedName(context),
                          state.message.getLocalizedMessage(context),
                        );
                        // Navigate after a short delay to allow snackbar to be visible
                        Future.delayed(const Duration(milliseconds: 500), () {
                          if (context.mounted) {
                            Navigator.pushReplacementNamed(context, '/main');
                          }
                        });
                      }
                    },
                    builder: (context, state) {
                      return SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: state.processState == ProcessState.loading
                              ? null
                              : () async {
                                  cubit.signInWithEmailPassword(context);
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
                                      S.of(context).signIn,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  S.of(context).signIn,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),

                  // Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        S.of(context).authorizedByAdmin,
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/sign-up');
                        },
                        child: Text(
                          S.of(context).signUp,
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
