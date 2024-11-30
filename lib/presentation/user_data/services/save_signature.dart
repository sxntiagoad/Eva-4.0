import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static Future<String?> uploadSignature(Uint8List signatureBytes, String userId) async {
    try {
      final storageRef = FirebaseStorage.instance.ref();
      final signatureRef = storageRef.child('firmas/$userId.png');
      
      await signatureRef.putData(signatureBytes);
      
      final downloadUrl = await signatureRef.getDownloadURL();
      
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'signature': downloadUrl});
      
      return downloadUrl;
    } catch (e) {
      print('Error al subir la firma: $e');
      return null;
    }
  }
}
