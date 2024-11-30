import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/limpieza/limpiezas_provider.dart';
import '../widgets/limpiezas_card.dart';

class LimpiezasScreen extends ConsumerWidget {
  static const name = 'limpiezas-screen';
  
  const LimpiezasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final limpiezasAsync = ref.watch(openLimpiezasProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Limpiezas Abiertas'),
      ),
      body: limpiezasAsync.when(
        data: (limpiezas) {
          if (limpiezas.isEmpty) {
            return const Center(
              child: Text('No hay limpiezas abiertas'),
            );
          }

          return ListView.builder(
            itemCount: limpiezas.length,
            itemBuilder: (context, index) {
              final limpieza = limpiezas[index];
              return LimpiezasCard(limpieza: limpieza);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error al cargar las limpiezas: $error'),
        ),
      ),
    );
  }
}