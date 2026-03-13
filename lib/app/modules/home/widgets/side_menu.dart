import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/bloc/auth_cubit.dart';
import '../../../routes/app_routes.dart';
import '../../dashboard/views/DashboardScreen.dart';
import '../../gestores/views/gestores_list_screen.dart';
import '../../lojas/views/lojas_list_screen.dart';
import '../../categorias/views/categorias_list_screen.dart';
import '../views/home_screen.dart';
import '../../theme/bloc/theme_cubit.dart';
import '../../theme/bloc/theme_state.dart';

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
                    Icons.admin_panel_settings, 
                    size: 40, 
                    color: Colors.white
                  ),
                ),
                if (!isCompact) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'QuiGestor',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Painel Administrativo',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
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
                    icon: Icons.dashboard_outlined,
                    label: 'Dashboard',
                    content: const DashboardScreen(),
                    isCompact: isCompact,
                  ),
                ),
                
                _buildSectionHeader(context, 'USUÁRIOS', isCompact),
                _buildMenuItem(
                  context,
                  icon: Icons.admin_panel_settings_outlined,
                  label: 'Gestores',
                  content: const GestoresListScreen(),
                  isCompact: isCompact,
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.storefront_outlined,
                  label: 'Lojistas',
                  content: const Center(child: Text('Lojistas Screen')),
                  isCompact: isCompact,
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.people_outlined,
                  label: 'Clientes',
                  content: const Center(child: Text('Clientes Screen')),
                  isCompact: isCompact,
                ),
                
                _buildSectionHeader(context, 'LOJAS', isCompact),
                _buildMenuItem(
                  context,
                  icon: Icons.store_mall_directory_outlined,
                  label: 'Todas as Lojas',
                  content: const LojasListScreen(),
                  isCompact: isCompact,
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.category_outlined,
                  label: 'Categorias',
                  content: const CategoriasListScreen(),
                  isCompact: isCompact,
                ),
                
                _buildSectionHeader(context, 'PEDIDOS', isCompact),
                _buildMenuItem(
                  context,
                  icon: Icons.receipt_outlined,
                  label: 'Todos os Pedidos',
                  content: const Center(child: Text('Pedidos Screen')),
                  isCompact: isCompact,
                ),
                
                _buildSectionHeader(context, 'SISTEMA', isCompact),
                _buildMenuItem(
                  context,
                  icon: Icons.settings_outlined,
                  label: 'Configurações',
                  content: const Center(child: Text('Configurações Screen')),
                  isCompact: isCompact,
                ),
              ],
            ),
          ),
          
          // Theme Toggle
          BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, state) {
              final isDark = state.themeMode == ThemeMode.dark;
              return ListTile(
                leading: Icon(
                  isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                  color: theme.colorScheme.primary,
                ),
                title: isCompact ? null : Text(isDark ? 'Tema Claro' : 'Tema Escuro'),
                onTap: () => context.read<ThemeCubit>().toggleTheme(),
              );
            },
          ),

          // Logout
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.red),
            title: isCompact ? null : const Text('Sair', style: TextStyle(color: Colors.red)),
            onTap: () {
              context.read<AuthCubit>().logout();
              Navigator.pushReplacementNamed(context, Routes.LOGIN);
            },
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, bool isCompact) {
    if (isCompact) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12, 
          fontWeight: FontWeight.bold, 
          color: Theme.of(context).disabledColor,
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Widget content,
    required bool isCompact,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: isCompact ? null : Text(label),
      dense: true,
      onTap: () {
        // Fecha drawer se estiver aberto (Mobile)
        try {
          if (Scaffold.of(context).isDrawerOpen) {
            Navigator.pop(context);
          }
        } catch (_) {}
        
        // 🔥 Acessa o HomeScreen e navega
        final homeState = context.findAncestorStateOfType<HomeScreenState>();
        if (homeState != null) {
          homeState.navigateTo(content, label);
        }
      },
    );
  }
}
