import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:convert';

class UpdateService {
  static const String UPDATE_API_URL = 'https://updatemgmteva-production.up.railway.app/api/updates/latest';
  static const String DOWNLOAD_URL = 'https://updatemgmteva-production.up.railway.app/api/updates/download';

  static Future<void> launchUpdateUrl(BuildContext context) async {
    final url = Uri.parse(DOWNLOAD_URL);
    
    try {
      print('🌐 Intentando abrir URL en navegador externo...');
      
      final chromeLaunch = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
        webViewConfiguration: const WebViewConfiguration(
          enableJavaScript: true,
          enableDomStorage: true,
        ),
      );

      if (!chromeLaunch) {
        print('❌ No se pudo abrir en navegador externo');
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Error'),
              content: const Text('No se pudo abrir el navegador. Por favor, intenta de nuevo.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Error al abrir URL: $e');
    }
  }

  static bool isNewerVersion(String currentVersion, String serverVersion) {
    try {
      List<int> current = currentVersion.split('.').map(int.parse).toList();
      List<int> server = serverVersion.split('.').map(int.parse).toList();
      
      for (int i = 0; i < 3; i++) {
        if (server[i] > current[i]) return true;
        if (server[i] < current[i]) return false;
      }
      return false;
    } catch (e) {
      print('❌ Error comparando versiones: $e');
      return false;
    }
  }

  static Future<void> checkForUpdates(BuildContext context) async {
    if (!context.mounted) return;

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      print('📱 Versión actual: $currentVersion');

      final response = await http.get(Uri.parse(UPDATE_API_URL));
      
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final serverVersion = json['latestVersion'].toString();
        final forceUpdate = json['forceUpdate'] ?? false;
        final changelog = json['changelog'] ?? 'Nueva versión disponible';
        final releaseNotes = List<String>.from(json['releaseNotes'] ?? []);

        print('🔄 Versión del servidor: $serverVersion');
        print('⚠️ Actualización forzada: $forceUpdate');
        
        if (isNewerVersion(currentVersion, serverVersion)) {
          if (!context.mounted) return;

          await showDialog(
            context: context,
            useRootNavigator: true,
            barrierDismissible: !forceUpdate,
            builder: (BuildContext dialogContext) => PopScope(
              canPop: !forceUpdate,
              onPopInvoked: (didPop) {
                if (forceUpdate) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Esta actualización es obligatoria'),
                    ),
                  );
                }
              },
              child: AlertDialog(
                title: const Text('Actualización Disponible'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Versión actual: $currentVersion'),
                      Text('Nueva versión: $serverVersion'),
                      const SizedBox(height: 16),
                      Text(changelog),
                      if (releaseNotes.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Text('Notas de la versión:'),
                        ...releaseNotes.map((note) => Padding(
                          padding: const EdgeInsets.only(left: 8, top: 4),
                          child: Text('• $note'),
                        )),
                      ],
                    ],
                  ),
                ),
                actions: [
                  if (!forceUpdate)
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text('Más tarde'),
                    ),
                  ElevatedButton(
                    onPressed: () async {
                      await launchUpdateUrl(context);
                      if (context.mounted) {
                        Navigator.of(dialogContext).pop();
                      }
                    },
                    child: const Text('Actualizar ahora'),
                  ),
                ],
              ),
            ),
          );
        } else {
          print('✅ La aplicación está actualizada');
        }
      }
    } catch (e, stackTrace) {
      print('❌ Error durante la verificación de actualizaciones:');
      print('Error: $e');
      print('Stack trace: $stackTrace');
    }
  }
}