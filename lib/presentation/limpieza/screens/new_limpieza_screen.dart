import 'package:eva/core/excel/limpieza_generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/car_selector.dart';
import '../widgets/list_category.dart';
import '../../../providers/limpieza/new_limpieza_provider.dart';

class NewLimpiezaScreen extends ConsumerStatefulWidget {
  static const name = 'new-limpieza-screen';
  const NewLimpiezaScreen({super.key});

  @override
  ConsumerState<NewLimpiezaScreen> createState() => _NewLimpiezaScreenState();
}

class _NewLimpiezaScreenState extends ConsumerState<NewLimpiezaScreen> {
  bool _isSaving = false;

  void setSaving(bool value) {
    setState(() {
      _isSaving = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final limpieza = ref.watch(newLimpiezaProvider);

    return PopScope(
      canPop: !_isSaving,
      onPopInvoked: (didPop) {
        if (_isSaving) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Por favor, espere mientras se guarda la limpieza',
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
              title: const Text('Nuevo Chequeo de Limpieza'),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: IconButton(
                    icon: Icon(
                      limpieza.isOpen ? Icons.lock_open_rounded : Icons.lock_rounded,
                      color: limpieza.isOpen ? Colors.green : Colors.red,
                    ),
                    onPressed: _isSaving
                        ? null
                        : () {
                            ref.read(newLimpiezaProvider.notifier).toggleIsOpen();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  limpieza.isOpen
                                      ? 'Cerrando chequeo de limpieza...'
                                      : 'Abriendo chequeo de limpieza...',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                backgroundColor: !limpieza.isOpen
                                    ? Colors.green
                                    : Colors.red,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                  ),
                ),
              ],
            ),
            body: AbsorbPointer(
              absorbing: _isSaving,
              child: CustomScrollView(
                slivers: [
                  const SliverPadding(
                    padding: EdgeInsets.all(16.0),
                    sliver: SliverToBoxAdapter(
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CarSelector(),
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  ListCategory(
                    onUpdateInspeccion: (category, day, value) {
                      ref.read(newLimpiezaProvider.notifier).updateDayOfWeek(
                            category,
                            day,
                            value,
                          );
                    },
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
              ),
            ),
            bottomNavigationBar: SaveButtonLimpieza(onSavingStateChanged: setSaving),
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
                          'Guardando limpieza...\nPor favor, espere.',
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

class SaveButtonLimpieza extends ConsumerStatefulWidget {
  final Function(bool) onSavingStateChanged;

  const SaveButtonLimpieza({
    required this.onSavingStateChanged,
    super.key,
  });

  @override
  SaveButtonLimpiezaState createState() => SaveButtonLimpiezaState();
}

class SaveButtonLimpiezaState extends ConsumerState<SaveButtonLimpieza> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final limpieza = ref.watch(newLimpiezaProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        height: 60,
        child: FilledButton(
          onPressed: limpieza.carId.isEmpty || isLoading
              ? null
              : () async {
                  setState(() {
                    isLoading = true;
                  });
                  widget.onSavingStateChanged(true);

                  try {
                    final docId = await ref
                            .read(newLimpiezaProvider.notifier)
                            .saveLimpieza() ??
                        '';

                    try {
                      await limpiezaDataJson(
                        ref: ref,
                        limpieza: ref.read(newLimpiezaProvider),
                        idDoc: docId,
                      );

                      if (context.mounted) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text('Limpieza guardada correctamente'),
                          backgroundColor: Colors.blue,
                        ));

                        ref.read(newLimpiezaProvider.notifier).reset();
                        context.pop();
                      }
                    } catch (excelError) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              'La limpieza se guardó pero hubo un error al generar el Excel: $excelError'),
                          backgroundColor: Colors.orange,
                        ));
                        context.pop();
                      }
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Error al guardar: $e'),
                        backgroundColor: Colors.red,
                      ));
                    }
                  } finally {
                    setState(() {
                      isLoading = false;
                    });
                    widget.onSavingStateChanged(false);
                  }
                },
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
              if (states.contains(WidgetState.disabled)) {
                return Colors.grey;
              }
              return limpieza.isOpen ? Colors.green : Colors.red;
            }),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                )
              : Text(
                  limpieza.isOpen
                      ? 'Guardar Limpieza (Abierta)'
                      : 'Guardar Limpieza (Cerrada)',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}
