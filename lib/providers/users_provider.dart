import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final usersProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final querySnapshot = await FirebaseFirestore.instance
      .collection('users')
      .where('role', isEqualTo: "CONDUCTOR")
      .get();
  
  // Agregamos el ID del documento a cada map de datos
  return querySnapshot.docs.map((doc) => {
    ...doc.data(),
    'uid': doc.id, // Agregamos el ID del documento como 'uid'
  }).toList();
});
class UserFilteredNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  UserFilteredNotifier(this.ref) : super([]) {
    _initialize();
  }

  final Ref ref;

  void _initialize() {
    ref.listen<AsyncValue<List<Map<String, dynamic>>>>(usersProvider,
        (previous, next) {
      next.whenData((users) {
        state = users; // Inicialmente, todos los usuarios
      });
    });
  }

  void filterUsers(String query) {
    final usersAsyncValue = ref.read(usersProvider);
    usersAsyncValue.whenData((users) {
      state = users
          .where((user) => (user['fullName'] ?? '')
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    });
  }
}

class RelevantUsersNotifier extends StateNotifier<List<String>> {
  RelevantUsersNotifier() : super([]);

  void addRelevante(Map<String, dynamic> user) {
    final fullName = user['fullName'] as String?;
    if (fullName != null && !state.contains(fullName)) {
      state = [...state, fullName];
      print('✅ Usuario agregado exitosamente: $fullName');
    } else {
      print('❌ No se pudo agregar el usuario: $fullName');
    }
  }

  void removeRelevante(String fullName) {
    state = state.where((name) => name != fullName).toList();
    print('Usuario eliminado: $fullName');
  }
}

final userFilteredProvider =
    StateNotifierProvider<UserFilteredNotifier, List<Map<String, dynamic>>>(
  (ref) => UserFilteredNotifier(ref),
);

final relevantUsersProvider =
    StateNotifierProvider<RelevantUsersNotifier, List<String>>(
  (ref) => RelevantUsersNotifier(),
);
