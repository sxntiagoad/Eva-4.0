import 'package:eva/providers/current_user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserPhoto extends ConsumerWidget {
  const UserPhoto({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsyncValue = ref.watch(currentUserProvider);
    Color? backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    return userAsyncValue.when(
      error: (error, stack) => Center(child: Text('Error: $error')),
      loading: () => const CircleAvatar(
        radius: 80,
      ),
      data: (data) => Hero(
        tag: data.photoUrl,
        child: Stack(
          children: [
            CircleAvatar(
              radius: 80,
              backgroundImage: NetworkImage(
                data.photoUrl,
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  shape: BoxShape.circle,
                ),
                child: const CircleAvatar(
                  radius: 25,
                  child: Icon(Icons.edit),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
