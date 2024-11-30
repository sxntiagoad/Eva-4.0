import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva/models/mi_user.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> registerUser(MyUser user) async {
  try {
    // Crear usuario en Firebase Auth
    UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: user.email, password: user.password);
    
    User? firebaseUser = userCredential.user;

    if (firebaseUser != null) {
      // Crear documento en la colección 'users' con el ID del usuario
      await FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid).set(user.toMap());
    }
  } catch (e) {
    // print('Error registering user: $e');
    // Manejo de errores aquí
  }
}