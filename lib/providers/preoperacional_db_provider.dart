import 'package:eva/models/format_inspecciones.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Añade esta importación

import '../models/preoperacional.dart';
import '../models/week.dart';

class PreoperacionalDbNotifier extends StateNotifier<Preoperacional> {
  PreoperacionalDbNotifier()
      : super(Preoperacional(
          carId: '',
          fecha: _getCurrentDateAsString(),
          inspecciones: formatInspecciones(),
          isOpen: false,
          typeKit: '',
          observaciones: '',
          kilometrajeInit: 0,
          kilometrajeFinal: 0,
          fechaInit: '',
          fechaFinal: '',
          userId: FirebaseAuth.instance.currentUser?.uid ?? '', // Modificado aquí
        ));

  // Actualiza el carId
  void updateCarId(String newCarId) {
    state = state.copyWith(carId: newCarId);
  }

  // Actualiza la fecha
  void updateFecha(String newFecha) {
    state = state.copyWith(fecha: newFecha);
  }

  // Añadir o actualizar inspecciones
  void addOrUpdateInspecciones(Map<String, Map<String, Week>> newInspecciones) {
    final updatedInspecciones =
        Map<String, Map<String, Week>>.from(state.inspecciones);

    newInspecciones.forEach((key, value) {
      updatedInspecciones[key] = value;
    });

    state = state.copyWith(inspecciones: updatedInspecciones);
  }

  // Actualiza el estado de isOpen
  void updateIsOpen(bool newIsOpen) {
    state = state.copyWith(isOpen: newIsOpen);
  }

  // Actualiza el typeKit
  void updateTypeKit(String newTypeKit) {
    state = state.copyWith(typeKit: newTypeKit);
  }

  // Actualiza el docId
  void updateDocId(String newDocId) {
    state = state.copyWith(docId: newDocId);
  }

  // Actualiza las observaciones
  void updateObservaciones(String newObservaciones) {
    state = state.copyWith(observaciones: newObservaciones);
  }

  // Actualiza el kilometrajeInit
  void updateKilometrajeInit(int newKilometrajeInit) {
    state = state.copyWith(kilometrajeInit: newKilometrajeInit);
  }

  // Actualiza el kilometrajeFinal
  void updateKilometrajeFinal(int newKilometrajeFinal) {
    state = state.copyWith(kilometrajeFinal: newKilometrajeFinal);
  }

  // Actualiza la fechaInit
  void updateFechaInit(String newFechaInit) {
    state = state.copyWith(fechaInit: newFechaInit);
  }

  // Actualiza la fechaFinal
  void updateFechaFinal(String newFechaFinal) {
    state = state.copyWith(fechaFinal: newFechaFinal);
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

  // Actualiza el día de la semana

  void updateDayOfWeek(
    String category,
    String subCategory,
    String day,
    bool? value,
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
        state = state.copyWith(
          inspecciones: updatedInspecciones,
        );
      }
    }
  }

  // Reemplaza el preoperacional completo (incluyendo observaciones)
  void replacePreoperacional(Preoperacional newPreoperacional) {
    state = newPreoperacional.copyWith(
      observaciones: newPreoperacional.observaciones, // Asegurar que se copien las observaciones
      userId: state.userId, // Mantén el userId original
    );
  }
}

// Proveedor de estado para Preoperacional
final preoperacionalDbProvider =
    StateNotifierProvider.autoDispose<PreoperacionalDbNotifier, Preoperacional>((ref) {
  return PreoperacionalDbNotifier();
});

// Función auxiliar para obtener la fecha actual como string
String _getCurrentDateAsString() {
  const bogotaTimeZone = Duration(hours: -5); // UTC-5 para Bogotá
  final now = DateTime.now().toUtc().add(bogotaTimeZone);
  final formattedDate =
      "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";

  return formattedDate;
}
