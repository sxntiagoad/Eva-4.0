import 'package:eva/providers/edit_user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/signature.dart';
import '../widgets/user_photo.dart';

class UserDataScreen extends ConsumerStatefulWidget {
  static const name = 'user-data-screen';
  const UserDataScreen({super.key});

  @override
  _UserDataScreenState createState() => _UserDataScreenState();
}

class _UserDataScreenState extends ConsumerState<UserDataScreen> {
  // Primero definimos algunos colores constantes
  final _softBlue = const Color(0xFF5B86E5);
  final _lightBlue = const Color(0xFFEDF2FF);
  final _textBlue = const Color(0xFF36455A);

  @override
  Widget build(BuildContext context) {
    final userDataNotifier = ref.watch(userDataProvider.notifier);
    final userData = ref.watch(userDataProvider);
    final isEditing = userDataNotifier.isEditing;

    if (userData == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _softBlue,
        title: Text('Datos personales',
            style: TextStyle(color: _textBlue, fontWeight: FontWeight.w600)),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              isEditing ? Icons.check_circle_outline : Icons.edit_outlined,
              color: _softBlue,
            ),
            onPressed: () {
              if (isEditing) {
                userDataNotifier.saveChanges();
              }
              userDataNotifier.toggleEditing();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const UserPhoto(),
              const SizedBox(height: 32),
              _buildTextField('Nombre completo', userData.fullName, isEditing,
                  (value) => userDataNotifier.updateField('fullName', value)),
              const SizedBox(height: 20),
              _buildTextField('Email', userData.email, isEditing,
                  (value) => userDataNotifier.updateField('email', value)),
              const SizedBox(height: 20),
              _buildReadOnlyField('Cargo', userData.role),
              const SizedBox(height: 20),
              SignatureWidget(
                key: ValueKey(userData.email),
                initialSignatureUrl: userData.signature,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: isEditing
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.mainColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: userDataNotifier.saveChanges,
                child: const Text(
                  'Guardar cambios',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildTextField(String label, String initialValue, bool isEditing,
      Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: _softBlue.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: _softBlue, width: 1.5),
              borderRadius: BorderRadius.circular(12),
            ),
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[100]!),
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: isEditing ? Colors.white : _lightBlue.withOpacity(0.5),
          ),
          style: TextStyle(
            color: _textBlue,
            fontSize: 15,
          ),
          enabled: isEditing,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: _lightBlue.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _softBlue.withOpacity(0.2)),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: _textBlue,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }
}
