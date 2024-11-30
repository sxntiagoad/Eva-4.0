import 'package:eva/models/limpieza.dart';
import 'package:eva/providers/car_provider.dart';
import 'package:eva/providers/current_user_provider.dart';
import 'package:eva/providers/limpieza/limpieza_endpoint.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> limpiezaDataJson(
    {required WidgetRef ref,
    required Limpieza limpieza,
    String idDoc = ''}) async {
  Map<String, dynamic> data = {};
  
  // Creamos un map temporal para las inspecciones
  Map<String, dynamic> inspeccionesMap = {};
  limpieza.inspecciones.forEach((key, value) {
    inspeccionesMap[key] = value.toMap();
  });
  
  // Agregamos las inspecciones bajo una key
  data["INSPECCION"] = inspeccionesMap;
  final cars = await getAllCars();
  final currentCar = cars[limpieza.carId];
  // Agregamos el formulario
  data["FORMULARIO"] = {
    'PLACA': currentCar?.carPlate ?? '',
    'FECHA': formatDate(limpieza.fecha),
    "AÑO": "24",
    'userId': limpieza.userId,
  };
  final user = ref.read(currentUserProvider);
  final userValue = user.value;

  final logoUrl = await getSESCOTURImageUrl();
  String firmaUrl = '';
  if (userValue != null) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      firmaUrl = await getUserSignatureUrl(uid);
    }
  }
  data['IMAGENES'] = {
    'FIRMA_USER': firmaUrl,
    'LOGO': logoUrl,
  };


  await enviarAFirebaseLimpieza(jsonData: data, archiveName: limpieza.docId, isPo: false);
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


Future<String> getUserSignatureUrl(String uid) async {
  try {
    return await FirebaseStorage.instance.ref('firmas/$uid.png').getDownloadURL();
  } catch (e) {
    // ignore: avoid_print
    return '';
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
