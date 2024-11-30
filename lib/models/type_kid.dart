import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<String>> getKidsArray() async {
  try {
  
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('typekid') 
        .doc('kyb0aLSQnumHGvPKkIT1') 
        .get();

  
    if (doc.exists && doc.data() != null) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      
      
      List<dynamic> kidsDynamic = data['kids'];
      List<String> kids = List<String>.from(kidsDynamic);
      
      return kids;
    } else {
     
      return [];
    }
  } catch (e) {
    // print('Error obteniendo el array: $e');
    return [];
  }
}
