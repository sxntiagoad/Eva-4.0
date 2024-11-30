import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:eva/models/limpieza.dart';

class LimpiezaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> saveLimpieza(Limpieza limpieza) async {
    try {
      // Verificar que hay un usuario autenticado
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('No hay usuario autenticado');
      }

      // Verificar que el userId coincide con el usuario actual
      if (limpieza.userId != currentUser.uid) {
        throw Exception('Usuario no autorizado');
      }

      // Crear nuevo documento con ID automático
      final docRef = await _firestore.collection('limpieza').add(limpieza.toMap());
      
      // Actualizar el documento con su ID
      await docRef.update({'docId': docRef.id});
      
      return docRef.id;
    } catch (e) {
      throw Exception('Error al guardar limpieza: $e');
    }
  }

  // Método para obtener limpiezas del usuario actual
  Stream<List<Limpieza>> getLimpiezasByUser() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('No hay usuario autenticado');

    return _firestore
        .collection('limpieza')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Limpieza.fromMap(doc.data()))
            .toList());
  }
}