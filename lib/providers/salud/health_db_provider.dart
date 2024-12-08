import 'package:eva/models/health_report.dart';
import 'package:eva/models/week.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class HealthDbNotifier extends StateNotifier<HealthReport> {
  HealthDbNotifier()
      : super(HealthReport(
          userId: FirebaseAuth.instance.currentUser?.uid ?? '',
          fecha: DateFormat('yyyy-MM-dd HH:mm:ss')
              .format(DateTime.now().toLocal()),
          questions: {},
          selectedValue: '',
        ));

   Future<void> loadHealthReport(String docId) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final docRef = firestore.collection('health_reports').doc(docId);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        if (data != null) {
          final loadedHealthReport = HealthReport.fromMap(data);
          state = loadedHealthReport;
        }
      } else {
      }
    } catch (e) {
      throw Exception('Error al cargar el reporte de salud: $e');
    }
  }

  void updateIsOpen(bool newIsOpen) {
    state = state.copyWith(isOpen: newIsOpen);
  }

  void updateDayOfWeek(String questionId, String day, bool? value) {
    final updatedQuestions = Map<String, Week>.from(state.questions);

    if (!updatedQuestions.containsKey(questionId)) {
      updatedQuestions[questionId] = Week();
    }

    final currentWeek = updatedQuestions[questionId];
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

    updatedQuestions[questionId] = updatedWeek;
    state = state.copyWith(questions: updatedQuestions);
  }

  void updateSelectedValue(String newValue) {
    state = state.copyWith(selectedValue: newValue);
  }

  void replaceHealth(HealthReport newHealth) {
    print('replaceHealth - Datos recibidos:');
    print('DocId: ${newHealth.docId}');
    print('UserId: ${newHealth.userId}');
    print('Fecha: ${newHealth.fecha}');
    print('IsOpen: ${newHealth.isOpen}');
    print('Questions: ${newHealth.questions}');
    
    state = newHealth;
  }

  Future<void> updateHealthInFirebase() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final healthRef = firestore.collection('health_reports');


      if (state.docId.isEmpty) {
        // Si no hay docId, crear nuevo documento
        final docRef = await healthRef.add(state.toMap());
        state = state.copyWith(docId: docRef.id);
      } else {
        // Si hay docId, intentar actualizar
        final docRef = healthRef.doc(state.docId);
        
        // Verificar si el documento existe
        final docSnapshot = await docRef.get();
        if (docSnapshot.exists) {
          // Actualizar documento existente
          await docRef.update(state.toMap());
        } else {
          // Si el documento no existe, crear uno nuevo
          final newDocRef = await healthRef.add(state.toMap());
          state = state.copyWith(docId: newDocRef.id);
        }
      }
    } catch (e) {
      print('Error en updateHealthInFirebase: $e');
      throw Exception('Error al actualizar reporte de salud: $e');
    }
  }

}

final healthDbProvider =
    StateNotifierProvider.autoDispose<HealthDbNotifier, HealthReport>((ref) {
  return HealthDbNotifier();
});