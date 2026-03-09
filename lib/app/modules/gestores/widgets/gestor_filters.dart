import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/gestores_cubit.dart';
import '../../../../apparte/widgets/app_text.dart';
import '../../../../apparte/widgets/gradient_button.dart';

class GestorFilters extends StatelessWidget {
  const GestorFilters({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const TextH2('Filtros'),
              TextButton(
                onPressed: () {
                  context.read<GestoresCubit>().clearFilters();
                  Navigator.pop(context);
                },
                child: const Text('Limpar'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          const TextBody1('Nível de Acesso', fontWeight: FontWeight.bold),
          const SizedBox(height: 8),
          
          BlocBuilder<GestoresCubit, GestoresState>(
            builder: (context, state) {
              final cubit = context.read<GestoresCubit>();
              
              return Wrap(
                spacing: 8,
                children: [
                  _FilterChip(
                    label: 'Todos',
                    isSelected: cubit.currentNivel == null,
                    onSelected: (_) => cubit.applyNivel(null),
                  ),
                  _FilterChip(
                    label: 'Admin',
                    isSelected: cubit.currentNivel == 'admin',
                    onSelected: (_) => cubit.applyNivel('admin'),
                  ),
                  _FilterChip(
                    label: 'Comercial',
                    isSelected: cubit.currentNivel == 'comercial',
                    onSelected: (_) => cubit.applyNivel('comercial'),
                  ),
                  _FilterChip(
                    label: 'Suporte',
                    isSelected: cubit.currentNivel == 'suporte',
                    onSelected: (_) => cubit.applyNivel('suporte'),
                  ),
                ],
              );
            },
          ),
          
          const SizedBox(height: 20),
          const TextBody1('Status', fontWeight: FontWeight.bold),
          const SizedBox(height: 8),
          
          BlocBuilder<GestoresCubit, GestoresState>(
            builder: (context, state) {
              final cubit = context.read<GestoresCubit>();
              
              return Wrap(
                spacing: 8,
                children: [
                  _FilterChip(
                    label: 'Todos',
                    isSelected: cubit.currentStatus == null,
                    onSelected: (_) => cubit.applyStatus(null),
                  ),
                  _FilterChip(
                    label: 'Ativos',
                    isSelected: cubit.currentStatus == 1,
                    onSelected: (_) => cubit.applyStatus(1),
                  ),
                  _FilterChip(
                    label: 'Inativos',
                    isSelected: cubit.currentStatus == 0,
                    onSelected: (_) => cubit.applyStatus(0),
                  ),
                ],
              );
            },
          ),
          
          const SizedBox(height: 32),
          GradientButton(
            label: 'Aplicar Filtros',
            onPressed: () => Navigator.pop(context),
            fullWidth: true,
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Function(bool) onSelected;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      checkmarkColor: Theme.of(context).colorScheme.primary,
    );
  }
}
