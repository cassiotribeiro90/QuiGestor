import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/home_cubit.dart';
import '../../auth/bloc/auth_cubit.dart';
import '../../../routes/app_routes.dart';
import '../../dashboard/views/DashboardScreen.dart';

class SideMenu extends StatelessWidget {
  final bool isCompact; // Para futura versão compacta (ícones apenas)
  
  const SideMenu({super.key, this.isCompact = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: isCompact ? 72 : 260, // Largura fixa: 260px normal, 72px compacto
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        border: Border(
          right: BorderSide(
            color: theme.brightness == Brightness.light 
                ? Colors.grey[200]! 
                : Colors.grey[800]!,
          ),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
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
                _buildMenuItem(
                  context,
                  icon: Icons.dashboard_outlined,
                  label: 'Dashboard',
                  index: 0,
                  content: const DashboardScreen(),
                  isCompact: isCompact,
                ),
                const Divider(),
                _buildSectionHeader('USUÁRIOS', isCompact),
                _buildMenuItem(
                  context,
                  icon: Icons.admin_panel_settings_outlined,
                  label: 'Gestores',
                  index: 1,
                  content: const Center(child: Text('Gestores Screen')),
                  isCompact: isCompact,
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.storefront_outlined,
                  label: 'Lojistas',
                  index: 2,
                  content: const Center(child: Text('Lojistas Screen')),
                  isCompact: isCompact,
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.people_outlined,
                  label: 'Clientes',
                  index: 3,
                  content: const Center(child: Text('Clientes Screen')),
                  isCompact: isCompact,
                ),
                
                const Divider(),
                _buildSectionHeader('LOJAS', isCompact),
                _buildMenuItem(
                  context,
                  icon: Icons.store_mall_directory_outlined,
                  label: 'Todas as Lojas',
                  index: 4,
                  content: const Center(child: Text('Lojas List Screen')),
                  isCompact: isCompact,
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.category_outlined,
                  label: 'Categorias',
                  index: 5,
                  content: const Center(child: Text('Categorias List Screen')),
                  isCompact: isCompact,
                ),
                
                const Divider(),
                _buildSectionHeader('PEDIDOS', isCompact),
                _buildMenuItem(
                  context,
                  icon: Icons.receipt_outlined,
                  label: 'Todos os Pedidos',
                  index: 7,
                  content: const Center(child: Text('Pedidos Screen')),
                  isCompact: isCompact,
                ),
                
                const Divider(),
                _buildMenuItem(
                  context,
                  icon: Icons.settings_outlined,
                  label: 'Configurações',
                  index: 10,
                  content: const Center(child: Text('Configurações Screen')),
                  isCompact: isCompact,
                ),
              ],
            ),
          ),
          
          // Logout
          Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            child: ListTile(
              leading: const Icon(Icons.logout_rounded, color: Colors.red),
              title: isCompact ? null : const Text('Sair', style: TextStyle(color: Colors.red)),
              onTap: () {
                print('🚪 [SideMenu] Solicitando logout...');
                context.read<AuthCubit>().logout();
                Navigator.pushReplacementNamed(context, Routes.LOGIN);
              },
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isCompact) {
    if (isCompact) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int index,
    required Widget content,
    required bool isCompact,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: isCompact ? null : Text(label),
      onTap: () {
        print('Sidebar/Drawer -> Navegando para: $label (index: $index)');
        // Se estiver dentro de um Drawer, fecha ele primeiro
        try {
          if (Scaffold.of(context).isDrawerOpen) {
            Navigator.pop(context);
          }
        } catch (e) {
          // Não está em um Scaffold com Drawer
        }
        context.read<HomeCubit>().navigateTo(index, label, content);
      },
    );
  }
}
