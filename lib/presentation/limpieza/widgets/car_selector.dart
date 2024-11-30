import 'package:eva/providers/car_provider.dart';
import 'package:eva/providers/limpieza/new_limpieza_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CarSelector extends ConsumerWidget {
  final String? selectedCarId;
  final Function(String)? onCarSelected;

  const CarSelector({
    this.selectedCarId,
    this.onCarSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Si no hay selectedCarId, usa el newLimpiezaProvider
    final carId = selectedCarId ?? ref.watch(newLimpiezaProvider).carId;
    final carsProvider = ref.watch(mapCarsProvider);

    return carsProvider.when(
      data: (data) => DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          labelText: 'Seleccione un carro',
        ),
        value: carId.isEmpty ? null : carId,
        items: data.entries
            .map((e) => DropdownMenuItem(
                  value: e.key,
                  child: Text(e.value.carPlate),
                ))
            .toList(),
        onChanged: (value) {
          if (onCarSelected != null) {
            // Si hay callback, úsalo (modo edición)
            onCarSelected!(value ?? '');
          } else {
            // Si no hay callback, usa el provider (modo nuevo)
            ref.read(newLimpiezaProvider.notifier).updateCarId(value ?? '');
          }
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}
