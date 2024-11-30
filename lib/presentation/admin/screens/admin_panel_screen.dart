import 'package:eva/presentation/admin/screens/cars/car_management_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'preoperacionales/admin_cars.dart'; // Asegúrate de importar la clase AdminCars
import 'limpiezas/admin_limpiezas.dart';

class AdminPanelScreen extends ConsumerWidget {
  static const String name = 'admin-panel';

  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 768;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Panel de Administración'),
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isDesktop ? 1200 : double.infinity,
          ),
          padding: EdgeInsets.all(isDesktop ? 32.0 : 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bienvenido al Panel de Control',
                style: TextStyle(
                  fontSize: isDesktop ? 28 : 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Selecciona una opción para comenzar',
                style: TextStyle(
                  fontSize: isDesktop ? 16 : 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),
              if (isDesktop)
                SizedBox(
                  height: 300,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      SizedBox(
                        width: 300,
                        child: _buildOptionCard(
                          context: context,
                          title: 'Preoperacionales',
                          description: 'Gestiona los preoperacionales de los vehículos',
                          icon: Icons.assignment_outlined,
                          route: AdminCars.name,
                          isDesktop: true,
                        ),
                      ),
                      const SizedBox(width: 24),
                      SizedBox(
                        width: 300,
                        child: _buildOptionCard(
                          context: context,
                          title: 'Gestionar Carros',
                          description: 'Administra la flota de vehículos',
                          icon: Icons.directions_car_outlined,
                          route: CarManagementPage.name,
                          isDesktop: true,
                        ),
                      ),
                      const SizedBox(width: 24),
                      SizedBox(
                        width: 300,
                        child: _buildOptionCard(
                          context: context,
                          title: 'Limpiezas',
                          description: 'Gestiona los registros de limpieza de vehículos',
                          icon: Icons.cleaning_services_outlined,
                          route: AdminLimpiezas.name,
                          isDesktop: true,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Column(
                  children: [
                    _buildOptionCard(
                      context: context,
                      title: 'Preoperacionales',
                      description: 'Gestiona los preoperacionales de los vehículos',
                      icon: Icons.assignment_outlined,
                      route: AdminCars.name,
                      isDesktop: false,
                    ),
                    const SizedBox(height: 16),
                    _buildOptionCard(
                      context: context,
                      title: 'Gestionar Carros',
                      description: 'Administra la flota de vehículos',
                      icon: Icons.directions_car_outlined,
                      route: CarManagementPage.name,
                      isDesktop: false,
                    ),
                    const SizedBox(height: 16),
                    _buildOptionCard(
                      context: context,
                      title: 'Limpiezas',
                      description: 'Gestiona los registros de limpieza de vehículos',
                      icon: Icons.cleaning_services_outlined,
                      route: AdminLimpiezas.name,
                      isDesktop: false,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required String route,
    required bool isDesktop,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/$route'),
        child: Padding(
          padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: isDesktop ? 32 : 28,
                  color: Colors.blue.shade700,
                ),
              ),
              SizedBox(height: isDesktop ? 24 : 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: isDesktop ? 20 : 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: isDesktop ? 14 : 13,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: isDesktop ? 24 : 16),
              Row(
                children: [
                  Text(
                    'Acceder',
                    style: TextStyle(
                      fontSize: isDesktop ? 14 : 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward,
                    size: isDesktop ? 18 : 16,
                    color: Colors.blue.shade700,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}