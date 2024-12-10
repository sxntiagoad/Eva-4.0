import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:eva/models/week.dart';

class Limpieza {
  final String docId;
  final String carId;
  final String fecha;
  final String userId;
  final Map<String, Week> inspecciones;
  final bool isOpen;
  final Map<String, String> modifiedBy;
  final List<String> relevantes;

  Limpieza({
    this.docId = '',
    required this.carId,
    required this.fecha,
    required this.userId,
    required this.inspecciones,
    this.isOpen = true,
    this.modifiedBy = const {},
    this.relevantes = const [],
  });

  Limpieza copyWith({
    String? carId,
    String? fecha,
    String? userId,
    Map<String, Week>? inspecciones,
    String? docId,
    bool? isOpen,
    Map<String, String>? modifiedBy,
    List<String>? relevantes,
  }) {
    return Limpieza(
      carId: carId ?? this.carId,
      fecha: fecha ?? this.fecha,
      userId: userId ?? this.userId,
      inspecciones: inspecciones ?? this.inspecciones,
      modifiedBy: modifiedBy ?? this.modifiedBy,
      relevantes: relevantes ?? this.relevantes,
      docId: docId ?? this.docId,
      isOpen: isOpen ?? this.isOpen,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'carId': carId,
      'fecha': fecha,
      'userId': userId,
      'inspecciones': inspecciones.map(
        (key, value) => MapEntry(key, value.toMap()),
      ),
      'isOpen': isOpen,
      'modifiedBy': modifiedBy,
      'relevantes': relevantes,
    };
  }

  factory Limpieza.fromMap(Map<String, dynamic> map) {
    return Limpieza(
      docId: map['docId'] ?? '',
      carId: map['carId'] ?? '',
      fecha: map['fecha'] ?? '',
      userId: map['userId'] ?? '',
      inspecciones: map['inspecciones'] != null 
          ? (map['inspecciones'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(key, Week.fromMap(value as Map<String, dynamic>)),
            )
          : {},
      isOpen: map['isOpen'] ?? true,
      modifiedBy: Map<String, String>.from(map['modifiedBy'] ?? {}),
      relevantes: List<String>.from(map['relevantes'] ?? []),
    );
  }

  String toJson() => json.encode(toMap());

  factory Limpieza.fromJson(String source) =>
      Limpieza.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Limpieza(docId: $docId, carId: $carId, fecha: $fecha, userId: $userId, inspecciones: $inspecciones)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Limpieza &&
        other.docId == docId &&
        other.carId == carId &&
        other.fecha == fecha &&
        other.userId == userId &&
        other.modifiedBy == modifiedBy &&
        other.relevantes == relevantes &&
        mapEquals(other.inspecciones, inspecciones);
  }

  @override
  int get hashCode {
    return docId.hashCode ^
        carId.hashCode ^
        fecha.hashCode ^
        userId.hashCode ^
        modifiedBy.hashCode ^
        relevantes.hashCode ^
        inspecciones.hashCode;
  }
}
