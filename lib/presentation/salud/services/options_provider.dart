import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final optionsProvider = FutureProvider<List<String>>((ref) async {
  final firestore = FirebaseFirestore.instance;
  final docSnapshot = await firestore.collection('proyectos').doc('list_proyectos').get();

  if (docSnapshot.exists) {
    final data = docSnapshot.data();
    if (data != null && data['proyectos'] is List) {
      return List<String>.from(data['proyectos']);
    }
  }
  return [];
});
