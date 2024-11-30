
import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

Future<void> enviarAFirebaseLimpieza({
  required Map<String, dynamic> jsonData,
  required String archiveName,
  bool isPo = false,
}) async {
  try {
    Dio dio = Dio();
    String url = 'https://web-production-1db54.up.railway.app/rellenar_excel_limpieza';

    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);
    
    Response response = await dio.post(
      url,
      data: jsonData,
      options: Options(
        responseType: ResponseType.bytes,
        headers: {
          'Content-Type': 'application/json',
        },
        validateStatus: (status) => status! < 500,
      ),
    );

    if (response.statusCode == 200) {
      Uint8List bytes = Uint8List.fromList(response.data);

      if (kIsWeb) {
        await uploadToFirebaseWeb(bytes, archiveName, isPo: false);
      } else {
        await uploadToFirebaseMobile(bytes, archiveName, isPo: false);
      }
    } else {
      throw Exception('Error del servidor: ${response.statusCode} - ${response.statusMessage}');
    }
  } on DioException catch (e) {
    String mensaje = '';
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        mensaje = 'Tiempo de conexión agotado';
        break;
      case DioExceptionType.sendTimeout:
        mensaje = 'Tiempo de envío agotado';
        break;
      case DioExceptionType.receiveTimeout:
        mensaje = 'Tiempo de respuesta agotado';
        break;
      case DioExceptionType.connectionError:
        mensaje = 'Error de conexión. Verifica tu conexión a internet';
        break;
      default:
        mensaje = 'Error de conexión: ${e.message}';
    }
    throw Exception(mensaje);
  } catch (e) {
    throw Exception('Error inesperado: $e');
  }
}

Future<void> uploadToFirebaseWeb(Uint8List bytes, String archiveName, {bool isPo = true}) async {
  FirebaseStorage storage = FirebaseStorage.instance;
  String path = isPo ? 'preoperacionales' : 'chequeos_limpieza';
  Reference ref = storage.ref().child('$path/$archiveName.xlsx');

  UploadTask uploadTask = ref.putData(bytes);
  try {
    await uploadTask;
  } catch (e) {
    print('Error al subir archivo: $e');
  }
}

Future<void> uploadToFirebaseMobile(Uint8List bytes, String archiveName, {bool isPo = true}) async {
  FirebaseStorage storage = FirebaseStorage.instance;
  String path = isPo ? 'preoperacionales' : 'chequeos_limpieza';
  Reference ref = storage.ref().child('$path/$archiveName.xlsx');

  UploadTask uploadTask = ref.putData(bytes);
  await uploadTask.whenComplete(() {
    print('Subida completada');
  });
}