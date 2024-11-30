import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/limpieza.dart';
import 'package:firebase_auth/firebase_auth.dart';

final openLimpiezasProvider = StreamProvider<List<Limpieza>>((ref) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  
  if (userId == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('limpieza')
      .where('isOpen', isEqualTo: true)
      .where('userId', isEqualTo: userId)
      .snapshots()
      .map((snapshot) {
        final limpiezas = snapshot.docs.map((doc) {
          final data = doc.data();
          return Limpieza.fromMap({
            ...data,
            'docId': doc.id,
          });
        }).toList();

        // Ordenar por fecha descendente (más reciente primero)
        limpiezas.sort((a, b) {
          final fechaA = DateTime.parse(a.fecha);
          final fechaB = DateTime.parse(b.fecha);
          return fechaB.compareTo(fechaA); // Orden descendente
        });

        return limpiezas;
      });
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
