import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/home_cubit.dart';
import '../../auth/bloc/auth_cubit.dart';
import '../../../routes/app_routes.dart';

// IMPORTS DAS TELAS
import '../../dashboard/views/DashboardScreen.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Drawer(
      child: Column(
        children: [
          // Header Expandido
          DrawerHeader(
            margin: EdgeInsets.zero, // Remove as margens para ocupar tudo
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16), // Padding interno
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Image.asset(
                    'assets/images/quigestor.png',
                    width: 120, // Aumentado para melhor visibilidade
                    height: 60,
                    fit: BoxFit.contain,
                    // Removi o color: Colors.white para mostrar a logo original
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.admin_panel_settings, 
                      size: 40, 
                      color: Colors.white
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'QuiGestor',
                    style: TextStyle(
                      color: Colors.white, 
                      fontSize: 20, 
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Text(
                    'Painel Administrativo', 
                    style: TextStyle(
                      color: Colors.white70, 
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // MENU ITEMS
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
                ),
                
                const Divider(),
                
                // MÓDULO USUÁRIOS
                _buildSectionHeader('USUÁRIOS'),
                _buildMenuItem(
                  context,
                  icon: Icons.admin_panel_settings_outlined,
                  label: 'Gestores',
                  index: 1,
                  content: const Center(child: Text('Gestores Screen')), 
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.storefront_outlined,
                  label: 'Lojistas',
                  index: 2,
                  content: const Center(child: Text('Lojistas Screen')),
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.people_outlined,
                  label: 'Clientes',
                  index: 3,
                  content: const Center(child: Text('Clientes Screen')),
                ),
                
                const Divider(),
                
                // MÓDULO LOJAS
                _buildSectionHeader('LOJAS'),
                _buildMenuItem(
                  context,
                  icon: Icons.store_mall_directory_outlined,
                  label: 'Todas as Lojas',
                  index: 4,
                  content: const Center(child: Text('Lojas List Screen')),
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.category_outlined,
                  label: 'Categorias',
                  index: 5,
                  content: const Center(child: Text('Categorias List Screen')),
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.star_outline,
                  label: 'Lojas em Destaque',
                  index: 6,
                  content: const Center(child: Text('Destaques Screen')),
                ),
                
                const Divider(),
                
                // MÓDULO PEDIDOS
                _buildSectionHeader('PEDIDOS'),
                _buildMenuItem(
                  context,
                  icon: Icons.receipt_outlined,
                  label: 'Todos os Pedidos',
                  index: 7,
                  content: const Center(child: Text('Pedidos Screen')),
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.analytics_outlined,
                  label: 'Relatórios',
                  index: 8,
                  content: const Center(child: Text('Relatórios Screen')),
                ),
                
                const Divider(),
                
                // MÓDULO AVALIAÇÕES
                _buildMenuItem(
                  context,
                  icon: Icons.rate_review_outlined,
                  label: 'Avaliações',
                  index: 9,
                  content: const Center(child: Text('Avaliações Screen')),
                ),
                
                const Divider(),
                
                // CONFIGURAÇÕES
                _buildMenuItem(
                  context,
                  icon: Icons.settings_outlined,
                  label: 'Configurações',
                  index: 10,
                  content: const Center(child: Text('Configurações Screen')),
                ),
              ],
            ),
          ),
          
          // SAIR (fixo no final)
          Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            child: ListTile(
              leading: const Icon(Icons.logout_rounded, color: Colors.red),
              title: const Text('Sair', style: TextStyle(color: Colors.red)),
              onTap: () {
                context.read<AuthCubit>().logout();
                Navigator.pushReplacementNamed(context, Routes.LOGIN);
              },
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom), // Garante espaço para a barra do sistema
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int index,
    required Widget content,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: () {
        Navigator.pop(context); // Fecha o drawer
        context.read<HomeCubit>().navigateTo(
          index,
          label,
          content,
        );
      },
    );
  }
}
