import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva/models/health_report.dart';

class HealthReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> saveHealthReport(HealthReport report) async {
    try {
      final docRef = await _firestore.collection('health_reports').add(report.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Error al guardar el reporte: $e');
    }
  }

  // Aquí puedes agregar más métodos para obtener reportes, actualizarlos, etc.
}