import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/mi_user.dart';

class UserDataNotifier extends StateNotifier<MyUser?> {
  UserDataNotifier() : super(null) {
    _loadUserData();
  }

  bool _isEditing = false;
  bool get isEditing => _isEditing;

  void _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userData.exists) {
        state = MyUser.fromMap(userData.data()!);
      }
    }
  }

  void toggleEditing() {
    _isEditing = !_isEditing;
    state = state?.copyWith(); // Trigger a rebuild
  }

  void updateField(String field, String value) {
    if (state != null) {
      state = state!.copyWith(
        fullName: field == 'fullName' ? value : state!.fullName,
        email: field == 'email' ? value : state!.email,
        role: field == 'role' ? value : state!.role,
      );
    }
  }

  Future<void> saveChanges() async {
    if (state != null) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update(state!.toMap());
      }
    }
    _isEditing = false;
    state = state?.copyWith(); // Trigger a rebuild
  }
}

final userDataProvider =
    StateNotifierProvider<UserDataNotifier, MyUser?>((ref) {
  return UserDataNotifier();
});