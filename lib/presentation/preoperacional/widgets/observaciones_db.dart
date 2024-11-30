import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/preoperacional_db_provider.dart';

class ObservacionesDbWidget extends ConsumerStatefulWidget {
  const ObservacionesDbWidget({super.key});

  @override
  _ObservacionesDbWidgetState createState() => _ObservacionesDbWidgetState();
}

class _ObservacionesDbWidgetState extends ConsumerState<ObservacionesDbWidget> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final preoperacional = ref.read(preoperacionalDbProvider);
    _controller = TextEditingController(text: preoperacional.observaciones);
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
          ref.read(preoperacionalDbProvider.notifier).updateObservaciones(value);
        },
      ),
    );
  }
}