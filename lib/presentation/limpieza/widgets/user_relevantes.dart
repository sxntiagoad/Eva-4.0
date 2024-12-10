import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva/providers/limpieza/limpieza_db_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/users_provider.dart';

class UserRelevantes extends ConsumerStatefulWidget {
  const UserRelevantes({super.key});

  @override
  ConsumerState<UserRelevantes> createState() => _UserRelevantesState();
}

class _UserRelevantesState extends ConsumerState<UserRelevantes> {
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
    final limpieza = ref.watch(limpiezaDbProvider);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Usuarios Relevantes:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  alignment: WrapAlignment.start,
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: limpieza.relevantes.map((usuarioUid) {
                    final usuario = usuariosFiltrados.firstWhere(
                      (u) => u['uid'] == usuarioUid,
                      orElse: () => {'fullName': 'Usuario Desconocido'},
                    );
                    final nombreUsuario =
                        usuario['fullName'] ?? 'Usuario Desconocido';

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.blue.shade100,
                          width: 1,
                        ),
                      ),
                      child: Chip(
                        label: Text(
                          nombreUsuario,
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 13,
                          ),
                        ),
                        backgroundColor: Colors.transparent,
                        deleteIcon: Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.blue.shade400,
                        ),
                        onDeleted: () {
                          final nuevosRelevantes =
                              List<String>.from(limpieza.relevantes)
                                ..remove(usuarioUid);
                          ref
                              .read(limpiezaDbProvider.notifier)
                              .updateRelevantes(nuevosRelevantes);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('Usuario eliminado: $nombreUsuario'),
                              duration: const Duration(seconds: 1),
                              backgroundColor: Colors.blue.shade700,
                            ),
                          );
                        },
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          ListTile(
            title: Text(
              'Agregar Usuario Relevante',
              style: TextStyle(
                color: Colors.blue.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: Icon(
              _isExpanded ? Icons.expand_less : Icons.expand_more,
              color: Colors.blue.shade400,
            ),
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
                if (!_isExpanded) {
                  _searchController.clear();
                  _filtrarUsuarios('');
                }
              });
            },
            hoverColor: Colors.blue.shade50,
            splashColor: Colors.blue.shade100,
          ),
          if (_isExpanded) ...[
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextField(
                controller: _searchController,
                onChanged: _filtrarUsuarios,
                decoration: InputDecoration(
                  hintText: 'Buscar usuario...',
                  hintStyle: TextStyle(color: Colors.blue.shade200),
                  prefixIcon: Icon(Icons.search, color: Colors.blue.shade400),
                  filled: true,
                  fillColor: Colors.blue.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blue.shade100),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blue.shade100),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blue.shade400),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: usuariosFiltrados.length,
                itemBuilder: (context, index) {
                  final usuario = usuariosFiltrados[index];
                  final fullName = usuario['fullName'] ?? 'Nombre desconocido';
                  final bool yaSeleccionado =
                      limpieza.relevantes.contains(usuario['uid']);

                  return ListTile(
                    title: Text(
                      fullName,
                      style: TextStyle(
                        color: yaSeleccionado
                            ? Colors.blue.shade700
                            : Colors.black87,
                      ),
                    ),
                    trailing: Icon(
                      yaSeleccionado
                          ? Icons.check_circle
                          : Icons.add_circle_outline,
                      color: yaSeleccionado
                          ? Colors.blue.shade400
                          : Colors.blue.shade200,
                    ),
                    onTap: () async {
                      if (!yaSeleccionado) {
                        final uid = usuario['uid'] ?? '';
                        final nuevosRelevantes =
                            List<String>.from(limpieza.relevantes)..add(uid);

                        ref
                            .read(limpiezaDbProvider.notifier)
                            .updateRelevantes(nuevosRelevantes);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Usuario agregado: $fullName'),
                            duration: const Duration(seconds: 1),
                            backgroundColor: Colors.blue.shade700,
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
