import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../theme/bloc/theme_cubit.dart';
import '../../theme/bloc/theme_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.palette_outlined, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Aparência',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  BlocBuilder<ThemeCubit, ThemeState>(
                    builder: (context, state) {
                      return Column(
                        children: [
                          RadioListTile<ThemeMode>(
                            title: const Text('Claro'),
                            secondary: const Icon(Icons.light_mode_outlined),
                            value: ThemeMode.light,
                            groupValue: state.themeMode,
                            onChanged: (value) {
                              if (value != null) {
                                context.read<ThemeCubit>().setTheme(value);
                              }
                            },
                          ),
                          RadioListTile<ThemeMode>(
                            title: const Text('Escuro'),
                            secondary: const Icon(Icons.dark_mode_outlined),
                            value: ThemeMode.dark,
                            groupValue: state.themeMode,
                            onChanged: (value) {
                              if (value != null) {
                                context.read<ThemeCubit>().setTheme(value);
                              }
                            },
                          ),
                          RadioListTile<ThemeMode>(
                            title: const Text('Sistema'),
                            secondary: const Icon(Icons.settings_suggest_outlined),
                            value: ThemeMode.system,
                            groupValue: state.themeMode,
                            onChanged: (value) {
                              if (value != null) {
                                context.read<ThemeCubit>().setTheme(value);
                              }
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Sobre o QuiGestor'),
              subtitle: const Text('Versão 1.0.0'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'QuiGestor',
                  applicationVersion: '1.0.0',
                  applicationIcon: Icon(Icons.store, size: 48, color: theme.colorScheme.primary),
                  children: [
                    const Text('Sistema de gestão inteligente para o ecossistema Qui.'),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
