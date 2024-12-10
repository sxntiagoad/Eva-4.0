import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/limpieza.dart';
import 'package:firebase_auth/firebase_auth.dart';


Future<List<Limpieza>> getAllLimpiezas() async {
  try {
    final String userId = FirebaseAuth.instance.currentUser!.uid;
    
    final queryOwner = await FirebaseFirestore.instance
        .collection('limpieza')
        .where('userId', isEqualTo: userId)
        .where('isOpen', isEqualTo: true)
        .get();

    final queryRelevant = await FirebaseFirestore.instance
        .collection('limpieza')
        .where('relevantes', arrayContains: userId)
        .where('isOpen', isEqualTo: true)
        .get();

    // Usamos un Map para evitar duplicados
    Map<String, Limpieza> limpiezasMap = {};

    // Agregamos los documentos del propietario
    for (var doc in queryOwner.docs) {
      limpiezasMap[doc.id] = Limpieza.fromMap(doc.data())
          .copyWith(docId: doc.id);
    }

    // Agregamos los documentos relevantes (si ya existe uno con el mismo ID, se sobrescribe)
    for (var doc in queryRelevant.docs) {
      limpiezasMap[doc.id] = Limpieza.fromMap(doc.data())
          .copyWith(docId: doc.id);
    }

    // Convertimos el Map a List
    List<Limpieza> limpiezas = limpiezasMap.values.toList();

    // Ordenamos los resultados
    limpiezas.sort((a, b) {
      DateTime fechaA = DateTime.parse(a.fecha);
      DateTime fechaB = DateTime.parse(b.fecha);
      return fechaB.compareTo(fechaA);
    });
    return limpiezas;
  } catch (e) {
    rethrow;
  }
}

final openLimpiezasProvider =
    FutureProvider.autoDispose<List<Limpieza>>((ref) async {
  return await getAllLimpiezas();
});

final limpiezaByIdProvider = StreamProvider.family<Limpieza?, String>((ref, docId) {
  return FirebaseFirestore.instance
      .collection('limpieza')
      .doc(docId)
      .snapshots()
      .map((doc) {
        if (!doc.exists) return null;
        return Limpieza.fromMap({
          ...doc.data()!,
          'docId': doc.id,
        });
      });
});
