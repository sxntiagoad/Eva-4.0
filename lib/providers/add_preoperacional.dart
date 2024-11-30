import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva/models/preoperacional.dart';
import 'package:eva/providers/preoperacionales_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<String?> addPreoperacional(
    Preoperacional preoperacional, WidgetRef ref) async {
  try {
    DocumentReference docRef = await FirebaseFirestore.instance
        .collection('preoperacionales')
        .add(preoperacional.toMap());

    ref.invalidate(allPreoperacionalesProvider);

    return docRef.id;
  } catch (e) {
    return null;
  }
}
