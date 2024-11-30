import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva/models/mi_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<MyUser> getCurrentUserFromFirestore() async {
  User? currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser != null) {
    String uid = currentUser.uid;

    DocumentSnapshot userDocument = await FirebaseFirestore.instance
        .collection(
          'users',
        )
        .doc(
          uid,
        )
        .get();
    Map<String, dynamic>? currentUserAux;
    currentUserAux = (userDocument.data() != null)
        ? userDocument.data() as Map<String, dynamic>
        : MyUser(
            fullName: '',
            email: '',
            role: '',
            photoUrl: 'https://www.transparentpng.com/thumb/user/gray-user-profile-icon-png-fP8Q1P.png',
            password: '',
            signature: '', // Añadimos el campo signature con un valor por defecto
          ).toMap();
    return MyUser.fromMap(currentUserAux);
  } else {
    throw Exception("No hay un usuario con la sesión iniciada.");
  }
}

final currentUserProvider = FutureProvider.autoDispose<MyUser>((ref) async {
  return await getCurrentUserFromFirestore();
});
