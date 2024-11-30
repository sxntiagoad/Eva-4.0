import 'package:eva/providers/car_provider.dart';
import 'package:eva/providers/new_preoperacional_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CarPlate extends ConsumerWidget {
  const CarPlate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCar = ref.watch(newPreoperacionalProvider).carId;
    final carsProvider = ref.watch(mapCarsProvider);

    return carsProvider.when(
      data: (data) => DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          labelText: 'Seleccione un carro',
        ),
        value: selectedCar.isEmpty ? null : selectedCar,
        items: data.entries
            .map(
              (e) => DropdownMenuItem(
                value: e.key,
                child: Text(e.value.carPlate),
              ),
            )
            .toList(),
        onChanged: (value) {
          ref.read(newPreoperacionalProvider.notifier).updateCarId(value ?? '');
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}
