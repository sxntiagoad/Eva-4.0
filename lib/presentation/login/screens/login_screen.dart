import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/footer_wave.dart';
import '../../../shared/widgets/gap.dart';
import '../../../shared/widgets/wave_header.dart';
import '../../forgot_password/screens/forgot_password_screen.dart';
import '../../register/screens/register_screen.dart';
import '../service/sign_in_with_email_and_password.dart';
import '../widgets/login_form.dart';

class LoginScreen extends ConsumerWidget {
  static const name = 'login-screen';
  const LoginScreen({super.key});

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref
  ) {
    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    const WaveHeader(),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Inicio de Sesión',
                              style: AppTheme.customTitle(),
                            ),
                          ),
                          const Gap(20),
                          LoginForm(
                            formKey: formKey,
                            emailController: emailController,
                            passwordController: passwordController,
                          ),
                          const Gap(20),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                context.pushNamed(ForgotPasswordScreen.name);
                              },
                              child: const Text(
                                '¿Olvidaste tu contraseña?',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Stack(
                      children: [
                        const WaveFooter(
                          height: 200,
                        ),
                        Positioned(
                          bottom: 35,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          context.pushNamed(
                                            RegisterScreen.name,
                                          );
                                        },
                                        child: const Text(
                                          '¿Nuevo? Registrate aquí',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 80,
                                      ),
                                      FilledButton(
                                        style: AppTheme.buttonStyleLogin(),
                                        onPressed: () async{
                                          if (formKey.currentState
                                                  ?.validate() ==
                                              true) {
                                          
                                           await signInWithEmailAndPassword(
                                              context,
                                              emailController.text,
                                              passwordController.text,
                                              ref
                                            );

                                          }
                                        },
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 10,
                                          ),
                                          child: Text(
                                            'Comencemos',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
