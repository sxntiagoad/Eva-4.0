import 'package:eva/core/theme/app_theme.dart';
import 'package:eva/models/car.dart';
import 'package:eva/models/firebase_file.dart';
import 'package:eva/presentation/preoperacional/screens/preoperacional_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:dio/dio.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../models/preoperacional.dart';
import '../../../providers/car_provider.dart';
import '../../../providers/firebase_api.dart';

class PreoperacionalesCard extends ConsumerWidget {
  final Preoperacional preoperacional;
  const PreoperacionalesCard({
    super.key,
    required this.preoperacional,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapCars = ref.watch(mapCarsProvider);
    return mapCars.when(
      data: (data) => _ListTitlePreoperacional(
        preoperacional: preoperacional,
        data: data,
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}

class _ListTitlePreoperacional extends StatefulWidget {
  final Preoperacional preoperacional;
  final Map<String, Car> data;

  const _ListTitlePreoperacional({
    required this.preoperacional,
    required this.data,
  });

  @override
  _ListTitlePreoperacionalState createState() =>
      _ListTitlePreoperacionalState();
}

class _ListTitlePreoperacionalState extends State<_ListTitlePreoperacional> {
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    if (!kIsWeb) {
      if (await Permission.storage.request().isGranted) {
        // Permiso concedido
      } else {
        // Permiso denegado
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permiso de almacenamiento denegado'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _downloadFile() async {
    if (_isDownloading) return;
    setState(() => _isDownloading = true);

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('preoperacionales/${widget.preoperacional.docId}.xlsx');

      final url = await ref.getDownloadURL();

      if (!mounted) return;

      if (kIsWeb) {
        final firebaseFile =
            await _getFirebaseFile(widget.preoperacional.docId);
        if (firebaseFile != null) {
          await downloadFile(firebaseFile, context);

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Archivo descargado'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else if (Platform.isAndroid || Platform.isIOS) {
        await FileDownloader.downloadFile(
            url: url,
            name: 'preoperacional_${widget.preoperacional.docId}.xlsx',
            onDownloadCompleted: (path) async {
              if (!mounted) return;

              try {
                final result = await OpenFile.open(path);

                if (result.type != ResultType.done) {
                  throw Exception(
                      'No se pudo abrir el archivo: ${result.message}');
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Archivo abierto correctamente'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error al abrir el archivo: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            onDownloadError: (error) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error al descargar: $error'),
                  backgroundColor: Colors.red,
                ),
              );
            });
      } else {
        // Lanzar la URL en el navegador del dispositivo
        final result = await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        );

        if (!mounted) return;

        if (result) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Descarga iniciada'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          throw Exception('No se pudo abrir la URL');
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al descargar: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        '${widget.data[widget.preoperacional.carId]?.carPlate ?? ''} - ${widget.data[widget.preoperacional.carId]?.brand ?? ''}',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppTheme.mainColor,
        ),
      ),
      subtitle: Text(widget.preoperacional.fechaInit),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          widget.preoperacional.isOpen
              ? const Icon(Icons.lock_open_outlined, color: Colors.green)
              : const Icon(Icons.lock, color: Colors.red),
          IconButton(
            icon: _isDownloading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppTheme.mainColor),
                    ))
                : const Icon(Icons.file_download, color: AppTheme.mainColor),
            onPressed: _isDownloading ? null : _downloadFile,
          ),
        ],
      ),
      onTap: () {
        context.pushNamed(
          PreoperacionalScreen.name,
          extra: widget.preoperacional,
        );
      },
    );
  }

  Future<FirebaseFile?> _getFirebaseFile(String fileName) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('preoperacionales/$fileName.xlsx');

      final url = await ref.getDownloadURL();

      return FirebaseFile(ref: ref, name: fileName, url: url);
    } catch (e, stackTrace) {
      return null;
    }
  }

  Future<void> downloadFile(FirebaseFile file, BuildContext context) async {
    try {
      await FirebaseApi.downloadFile(file.ref);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Archivo descargado: ${file.name}'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e, stackTrace) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error detallado en downloadFile: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
}
