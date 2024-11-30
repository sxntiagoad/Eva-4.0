import 'package:eva/presentation/login/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Asegúrate de tener el paquete go_router importado
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/footer_wave.dart';
import '../../../shared/widgets/gap.dart';
import '../../../shared/widgets/wave_pop.dart';
import 'package:eva/models/mi_user.dart';
import 'package:eva/presentation/register/services/register_user.dart';

class RegisterScreen extends StatefulWidget {
  static const name = 'register-screen';
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final formKey = GlobalKey<FormState>();
  String fullName = '';
  String email = '';
  String password = '';
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

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
                    WavePop(
                      topPadding: topPadding,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: formKey,
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Registro',
                                style: AppTheme.customTitle(),
                              ),
                            ),
                            const Gap(20),
                            TextFormField(
                              initialValue: fullName,
                              decoration: const InputDecoration(
                                labelText: 'Nombre completo',
                              ),
                              onChanged: (value) {
                                fullName = value;
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingrese su nombre completo';
                                }
                                return null;
                              },
                            ),
                            const Gap(10),
                            TextFormField(
                              initialValue: email,
                              decoration:
                                  const InputDecoration(labelText: 'Email'),
                              onChanged: (value) {
                                email = value;
                              },
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    !value.contains('@')) {
                                  return 'Por favor ingrese un email válido';
                                }
                                return null;
                              },
                            ),
                            const Gap(10),
                            TextFormField(
                              initialValue: password,
                              decoration: const InputDecoration(
                                labelText: 'Contraseña',
                              ),
                              obscureText: true,
                              onChanged: (value) {
                                setState(() {
                                  password = value;
                                });
                              },
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    value.length < 6) {
                                  return 'La contraseña debe tener al menos 6 caracteres';
                                }
                                return null;
                              },
                            ),
                            const Gap(10),
                          ],
                        ),
                      ),
                    ),
                    const Gap(10),
                    const Spacer(),
                    Stack(
                      children: [
                        const WaveFooter(height: 200),
                        Positioned(
                          right: 16,
                          bottom: 45,
                          child: FilledButton(
                            style: AppTheme.buttonStyleLogin(),
                            onPressed: () async {
                              if (formKey.currentState?.validate() == true) {
                                setState(() {
                                  isLoading = true;
                                });

                                try {
                                  await registerUser(
                                    MyUser(
                                      fullName: fullName,
                                      email: email,
                                      role: 'CONDUCTOR',
                                   
                                      password: password,
                                    ),
                                  );
                                  // Redirigir a la pantalla de inicio
                                  if (context.mounted) {
                                    context.pushNamed(LoginScreen.name);
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Error al registrar el usuario'),
                                      ),
                                    );
                                  }
                                } finally {
                                  setState(() {
                                    isLoading = false;
                                  });
                                }
                              }
                            },
                            child: isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  )
                                : const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Text(
                                      'Regístrate',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
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
