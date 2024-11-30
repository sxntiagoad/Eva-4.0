import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/car.dart';

Future<Map<String, Car>> getAllCars() async {
  final firestore = FirebaseFirestore.instance;
  final Map<String, Car> carsMap = {};

  try {
    final snapshot = await firestore.collection('cars').get();
    for (var doc in snapshot.docs) {
      final carData = Car.fromMap(doc.data());
      carsMap[doc.id] = carData;
    }
  } catch (e) {
    rethrow;
  }

  return carsMap;
}

final mapCarsProvider = FutureProvider<Map<String, Car>>((ref) async {
  return await getAllCars();
});

final selectedCarProvider =
    StateNotifierProvider<SelectedCarNotifier, Car?>((ref) {
  return SelectedCarNotifier();
});

class SelectedCarNotifier extends StateNotifier<Car?> {
  SelectedCarNotifier() : super(null);

  void setCar(Car? car) {
    state = car;
  }

  void updateField(String field, dynamic value) {
    if (state == null) return;

    state = state!.copyWith(
      extracto: field == 'extracto' ? value : state!.extracto,
      soat: field == 'soat' ? value : state!.soat,
      tarjetaOp: field == 'tarjetaOp' ? value : state!.tarjetaOp,
      tecnicoMec: field == 'tecnicoMec' ? value : state!.tecnicoMec,
      brand: field == 'brand' ? value : state!.brand,
      carPlate: field == 'carPlate' ? value : state!.carPlate,
      carType: field == 'carType' ? value : state!.carType,
      model: field == 'model' ? value : state!.model,
      ultCambioAceite:
          field == 'ultCambioAceite' ? value : state!.ultCambioAceite,
      proxCambioAceite:
          field == 'proxCambioAceite' ? value : state!.proxCambioAceite,
    );
  }

  void clearCar() {
    state = null;
  }
}

final selectedCarsProvider =
    StateNotifierProvider<SelectedCarsNotifier, Set<String>>((ref) {
  return SelectedCarsNotifier();
});

class SelectedCarsNotifier extends StateNotifier<Set<String>> {
  SelectedCarsNotifier() : super({});

  void toggleSelection(String carId) {
    if (state.contains(carId)) {
      state = Set.from(state)..remove(carId);
    } else {
      state = Set.from(state)..add(carId);
    }
  }

  void clearSelection() {
    state = {};
  }
}

Future<void> deleteSelectedCars(WidgetRef ref) async {
  final selectedCars = ref.read(selectedCarsProvider);

  if (selectedCars.isNotEmpty) {
    final firestore = FirebaseFirestore.instance;
    for (String carId in selectedCars) {
      try {
        await firestore.collection('cars').doc(carId).delete();
      } catch (e) {
        print('Error al eliminar el carro $carId: $e');
      }
    }

    // Clear selection and invalidate the cars map after deleting the selected cars
    ref.read(selectedCarsProvider.notifier).clearSelection();
    ref.invalidate(mapCarsProvider);
  }
}
