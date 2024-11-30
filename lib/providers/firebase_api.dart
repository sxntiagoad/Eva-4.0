import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:universal_html/html.dart' as html;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class FirebaseApi {
  static Future<void> downloadFile(Reference ref) async {
    try {
      final downloadUrl = await ref.getDownloadURL();

      if (kIsWeb) {
        await _downloadFileWeb(downloadUrl, ref.name);
      } else {
        await _downloadFileMobile(downloadUrl, ref.name);
      }

      print('Archivo descargado: ${ref.name}');
    } catch (e) {
      print('Error al descargar archivo: $e');
      rethrow;
    }
  }

  static Future<void> _downloadFileWeb(String url, String fileName) async {
    try {
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", fileName)
        ..style.display = 'none'
        ..target = 'blank';

      html.document.body?.children.add(anchor);
      anchor.click();

      html.document.body?.children.remove(anchor);
    } catch (e) {
      print('Error en descarga web: $e');
      rethrow;
    }
  }

  static Future<void> _downloadFileMobile(String url, String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName');

    final response = await Dio().get(
      url,
      options: Options(responseType: ResponseType.bytes),
    );

    await file.writeAsBytes(response.data);
  }
}
