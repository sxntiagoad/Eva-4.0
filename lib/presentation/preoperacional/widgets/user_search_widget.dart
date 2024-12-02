import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/users_provider.dart';
import '../../../providers/preoperacional_db_provider.dart';

class UserSearchWidget extends ConsumerStatefulWidget {
  const UserSearchWidget({super.key});

  @override
  ConsumerState<UserSearchWidget> createState() => _UserSearchWidgetState();
}

class _UserSearchWidgetState extends ConsumerState<UserSearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  bool _isExpanded = false;

  void _filtrarUsuarios(String query) {
    ref.read(userFilteredProvider.notifier).filterUsers(query);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usuariosFiltrados = ref.watch(userFilteredProvider);
    final usuariosRelevantes = ref.watch(relevantUsersProvider);
    final preoperacional = ref.watch(preoperacionalDbProvider);

    return Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Usuarios Relevantes:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: preoperacional.relevantes.map((usuarioUid) {
                    final usuario = usuariosFiltrados.firstWhere(
                      (u) => u['uid'] == usuarioUid,
                      orElse: () => {'fullName': 'Usuario Desconocido'},
                    );
                    final nombreUsuario = usuario['fullName'] ?? 'Usuario Desconocido';

                    return Chip(
                      label: Text(nombreUsuario),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () {
                        final nuevosRelevantes = List<String>.from(preoperacional.relevantes)
                          ..remove(usuarioUid);
                        ref
                            .read(preoperacionalDbProvider.notifier)
                            .updateRelevantes(nuevosRelevantes);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Usuario eliminado: $nombreUsuario'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          ListTile(
            title: const Text('Agregar Usuario Relevante'),
            trailing: IconButton(
              icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                  if (!_isExpanded) {
                    _searchController.clear();
                    _filtrarUsuarios('');
                  }
                });
              },
            ),
          ),
          if (_isExpanded) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _searchController,
                onChanged: _filtrarUsuarios,
                decoration: InputDecoration(
                  hintText: 'Buscar usuario...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: usuariosFiltrados.length,
                itemBuilder: (context, index) {
                  final usuario = usuariosFiltrados[index];
                  final fullName = usuario['fullName'] ?? 'Nombre desconocido';
                  final bool yaSeleccionado =
                      preoperacional.relevantes.contains(usuario['uid']);

                  return ListTile(
                    title: Text(fullName),
                    trailing: yaSeleccionado
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : const Icon(Icons.add_circle_outline),
                    onTap: () async {
                      if (!yaSeleccionado) {
                        final uid = usuario['uid'] ?? '';
                        final nuevosRelevantes = List<String>.from(preoperacional.relevantes)
                          ..add(uid);

                        ref
                            .read(preoperacionalDbProvider.notifier)
                            .updateRelevantes(nuevosRelevantes);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Usuario agregado: $fullName'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
