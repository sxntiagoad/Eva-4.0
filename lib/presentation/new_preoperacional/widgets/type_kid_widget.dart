import 'package:eva/providers/new_preoperacional_provider.dart';
import 'package:eva/providers/type_kid_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TypeKidWidget extends ConsumerWidget {
  const TypeKidWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedType = ref.watch(newPreoperacionalProvider).typeKit;
    final typeKid = ref.watch(typeKidprovider);

    return typeKid.when(
      data: (data) => DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          labelText: 'Seleccione tipo botiquin',
        ),
        value: selectedType.isEmpty ? null : selectedType,
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
          ref
              .read(newPreoperacionalProvider.notifier)
              .updateTypeKit(value ?? '');
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}
