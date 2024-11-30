import 'package:eva/presentation/new_preoperacional/widgets/kilometraje.dart';
import 'package:eva/presentation/new_preoperacional/widgets/observaciones.dart';
import 'package:eva/providers/is_open.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/carplate.dart';
import '../widgets/inspecciones/list_category.dart';
import '../widgets/save_widget.dart';
import '../widgets/type_kid_widget.dart';

class NewPreoperacionalScree extends ConsumerStatefulWidget {
  static const name = 'new-preoperacional-screen';
  const NewPreoperacionalScree({super.key});

  @override
  ConsumerState<NewPreoperacionalScree> createState() => _NewPreoperacionalScreeState();
}

class _NewPreoperacionalScreeState extends ConsumerState<NewPreoperacionalScree> {
  bool _isSaving = false;

  void setSaving(bool value) {
    setState(() {
      _isSaving = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isOpen = ref.watch(isOpenProvider);

    return PopScope(
      canPop: !_isSaving,
      onPopInvoked: (didPop) {
        if (_isSaving) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Por favor, espere mientras se guarda el preoperacional',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              title: const Text('Nuevo preoperacional'),
              actions: [
                IconButton(
                  onPressed: _isSaving 
                    ? null 
                    : () {
                        ref.read(isOpenProvider.notifier).state = !isOpen;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Guardar y ${isOpen ? 'CERRAR' : 'dejar ABIERTO'}',
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            backgroundColor: isOpen ? Colors.red : Colors.green,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                  icon: isOpen
                      ? const Icon(
                          Icons.lock_open,
                          color: Colors.green,
                        )
                      : const Icon(
                          Icons.lock_outline_rounded,
                          color: Colors.red,
                        ),
                )
              ],
            ),
            body: Column(
              children: [
                Expanded(
                  child: AbsorbPointer(
                    absorbing: _isSaving,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ListView(
                        children: const [
                          SizedBox(height: 10),
                          CarPlate(),
                          SizedBox(height: 10),
                          TypeKidWidget(),
                          SizedBox(height: 10),
                          KilometrajeWidget(),
                          SizedBox(height: 10),
                          ListCategory(),
                          ObservacionesWidget(),
                          SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            bottomNavigationBar: Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SaveWidget(onSavingStateChanged: setSaving),
            ),
          ),
          if (_isSaving)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 20),
                        Text(
                          'Guardando preoperacional...\nPor favor, espere.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
