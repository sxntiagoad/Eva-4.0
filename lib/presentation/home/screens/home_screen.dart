import 'package:eva/presentation/limpieza/screens/new_limpieza_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/current_user_provider.dart';
import '../../list_preoperacionales.dart/screens/list_preoperacionales_screen.dart';
import '../../new_preoperacional/screens/new_preoperacional_scree.dart';
import '../widgets/custom_drawer.dart';

class HomeScreen extends ConsumerWidget {
  static const name = 'home-screen';
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scaffoldKey = GlobalKey<ScaffoldState>();
    final userAsyncValue = ref.watch(currentUserProvider);
    final size = MediaQuery.of(context).size;
    final isWebPlatform = size.width > 600;
    final colors = Theme.of(context).colorScheme;

    return userAsyncValue.when(
      data: (data) {
        return Scaffold(
          key: scaffoldKey,
          backgroundColor: colors.surface,
          drawer: isWebPlatform ? null : CutomDrawer(scaffoldKey),
          body: Stack(
            children: [
              Row(
                children: [
                  if (isWebPlatform)
                    Container(
                      width: 280,
                      decoration: BoxDecoration(
                        color: colors.surface,
                        boxShadow: [
                          BoxShadow(
                            color: colors.shadow.withOpacity(0.05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: CutomDrawer(scaffoldKey),
                    ),
                  Expanded(
                    child: CustomScrollView(
                      slivers: [
                        SliverAppBar(
                          backgroundColor: colors.surface,
                          expandedHeight: isWebPlatform ? 180 : 200,
                          floating: false,
                          pinned: true,
                          automaticallyImplyLeading: !isWebPlatform,
                          flexibleSpace: FlexibleSpaceBar(
                            background: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppTheme.mainColor.withOpacity(0.05),
                                    colors.surface,
                                  ],
                                ),
                                borderRadius: const BorderRadius.vertical(
                                  bottom: Radius.circular(30),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Hero(
                                    tag: 'logo-tag',
                                    child: Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppTheme.mainColor.withOpacity(0.2),
                                          width: 2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppTheme.mainColor.withOpacity(0.1),
                                            blurRadius: 10,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                      child: CircleAvatar(
                                        radius: isWebPlatform ? 35 : 40,
                                        backgroundImage: const AssetImage('assets/logo_eva.png'),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Bienvenido de nuevo,',
                                    style: TextStyle(
                                      color: AppTheme.mainColor.withOpacity(0.7),
                                      fontSize: isWebPlatform ? 14 : 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    data.fullName,
                                    style: TextStyle(
                                      color: AppTheme.mainColor,
                                      fontSize: isWebPlatform ? 20 : 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isWebPlatform ? 40 : 20,
                            vertical: 30,
                          ),
                          sliver: SliverToBoxAdapter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '¿Qué deseas hacer hoy?',
                                  style: TextStyle(
                                    fontSize: isWebPlatform ? 26 : 24,
                                    fontWeight: FontWeight.w600,
                                    color: colors.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 30),
                                _DashboardGrid(isWebPlatform: isWebPlatform),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                right: 10,
                bottom: 10,
                child: FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox.shrink();
                    return Text(
                      'v${snapshot.data!.version}',
                      style: TextStyle(
                        color: colors.onSurface.withOpacity(0.3),
                        fontSize: 12,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const _LoadingView(),
      error: (error, stack) => _ErrorView(error: error.toString()),
    );
  }
}

class _DashboardGrid extends StatelessWidget {
  final bool isWebPlatform;

  const _DashboardGrid({required this.isWebPlatform});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: isWebPlatform ? 4 : 2,
          crossAxisSpacing: isWebPlatform ? 25 : 15,
          mainAxisSpacing: isWebPlatform ? 25 : 15,
          childAspectRatio: isWebPlatform ? 1.2 : 1.1,
          children: [
            _DashboardCard(
              title: 'Nuevo\nPreoperacional',
              subtitle: 'Crear nuevo registro',
              icon: Icons.add_circle_outline,
              color: AppTheme.mainColor,
              isMain: true,
              onTap: () => context.pushNamed(NewPreoperacionalScree.name),
              isWebPlatform: isWebPlatform,
            ),
            _DashboardCard(
              title: 'Editar\nPreoperacional',
              subtitle: 'Modificar existente',
              icon: Icons.edit_document,
              color: AppTheme.mainColor,
              onTap: () => context.pushNamed(ListPreoperacionalesScreen.name),
              isWebPlatform: isWebPlatform,
            ),
            _DashboardCard(
              title: 'Nuevo Chequeo\nde Limpieza',
              subtitle: 'Registro de chequeo',
              icon: Icons.cleaning_services,  // Icono de limpieza
              color: AppTheme.mainColor,
              onTap: () => context.pushNamed(NewLimpiezaScreen.name),
              isWebPlatform: isWebPlatform,
            ),
            _DashboardCard(
              title: 'Editar Chequeo\nde Limpieza',
              subtitle: 'Modificar existente',
              icon: Icons.playlist_add_check_circle_sharp,
              color: AppTheme.mainColor,
              onTap: () => context.pushNamed('limpiezas-screen'),
              isWebPlatform: isWebPlatform,
            ),
          ],
        );
      },
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isWebPlatform;
  final bool isMain;

  const _DashboardCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.isWebPlatform,
    this.isMain = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isMain ? color : color.withOpacity(0.1),
          width: isMain ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: EdgeInsets.all(isWebPlatform ? 20 : 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: isMain ? color.withOpacity(0.05) : Colors.white,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: isWebPlatform ? 28 : 24,
                  color: color,
                ),
              ),
              SizedBox(height: isWebPlatform ? 12 : 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: isWebPlatform ? 15 : 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.onSurface.withOpacity(0.6),
                  fontSize: isWebPlatform ? 12 : 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;

  const _ErrorView({required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Error: $error',
          style: TextStyle(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      ),
    );
  }
}