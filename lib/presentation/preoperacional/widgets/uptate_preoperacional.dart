import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/excel/excel_generator.dart';
import '../../../providers/is_open.dart';
import '../../../providers/preoperacional_db_provider.dart';
import '../../home/screens/home_screen.dart';
import '../service/update_preoperacional.dart';

class UpdatePreoperacional extends ConsumerStatefulWidget {
  final Function(bool) onSavingStateChanged;

  const UpdatePreoperacional({
    required this.onSavingStateChanged,
    super.key,
  });

  @override
  SaveWidgetState createState() => SaveWidgetState();
}

class SaveWidgetState extends ConsumerState<UpdatePreoperacional> {
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
              ref.read(preoperacionalDbProvider.notifier).updateIsOpen(isOpen);
              setState(() {
                _isLoading = true;
              });
              widget.onSavingStateChanged(true);

              try {
                ref
                    .read(preoperacionalDbProvider.notifier)
                    .updateFechas(isOpen);
                await updatePreoperacional(
                  ref.read(preoperacionalDbProvider),
                  ref,
                );
                await dataJson(
                  ref: ref,
                  preoperacional: ref.read(
                    preoperacionalDbProvider,
                  ),
                );

                if (context.mounted) {
                  context.goNamed(HomeScreen.name);
                }
              } finally {
                setState(() {
                  _isLoading = false;
                });
                widget.onSavingStateChanged(false);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Preoperacional actualizado ${isOpen ? 'abierto' : 'cerrado'}',
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
              isOpen ? 'Actualizar abierto' : 'Actualizar y cerrar',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }
}
