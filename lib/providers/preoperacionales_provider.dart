import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva/models/preoperacional.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<List<Preoperacional>> getAllPreoperacionales() async {
  try {
    final String userId = FirebaseAuth.instance.currentUser!.uid;
    
    final queryOwner = await FirebaseFirestore.instance
        .collection('preoperacionales')
        .where('userId', isEqualTo: userId)
        .where('isOpen', isEqualTo: true)
        .get();

    final queryRelevant = await FirebaseFirestore.instance
        .collection('preoperacionales')
        .where('relevantes', arrayContains: userId)
        .where('isOpen', isEqualTo: true)
        .get();

    // Combinamos los resultados directamente
    List<Preoperacional> preoperacionales = [
      ...queryOwner.docs.map((doc) => 
        Preoperacional.fromMap(doc.data()).copyWith(docId: doc.id)
      ),
      ...queryRelevant.docs.map((doc) => 
        Preoperacional.fromMap(doc.data()).copyWith(docId: doc.id)
      ),
    ];

    // Eliminamos duplicados si es necesario usando un Set
    preoperacionales = preoperacionales.toSet().toList();

    // Ordenamos los resultados
    preoperacionales.sort((a, b) {
      final aDate = a.fechaFinal.isNotEmpty ? a.fechaFinal : a.fechaInit;
      final bDate = b.fechaFinal.isNotEmpty ? b.fechaFinal : b.fechaInit;
      return bDate.compareTo(aDate);
    });

    return preoperacionales;
  } catch (e) {
    rethrow;
  }
}

final allPreoperacionalesProvider =
    FutureProvider.autoDispose<List<Preoperacional>>((ref) async {
  return await getAllPreoperacionales();
});

// Nuevo provider para obtener todos los preoperacionales sin importar 'isOpen' o 'userId'
Future<List<Preoperacional>> getAllPreoperacionalesUnfiltered() async {
  try {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('preoperacionales')
        .get();

    List<Preoperacional> preoperacionales = querySnapshot.docs.map((doc) {
      return Preoperacional.fromMap(doc.data()).copyWith(docId: doc.id);
    }).toList();

    return preoperacionales;
  } catch (e) {
    rethrow;
  }
}

final allPreoperacionalesUnfilteredProvider =
    FutureProvider.autoDispose<List<Preoperacional>>((ref) async {
  return await getAllPreoperacionalesUnfiltered();
});
