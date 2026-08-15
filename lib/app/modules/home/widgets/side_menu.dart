import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../apparte/widgets/app_text.dart';
import '../../auth/bloc/auth_cubit.dart';
import '../../../routes/app_routes.dart';
import '../bloc/home_cubit.dart';
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
                  ),
                  const TextBody3(
                    'Painel Administrativo',
                    color: Colors.white70,
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
                    index: 0,
                    isCompact: isCompact,
                  ),
                ),
                
                _buildSectionHeader(context, 'USUÁRIOS', isCompact),
                _buildMenuItem(
                  context,
                  icon: AppIcons.admin,
                  label: 'Gestores',
                  index: 1,
                  isCompact: isCompact,
                ),
                _buildMenuItem(
                  context,
                  icon: AppIcons.people,
                  label: 'Lojistas',
                  index: 2,
                  isCompact: isCompact,
                ),
                _buildMenuItem(
                  context,
                  icon: AppIcons.person,
                  label: 'Clientes',
                  index: 3,
                  isCompact: isCompact,
                ),
                
                _buildSectionHeader(context, 'LOJAS', isCompact),
                _buildMenuItem(
                  context,
                  icon: AppIcons.store,
                  label: 'Todas as Lojas',
                  index: 4,
                  isCompact: isCompact,
                ),
                _buildMenuItem(
                  context,
                  icon: AppIcons.category,
                  label: 'Categorias',
                  index: 5,
                  isCompact: isCompact,
                ),
                
                _buildSectionHeader(context, 'PEDIDOS', isCompact),
                _buildMenuItem(
                  context,
                  icon: AppIcons.inventory,
                  label: 'Todos os Pedidos',
                  index: 6,
                  isCompact: isCompact,
                ),
                
                _buildSectionHeader(context, 'SISTEMA', isCompact),
                _buildMenuItem(
                  context,
                  icon: AppIcons.settings,
                  label: 'Configurações',
                  index: 7,
                  isCompact: isCompact,
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(),
                ),

                // Theme Toggle dentro do scroll
                BlocBuilder<ThemeCubit, ThemeState>(
                  builder: (context, state) {
                    final isDark = state.themeMode == ThemeMode.dark;
                    return ListTile(
                      leading: Icon(
                        isDark ? AppIcons.visibility : AppIcons.visibilityOff,
                        color: theme.colorScheme.primary,
                      ),
                      title: isCompact ? null : TextBody2(isDark ? 'Tema Claro' : 'Tema Escuro'),
                      onTap: () => context.read<ThemeCubit>().toggleTheme(),
                    );
                  },
                ),

                // Logout dentro do scroll
                ListTile(
                  leading: const Icon(AppIcons.logout, color: Colors.red),
                  title: isCompact ? null : const TextBody2('Sair', color: Colors.red),
                  onTap: () {
                    context.read<AuthCubit>().logout();
                    Navigator.pushReplacementNamed(context, Routes.LOGIN);
                  },
                ),
                
                // Espaço extra no final da lista
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
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int index,
    required bool isCompact,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: isCompact ? null : TextBody2(label),
      dense: true,
      onTap: () {
        // Fecha drawer se estiver aberto (Mobile)
        try {
          if (Scaffold.of(context).isDrawerOpen) {
            Navigator.pop(context);
          }
        } catch (_) {}
        
        context.read<HomeCubit>().changeModule(index, label);
      },
    );
  }
}
