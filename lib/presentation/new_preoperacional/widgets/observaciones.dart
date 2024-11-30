import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/new_preoperacional_provider.dart';

class ObservacionesWidget extends ConsumerStatefulWidget {
  const ObservacionesWidget({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ObservacionesWidgetState createState() => _ObservacionesWidgetState();
}

class _ObservacionesWidgetState extends ConsumerState<ObservacionesWidget> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final newPreoperacional = ref.read(newPreoperacionalProvider);
    _controller = TextEditingController(text: newPreoperacional.observaciones);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        maxLines: 3,
        decoration: const InputDecoration(
          labelText: 'Observaciones',
          border: OutlineInputBorder(),
        ),
        controller: _controller,
        onChanged: (value) {
          ref.read(newPreoperacionalProvider.notifier).updateObservaciones(value);
        },
      ),
    );
  }
}