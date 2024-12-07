import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/salud/new_health_report_provider.dart';

class SaveHealthReportButton extends ConsumerStatefulWidget {
  final Function(bool) onSavingStateChanged;
  final Future<void> Function() onSave;
  final bool ignoreValidation;

  const SaveHealthReportButton({
    required this.onSavingStateChanged,
    required this.onSave,
    this.ignoreValidation = false,
    super.key,
  });

  @override
  SaveHealthReportButtonState createState() => SaveHealthReportButtonState();
}

class SaveHealthReportButtonState extends ConsumerState<SaveHealthReportButton> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final healthReport = ref.watch(newHealthReportProvider);
    final isValid = widget.ignoreValidation || ref.watch(isHealthReportValidProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: FilledButton(
        onPressed: isLoading || !isValid
            ? null
            : () async {
                setState(() => isLoading = true);
                widget.onSavingStateChanged(true);

                try {
                  await widget.onSave();
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error al guardar: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } finally {
                  setState(() => isLoading = false);
                  widget.onSavingStateChanged(false);
                }
              },
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.disabled)) return Colors.grey;
            return healthReport.isOpen ? Colors.green : Colors.red;
          }),
        ),
        child: isLoading
            ? const SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : Text(
                healthReport.isOpen
                    ? 'Guardar Autoreporte (Abierto)'
                    : 'Guardar Autoreporte (Cerrado)',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}