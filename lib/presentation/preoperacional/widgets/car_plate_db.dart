import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/car_provider.dart';
import '../../../providers/preoperacional_db_provider.dart';

class CarPlateDb extends ConsumerWidget {
  const CarPlateDb({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String? role;

    final carsProvider = ref.watch(mapCarsProvider);
    final preopreciona = ref.watch(preoperacionalDbProvider);
    
    if (preopreciona.carId.isNotEmpty) {
      role = preopreciona.carId;
    }
    return carsProvider.when(
      data: (data) => DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          labelText: 'Seleccione un carro',
        ),
        value: role,
        items: data.entries
            .map(
              (e) => DropdownMenuItem(
                value: e.key,
                child: Text(e.value.carPlate),
              ),
            )
            .toList(),
        onChanged: (value) {
          role = value;
          ref.read(preoperacionalDbProvider.notifier).updateCarId(value ?? '');
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}
