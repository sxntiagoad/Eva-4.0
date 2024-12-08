import 'package:eva/models/health_report.dart';
import 'package:eva/models/week.dart';
import 'package:eva/presentation/salud/services/health_report_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class HealthReportNotifier extends StateNotifier<HealthReport> {
  final HealthReportService _healthService = HealthReportService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  HealthReportNotifier() 
    : super(HealthReport(
        userId: FirebaseAuth.instance.currentUser?.uid ?? '',
        fecha: DateFormat('yyyy-MM-dd HH:mm:ss')
            .format(DateTime.now().toLocal()),
        questions: HealthReport.createEmptyQuestions(),
        isOpen: true,
        selectedValue: '',
      ));

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

  void updateSelectedValue(String newValue) {
    state = state.copyWith(selectedValue: newValue);
  }

  void reset() {
    state = HealthReport(
      userId: _auth.currentUser?.uid ?? '',
      fecha: DateFormat('yyyy-MM-dd HH:mm:ss')
          .format(DateTime.now().toLocal()),
      questions: HealthReport.createEmptyQuestions(),
      isOpen: true,
      selectedValue: '',
    );
  }

  void toggleIsOpen() {
    state = state.copyWith(isOpen: !state.isOpen);
  }

  Future<String?> saveHealthReport() async {
    try {
      print('Guardando reporte de salud con selectedValue: ${state.selectedValue}');
      final docId = await _healthService.saveHealthReport(state);
      state = state.copyWith(docId: docId);
      return docId;
    } catch (e) {
      throw Exception('Error al guardar reporte de salud: $e');
    }
  }
}

final newHealthReportProvider = StateNotifierProvider<HealthReportNotifier, HealthReport>((ref) {
  return HealthReportNotifier();
});

final isHealthReportValidProvider = Provider<bool>((ref) {
  final report = ref.watch(newHealthReportProvider);
  // Validar que al menos una pregunta tenga respuesta
  return report.questions.values.any((week) => 
    week.lunes != null || week.martes != null || 
    week.miercoles != null || week.jueves != null || 
    week.viernes != null || week.sabado != null || 
    week.domingo != null
  );
});

final saveHealthReportProvider = FutureProvider.autoDispose<String>((ref) async {
  final report = ref.read(newHealthReportProvider.notifier);
  return await report.saveHealthReport() ?? '';
});