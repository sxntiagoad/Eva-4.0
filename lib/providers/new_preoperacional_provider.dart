import 'package:eva/models/format_inspecciones.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Añade esta importación
import 'package:cloud_firestore/cloud_firestore.dart'; // Asegúrate de importar esto

import '../models/preoperacional.dart';
import '../models/week.dart';

class PreoperacionalNotifier extends StateNotifier<Preoperacional> {
  PreoperacionalNotifier()
      : super(Preoperacional(
          carId: '',
          fecha: '',
          inspecciones: formatInspecciones(),
          isOpen: false,
          typeKit: '',
          observaciones: '',
          kilometrajeInit: 0,
          kilometrajeFinal: 0,
          fechaInit: '',
          fechaFinal: '',
          modifiedBy: {},
          userId: FirebaseAuth.instance.currentUser?.uid ?? '',
          relevantes: [FirebaseAuth.instance.currentUser?.uid ?? '']
              .where((uid) => uid.isNotEmpty)
              .toList(),
          ultimoCambioAceite: 0,
          proximoCambioAceite: 0,
          extracto: null,
        ));

  void updateCarId(String newCarId) {
    state = state.copyWith(carId: newCarId);
  }

  void updateFecha(String newFecha) {
    state = state.copyWith(fecha: newFecha);
  }

  void addOrUpdateInspecciones(Map<String, Map<String, Week>> newInspecciones) {
    final updatedInspecciones =
        Map<String, Map<String, Week>>.from(state.inspecciones);

    newInspecciones.forEach((key, value) {
      updatedInspecciones[key] = value;
    });

    state = state.copyWith(inspecciones: updatedInspecciones);
  }

  void updateIsOpen(bool newIsOpen) {
    state = state.copyWith(isOpen: newIsOpen);
  }

  void updateTypeKit(String newTypeKit) {
    state = state.copyWith(typeKit: newTypeKit);
  }

  void updateDocId(String newDocId) {
    state = state.copyWith(docId: newDocId);
  }

  // Nuevo método para actualizar observaciones
  void updateObservaciones(String newObservaciones) {
    state = state.copyWith(observaciones: newObservaciones);
  }

  void updateKilometrajeInit(int newKilometrajeInit) {
    state = state.copyWith(kilometrajeInit: newKilometrajeInit);
  }

  void updateKilometrajeFinal(int newKilometrajeFinal) {
    state = state.copyWith(kilometrajeFinal: newKilometrajeFinal);
  }

  void updateFechaInit(String newFechaInit) {
    state = state.copyWith(fechaInit: newFechaInit);
  }

  void updateFechaFinal(String newFechaFinal) {
    state = state.copyWith(fechaFinal: newFechaFinal);
  }

  void updateDayOfWeek(
    String category,
    String subCategory,
    String day,
    bool? value,
    String userId,
  ) {
    final updatedInspecciones = Map<String, Map<String, Week>>.from(
      state.inspecciones,
    );

    if (updatedInspecciones.containsKey(
          category,
        ) &&
        updatedInspecciones[category]!.containsKey(
          subCategory,
        )) {
      final currentWeek = updatedInspecciones[category]![subCategory];

      final updatedWeek = currentWeek?.copyWith(
        lunes: day == 'Lunes' ? () => value : null,
        martes: day == 'Martes' ? () => value : null,
        miercoles: day == 'Miercoles' ? () => value : null,
        jueves: day == 'Jueves' ? () => value : null,
        viernes: day == 'Viernes' ? () => value : null,
        sabado: day == 'Sabado' ? () => value : null,
        domingo: day == 'Domingo' ? () => value : null,
      );

      if (updatedWeek != null) {
        updatedInspecciones[category]![subCategory] = updatedWeek;

        // Actualizar el mapa modifiedBy en el nivel del documento
        final updatedModifiedBy = Map<String, String>.from(state.modifiedBy);
        updatedModifiedBy[day] = userId;

        state = state.copyWith(
          inspecciones: updatedInspecciones,
          modifiedBy: updatedModifiedBy,
        );
      }
    }
  }

  void updateFechas(bool isOpen) {
    final now = _getCurrentDateAsString();

    if (state.fechaInit.isEmpty) {
      state = state.copyWith(fechaInit: now);
    }

    if (!isOpen && state.fechaFinal.isEmpty) {
      state = state.copyWith(fechaFinal: now);
    }
  }

  // Elimina este método, ya que no lo necesitaremos
  // void updateUserId(String newUserId) {
  //   state = state.copyWith(userId: newUserId);
  // }

  void updateUltimoCambioAceite(int kilometraje) {
    state = state.copyWith(ultimoCambioAceite: kilometraje);
  }

  void updateProximoCambioAceite(int kilometraje) {
    state = state.copyWith(proximoCambioAceite: kilometraje);
  }

  void addRelevante(String userId) {
    if (userId.isNotEmpty) {
      final updatedRelevantes = List<String>.from(state.relevantes);
      if (!updatedRelevantes.contains(userId)) {
        updatedRelevantes.add(userId);
        state = state.copyWith(relevantes: updatedRelevantes);
      }
    }
  }

  void updateExtracto(Timestamp newExtracto) {
    state = state.copyWith(extracto: newExtracto);
  }
}

final newPreoperacionalProvider =
    StateNotifierProvider.autoDispose<PreoperacionalNotifier, Preoperacional>(
        (ref) {
  return PreoperacionalNotifier();
});

// Función auxiliar para obtener la fecha actual como string
String _getCurrentDateAsString() {
  const bogotaTimeZone = Duration(hours: -5); // UTC-5 para Bogotá
  final now = DateTime.now().toUtc().add(bogotaTimeZone);
  final formattedDate =
      "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";

  return formattedDate;
}
