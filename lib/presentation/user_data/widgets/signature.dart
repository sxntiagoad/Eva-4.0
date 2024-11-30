import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signature/signature.dart';
import '../../../providers/signature_provider.dart';

const _softBlue = Color(0xFF5B86E5);
const _lightBlue = Color(0xFFEDF2FF);
const _textBlue = Color(0xFF36455A);

class SignatureWidget extends ConsumerStatefulWidget {
  final String? initialSignatureUrl;

  const SignatureWidget({super.key, this.initialSignatureUrl});

  @override
  ConsumerState<SignatureWidget> createState() => _SignatureWidgetState();
}

class _SignatureWidgetState extends ConsumerState<SignatureWidget> {
  late SignatureController _signatureController;

  @override
  void initState() {
    super.initState();
    _signatureController = SignatureController(
      penStrokeWidth: 2,
      penColor: Colors.black87,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(signatureProvider.notifier).setSignature(widget.initialSignatureUrl);
    });
  }

  @override
  void dispose() {
    _signatureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final signatureUrl = ref.watch(signatureProvider);
    final isEditing = ref.watch(isEditingProvider);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _softBlue.withOpacity(0.2)),
        color: _lightBlue.withOpacity(0.5),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tu firma',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                if (!isEditing && signatureUrl != null)
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        signatureUrl,
                        key: ValueKey(signatureUrl),
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(
                              color: _softBlue,
                              strokeWidth: 2,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Text(
                              'Error al cargar la firma',
                              style: TextStyle(color: _textBlue),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                if (isEditing)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _softBlue.withOpacity(0.3)),
                    ),
                    child: Signature(
                      controller: _signatureController,
                      width: double.infinity,
                      height: 200,
                      backgroundColor: Colors.white,
                    ),
                  ),
                const SizedBox(height: 16),
                if (!isEditing)
                  Center(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ref.read(isEditingProvider.notifier).state = true;
                      },
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      label: const Text('Modificar firma'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _softBlue,
                        side: const BorderSide(color: _softBlue),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                if (isEditing)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          _signatureController.clear();
                          ref.read(isEditingProvider.notifier).state = false;
                        },
                        icon: const Icon(Icons.close, size: 20),
                        label: const Text('Cancelar'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey[700],
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final signatureImage = await _signatureController.toPngBytes();
                          if (signatureImage != null) {
                            await ref.read(signatureProvider.notifier).saveSignature(signatureImage);
                            ref.read(isEditingProvider.notifier).state = false;
                            _signatureController.clear();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Por favor, dibuja tu firma antes de guardar'),
                                backgroundColor: _softBlue,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.check, size: 20),
                        label: const Text('Guardar firma'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _softBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}