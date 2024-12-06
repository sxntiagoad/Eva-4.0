import 'package:eva/providers/salud/health_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:go_router/go_router.dart';
import '../../../models/health_report.dart';
import '../../../providers/salud/health_db_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../screens/edit_health_screen.dart';

class HealthCard extends ConsumerWidget {
  final HealthReport healthReport;
  const HealthCard({
    super.key,
    required this.healthReport,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userName = ref.watch(userNameProvider(healthReport.userId));
    return ListTile(
      title: Text(
        'Reporte de Salud - ${healthReport.fecha}',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppTheme.mainColor,
        ),
      ),
      subtitle: userName.when(
        data: (name) => Text('Usuario: $name'),
        loading: () => const Text('Cargando nombre...'),
        error: (error, stack) => Text('Error: $error'),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          healthReport.isOpen
              ? const Icon(Icons.lock_open_outlined, color: Colors.green)
              : const Icon(Icons.lock, color: Colors.red),
        ],
      ),
      onTap: () {
        context.pushNamed(
          EditHealthScreen.name,
          extra: healthReport,
        );
      },
    );
  }

}