import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:eva/models/car.dart';
import 'package:eva/models/firebase_file.dart';
import 'package:eva/providers/excel_provider.dart';
import 'package:eva/providers/firebase_api.dart';
import 'package:intl/intl.dart';

class CarPos extends ConsumerStatefulWidget {
  final Car car;

  const CarPos({required this.car, super.key});

  @override
  ConsumerState<CarPos> createState() => _CarPosState();
}

class _CarPosState extends ConsumerState<CarPos> {
  @override
  void initState() {
    super.initState();
    // Limpiar selección cuando la página se inicia
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(selectedFilesProvider.notifier).clearSelection();
    });
  }

  @override
  Widget build(BuildContext context) {
    final relevantExcelFiles =
        ref.watch(relevantExcelFilesProvider(widget.car.carPlate));
    final selectedFiles = ref.watch(selectedFilesProvider);

    void refreshData() {
      ref.invalidate(excelFilesProvider);
      ref.invalidate(preoperacionalByUidProvider);
      ref.invalidate(carByIdProvider);
      ref.invalidate(userByIdProvider);
      ref.read(refreshTriggerProvider.notifier).state++;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade50,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.car.carPlate,
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900)),
            Text('Preoperacionales',
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
              color:
                  selectedFiles.isNotEmpty ? Colors.blue.shade700 : Colors.grey,
            ),
            onPressed: selectedFiles.isNotEmpty
                ? () async {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Confirmar eliminación'),
                        content: Text(
                            '¿Estás seguro de eliminar ${selectedFiles.length} archivos?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancelar'),
                          ),
                          FilledButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              try {
                                await deleteSelectedFiles(ref);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).clearSnackBars();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Archivos eliminados correctamente'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                                refreshData();
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).clearSnackBars();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error al eliminar archivos: $e'),
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
        child: relevantExcelFiles.when(
          data: (relevantFiles) {
            if (relevantFiles.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.assignment_outlined,
                        size: 100, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      'No hay preoperacionales',
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

            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade50, Colors.white],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  margin: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total de preoperacionales',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${relevantFiles.length}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade900,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.check_circle,
                                      size: 16, color: Colors.green.shade700),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Abiertos: ${relevantFiles.where((f) => f['isOpen']).length}',
                                    style: TextStyle(
                                      color: Colors.green.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(Icons.cancel,
                                      size: 16, color: Colors.red.shade700),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Cerrados: ${relevantFiles.where((f) => !f['isOpen']).length}',
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: relevantFiles.length,
                    itemBuilder: (context, index) {
                      final fileInfo = relevantFiles[index];
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
                                    ? Colors.green
                                    : Colors.red,
                                width: 4,
                              ),
                            ),
                          ),
                          child: ListTile(
                            onTap: () {
                              ref
                                  .read(selectedFilesProvider.notifier)
                                  .toggleSelection(fileInfo['fileName']);
                            },
                            leading: Checkbox(
                              value: isSelected,
                              activeColor: Colors.blue,
                              onChanged: (bool? value) {
                                ref
                                    .read(selectedFilesProvider.notifier)
                                    .toggleSelection(fileInfo['fileName']);
                              },
                            ),
                            title: Text(
                              fileInfo['userName'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
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
                                      _formatDate(fileInfo['finalDate'],
                                          fileInfo['initDate']),
                                      style: TextStyle(
                                          color: Colors.blue.shade700),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: fileInfo['isOpen']
                                        ? Colors.green.shade50
                                        : Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: fileInfo['isOpen']
                                          ? Colors.green.shade300
                                          : Colors.red.shade300,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        fileInfo['isOpen']
                                            ? Icons.lock_open
                                            : Icons.lock_outline,
                                        size: 12,
                                        color: fileInfo['isOpen']
                                            ? Colors.green.shade700
                                            : Colors.red.shade700,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        fileInfo['isOpen']
                                            ? 'Abierto'
                                            : 'Cerrado',
                                        style: TextStyle(
                                          color: fileInfo['isOpen']
                                              ? Colors.green.shade700
                                              : Colors.red.shade700,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                    icon: const Icon(Icons.file_download),
                    onPressed: () async {
                      final firebaseFile = await _getFirebaseFile(fileInfo['fileName']);
                      if (firebaseFile != null) {
                        await _downloadFile(firebaseFile, context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Error al obtener el archivo')),
                        );
                      }
                    },
                  ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Cargando preoperacionales...'),
              ],
            ),
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

  String _formatDate(String finalDate, String initDate) {
    try {
      final dateToUse = finalDate.isNotEmpty ? finalDate : initDate;
      final date = DateTime.parse(dateToUse);
      final dateFormat = DateFormat('dd MMM yyyy HH:mm:ss');
      return dateFormat.format(date);
    } catch (e) {
      return finalDate.isNotEmpty ? finalDate : initDate;
    }
  }

  Future<FirebaseFile?> _getFirebaseFile(String fileName) async {
    try {
      final ref = FirebaseStorage.instance.ref().child('preoperacionales/$fileName');
      final url = await ref.getDownloadURL();
      return FirebaseFile(ref: ref, name: fileName, url: url);
    } catch (e) {
      return null;
    }
  }

  Future _downloadFile(FirebaseFile file, BuildContext context) async {
    try {
      await FirebaseApi.downloadFile(file.ref);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Archivo descargado: ${file.name}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al descargar archivo: $e')),
      );
    }
  }
}