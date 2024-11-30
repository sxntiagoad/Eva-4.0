// ignore_for_file: avoid_print

import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_storage/firebase_storage.dart';

Future<void> enviarJsonYSubirArchivoAFirebase({
  required Map<String, Map<String, Object>> jsonData,
  required String archiveName,
}) async {
  try {
    Dio dio = Dio();

    String url = 'https://web-production-1db54.up.railway.app/rellenar_excel';

    Response response = await dio.post(
      url,
      data: jsonData,
      options: Options(
        responseType: ResponseType.bytes,
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    if (response.statusCode == 200) {
      Uint8List bytes = Uint8List.fromList(response.data);

      // Usar kIsWeb para detectar si estamos en web o móvil
      if (kIsWeb) {
        await uploadToFirebaseWeb(bytes, archiveName);
      } else {
        await uploadToFirebaseMobile(bytes, archiveName);
      }
    } else {
      print('Error: ${response.statusCode} - ${response.statusMessage}');
    }
  } catch (e) {
    print('Ocurrió un error: $e');
  }
}

Future<void> uploadToFirebaseWeb(Uint8List bytes, String archiveName) async {
  FirebaseStorage storage = FirebaseStorage.instance;
  Reference ref = storage.ref().child('preoperacionales/$archiveName.xlsx');

  UploadTask uploadTask = ref.putData(bytes);
  try {
    await uploadTask;
  } catch (e) {
    print('Error al subir archivo: $e');
  }
}

Future<void> uploadToFirebaseMobile(Uint8List bytes, String archiveName) async {
  FirebaseStorage storage = FirebaseStorage.instance;
  Reference ref = storage.ref().child('preoperacionales/$archiveName.xlsx');

  UploadTask uploadTask = ref.putData(bytes);

  await uploadTask.whenComplete(() {
    print('Subida completada');
  });

}
