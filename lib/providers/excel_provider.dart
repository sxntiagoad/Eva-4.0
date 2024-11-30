import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:eva/models/preoperacional.dart';
import 'package:eva/models/car.dart';

final excelFilesProvider = FutureProvider.autoDispose((ref) async {
  ref.watch(refreshTriggerProvider);

  try {
    final storageRef =
        FirebaseStorage.instance.ref().child('preoperacionales/');
    final ListResult result = await storageRef.listAll();
    return result.items.map((item) => item.name).toList();
  } catch (e) {
    throw Exception("Error al obtener archivos de Storage: $e");
  }
});

final preoperacionalByUidProvider = FutureProvider.autoDispose
    .family<Preoperacional?, String>((ref, uid) async {
  ref.watch(refreshTriggerProvider);

  if (uid.isEmpty) return null;
  final docId = uid.split('.')[0];
  if (docId.isEmpty) return null;

  try {
    final doc = await FirebaseFirestore.instance
        .collection('preoperacionales')
        .doc(docId)
        .get();
    return doc.exists
        ? Preoperacional.fromMap(doc.data()!).copyWith(docId: doc.id)
        : null;
  } catch (e) {
    return null;
  }
});

final carByIdProvider =
    FutureProvider.autoDispose.family<Car?, String>((ref, carId) async {
  ref.watch(refreshTriggerProvider);
  if (carId.isEmpty) return null;

  try {
    final doc =
        await FirebaseFirestore.instance.collection('cars').doc(carId).get();
    return doc.exists ? Car.fromMap(doc.data()!) : null;
  } catch (e) {
    return null;
  }
});

final userByIdProvider =
    FutureProvider.autoDispose.family<String, String>((ref, userId) async {
  ref.watch(refreshTriggerProvider);
  if (userId.isEmpty) return 'Usuario Desconocido';

  try {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return (doc.exists && doc.data()!.containsKey('fullName'))
        ? doc.data()!['fullName'] as String
        : 'Usuario Desconocido';
  } catch (e) {
    return 'Usuario Desconocido';
  }
});

final refreshTriggerProvider = StateProvider.autoDispose((ref) => 0);

final relevantExcelFilesProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, String>((ref, carPlate) async {
  ref.watch(refreshTriggerProvider);
  if (carPlate.isEmpty) return [];

  try {
    final excelFiles = await ref.watch(excelFilesProvider.future);
    List<Map<String, dynamic>> relevantFiles = [];

    await Future.wait(excelFiles.map((file) async {
      try {
        final preoperacionalUid = file.split('.')[0];
        final preoperacional = await ref
            .read(preoperacionalByUidProvider(preoperacionalUid).future);

        if (preoperacional != null) {
          final car =
              await ref.read(carByIdProvider(preoperacional.carId).future);
          if (car != null && car.carPlate == carPlate) {
            final userName =
                await ref.read(userByIdProvider(preoperacional.userId).future);
            relevantFiles.add({
              'fileName': file,
              'userName': userName,
              'finalDate': preoperacional.fechaFinal,
              'initDate': preoperacional.fechaInit,
              'isOpen': preoperacional.isOpen,
              'preoperacionalUid': preoperacionalUid,
            });
          }
        }
      } catch (_) {}
    }));

    relevantFiles.sort((a, b) {
      final aDate = a['finalDate'].isNotEmpty ? a['finalDate'] : a['initDate'];
      final bDate = b['finalDate'].isNotEmpty ? b['finalDate'] : b['initDate'];
      return bDate.compareTo(aDate); // Descending order
    });

    return relevantFiles;
  } catch (e) {
    return [];
  }
});

class SelectedFilesNotifier extends StateNotifier<Set<String>> {
  SelectedFilesNotifier() : super({});

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

final selectedFilesProvider =
    StateNotifierProvider<SelectedFilesNotifier, Set<String>>((ref) {
  return SelectedFilesNotifier();
});

final deleteFilesProvider = FutureProvider.autoDispose
    .family<void, List<String>>((ref, fileNames) async {
  if (fileNames.isEmpty) return;

  final storageRef = FirebaseStorage.instance.ref().child('preoperacionales/');
  final firestoreRef =
      FirebaseFirestore.instance.collection('preoperacionales');

  await Future.wait(fileNames.map((fileName) async {
    try {
      final docId = fileName.split('.')[0];
      if (docId.isNotEmpty) {
        await storageRef.child(fileName).delete();
        await firestoreRef.doc(docId).delete();
      }
    } catch (_) {}
  }));

  ref.invalidate(excelFilesProvider);
  ref.invalidate(relevantExcelFilesProvider);
  ref.read(refreshTriggerProvider.notifier).state++;
});

Future<void> deleteSelectedFiles(WidgetRef ref) async {
  final selectedFiles = ref.read(selectedFilesProvider);
  if (selectedFiles.isEmpty) return;

  try {
    await ref.read(deleteFilesProvider(selectedFiles.toList()).future);
    ref.read(selectedFilesProvider.notifier).clearSelection();
  } catch (_) {}
}
