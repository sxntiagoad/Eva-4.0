import 'package:eva/models/health_report.dart';
import 'package:eva/providers/current_user_provider.dart';
import 'package:eva/providers/salud/salud_endpoint.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> healthDataJson({
  required WidgetRef ref,
  required HealthReport healthReport,
}) async {
  Map<String, dynamic> data = {};

  // Agregar las preguntas y respuestas
  Map<String, dynamic> questionsMap = {};
  healthReport.questions.forEach((key, value) {
    questionsMap[key] = value.toMap();
  });

  data["PREGUNTAS"] = questionsMap;

  final user = ref.read(currentUserProvider);
  final userValue = user.value;

  // Agregar información del formulario
  data["FORMULARIO"] = {
    'FECHA': formatDate(healthReport.fecha),
    'proyecto': healthReport.selectedValue,
    'userName': userValue?.fullName,
    'rol': userValue?.role,
    'cc': userValue?.cc,
    'eps': userValue?.eps,
    'arl': userValue?.arl,
    'afp': userValue?.afp,
    'contactoEmergencia': userValue?.emergencyContactName,
    'telefonoEmergencia': userValue?.emergencyContactPhone,
    'parentesco': userValue?.relationship,
    'direccion': userValue?.address,
  };

  // Obtener URLs de imágenes
  final firmaUrl = await getUserSignatureUrl(healthReport.userId);
  final logoUrl = await getSESCOTURImageUrl();
  final superTransUrl = await getSuperTrans();

  data['IMAGENES'] = {
    'FIRMA_USER': firmaUrl,
    'LOGO': logoUrl,
    'TRANS': superTransUrl
  };

  // Enviar a Firebase
  await enviarAFirebaseSalud(jsonData: data, archiveName: healthReport.docId);
}

Future<String> getSESCOTURImageUrl() async {
  try {
    final storage = FirebaseStorage.instance;
    final ref = storage.ref().child('SESCOTUR.png');
    final url = await ref.getDownloadURL();
    return url;
  } catch (e) {
    return ''; // Retorna una cadena vacía en caso de error
  }
}

Future<String> getUserSignatureUrl(String userId) async {
  try {
    return await FirebaseStorage.instance
        .ref('firmas/$userId.png')
        .getDownloadURL();
  } catch (e) {
    return '';
  }
}

Future<String> getSuperTrans() async {
  try {
    final storage = FirebaseStorage.instance;
    final ref = storage.ref().child('super_transporte.png');
    final url = await ref.getDownloadURL();
    return url;
  } catch (e) {
    return ''; // Retorna una cadena vacía en caso de error
  }
}

String formatDate(String? fecha) {
  if (fecha == null || fecha.isEmpty) return 'Sin fecha';
  try {
    DateTime dateTime = DateTime.parse(fecha);
    String dia = dateTime.day.toString().padLeft(2, '0');
    String mes = dateTime.month.toString().padLeft(2, '0');
    String hora = dateTime.hour.toString().padLeft(2, '0');
    String minutos = dateTime.minute.toString().padLeft(2, '0');

    return '$dia/$mes $hora:$minutos';
  } catch (e) {
    return 'Fecha inválida';
  }
}
