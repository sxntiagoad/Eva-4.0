import 'package:eva/models/firebase_file.dart';
import 'package:eva/providers/firebase_api.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eva/providers/salud/salud_file_provider.dart';
import 'package:intl/intl.dart';

class UserHealthReports extends ConsumerStatefulWidget {
  final String userId;
  final String userName;

  const UserHealthReports({
    required this.userId,
    required this.userName,
    super.key,
  });

  @override
  ConsumerState<UserHealthReports> createState() => _UserHealthReportsState();
}

class _UserHealthReportsState extends ConsumerState<UserHealthReports> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(selectedHealthFilesProvider.notifier).clearSelection();
    });
  }

  @override
  Widget build(BuildContext context) {
    final healthFiles = ref.watch(healthReportFilesProvider(widget.userId));
    final selectedFiles = ref.watch(selectedHealthFilesProvider);

    void refreshData() {
      ref.invalidate(healthReportFilesProvider);
      ref.read(refreshTriggerProvider.notifier).state++;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade50,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reportes de Salud',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900)),
            Text('Usuario: ${widget.userName}',
                style: TextStyle(fontSize: 14, color: Colors.blue.shade700)),
          ],
        ),
        actions: [
          if (selectedFiles.isNotEmpty)
            Chip(
              label: Text('${selectedFiles.length} seleccionados',
                  style: const TextStyle(color: Colors.white)),
              backgroundColor: Colors.blue.shade600,
            ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.blue.shade700),
            onPressed: refreshData,
            tooltip: 'Actualizar datos',
          ),
          IconButton(
            icon: Icon(
              Icons.delete,
              color: selectedFiles.isNotEmpty
                  ? Colors.blue.shade700
                  : Colors.grey,
            ),
            onPressed: selectedFiles.isNotEmpty
                ? () async {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Confirmar eliminación'),
                        content: Text(
                            '¿Estás seguro de eliminar ${selectedFiles.length} registros?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancelar'),
                          ),
                          FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: () async {
                              try {
                                Navigator.pop(context);
                                await deleteSelectedHealthFiles(ref);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context)
                                      .clearSnackBars();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Registros eliminados correctamente'),
                                      backgroundColor: Colors.green,
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }
                                refreshData();
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context)
                                      .clearSnackBars();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Error al eliminar registros: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                            child: const Text('Eliminar'),
                          ),
                        ],
                      ),
                    );
                  }
                : null,
            tooltip: 'Eliminar seleccionados',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => refreshData(),
        child: healthFiles.when(
          data: (files) {
            if (files.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.health_and_safety_outlined,
                        size: 100, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      'No hay reportes de salud',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: refreshData,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Actualizar'),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: files.length,
              itemBuilder: (context, index) {
                final fileInfo = files[index];
                final isSelected =
                    selectedFiles.contains(fileInfo['fileName']);
                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 4),
                  elevation: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: fileInfo['isOpen']
                              ? Colors.green.shade600
                              : Colors.red.shade600,
                          width: 4,
                        ),
                      ),
                    ),
                    child: ListTile(
                      onTap: () {
                        ref
                            .read(selectedHealthFilesProvider.notifier)
                            .toggleSelection(fileInfo['fileName']);
                      },
                      leading: Checkbox(
                        value: isSelected,
                        activeColor: Colors.blue,
                        onChanged: (bool? value) {
                          ref
                              .read(selectedHealthFilesProvider.notifier)
                              .toggleSelection(fileInfo['fileName']);
                        },
                      ),
                      title: Row(
                        children: [
                          Text(
                            'Reporte de Salud',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: fileInfo['isOpen']
                                  ? Colors.green.shade50
                                  : Colors.red.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: fileInfo['isOpen']
                                    ? Colors.green.shade200
                                    : Colors.red.shade200,
                              ),
                            ),
                            child: Text(
                              fileInfo['isOpen']
                                  ? 'Completada'
                                  : 'Pendiente',
                              style: TextStyle(
                                fontSize: 12,
                                color: fileInfo['isOpen']
                                    ? Colors.green.shade700
                                    : Colors.red.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.calendar_today,
                                  size: 14, color: Colors.blue.shade300),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat('dd MMM yyyy HH:mm')
                                    .format(fileInfo['fecha']),
                                style: TextStyle(
                                    color: Colors.blue.shade700),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        icon: const Icon(Icons.file_download, size: 18),
                        label: const Text('Descargar'),
                        onPressed: () async {
                          try {
                            final firebaseFile =
                                await _getFirebaseFile(fileInfo['fileName']);
                            if (firebaseFile != null) {
                              await _downloadFile(firebaseFile, context);

                              if (context.mounted) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                    content: Text('Archivo descargado'),
                                    backgroundColor: Colors.green,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context)
                                  .clearSnackBars();
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                SnackBar(
                                  content: Text(e.toString()),
                                  backgroundColor: Colors.red,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: $error'),
                ElevatedButton.icon(
                  onPressed: refreshData,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<FirebaseFile?> _getFirebaseFile(String fileName) async {
    try {
      final ref =
          FirebaseStorage.instance.ref().child('reportes_salud/$fileName');
      final url = await ref.getDownloadURL();
      return FirebaseFile(ref: ref, name: fileName, url: url);
    } catch (e) {
      return null;
    }
  }

  Future<void> _downloadFile(FirebaseFile file, BuildContext context) async {
    try {
      await FirebaseApi.downloadFile(file.ref);
    } catch (e) {
      throw Exception('Error al descargar archivo: $e');
    }
  }
}