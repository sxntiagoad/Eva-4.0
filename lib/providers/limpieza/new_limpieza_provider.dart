import 'package:eva/models/format_limpieza.dart';
import 'package:eva/models/limpieza.dart';
import 'package:eva/models/week.dart';
import 'package:eva/presentation/limpieza/services/limpieza_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class LimpiezaNotifier extends StateNotifier<Limpieza> {
  final LimpiezaService _limpiezaService = LimpiezaService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  LimpiezaNotifier() 
    : super(Limpieza(
        carId: '', 
        fecha: DateFormat('yyyy-MM-dd HH:mm:ss')
            .format(DateTime.now().toLocal()),
        userId: FirebaseAuth.instance.currentUser?.uid ?? '',
        inspecciones: formatInspeccionesLimpieza()
      ));

  void updateCarId(String newCarId) {
    state = state.copyWith(carId: newCarId);
  }

  void updateDayOfWeek(String category, String day, bool? value) {
    final updatedInspecciones = Map<String, Week>.from(state.inspecciones);
    
    if (updatedInspecciones.containsKey(category)) {
      final currentWeek = updatedInspecciones[category]!;
      
      final updatedWeek = currentWeek.copyWith(
        lunes: day == 'Lunes' ? () => value : null,
        martes: day == 'Martes' ? () => value : null,
        miercoles: day == 'Miercoles' ? () => value : null,
        jueves: day == 'Jueves' ? () => value : null,
        viernes: day == 'Viernes' ? () => value : null,
        sabado: day == 'Sabado' ? () => value : null,
        domingo: day == 'Domingo' ? () => value : null,
      );

      updatedInspecciones[category] = updatedWeek;
      state = state.copyWith(inspecciones: updatedInspecciones);
    }
  }

  void reset() {
    state = Limpieza(
      carId: '', 
      fecha: DateFormat('yyyy-MM-dd HH:mm:ss')
          .format(DateTime.now().toLocal()),
      userId: _auth.currentUser?.uid ?? '',
      inspecciones: formatInspeccionesLimpieza(),
      isOpen: true,
    );
  }

  void toggleIsOpen() {
    state = state.copyWith(isOpen: !state.isOpen);
  }

  Future<String?> saveLimpieza() async {
    try {
      final docId = await _limpiezaService.saveLimpieza(state);
      state = state.copyWith(docId: docId);
      return docId;
    } catch (e) {
      throw Exception('Error al guardar limpieza: $e');
    }
  }
}

// Provider global
final newLimpiezaProvider = StateNotifierProvider<LimpiezaNotifier, Limpieza>((ref) {
  return LimpiezaNotifier();
});

// Provider simple para validación básica
final isLimpiezaValidProvider = Provider<bool>((ref) {
  final limpieza = ref.watch(newLimpiezaProvider);
  return limpieza.carId.isNotEmpty;
});

// Agregar provider para el estado de guardado
final saveLimpiezaProvider = FutureProvider.autoDispose<String>((ref) async {
  final limpieza = ref.read(newLimpiezaProvider.notifier);
  return await limpieza.saveLimpieza() ?? '';
});