import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/limpieza.dart';
import '../../models/week.dart';

class LimpiezaDbNotifier extends StateNotifier<Limpieza> {
  LimpiezaDbNotifier()
      : super(Limpieza(
          carId: '',
          fecha: DateFormat('yyyy-MM-dd HH:mm:ss')
              .format(DateTime.now().toLocal()),
          inspecciones: {},
          isOpen: true,
          docId: '',
          userId: FirebaseAuth.instance.currentUser?.uid ?? '',
        ));

  void updateCarId(String newCarId) {
    state = state.copyWith(carId: newCarId);
  }

  void updateFecha(String newFecha) {
    state = state.copyWith(fecha: newFecha);
  }

  void updateIsOpen(bool newIsOpen) {
    state = state.copyWith(isOpen: newIsOpen);
  }

  void updateDocId(String newDocId) {
    state = state.copyWith(docId: newDocId);
  }

  void updateInspecciones(Map<String, Week> newInspecciones) {
    state = state.copyWith(inspecciones: newInspecciones);
  }

  void updateInspeccion(String category, String day, bool? value) {
    final updatedInspecciones = Map<String, Week>.from(state.inspecciones);

    if (!updatedInspecciones.containsKey(category)) {
      updatedInspecciones[category] = Week();
    }

    final currentWeek = updatedInspecciones[category];
    Week updatedWeek;

    switch (day.toLowerCase()) {
      case 'lunes':
        updatedWeek = currentWeek!.copyWith(lunes: () => value);
        break;
      case 'martes':
        updatedWeek = currentWeek!.copyWith(martes: () => value);
        break;
      case 'miercoles':
        updatedWeek = currentWeek!.copyWith(miercoles: () => value);
        break;
      case 'jueves':
        updatedWeek = currentWeek!.copyWith(jueves: () => value);
        break;
      case 'viernes':
        updatedWeek = currentWeek!.copyWith(viernes: () => value);
        break;
      case 'sabado':
        updatedWeek = currentWeek!.copyWith(sabado: () => value);
        break;
      case 'domingo':
        updatedWeek = currentWeek!.copyWith(domingo: () => value);
        break;
      default:
        return;
    }

    updatedInspecciones[category] = updatedWeek;
    state = state.copyWith(inspecciones: updatedInspecciones);
  }

  void replaceLimpieza(Limpieza newLimpieza) {
    print('replaceLimpieza - Datos recibidos:');
    print('DocId: ${newLimpieza.docId}');
    print('CarId: ${newLimpieza.carId}');
    print('Fecha: ${newLimpieza.fecha}');
    print('IsOpen: ${newLimpieza.isOpen}');
    print('Inspecciones: ${newLimpieza.inspecciones}');
    
    state = newLimpieza;
  }

  Future<void> updateLimpiezaInFirebase() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final limpiezasRef = firestore.collection('limpieza');

      print('Intentando actualizar/crear limpieza');
      print('DocId: ${state.docId}');
      print('Datos: ${state.toMap()}');

      if (state.docId.isEmpty) {
        // Si no hay docId, crear nuevo documento
        final docRef = await limpiezasRef.add(state.toMap());
        state = state.copyWith(docId: docRef.id);
        print('Nuevo documento creado con ID: ${docRef.id}');
      } else {
        // Si hay docId, intentar actualizar
        final docRef = limpiezasRef.doc(state.docId);
        
        // Verificar si el documento existe
        final docSnapshot = await docRef.get();
        if (docSnapshot.exists) {
          // Actualizar documento existente
          await docRef.update(state.toMap());
          print('Documento existente actualizado');
        } else {
          // Si el documento no existe, crear uno nuevo
          final newDocRef = await limpiezasRef.add(state.toMap());
          state = state.copyWith(docId: newDocRef.id);
          print('Documento no encontrado, creado nuevo con ID: ${newDocRef.id}');
        }
      }
    } catch (e) {
      print('Error en updateLimpiezaInFirebase: $e');
      throw Exception('Error al actualizar limpieza: $e');
    }
  }
}

final limpiezaDbProvider =
    StateNotifierProvider.autoDispose<LimpiezaDbNotifier, Limpieza>((ref) {
  return LimpiezaDbNotifier();
});

String _getCurrentDateAsString() {
  const bogotaTimeZone = Duration(hours: -5);
  final now = DateTime.now().toUtc().add(bogotaTimeZone);
  return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
}
