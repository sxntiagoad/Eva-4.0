import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class Car {
  final String brand;
  final String carPlate;
  final String carType;
  final String model;
  final Timestamp? extracto;
  final Timestamp? soat;
  final Timestamp? tarjetaOp;
  final Timestamp? tecnicoMec;

  Car({
    required this.brand,
    required this.carPlate,
    required this.carType,
    required this.model,
    this.extracto,
    this.soat,
    this.tarjetaOp,
    this.tecnicoMec,
  });

  factory Car.fromMap(Map<String, dynamic> map) {
    try {
      return Car(
        brand: map['brand'] ?? '',
        carPlate: map['carPlate'] ?? '',
        carType: map['carType'] ?? '',
        model: map['model'] ?? '',
        extracto:
            map['extracto'] is Timestamp ? map['extracto'] as Timestamp : null,
        soat: map['soat'] is Timestamp ? map['soat'] as Timestamp : null,
        tarjetaOp: map['tarjetaOp'] is Timestamp
            ? map['tarjetaOp'] as Timestamp
            : null,
        tecnicoMec: map['tecnicoMec'] is Timestamp
            ? map['tecnicoMec'] as Timestamp
            : null,
      );
    } catch (e) {
      print('Error al convertir documento a Car: $e');
      print('Datos del documento: $map');
      rethrow;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'brand': brand,
      'carPlate': carPlate,
      'carType': carType,
      'model': model,
      'extracto': extracto,
      'soat': soat,
      'tarjetaOp': tarjetaOp,
      'tecnicoMec': tecnicoMec,
    };
  }

  Car copyWith({
    String? brand,
    String? carPlate,
    String? carType,
    String? model,
    Timestamp? extracto,
    Timestamp? soat,
    Timestamp? tarjetaOp,
    Timestamp? tecnicoMec,
  }) {
    return Car(
      brand: brand ?? this.brand,
      carPlate: carPlate ?? this.carPlate,
      carType: carType ?? this.carType,
      model: model ?? this.model,
      extracto: extracto ?? this.extracto,
      soat: soat ?? this.soat,
      tarjetaOp: tarjetaOp ?? this.tarjetaOp,
      tecnicoMec: tecnicoMec ?? this.tecnicoMec,
    );
  }

  String toJson() => json.encode(toMap());

  factory Car.fromJson(String source) => Car.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Car(brand: $brand, carPlate: $carPlate, carType: $carType, model: $model, extracto: $extracto, soat: $soat, tarjetaOp: $tarjetaOp, tecnicoMec: $tecnicoMec)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Car &&
        other.brand == brand &&
        other.carPlate == carPlate &&
        other.carType == carType &&
        other.model == model &&
        other.extracto == extracto &&
        other.soat == soat &&
        other.tarjetaOp == tarjetaOp &&
        other.tecnicoMec == tecnicoMec;
  }

  @override
  int get hashCode {
    return brand.hashCode ^
        carPlate.hashCode ^
        carType.hashCode ^
        model.hashCode ^
        extracto.hashCode ^
        soat.hashCode ^
        tarjetaOp.hashCode ^
        tecnicoMec.hashCode;
  }
}
