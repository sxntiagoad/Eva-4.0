import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva/models/car.dart';
import 'package:eva/models/health_report.dart';
import 'package:eva/models/limpieza.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final excelFilesProvider = FutureProvider.autoDispose((ref) async {
  ref.watch(refreshTriggerProvider);

  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("Usuario no autenticado");
    }
    final storageRef = FirebaseStorage.instance.ref().child('reportes_salud/');
    final ListResult result = await storageRef.listAll();
    return result.items.map((item) => item.name).toList();
  } catch (e) {
    throw Exception("Error al obtener archivos de Storage: $e");
  }
});

final saludByUidProvider = FutureProvider.autoDispose
    .family<HealthReport?, String>((ref, uid) async {
  ref.watch(refreshTriggerProvider);

  if (uid.isEmpty) return null;
  final docId = uid.split('.')[0];
  if (docId.isEmpty) return null;

  try {
    final doc = await FirebaseFirestore.instance
        .collection('health_reports')
        .doc(docId)
        .get();
    return doc.exists
        ? HealthReport.fromMap(doc.data()!).copyWith(docId: doc.id)
        : null;
  } catch (e) {
    return null;
  }
});

final refreshTriggerProvider = StateProvider.autoDispose((ref) => 0);

final healthReportFilesProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, String>((ref, userId) async {
  ref.watch(refreshTriggerProvider);
  if (userId.isEmpty) return [];

  try {
    final storageRef = FirebaseStorage.instance.ref().child('reportes_salud/');
    final ListResult result = await storageRef.listAll();
    List<Map<String, dynamic>> healthFiles = [];

    await Future.wait(result.items.map((item) async {
      try {
        final reportUid = item.name.split('.')[0];
        final doc = await FirebaseFirestore.instance
            .collection('health_reports')
            .doc(reportUid)
            .get();

        if (doc.exists && doc.data()!['userId'] == userId) {
          DateTime fecha;
          try {
            fecha = DateTime.parse(doc.data()!['fecha'].toString());
          } catch (e) {
            fecha = DateTime.now();
          }

          healthFiles.add({
            'fileName': item.name,
            'fecha': fecha,
            'isOpen': doc.data()!['isOpen'],
            'reportUid': doc.id,
          });
        }
      } catch (_) {}
    }));

    healthFiles.sort((a, b) => 
      (b['fecha'] as DateTime).compareTo(a['fecha'] as DateTime)
    );

    return healthFiles;
  } catch (e) {
    return [];
  }
});

class SelectedHealthFilesNotifier extends StateNotifier<Set<String>> {
  SelectedHealthFilesNotifier() : super({});

  void toggleSelection(String fileName) {
    if (state.contains(fileName)) {
      state = Set.from(state)..remove(fileName);
    } else {
      state = Set.from(state)..add(fileName);
    }
  }

  void clearSelection() {
    state = {};
  }
}

final selectedHealthFilesProvider =
    StateNotifierProvider<SelectedHealthFilesNotifier, Set<String>>((ref) {
  return SelectedHealthFilesNotifier();
});

Future<void> deleteSelectedHealthFiles(WidgetRef ref) async {
  final selectedFiles = ref.read(selectedHealthFilesProvider);
  if (selectedFiles.isEmpty) return;

  try {
    await ref.read(deleteHealthFilesProvider(selectedFiles.toList()).future);
    await Future.delayed(const Duration(milliseconds: 200));
    ref.read(selectedHealthFilesProvider.notifier).clearSelection();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(refreshTriggerProvider.notifier).update((state) => state + 1);
    });
  } catch (e) {
    print('Error en deleteSelectedHealthFiles: $e');
  }
}

final deleteHealthFilesProvider = FutureProvider.autoDispose.family<void, List<String>>(
  (ref, fileNames) async {
    if (fileNames.isEmpty) return;

    final storageRef = FirebaseStorage.instance.ref().child('reportes_salud/');
    final firestoreRef = FirebaseFirestore.instance.collection('health_reports');

    List<String> errors = [];

    await Future.forEach(fileNames, (String fileName) async {
      final docId = fileName.split('.')[0];
      if (docId.isEmpty) return;

      try {
        await Future.wait([
          storageRef.child(fileName).delete().catchError((e) {
            errors.add('Error al eliminar archivo $fileName de Storage: $e');
            return null;
          }),
          
          firestoreRef.doc(docId).delete().catchError((e) {
            errors.add('Error al eliminar documento $docId de Firestore: $e');
            return null;
          }),
        ]);

        await Future.delayed(const Duration(milliseconds: 50));
        
      } catch (e) {
        errors.add('Error general en la eliminación de $fileName: $e');
      }
    });

    if (errors.isNotEmpty) {
      throw Exception(errors.join('\n'));
    }
  }
);