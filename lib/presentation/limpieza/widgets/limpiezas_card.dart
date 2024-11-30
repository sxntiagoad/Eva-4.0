import 'package:eva/core/theme/app_theme.dart';
import 'package:eva/models/car.dart';
import 'package:eva/models/limpieza.dart';
import 'package:eva/presentation/limpieza/screens/edit_limpieza_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/car_provider.dart';

class LimpiezasCard extends ConsumerWidget {
  final Limpieza limpieza;
  const LimpiezasCard({
    super.key,
    required this.limpieza,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapCars = ref.watch(mapCarsProvider);
    return mapCars.when(
      data: (data) => _ListTitleLimpieza(
        limpieza: limpieza,
        data: data,
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}

class _ListTitleLimpieza extends StatelessWidget {
  final Limpieza limpieza;
  final Map<String, Car> data;
  const _ListTitleLimpieza({
    required this.limpieza,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        '${data[limpieza.carId]?.carPlate ?? ''} - ${data[limpieza.carId]?.brand ?? ''}',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppTheme.mainColor,
        ),
      ),
      subtitle: Text(limpieza.fecha),
      trailing: limpieza.isOpen
          ? const Icon(
              Icons.lock_open_outlined,
              color: Colors.green,
            )
          : const Icon(
              Icons.lock,
              color: Colors.red,
            ),
      onTap: () {
        context.pushNamed(
          EditLimpiezaScreen.name,
          extra: limpieza,
        );
      },
    );
  }
}