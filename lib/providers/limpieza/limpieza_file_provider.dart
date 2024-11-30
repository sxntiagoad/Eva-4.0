import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva/models/car.dart';
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
    final storageRef = FirebaseStorage.instance.ref().child('chequeos_limpieza/');
    final ListResult result = await storageRef.listAll();
    return result.items.map((item) => item.name).toList();
  } catch (e) {
    throw Exception("Error al obtener archivos de Storage: $e");
  }
});

final limpiezaByUidProvider = FutureProvider.autoDispose
    .family<Limpieza?, String>((ref, uid) async {
  ref.watch(refreshTriggerProvider);

  if (uid.isEmpty) return null;
  final docId = uid.split('.')[0];
  if (docId.isEmpty) return null;

  try {
    final doc = await FirebaseFirestore.instance
        .collection('limpieza')
        .doc(docId)
        .get();
    return doc.exists
        ? Limpieza.fromMap(doc.data()!).copyWith(docId: doc.id)
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
    final doc = await FirebaseFirestore.instance.collection('cars').doc(carId).get();
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
    final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
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
        final limpiezaUid = file.split('.')[0];
        final limpieza =
            await ref.read(limpiezaByUidProvider(limpiezaUid).future);

        if (limpieza != null) {
          final car = await ref.read(carByIdProvider(limpieza.carId).future);
          if (car != null && car.carPlate == carPlate) {
            final userName =
                await ref.read(userByIdProvider(limpieza.userId).future);
            
            DateTime fecha;
            try {
              fecha = DateTime.parse(limpieza.fecha.toString());
            } catch (e) {
              fecha = DateTime.now();
            }
            
            relevantFiles.add({
              'fileName': file,
              'userName': userName,
              'fecha': fecha,
              'isOpen': limpieza.isOpen,
              'preoperacionalUid': limpieza.docId,
            });
          }
        }
      } catch (_) {}
    }));

    relevantFiles.sort((a, b) => 
      (b['fecha'] as DateTime).compareTo(a['fecha'] as DateTime)
    );

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

Future<void> deleteSelectedFiles(WidgetRef ref) async {
  final selectedFiles = ref.read(selectedFilesProvider);
  if (selectedFiles.isEmpty) return;

  try {
    // Primero ejecutamos las operaciones de eliminación
    await ref.read(deleteFilesProvider(selectedFiles.toList()).future);
    
    // Esperamos un pequeño delay para asegurar que las operaciones se completen
    await Future.delayed(const Duration(milliseconds: 200));
    
    // Limpiamos la selección ANTES de actualizar el trigger
    ref.read(selectedFilesProvider.notifier).clearSelection();
    
    // Actualizamos el trigger en el siguiente frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(refreshTriggerProvider.notifier).update((state) => state + 1);
    });
  } catch (e) {
    print('Error en deleteSelectedFiles: $e');
    // Aquí podrías mostrar un mensaje de error al usuario
  }
}

// Modificación del deleteFilesProvider para manejar mejor los errores
final deleteFilesProvider = FutureProvider.autoDispose.family<void, List<String>>(
  (ref, fileNames) async {
    if (fileNames.isEmpty) return;

    final storageRef = FirebaseStorage.instance.ref().child('chequeos_limpieza/');
    final firestoreRef = FirebaseFirestore.instance.collection('limpieza');

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

        // Pequeño delay entre operaciones para evitar sobrecarga
        await Future.delayed(const Duration(milliseconds: 50));
        
      } catch (e) {
        errors.add('Error general en la eliminación de $fileName: $e');
      }
    });

    // Si hubo errores, los lanzamos como una excepción
    if (errors.isNotEmpty) {
      throw Exception(errors.join('\n'));
    }
  }
);