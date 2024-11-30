import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../models/limpieza.dart';
import '../../../providers/limpieza/limpieza_db_provider.dart';
import '../widgets/car_selector.dart';
import '../widgets/list_category.dart';
import '../../../core/excel/limpieza_generator.dart';

class EditLimpiezaScreen extends ConsumerStatefulWidget {
  final Limpieza limpieza;
  static const name = 'edit-limpieza-screen';
  
  const EditLimpiezaScreen({
    required this.limpieza,
    super.key,
  });

  @override
  ConsumerState<EditLimpiezaScreen> createState() => _EditLimpiezaScreenState();
}

class _EditLimpiezaScreenState extends ConsumerState<EditLimpiezaScreen> {
  bool _isSaving = false;

  void setSaving(bool value) {
    setState(() {
      _isSaving = value;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(limpiezaDbProvider.notifier).replaceLimpieza(widget.limpieza);
    });
  }

  @override
  Widget build(BuildContext context) {
    final limpieza = ref.watch(limpiezaDbProvider);

    return PopScope(
      canPop: !_isSaving,
      onPopInvoked: (didPop) {
        if (_isSaving) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Por favor, espere mientras se actualiza la limpieza',
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
              title: const Text('Editar Limpieza'),
              actions: [
                IconButton(
                  icon: Icon(
                    limpieza.isOpen ? Icons.lock_open : Icons.lock,
                    color: limpieza.isOpen ? Colors.green : Colors.red,
                  ),
                  onPressed: _isSaving
                      ? null
                      : () {
                          ref.read(limpiezaDbProvider.notifier).updateIsOpen(!limpieza.isOpen);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                limpieza.isOpen ? 'Cerrando limpieza...' : 'Abriendo limpieza...',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              backgroundColor: !limpieza.isOpen ? Colors.green : Colors.red,
                            ),
                          );
                        },
                ),
              ],
            ),
            body: AbsorbPointer(
              absorbing: _isSaving,
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.all(16.0),
                    sliver: SliverToBoxAdapter(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: CarSelector(
                            selectedCarId: limpieza.carId,
                            onCarSelected: (carId) {
                              ref.read(limpiezaDbProvider.notifier).updateCarId(carId);
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 16),
                  ),
                  
                  ListCategory(
                    inspecciones: limpieza.inspecciones,
                    onUpdateInspeccion: (category, day, value) {
                      ref.read(limpiezaDbProvider.notifier).updateInspeccion(category, day, value);
                    },
                  ),
                  
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 80),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                height: 60,
                child: FilledButton(
                  onPressed: _isSaving
                      ? null
                      : () async {
                          setState(() => _isSaving = true);
                          try {
                            await ref.read(limpiezaDbProvider.notifier).updateLimpiezaInFirebase();
                            
                            try {
                              await limpiezaDataJson(
                                ref: ref,
                                limpieza: ref.read(limpiezaDbProvider),
                                idDoc: widget.limpieza.docId,
                              );

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Limpieza actualizada correctamente'),
                                    backgroundColor: Colors.blue,
                                  ),
                                );
                                context.pop();
                              }
                            } catch (excelError) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'La limpieza se actualizó pero hubo un error al actualizar el Excel: $excelError'
                                    ),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                                context.pop();
                              }
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error al actualizar: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } finally {
                            if (mounted) setState(() => _isSaving = false);
                          }
                        },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                      if (states.contains(WidgetState.disabled)) return Colors.grey;
                      return limpieza.isOpen ? Colors.green : Colors.red;
                    }),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 30,
                          height: 30,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : Text(
                          limpieza.isOpen ? 'Actualizar (Abierta)' : 'Actualizar (Cerrada)',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
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
                          'Actualizando limpieza...\nPor favor, espere.',
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