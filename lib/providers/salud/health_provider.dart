import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva/models/health_report.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

final allHealthProvider = StreamProvider<List<HealthReport>>((ref) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  
  if (userId == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('health_reports')
      .where('isOpen', isEqualTo: true)
      .where('userId', isEqualTo: userId)
      .snapshots()
      .map((snapshot) {
        final healthRecords = snapshot.docs.map((doc) {
          final data = doc.data();
          return HealthReport.fromMap({
            ...data,
            'docId': doc.id,
          });
        }).toList();

        healthRecords.sort((a, b) {
          final fechaA = DateTime.parse(a.fecha);
          final fechaB = DateTime.parse(b.fecha);
          return fechaB.compareTo(fechaA);
        });

        return healthRecords;
      });
});

final userNameProvider = FutureProvider.family<String, String>((ref, userId) async {
  final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
  if (userDoc.exists) {
    return userDoc.data()?['fullName'] ?? 'Nombre no disponible';
  } else {
    throw Exception('Usuario no encontrado');
  }
});