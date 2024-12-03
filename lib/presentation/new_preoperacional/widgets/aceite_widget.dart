import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/new_preoperacional_provider.dart';

class AceiteWidget extends ConsumerStatefulWidget {
  const AceiteWidget({super.key});

  @override
  AceiteWidgetState createState() => AceiteWidgetState();
}

class AceiteWidgetState extends ConsumerState<AceiteWidget> {
  final TextEditingController _ultimoController = TextEditingController();
  final TextEditingController _proximoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final preoperacional = ref.read(newPreoperacionalProvider);
    _ultimoController.text = preoperacional.ultimoCambioAceite != 0 
        ? preoperacional.ultimoCambioAceite.toString() 
        : '';
    _proximoController.text = preoperacional.proximoCambioAceite != 0 
        ? preoperacional.proximoCambioAceite.toString() 
        : '';
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
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildAceiteField(
          context,
          'Último',
          _ultimoController,
          (value) => ref
              .read(newPreoperacionalProvider.notifier)
              .updateUltimoCambioAceite(value),
        ),
        const SizedBox(width: 2),
        _buildAceiteField(
          context,
          'Próximo',
          _proximoController,
          (value) => ref
              .read(newPreoperacionalProvider.notifier)
              .updateProximoCambioAceite(value),
        ),
      ],
    );
  }

  Widget _buildAceiteField(
    BuildContext context,
    String label,
    TextEditingController controller,
    Function(int) onChanged,
  ) {
    return SizedBox(
      width: 140,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: 'Cambio $label',
          hintText: 'Kilometraje',
          helperText: label == 'Último' ? 'Último cambio' : 'Próximo cambio',
          helperStyle: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        onChanged: (value) {
          final kilometraje = int.tryParse(value) ?? 0;
          onChanged(kilometraje);
        },
      ),
    );
  }
}