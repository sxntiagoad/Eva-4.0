import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/new_preoperacional_provider.dart';

class KilometrajeWidget extends ConsumerStatefulWidget {
  const KilometrajeWidget({super.key});

  @override
  KilometrajeWidgetState createState() => KilometrajeWidgetState();
}

class KilometrajeWidgetState extends ConsumerState<KilometrajeWidget> {
  final TextEditingController _inicialController = TextEditingController();
  final TextEditingController _finalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final preoperacional = ref.read(newPreoperacionalProvider);
    _inicialController.text = preoperacional.kilometrajeInit != 0 
        ? preoperacional.kilometrajeInit.toString() 
        : '';
    _finalController.text = preoperacional.kilometrajeFinal != 0 
        ? preoperacional.kilometrajeFinal.toString() 
        : '';
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
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildKilometrajeField(
          context,
          'Inicial',
          _inicialController,
          (value) => ref
              .read(newPreoperacionalProvider.notifier)
              .updateKilometrajeInit(value),
        ),
        const SizedBox(width: 2),
        _buildKilometrajeField(
          context,
          'Final',
          _finalController,
          (value) => ref
              .read(newPreoperacionalProvider.notifier)
              .updateKilometrajeFinal(value),
        ),
      ],
    );
  }

  Widget _buildKilometrajeField(
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
