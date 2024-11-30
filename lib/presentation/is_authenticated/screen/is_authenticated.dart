import 'package:eva/presentation/home/screens/home_screen.dart';
import 'package:eva/presentation/login/screens/login_screen.dart';
import 'package:eva/shared/widgets/footer_wave.dart';
import 'package:eva/shared/widgets/wave_header.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class IsAuthenticated extends StatefulWidget {
  static const name = 'is-authenticated';
  const IsAuthenticated({super.key});

  @override
  IsAuthenticatedState createState() => IsAuthenticatedState();
}

class IsAuthenticatedState extends State<IsAuthenticated> {
  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  void _checkAuthentication() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(seconds: 1));
      final FirebaseAuth auth = FirebaseAuth.instance;
      final User? user = auth.currentUser;

      if (user != null && mounted) {
        GoRouter.of(context).goNamed(HomeScreen.name);
      } else {
        if (mounted) {
          GoRouter.of(context).goNamed(LoginScreen.name);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const WaveHeader(),
          const Spacer(),
          Image.asset(
            'assets/logo_eva.png',
            height: 200,
            width: 200,
            fit: BoxFit.contain,
          ),
          const Spacer(),
          const WaveFooter(height: 100),
        ],
      ),
    );
  }
}
