import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva/providers/preoperacionales_provider.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/preoperacional.dart';

Future<void> updatePreoperacional(
    Preoperacional preoperacional, WidgetRef ref) async {
  try {
    CollectionReference preoperacionales =
        FirebaseFirestore.instance.collection('preoperacionales');
    DocumentReference document = preoperacionales.doc(preoperacional.docId);

    Map<String, dynamic> preoperacionalMap = preoperacional.toMap();

    await document.update(preoperacionalMap);
    ref.invalidate(allPreoperacionalesProvider);
  } catch (e) {
    rethrow;
  }
}
