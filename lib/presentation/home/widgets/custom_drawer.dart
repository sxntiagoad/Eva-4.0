import 'package:eva/core/theme/app_theme.dart';
import 'package:eva/presentation/admin/screens/admin_panel_screen.dart';
import 'package:eva/presentation/home/widgets/logout_show.dart';
import 'package:eva/presentation/user_data/screens/user_data_screen.dart';
import 'package:eva/providers/current_user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class CutomDrawer extends ConsumerWidget {
  final GlobalKey<ScaffoldState> drawerKey;
  const CutomDrawer(this.drawerKey, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsyncValue = ref.watch(currentUserProvider);
    final size = MediaQuery.of(context).size;
    final isWebPlatform = size.width > 600;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Drawer(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top + 20),
            userAsyncValue.when(
              data: (data) => Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
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
                      radius: 50,
                      backgroundImage: NetworkImage(data.photoUrl),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    data.fullName,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.mainColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.mainColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Rol: ${data.role}',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppTheme.mainColor.withOpacity(0.8),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                  _DrawerItem(
                    drawerKey: drawerKey,
                    icon: Icons.account_circle_outlined,
                    text: 'Datos',
                    navigateTo: UserDataScreen.name,
                  ),
                  if (data.role == 'ADMIN')
                    _DrawerItem(
                      drawerKey: drawerKey,
                      icon: Icons.admin_panel_settings,
                      text: 'Panel de Administrador',
                      navigateTo: AdminPanelScreen.name,
                    ),
                  _DrawerItem(
                    drawerKey: drawerKey,
                    icon: Icons.logout_rounded,
                    text: 'Cerrar sesión',
                    onTap: () {
                      if (drawerKey.currentState!.isDrawerOpen) {
                        drawerKey.currentState!.closeDrawer();
                      }
                      showLogoutDialog(context);
                    },
                  ),
                ],
              ),
              error: (error, stackTrace) => Center(
                child: Text(
                  'Error: $error',
                  style: GoogleFonts.poppins(color: Colors.red),
                ),
              ),
              loading: () => const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(AppTheme.mainColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final GlobalKey<ScaffoldState> drawerKey;
  final IconData icon;
  final String text;
  final String? navigateTo;
  final VoidCallback? onTap;

  const _DrawerItem({
    required this.drawerKey,
    required this.icon,
    required this.text,
    this.navigateTo,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap ?? () {
          if (navigateTo != null) {
            if (drawerKey.currentState!.isDrawerOpen) {
              drawerKey.currentState!.closeDrawer();
            }
            context.pushNamed(navigateTo!);
          }
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.mainColor.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppTheme.mainColor,
            size: 22,
          ),
        ),
        title: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 15,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.3,
          ),
        ),
        hoverColor: AppTheme.mainColor.withOpacity(0.05),
        selectedTileColor: AppTheme.mainColor.withOpacity(0.08),
      ),
    );
  }
}
