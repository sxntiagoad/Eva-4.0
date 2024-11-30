import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:typed_data';
import '../presentation/user_data/services/save_signature.dart';

class SignatureNotifier extends StateNotifier<String?> {
  SignatureNotifier() : super(null);

  void setSignature(String? newSignature) {
    state = newSignature;
  }

  Future<void> saveSignature(Uint8List signatureImage) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      String? newSignatureUrl = await FirebaseService.uploadSignature(signatureImage, currentUser.uid);
      if (newSignatureUrl != null) {
        state = newSignatureUrl;
      }
    }
  }
}

final signatureProvider = StateNotifierProvider.autoDispose<SignatureNotifier, String?>((ref) {
  return SignatureNotifier();
});

final isEditingProvider = StateProvider.autoDispose<bool>((ref) => false);
