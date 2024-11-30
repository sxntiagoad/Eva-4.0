import 'package:eva/presentation/home/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

Future<void> signInWithEmailAndPassword(
    BuildContext context, String email, String password,WidgetRef ref) async {
  try {
   
    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    

  
    if (userCredential.user != null && context.mounted) {
      // ref.invalidate()
      context.goNamed(HomeScreen
          .name,); 
    }
  } on FirebaseAuthException catch (e) {
    String errorMessage;

    // Manejo de errores
    if (e.code == 'user-not-found') {
      errorMessage = 'No se encontró un usuario con ese email.';
    } else if (e.code == 'wrong-password') {
      errorMessage = 'Contraseña incorrecta.';
    } else {
      errorMessage = 'Error al iniciar sesión. Por favor, intenta de nuevo.';
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorMessage,
          ),
        ),
      );
    }
  }
}
