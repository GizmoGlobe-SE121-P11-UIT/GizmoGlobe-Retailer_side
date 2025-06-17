import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/generated/l10n.dart';

import '../../../enums/processing/process_state_enum.dart';
import '../../../widgets/dialog/information_dialog.dart';
import '../../../widgets/general/gradient_text.dart';
import 'sign_in_cubit.dart';
import 'sign_in_state.dart';
import '../../../widgets/general/app_logo.dart';
import '../../../widgets/general/field_with_icon.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  static Widget newInstance() {
    return BlocProvider(
      create: (context) => SignInCubit(),
      child: const SignInScreen(),
    );
  }

  @override
  State<SignInScreen> createState() => _SignInScreen();
}

class _SignInScreen extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  SignInCubit get cubit => context.read<SignInCubit>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.symmetric(horizontal: 30),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                children: [
                  const SizedBox(height: 80),
                  const AppLogo(
                    alignment: Alignment.centerRight,
                  ),
                  const SizedBox(height: 32),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GradientText(
                        text: S.of(context).signIn, // Đăng nhập
                        fontSize: 32),
                  ),
                  const SizedBox(height: 30),
                  FieldWithIcon(
                    controller: _emailController,
                    hintText: S.of(context).yourEmail, // Email của bạn
                    fillColor: Theme.of(context).colorScheme.surface,
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    textColor: Theme.of(context).colorScheme.onSurface,
                    hintTextColor: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),  
                    onChanged: (value) {
                      cubit.emailChanged(value);
                    },
                  ),
                  const SizedBox(height: 16.0),
                  FieldWithIcon(
                    controller: _passwordController,
                    hintText: S.of(context).password, // Mật khẩu
                    fillColor: Theme.of(context).colorScheme.surface,
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    obscureText: true,
                    textColor: Theme.of(context).colorScheme.onSurface,
                    hintTextColor: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6), 
                    onChanged: (value) {
                      cubit.passwordChanged(value);
                    },
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/forget-password');
                      },
                      child: Text(
                        S.of(context).forgotPassword, // Quên mật khẩu?
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
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
                        showDialog(
                          context: context,
                          builder: (context) => InformationDialog(
                            title: state.dialogName.getLocalizedName(context),
                            content: state.message.getLocalizedMessage(context),
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, '/main');
                            },
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      if (state.processState == ProcessState.loading) {
                        return const CircularProgressIndicator();
                      }
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            cubit.signInWithEmailPassword(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                          ),
                          child: Text(S.of(context).signIn),
                        ),
                      );
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    S
                        .of(context)
                        .authorizedByAdmin, // Được cấp quyền bởi admin?
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/sign-up');
                    },
                    child: Text(
                      S.of(context).signUp, // Đăng ký
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
