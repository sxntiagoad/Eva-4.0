
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

class LogoutConfirmationDialog {
  static void showLogoutDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Cerrar sesión'),
          content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
          actions: <Widget>[
            CupertinoDialogAction(
              child: const Text('Cancelar'),
              onPressed: () {
                context.pop();
              },
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () {
                context.pop();
                

                // Lógica para cerrar sesión
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }
}
