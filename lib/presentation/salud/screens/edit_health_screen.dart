import 'package:eva/core/excel/salud_generator.dart';
import 'package:eva/models/health_report.dart';
import 'package:eva/providers/salud/health_db_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/health_question_list.dart';
import '../widgets/save_health_report_button.dart';
import '../widgets/proyecto_item.dart';

class EditHealthScreen extends ConsumerStatefulWidget {
  final HealthReport health;
  static const name = 'edit-health-screen';

  const EditHealthScreen({
    required this.health,
    super.key,
  });

  @override
  ConsumerState<EditHealthScreen> createState() => _EditHealthScreenState();
}

class _EditHealthScreenState extends ConsumerState<EditHealthScreen> {
  bool _isSaving = false;

  void _onSavingStateChanged(bool value) {
    setState(() {
      _isSaving = value;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(healthDbProvider.notifier).replaceHealth(widget.health);
    });
  }

  Future<void> _saveHealthReport() async {
    setState(() => _isSaving = true);
    try {
      final healthDbNotifier = ref.read(healthDbProvider.notifier);
      await healthDbNotifier.updateHealthInFirebase();

      await healthDataJson(
        ref: ref,
        healthReport: ref.read(healthDbProvider),
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Autoreporte guardado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final healthReport = ref.watch(healthDbProvider);

    return WillPopScope(
      onWillPop: () async {
        if (_isSaving) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Guardando reporte... Por favor, espere.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Editar Autoreporte de Salud'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: IconButton(
                icon: Icon(
                  healthReport.isOpen ? Icons.lock_open_rounded : Icons.lock_rounded,
                  color: healthReport.isOpen ? Colors.green : Colors.red,
                ),
                onPressed: _isSaving
                    ? null
                    : () {
                        ref.read(healthDbProvider.notifier).updateIsOpen(!healthReport.isOpen);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              healthReport.isOpen ? 'Autoreporte cerrado' : 'Autoreporte abierto',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            backgroundColor: healthReport.isOpen ? Colors.red : Colors.green,
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
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Instrucciones:',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Marque para cada día de la semana si presentó alguna de las siguientes condiciones:',
                                style: TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.green,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('No'),
                                  const SizedBox(width: 16),
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.red,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('Si'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ProyectoItem(
                        healthReport: healthReport,
                        onSelectedValueUpdate: (newValue) {
                          ref.read(healthDbProvider.notifier).updateSelectedValue(newValue);
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              HealthQuestionsList(
                onAnswerUpdate: (questionId, day, value) {
                  ref.read(healthDbProvider.notifier).updateDayOfWeek(questionId, day, value);
                },
                healthReport: healthReport,
              ),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SaveHealthReportButton(
            onSavingStateChanged: _onSavingStateChanged,
            ignoreValidation: true,
            onSave: _saveHealthReport,
          ),
        ),
        // Fixed the if statement syntax here by using bottomSheet
        bottomSheet: _isSaving
            ? Container(
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
                            'Guardando reporte de salud...\nPor favor, espere.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            : null,
      ),
    );
  }
}