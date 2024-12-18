import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva/providers/current_user_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/preoperacional.dart';
import '../../providers/car_provider.dart';
import '../../providers/endpoint.dart';

Future<void> dataJson(
    {required WidgetRef ref,
    required Preoperacional preoperacional,
    String idDoc = ''}) async {
  Map<String, Map<String, Object>> data = {};

  preoperacional.inspecciones.forEach((key, value) {
    data[key] = value.map((innerKey, week) => MapEntry(innerKey, week.toMap()));
  });


  final cars = await getAllCars();
  final currentCar = cars[preoperacional.carId];

  data["FORMULARIO"] = {
    "PLACAS No": currentCar?.carPlate ?? '',
    "MODELO": currentCar?.model ?? '',
    "KM TOTAL":
        (preoperacional.kilometrajeFinal - preoperacional.kilometrajeInit)
            .abs()
            .toString(),
    "MARCA": currentCar?.brand ?? '',
    "LUGAR": "Puerto Boyacá",
    "TIPO DE VEHICULO": currentCar?.carType ?? '',
    "F.V . TARJETA OPERACIÓN": fecha(currentCar?.tarjetaOp),
    "F.V . SOAT": fecha(currentCar?.soat),
    "F.V . TECNICOMECANICA": fecha(currentCar?.tecnicoMec),
    "F.V . EXTRACTO": fecha(preoperacional.extracto),
    "BOTIQUÍN TIPO": preoperacional.typeKit,
    "SEMANA DEL": formatDate(preoperacional.fechaInit),
    "AL": formatDate(preoperacional.fechaFinal),
    "DEL 20": "24",
    "KMTS INICIAL": preoperacional.kilometrajeInit.toString(),
    "KMTS FINAL": preoperacional.kilometrajeFinal.toString(),
    "KMTS ÚLTIMO CAMBIO DE ACEITE": preoperacional.ultimoCambioAceite,
    "KMTS PROXIMO CAMBIO DE ACEITE": preoperacional.proximoCambioAceite,
  };
  final user = ref.read(currentUserProvider);
  // ignore: unused_local_variable
  final userValue = user.value;

  final logoUrl = await getSESCOTURImageUrl();
  final firmaEncargadoUrl = await getManagerSignatureUrl();

  // Obtener firmas de usuarios relevantes
  Map<String, String> firmasRelevantes = {};
  for (String uid in preoperacional.relevantes) {
    String firma = await getUserSignatureUrl(uid);
    firmasRelevantes['FIRMA_USER_$uid'] = firma;
  }

  final firmaUrl = await getUserSignatureUrl(preoperacional.userId);

  data['IMAGENES'] = {
    'FIRMA_USER': firmaUrl,
    'FIRMA_ENCARGADO': firmaEncargadoUrl,
    'LOGO': logoUrl,
    'FIRMA_REP': firmaUrl,
    'FIRMAS_RELV':
        firmasRelevantes, // Agregar todas las firmas relevantes al mapa
  };

  data["PIE_TABLA"] = {
    "Nombre del Conductor": user.value?.fullName ?? '',
    "OBSERVACIONES": preoperacional.observaciones.isNotEmpty
        ? preoperacional.observaciones
        : 'Sin observaciones',
    "MODIFICADO_POR": preoperacional.modifiedBy,
  };

  await enviarJsonYSubirArchivoAFirebase(
    jsonData: data,
    archiveName: preoperacional.docId.isEmpty ? idDoc : preoperacional.docId,
  );
}

String fecha(Timestamp? fecha) {
  if (fecha != null) {
    DateTime dateTime = fecha.toDate();

    String day = dateTime.day.toString().padLeft(2, '0');
    String month = dateTime.month.toString().padLeft(2, '0');
    String year = dateTime.year.toString();
    String hour = dateTime.hour.toString().padLeft(2, '0');
    String minute = dateTime.minute.toString().padLeft(2, '0');

    String formattedDate = '$year-$month-$day';
    return formattedDate;
  }
  return 'Sin fecha';
}

String formatDate(String? fecha) {
  if (fecha == null || fecha.isEmpty) return 'Sin fecha';
  try {
    DateTime dateTime = DateTime.parse(fecha);
    String dia = dateTime.day.toString().padLeft(2, '0');
    String mes = dateTime.month.toString().padLeft(2, '0');
    String hora = dateTime.hour.toString().padLeft(2, '0');
    String minutos = dateTime.minute.toString().padLeft(2, '0');

    return '$dia/$mes';
  } catch (e) {
    return 'Fecha inválida';
  }
}

Future<String> getSESCOTURImageUrl() async {
  try {
    final storage = FirebaseStorage.instance;
    final ref = storage.ref().child('SESCOTUR.png');
    final url = await ref.getDownloadURL();
    return url;
  } catch (e) {
    // ignore: avoid_print
    return ''; // Retorna una cadena vacía en caso de error
  }
}

Future<String> getManagerSignatureUrl() async {
  try {
    return await FirebaseStorage.instance
        .ref('FIRMA_ROGER.png')
        .getDownloadURL();
  } catch (e) {
    // ignore: avoid_print
    return '';
  }
}

Future<String> getUserSignatureUrl(String uid) async {
  try {
    return await FirebaseStorage.instance
        .ref('firmas/$uid.png')
        .getDownloadURL();
  } catch (e) {
    // ignore: avoid_print
    return '';
  }
}
