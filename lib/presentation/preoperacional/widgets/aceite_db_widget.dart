import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/preoperacional_db_provider.dart';

class AceiteDbWidget extends ConsumerStatefulWidget {
  const AceiteDbWidget({super.key});

  @override
  ConsumerState<AceiteDbWidget> createState() => _AceiteDbWidgetState();
}

class _AceiteDbWidgetState extends ConsumerState<AceiteDbWidget> {
  late TextEditingController _ultimoController;
  late TextEditingController _proximoController;

  @override
  void initState() {
    super.initState();
    _ultimoController = TextEditingController();
    _proximoController = TextEditingController();
  }

  @override
  void dispose() {
    _ultimoController.dispose();
    _proximoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildAceiteField(
          context,
          ref,
          'Último',
          (value) => ref
              .read(preoperacionalDbProvider.notifier)
              .updateUltimoCambioAceite(value),
        ),
        const SizedBox(width: 3),
        _buildAceiteField(
          context,
          ref,
          'Próximo',
          (value) => ref
              .read(preoperacionalDbProvider.notifier)
              .updateProximoCambioAceite(value),
        ),
      ],
    );
  }

  Widget _buildAceiteField(
    BuildContext context,
    WidgetRef ref,
    String label,
    Function(int) onChanged,
  ) {
    final preoperacional = ref.watch(preoperacionalDbProvider);
    final controller = label == 'Último' ? _ultimoController : _proximoController;
    
    // Actualizar el texto del controller solo si es diferente
    final newValue = label == 'Último'
        ? preoperacional.ultimoCambioAceite.toString()
        : preoperacional.proximoCambioAceite.toString();
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
          labelText: 'Cambio Aceite $label',
        ),
        onChanged: (value) {
          final kilometraje = int.tryParse(value) ?? 0;
          onChanged(kilometraje);
        },
      ),
    );
  }
}