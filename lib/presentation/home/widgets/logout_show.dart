import 'package:eva/presentation/login/screens/login_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

Future<void> showLogoutDialog(BuildContext context) async {
  final FirebaseAuth auth = FirebaseAuth.instance;

  return showCupertinoDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: const Text('Confirmar Cierre de Sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: <Widget>[
          CupertinoDialogAction(
            child: const Text('Cancelar'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          CupertinoDialogAction(
            child: const Text(
              'Cerrar Sesión',
              style: TextStyle(color: Colors.red,),
            ),
            onPressed: () async {
              await auth.signOut();

              if (context.mounted) {
                GoRouter.of(context).goNamed(LoginScreen.name);

                Navigator.of(context).pop();
              }
            },
          ),
        ],
      );
    },
  );
}
