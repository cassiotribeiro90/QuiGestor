import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../apparte/widgets/app_text.dart';
import '../../auth/bloc/auth_cubit.dart';
import '../../theme/bloc/theme_cubit.dart';
import '../../theme/bloc/theme_state.dart';
import '../../../core/constants/icon_constants.dart';

class SideMenu extends StatelessWidget {
  final bool isCompact;

  const SideMenu({super.key, this.isCompact = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: isCompact ? 72 : 260,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
      ),
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/images/quigestor.png',
                  width: isCompact ? 40 : 120,
                  height: isCompact ? 40 : 60,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                      AppIcons.admin,
                      size: 40,
                      color: Colors.white
                  ),
                ),
                if (!isCompact) ...[
                  const SizedBox(height: 8),
                  const TextBody1(
                    'QuiGestor',
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    selectable: false,
                  ),
                  const TextBody3(
                    'Painel Administrativo',
                    color: Colors.white70,
                    selectable: false,
                  ),
                ],
              ],
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: _buildMenuItem(
                    context,
                    icon: AppIcons.dashboard,
                    label: 'Dashboard',
                    route: '/dashboard',
                    isCompact: isCompact,
                  ),
                ),

                _buildSectionHeader(context, 'USUÁRIOS', isCompact),
                _buildMenuItem(
                  context,
                  icon: AppIcons.admin,
                  label: 'Gestores',
                  route: '/gestores',
                  isCompact: isCompact,
                ),
                _buildMenuItem(
                  context,
                  icon: AppIcons.people,
                  label: 'Lojistas',
                  route: '/lojistas',
                  isCompact: isCompact,
                ),
                _buildMenuItem(
                  context,
                  icon: AppIcons.person,
                  label: 'Clientes',
                  route: '/clientes',
                  isCompact: isCompact,
                ),

                _buildSectionHeader(context, 'LOJAS', isCompact),
                _buildMenuItem(
                  context,
                  icon: AppIcons.store,
                  label: 'Todas as Lojas',
                  route: '/lojas',
                  isCompact: isCompact,
                ),
                _buildMenuItem(
                  context,
                  icon: AppIcons.category,
                  label: 'Categorias',
                  route: '/categorias',
                  isCompact: isCompact,
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.subdirectory_arrow_right,
                  label: 'Subcategorias',
                  route: '/subcategorias',
                  isCompact: isCompact,
                ),

                _buildSectionHeader(context, 'PEDIDOS', isCompact),
                _buildMenuItem(
                  context,
                  icon: AppIcons.inventory,
                  label: 'Todos os Pedidos',
                  route: '/pedidos',
                  isCompact: isCompact,
                ),

                _buildSectionHeader(context, 'SISTEMA', isCompact),
                _buildMenuItem(
                  context,
                  icon: AppIcons.settings,
                  label: 'Configurações',
                  route: '/configuracoes',
                  isCompact: isCompact,
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(),
                ),

                // Theme Toggle
                BlocBuilder<ThemeCubit, ThemeState>(
                  builder: (context, state) {
                    final isDark = state.themeMode == ThemeMode.dark;
                    return ListTile(
                      leading: Icon(
                        isDark ? AppIcons.visibility : AppIcons.visibilityOff,
                        color: theme.colorScheme.primary,
                      ),
                      title: isCompact ? null : TextBody2(isDark ? 'Tema Claro' : 'Tema Escuro', selectable: false),
                      onTap: () => context.read<ThemeCubit>().toggleTheme(),
                    );
                  },
                ),

                // Logout
                ListTile(
                  leading: const Icon(AppIcons.logout, color: Colors.red),
                  title: isCompact ? null : const TextBody2('Sair', color: Colors.red, selectable: false),
                  onTap: () {
                    context.read<AuthCubit>().logout();
                    // 🔥 Navega para login usando GoRouter
                    context.go('/login');
                  },
                ),

                SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, bool isCompact) {
    if (isCompact) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: TextBody3(
        title,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).disabledColor,
        selectable: false,
      ),
    );
  }

  Widget _buildMenuItem(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String route,
        required bool isCompact,
      }) {
    return ListTile(
      leading: Icon(icon),
      title: isCompact ? null : TextBody2(label, selectable: false),
      dense: true,
      onTap: () {
        // Fecha drawer se estiver aberto
        try {
          if (Scaffold.of(context).isDrawerOpen) {
            Navigator.pop(context);
          }
        } catch (_) {}

        // 🔥 Navega usando GoRouter
        context.go(route);
      },
    );
  }
}