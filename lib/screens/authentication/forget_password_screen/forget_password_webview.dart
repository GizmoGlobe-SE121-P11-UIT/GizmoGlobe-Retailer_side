import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/localization/app_localization.dart';

import '../../../enums/processing/process_state_enum.dart';
import '../../../widgets/dialog/information_dialog.dart';
import '../../../widgets/general/gradient_text.dart';
import '../../../widgets/general/app_logo.dart';
import '../../../widgets/general/field_with_icon.dart';
import 'forget_password_cubit.dart';
import 'forget_password_state.dart';

class ForgetPasswordWebView extends StatefulWidget {
  const ForgetPasswordWebView({super.key});

  @override
  State<ForgetPasswordWebView> createState() => _ForgetPasswordWebViewState();
}

class _ForgetPasswordWebViewState extends State<ForgetPasswordWebView> {
  final TextEditingController _emailController = TextEditingController();
  ForgetPasswordCubit get cubit => context.read<ForgetPasswordCubit>();

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
                  text: S.of(context).forgetPasswordTitle,
                  fontSize: 32,
                ),
              ),
              const SizedBox(height: 8),

              // Description
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  S.of(context).forgetPasswordDescription,
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Form Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Email Label
                  Text(
                    S.of(context).emailAddress,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Email Field
                  FieldWithIcon(
                    controller: _emailController,
                    hintText: S.of(context).enterYourEmailAddress,
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
                  const SizedBox(height: 32),

                  // Send Verification Link Button with BLoC integration
                  BlocConsumer<ForgetPasswordCubit, ForgetPasswordState>(
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
                      } else if (state.processState == ProcessState.failure) {
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
                                  cubit.sendVerificationLink(
                                      _emailController.text.trim());
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
                                      S.of(context).sendingVerificationLink(
                                          _emailController.text.trim()),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  S.of(context).sendVerificationLink,
                                  style: const TextStyle(
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
                        S.of(context).rememberYourPassword,
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
