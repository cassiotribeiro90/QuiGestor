import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/bloc/auth_cubit.dart';
import '../../loja/bloc/loja_cubit.dart';
import '../../loja/bloc/loja_state.dart';
import '../../theme/bloc/theme_cubit.dart';
import '../../theme/bloc/theme_state.dart';
import '../../../di/dependencies.dart';
import '../../../../apparte/widgets/quigestor_card.dart'; // To be moved/created
import '../../../routes/app_routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return BlocProvider<LojaCubit>(
      create: (context) => getIt<LojaCubit>()..fetchLojas(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('QuiGestor'),
          actions: [
            BlocBuilder<ThemeCubit, ThemeState>(
              builder: (context, state) {
                return IconButton(
                  icon: Icon(
                    state.themeMode == ThemeMode.dark 
                        ? Icons.light_mode_outlined 
                        : Icons.dark_mode_outlined,
                  ),
                  tooltip: 'Alternar Tema',
                  onPressed: () => context.read<ThemeCubit>().toggleTheme(),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.exit_to_app_rounded),
              tooltip: 'Sair',
              onPressed: () {
                context.read<AuthCubit>().logout();
                Navigator.pushReplacementNamed(context, Routes.LOGIN);
              },
            ),
          ],
        ),
        drawer: const AppDrawer(),
        body: BlocBuilder<LojaCubit, LojaState>(
          builder: (context, state) {
            if (state is LojaLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is LojaError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_off_rounded, size: 80, color: theme.colorScheme.error.withOpacity(0.5)),
                      const SizedBox(height: 16),
                      Text(
                        'Ops! Algo deu errado',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(state.message, textAlign: TextAlign.center),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => context.read<LojaCubit>().fetchLojas(),
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Tentar Novamente'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is LojaLoaded) {
              if (state.lojas.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.storefront_outlined, size: 100, color: theme.colorScheme.primary.withOpacity(0.2)),
                      const SizedBox(height: 16),
                      Text(
                        'Sua jornada começa aqui',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text('Crie sua primeira loja para gerenciar seu ecossistema'),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => context.read<LojaCubit>().fetchLojas(),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.lojas.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final loja = state.lojas[index];
                    return Card( // Fallback while QuiGestorCard is not fully migrated
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(loja.nome[0].toUpperCase()),
                        ),
                        title: Text(loja.nome),
                        subtitle: Text(loja.categoria ?? 'Sem categoria'),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () {
                          // Navigator.pushNamed(context, Routes.LOJA_DETAILS, arguments: loja);
                        },
                      ),
                    );
                  },
                ),
              );
            }

            return const SizedBox();
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            // Navigator.pushNamed(context, Routes.NOME_DA_ROTA_CRIAR_LOJA);
          },
          label: const Text('Nova Loja'),
          icon: const Icon(Icons.add_rounded),
        ),
      ),
    );
  }
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 30,
                    child: Icon(Icons.person_outline, size: 30, color: Colors.indigo),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'QuiGestor',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Início'),
            onTap: () => Navigator.pop(context),
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.red),
            title: const Text('Sair', style: TextStyle(color: Colors.red)),
            onTap: () {
              context.read<AuthCubit>().logout();
              Navigator.pushReplacementNamed(context, Routes.LOGIN);
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
