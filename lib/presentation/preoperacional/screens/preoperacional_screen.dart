import 'package:eva/presentation/new_preoperacional/widgets/date_field.dart';
import 'package:eva/presentation/preoperacional/widgets/aceite_db_widget.dart';
import 'package:eva/presentation/preoperacional/widgets/inspeccion_db/list_category_db.dart';
import 'package:eva/presentation/preoperacional/widgets/kilometraje_db.dart';
import 'package:eva/presentation/preoperacional/widgets/observaciones_db.dart';
import 'package:eva/presentation/preoperacional/widgets/uptate_preoperacional.dart';
import 'package:eva/presentation/preoperacional/widgets/user_search_widget.dart';
import 'package:eva/providers/is_open.dart';
import 'package:eva/providers/preoperacionales_provider.dart';
import 'package:eva/providers/users_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/preoperacional.dart';
import '../../../providers/preoperacional_db_provider.dart';
import '../widgets/car_plate_db.dart';

import '../widgets/type_kid_db.dart';
import 'package:eva/presentation/preoperacional/widgets/preoperacional_date_field.dart';

class PreoperacionalScreen extends ConsumerStatefulWidget {
  final Preoperacional preoperacional;
  static const name = 'preoperacional-screen';
  const PreoperacionalScreen({
    required this.preoperacional,
    super.key,
  });

  @override
  ConsumerState<PreoperacionalScreen> createState() =>
      _PreoperacionalScreenState();
}

class _PreoperacionalScreenState extends ConsumerState<PreoperacionalScreen> {
  bool _isSaving = false;
  List<Map<String, dynamic>> _usuariosSeleccionados = [];

  void setSaving(bool value) {
    setState(() {
      _isSaving = value;
    });
  }


  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(preoperacionalDbProvider.notifier)
          .replacePreoperacional(widget.preoperacional);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isOpen = ref.watch(isOpenProvider);
    final usuariosFiltrados = ref.watch(userFilteredProvider);
    final preoperacional = ref.watch(preoperacionalDbProvider);

    return PopScope(
      canPop: !_isSaving,
      onPopInvoked: (didPop) {
        if (_isSaving) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Por favor, espere mientras se actualiza el preoperacional',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          ref.invalidate(allPreoperacionalesProvider);
        }
      },
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: const Text('Preoperacional'),
              actions: [
                IconButton(
                  onPressed: _isSaving
                      ? null
                      : () {
                          ref.read(isOpenProvider.notifier).state = !isOpen;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Actualizar y ${isOpen ? 'CERRAR' : 'dejar ABIERTO'}',
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
                ),
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
                        children: [
                          const SizedBox(height: 10),
                          
                          const SizedBox(height: 10),
                          const UserSearchWidget(),
                          const SizedBox(height: 10),
                          const CarPlateDb(),
                          const SizedBox(height: 15),
                          const TypeKidDbWidget(),
                          const SizedBox(height: 10),
                          const KilometrajeDbWidget(),
                          const SizedBox(height: 10),
                          const AceiteDbWidget(),
                          const SizedBox(height: 10),
                          PreoperacionalDateField(
                            label: 'Extracto',
                            icon: Icons.date_range,
                          ),
                          const Divider(),
                          const ListCategoryDb(),
                          const SizedBox(height: 100),
                          const Divider(),
                          const ObservacionesDbWidget(),
                          const SizedBox(height: 80),
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
              child: UpdatePreoperacional(onSavingStateChanged: setSaving),
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
                          'Actualizando preoperacional...\nPor favor, espere.',
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
