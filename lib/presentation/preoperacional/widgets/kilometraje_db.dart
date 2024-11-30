import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/preoperacional_db_provider.dart';

class KilometrajeDbWidget extends ConsumerStatefulWidget {
  const KilometrajeDbWidget({super.key});

  @override
  ConsumerState<KilometrajeDbWidget> createState() => _KilometrajeDbWidgetState();
}

class _KilometrajeDbWidgetState extends ConsumerState<KilometrajeDbWidget> {
  late TextEditingController _inicialController;
  late TextEditingController _finalController;

  @override
  void initState() {
    super.initState();
    _inicialController = TextEditingController();
    _finalController = TextEditingController();
  }

  @override
  void dispose() {
    _inicialController.dispose();
    _finalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildKilometrajeField(
          context,
          ref,
          'Inicial',
          (value) => ref
              .read(preoperacionalDbProvider.notifier)
              .updateKilometrajeInit(value),
        ),
        const SizedBox(width: 3),
        _buildKilometrajeField(
          context,
          ref,
          'Final',
          (value) => ref
              .read(preoperacionalDbProvider.notifier)
              .updateKilometrajeFinal(value),
        ),
      ],
    );
  }

  Widget _buildKilometrajeField(
    BuildContext context,
    WidgetRef ref,
    String label,
    Function(int) onChanged,
  ) {
    final preoperacional = ref.watch(preoperacionalDbProvider);
    final controller = label == 'Inicial' ? _inicialController : _finalController;
    
    // Actualizar el texto del controller solo si es diferente
    final newValue = label == 'Inicial'
        ? preoperacional.kilometrajeInit.toString()
        : preoperacional.kilometrajeFinal.toString();
    if (controller.text != newValue) {
      controller.text = newValue;
    }

    return SizedBox(
      width: 150, // Ancho fijo para ambos campos
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: 'Kilometraje $label',
        ),
        onChanged: (value) {
          final kilometraje = int.tryParse(value) ?? 0;
          onChanged(kilometraje);
        },
      ),
    );
  }
}