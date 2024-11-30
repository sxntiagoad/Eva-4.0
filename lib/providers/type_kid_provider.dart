import 'package:eva/models/type_kid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final typeKidprovider = FutureProvider<List<String>>((ref) async {
  return await getKidsArray();
});