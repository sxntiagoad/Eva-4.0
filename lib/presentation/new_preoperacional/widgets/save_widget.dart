import 'package:eva/core/excel/excel_generator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/is_open.dart';
import '../../../providers/new_preoperacional_provider.dart';
import '../../../providers/add_preoperacional.dart';
import '../../home/screens/home_screen.dart';

class SaveWidget extends ConsumerStatefulWidget {
  final Function(bool) onSavingStateChanged;
  
  const SaveWidget({
    required this.onSavingStateChanged,
    super.key,
  });

  @override
  SaveWidgetState createState() => SaveWidgetState();
}

class SaveWidgetState extends ConsumerState<SaveWidget> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final isOpen = ref.watch(isOpenProvider);

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isOpen ? Colors.green : Colors.red,
      ),
      onPressed: _isLoading
          ? null
          : () async {
              ref.read(newPreoperacionalProvider.notifier).updateIsOpen(isOpen);
              setState(() {
                _isLoading = true;
              });
              widget.onSavingStateChanged(true); // Indicar inicio de guardado

              try {
                ref.read(newPreoperacionalProvider.notifier).updateFechas(isOpen);
                final String idDoc = await addPreoperacional(
                      ref.read(newPreoperacionalProvider),
                      ref,
                    ) ??
                    '';
                await dataJson(
                  ref: ref,
                  preoperacional: ref.read(
                    newPreoperacionalProvider,
                  ),
                  idDoc: idDoc,
                );
                if (context.mounted) {
                  context.goNamed(HomeScreen.name);
                }
              } finally {
                setState(() {
                  _isLoading = false;
                });
                widget.onSavingStateChanged(false); // Indicar fin de guardado
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Preoperacional guardado ${isOpen ? 'abierto' : 'cerrado'}',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: isOpen ? Colors.green : Colors.red,
                      duration: const Duration(seconds: 4),
                    ),
                  );
                }
              }
            },
      child: _isLoading
          ? const CupertinoActivityIndicator()
          : Text(
              isOpen ? 'Guardar abierto' : 'Guardar y cerrar',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }
}
