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

  Limpieza({
    this.docId = '',
    required this.carId,
    required this.fecha,
    required this.userId,
    required this.inspecciones,
    this.isOpen = true,
  });

  Limpieza copyWith({
    String? carId,
    String? fecha,
    String? userId,
    Map<String, Week>? inspecciones,
    String? docId,
    bool? isOpen,
  }) {
    return Limpieza(
      carId: carId ?? this.carId,
      fecha: fecha ?? this.fecha,
      userId: userId ?? this.userId,
      inspecciones: inspecciones ?? this.inspecciones,
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
        mapEquals(other.inspecciones, inspecciones);
  }

  @override
  int get hashCode {
    return docId.hashCode ^
        carId.hashCode ^
        fecha.hashCode ^
        userId.hashCode ^
        inspecciones.hashCode;
  }
}
