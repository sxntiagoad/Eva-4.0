import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:eva/models/week.dart';

class HealthReport {
  final String docId;
  final String userId;
  final String fecha;
  final Map<String, Week> questions;
  final bool isOpen;

  static const Map<String, String> questionsList = {
    'question1': 'Presenta una sintomatología específica - (Diagnostico emitido por médico).',
    'question2': 'Cree que su sintomatología puede afectar sus actividades laborales diarias.',
    'question3': 'Ha consultado a su EPS por esta sintomatología.',
  };

  HealthReport({
    this.docId = '',
    required this.userId,
    required this.fecha,
    required this.questions,
    this.isOpen = true,
  });

  HealthReport copyWith({
    String? docId,
    String? userId,
    String? fecha,
    Map<String, Week>? questions,
    bool? isOpen,
  }) {
    return HealthReport(
      docId: docId ?? this.docId,
      userId: userId ?? this.userId,
      fecha: fecha ?? this.fecha,
      questions: questions ?? this.questions,
      isOpen: isOpen ?? this.isOpen,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'fecha': fecha,
      'questions': questions.map(
        (key, value) => MapEntry(key, value.toMap()),
      ),
      'isOpen': isOpen,
    };
  }

  factory HealthReport.fromMap(Map<String, dynamic> map) {
    return HealthReport(
      docId: map['docId'] ?? '',
      userId: map['userId'] ?? '',
      fecha: map['fecha'] ?? '',
      questions: map['questions'] != null 
          ? (map['questions'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(key, Week.fromMap(value as Map<String, dynamic>)),
            )
          : {},
      isOpen: map['isOpen'] ?? true,
    );
  }

  String toJson() => json.encode(toMap());

  factory HealthReport.fromJson(String source) =>
      HealthReport.fromMap(json.decode(source));

  // Método de ayuda para crear un reporte vacío
  static Map<String, Week> createEmptyQuestions() {
    return questionsList.map((key, _) => MapEntry(key, Week()));
  }

  @override
  String toString() {
    return 'HealthReport(docId: $docId, userId: $userId, fecha: $fecha, questions: $questions, isOpen: $isOpen)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is HealthReport &&
        other.docId == docId &&
        other.userId == userId &&
        other.fecha == fecha &&
        mapEquals(other.questions, questions) &&
        other.isOpen == isOpen;
  }

  @override
  int get hashCode {
    return docId.hashCode ^
        userId.hashCode ^
        fecha.hashCode ^
        questions.hashCode ^
        isOpen.hashCode;
  }
}