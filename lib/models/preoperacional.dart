import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'week.dart';

class Preoperacional {
  final String docId;
  final String carId;
  final String fecha;
  final Map<String, Map<String, Week>> inspecciones;
  final bool isOpen;
  final String typeKit;
  final String userId;
  final String observaciones; // Nuevo campo de observaciones
  final String fechaInit;
  final String fechaFinal;
  final int kilometrajeInit;
  final int kilometrajeFinal;

  Preoperacional({
    this.docId = '',
    required this.carId,
    required this.fecha,
    required this.inspecciones,
    required this.isOpen,
    required this.typeKit,
    required this.kilometrajeInit,
    required this.fechaInit,
    required this.fechaFinal,
    required this.userId,
    this.kilometrajeFinal = 0,
    this.observaciones = '', // Inicialización del campo
  });

  Preoperacional copyWith({
    String? carId,
    String? fecha,
    Map<String, Map<String, Week>>? inspecciones,
    bool? isOpen,
    String? typeKit,
    String? docId,
    String? observaciones, // Para modificar las observaciones
    int? kilometrajeInit,
    int? kilometrajeFinal,
    String? fechaInit,
    String? fechaFinal,
    String? userId,
  }) {
    return Preoperacional(
      carId: carId ?? this.carId,
      fecha: fecha ?? this.fecha,
      inspecciones: inspecciones ?? this.inspecciones,
      isOpen: isOpen ?? this.isOpen,
      typeKit: typeKit ?? this.typeKit,
      docId: docId ?? this.docId,
      observaciones:
          observaciones ?? this.observaciones, // Actualizar las observaciones
      kilometrajeInit: kilometrajeInit ?? this.kilometrajeInit,
      kilometrajeFinal: kilometrajeFinal ?? this.kilometrajeFinal,
      fechaInit: fechaInit ?? this.fechaInit,
      fechaFinal: fechaFinal ?? this.fechaFinal,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'carId': carId,
      'fecha': fecha,
      'inspecciones': inspecciones.map(
        (key, value) => MapEntry(
          key,
          value.map(
            (k, v) => MapEntry(
              k,
              v.toMap(),
            ),
          ),
        ),
      ),
      'isOpen': isOpen,
      'typeKit': typeKit,
      'userId': userId,
      'observaciones': observaciones, // Incluir en el mapa
      'kilometrajeInit': kilometrajeInit,
      'kilometrajeFinal': kilometrajeFinal,
      'fechaInit': fechaInit,
      'fechaFinal': fechaFinal,
    };
  }

  factory Preoperacional.fromMap(Map<String, dynamic> map) {
    return Preoperacional(
      carId: map['carId'] ?? '',
      fecha: map['fecha'] ?? '',
      inspecciones: (map['inspecciones'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          key,
          (value as Map<String, dynamic>).map(
            (k, v) => MapEntry(k, Week.fromMap(v)),
          ),
        ),
      ),
      isOpen: map['isOpen'] ?? false,
      typeKit: map['typeKit'] ?? '',
      observaciones: map['observaciones'] ?? '', // Cargar las observaciones
      kilometrajeInit: map['kilometrajeInit']?.toInt() ?? 0,
      kilometrajeFinal: map['kilometrajeFinal']?.toInt() ?? 0,
      fechaInit: map['fechaInit'] ?? '',
      fechaFinal: map['fechaFinal'] ?? '',
      userId: map['userId'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Preoperacional.fromJson(String source) =>
      Preoperacional.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Preoperacional(carId: $carId, fecha: $fecha, inspecciones: $inspecciones, isOpen: $isOpen, typeKit: $typeKit, userId: $userId, observaciones: $observaciones, kilometrajeInit: $kilometrajeInit, kilometrajeFinal: $kilometrajeFinal)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Preoperacional &&
        other.carId == carId &&
        other.fecha == fecha &&
        mapEquals(other.inspecciones, inspecciones) &&
        other.isOpen == isOpen &&
        other.typeKit == typeKit &&
        other.userId == userId &&
        other.observaciones == observaciones &&
        other.kilometrajeInit == kilometrajeInit &&
        other.kilometrajeFinal == kilometrajeFinal &&
        other.fechaInit == fechaInit &&
        other.fechaFinal == fechaFinal;
  }

  @override
  int get hashCode {
    return carId.hashCode ^
        fecha.hashCode ^
        inspecciones.hashCode ^
        isOpen.hashCode ^
        typeKit.hashCode ^
        userId.hashCode ^
        observaciones.hashCode ^
        kilometrajeInit.hashCode ^
        kilometrajeFinal.hashCode ^
        fechaInit.hashCode ^
        fechaFinal.hashCode;
  }
}
