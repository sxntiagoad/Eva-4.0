import 'package:eva/presentation/salud/widgets/health_question_list.dart';
import 'package:eva/presentation/salud/widgets/proyecto_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/salud/new_health_report_provider.dart';
import '../widgets/save_health_report_button.dart';
import '../../../core/excel/salud_generator.dart';

class NewHealthReportScreen extends ConsumerStatefulWidget {
  static const name = 'new-health-report-screen';

  const NewHealthReportScreen({super.key});

  @override
  ConsumerState<NewHealthReportScreen> createState() =>
      _NewHealthReportScreenState();
}

class _NewHealthReportScreenState extends ConsumerState<NewHealthReportScreen> {
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(newHealthReportProvider.notifier).reset();
    });
  }

  void _onSavingStateChanged(bool value) {
    setState(() {
      _isSaving = value;
    });
  }

  Future<void> _saveHealthReport() async {
    setState(() => _isSaving = true);
    try {
      final healthReportNotifier = ref.read(newHealthReportProvider.notifier);
      await healthReportNotifier.saveHealthReport();

      await healthDataJson(
        ref: ref,
        healthReport: ref.read(newHealthReportProvider),
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
    final healthReport = ref.watch(newHealthReportProvider);

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
          title: const Text('Nuevo Autoreporte de Salud'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: IconButton(
                icon: Icon(
                  healthReport.isOpen
                      ? Icons.lock_open_rounded
                      : Icons.lock_rounded,
                  color: healthReport.isOpen ? Colors.green : Colors.red,
                ),
                onPressed: _isSaving
                    ? null
                    : () {
                        ref
                            .read(newHealthReportProvider.notifier)
                            .toggleIsOpen();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              healthReport.isOpen
                                  ? 'Autoreporte cerrado'
                                  : 'Autoreporte abierto',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            backgroundColor:
                                healthReport.isOpen ? Colors.red : Colors.green,
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
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Instrucciones:',
                            style:
                                Theme.of(context).textTheme.titleLarge?.copyWith(
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
                              const Text('Si'),
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
                              const Text('No'),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ProyectoItem(
                            healthReport: healthReport,
                            onSelectedValueUpdate: (newValue) {
                              ref.read(newHealthReportProvider.notifier).updateSelectedValue(newValue);
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              HealthQuestionsList(
                healthReport: healthReport,
                onAnswerUpdate: (questionId, day, value) {
                  ref
                      .read(newHealthReportProvider.notifier)
                      .updateDayOfWeek(questionId, day, value);
                },
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
            onSave: _saveHealthReport,
          ),
        ),
        // Fixed the if statement syntax here
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