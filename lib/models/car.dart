import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class Car {
  final Timestamp? extracto;
  final Timestamp? soat;
  final Timestamp? tarjetaOp;
  final Timestamp? tecnicoMec;
  final String brand;
  final String carPlate;
  final String carType;
  final String model;
  final Timestamp? ultCambioAceite;
  final Timestamp? proxCambioAceite;

  Car({
    this.extracto,
    this.soat,
    this.tarjetaOp,
    this.tecnicoMec,
    required this.brand,
    required this.carPlate,
    required this.carType,
    required this.model,
    this.ultCambioAceite,
    this.proxCambioAceite,
  });

  Car copyWith({
    Timestamp? extracto,
    Timestamp? soat,
    Timestamp? tarjetaOp,
    Timestamp? tecnicoMec,
    String? brand,
    String? carPlate,
    String? carType,
    String? model,
    Timestamp? ultCambioAceite,
    Timestamp? proxCambioAceite,
  }) {
    return Car(
      extracto: extracto ?? this.extracto,
      soat: soat ?? this.soat,
      tarjetaOp: tarjetaOp ?? this.tarjetaOp,
      tecnicoMec: tecnicoMec ?? this.tecnicoMec,
      brand: brand ?? this.brand,
      carPlate: carPlate ?? this.carPlate,
      carType: carType ?? this.carType,
      model: model ?? this.model,
      ultCambioAceite: ultCambioAceite ?? this.ultCambioAceite,
      proxCambioAceite: proxCambioAceite ?? this.proxCambioAceite,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'extracto': extracto,
      'soat': soat,
      'tarjetaOp': tarjetaOp,
      'tecnicoMec': tecnicoMec,
      'brand': brand,
      'carPlate': carPlate,
      'carType': carType,
      'model': model,
      'ultCambioAceite': ultCambioAceite,
      'proxCambioAceite': proxCambioAceite,
    };
  }

  factory Car.fromMap(Map<String, dynamic> map) {
    return Car(
      extracto: map['extracto'],
      soat: map['soat'],
      tarjetaOp: map['tarjetaOp'],
      tecnicoMec: map['tecnicoMec'],
      brand: map['brand'] ?? '',
      carPlate: map['carPlate'] ?? '',
      carType: map['carType'] ?? '',
      model: map['model'] ?? '',
      ultCambioAceite: map['ultCambioAceite'],
      proxCambioAceite: map['proxCambioAceite'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Car.fromJson(String source) => Car.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Car(extracto: $extracto, soat: $soat, tarjetaOp: $tarjetaOp, tecnicoMec: $tecnicoMec, brand: $brand, carPlate: $carPlate, carType: $carType, model: $model, ultCambioAceite: $ultCambioAceite, proxCambioAceite: $proxCambioAceite)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Car &&
        other.extracto == extracto &&
        other.soat == soat &&
        other.tarjetaOp == tarjetaOp &&
        other.tecnicoMec == tecnicoMec &&
        other.brand == brand &&
        other.carPlate == carPlate &&
        other.carType == carType &&
        other.model == model &&
        other.ultCambioAceite == ultCambioAceite &&
        other.proxCambioAceite == proxCambioAceite;
  }

  @override
  int get hashCode {
    return extracto.hashCode ^
        soat.hashCode ^
        tarjetaOp.hashCode ^
        tecnicoMec.hashCode ^
        brand.hashCode ^
        carPlate.hashCode ^
        carType.hashCode ^
        model.hashCode ^
        ultCambioAceite.hashCode ^
        proxCambioAceite.hashCode;
  }
}
