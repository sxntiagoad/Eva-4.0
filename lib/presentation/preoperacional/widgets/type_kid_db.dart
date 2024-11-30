import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/preoperacional_db_provider.dart';
import '../../../providers/type_kid_provider.dart';

class TypeKidDbWidget extends ConsumerWidget {
  const TypeKidDbWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String? role;
    final typeKid = ref.watch(typeKidprovider);
    final preopreciona = ref.watch(preoperacionalDbProvider);

    if (preopreciona.typeKit.isNotEmpty) {
      role = preopreciona.typeKit;
    }

    return typeKid.when(
      data: (data) => DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          labelText: 'Seleccione tipo botiquin',
        ),
        value: role,
        items: List.generate(
          data.length,
          (index) {
            return DropdownMenuItem(
              value: data[index],
              child: Text(
                data[index],
              ),
            );
          },
        ),
        onChanged: (value) {
          role = value;
          ref
              .read(preoperacionalDbProvider.notifier)
              .updateTypeKit(value ?? '');
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}
