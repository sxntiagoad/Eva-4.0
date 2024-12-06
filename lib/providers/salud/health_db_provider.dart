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
      ));

  void updateIsOpen(bool newIsOpen) {
    state = state.copyWith(isOpen: newIsOpen);
  }

  void replaceHealth(HealthReport newHealth) {
    state = newHealth;
  }
  void updateDayOfWeek(String questionId, String day, bool? value) {
    final updatedQuestions = Map<String, Week>.from(state.questions);
    
    if (updatedQuestions.containsKey(questionId)) {
      final currentWeek = updatedQuestions[questionId]!;
      
      final updatedWeek = currentWeek.copyWith(
        lunes: day == 'Lunes' ? () => value : null,
        martes: day == 'Martes' ? () => value : null,
        miercoles: day == 'Miercoles' ? () => value : null,
        jueves: day == 'Jueves' ? () => value : null,
        viernes: day == 'Viernes' ? () => value : null,
        sabado: day == 'Sabado' ? () => value : null,
        domingo: day == 'Domingo' ? () => value : null,
      );

      updatedQuestions[questionId] = updatedWeek;
      state = state.copyWith(questions: updatedQuestions);
    }
  }

  Future<void> updateHealthInFirebase() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final healthRef = firestore.collection('health');

      if (state.docId.isEmpty) {
        final docRef = await healthRef.add(state.toMap());
        state = state.copyWith(docId: docRef.id);
      } else {
        final docRef = healthRef.doc(state.docId);
        final docSnapshot = await docRef.get();
        if (docSnapshot.exists) {
          await docRef.update(state.toMap());
        } else {
          final newDocRef = await healthRef.add(state.toMap());
          state = state.copyWith(docId: newDocRef.id);
        }
      }
    } catch (e) {
      throw Exception('Error al actualizar registro de salud: $e');
    }
  }
}

final healthDbProvider =
    StateNotifierProvider.autoDispose<HealthDbNotifier, HealthReport>((ref) {
  return HealthDbNotifier();
});