import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/gestores_cubit.dart';
import '../../../../apparte/widgets/app_text.dart';

class GestorFilters extends StatelessWidget {
  const GestorFilters({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<GestoresCubit>();
    final theme = Theme.of(context);

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
                  cubit.clearFilters();
                  Navigator.pop(context);
                },
                child: const Text('Limpar'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          const TextBody1('Nível de Acesso', fontWeight: FontWeight.bold),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _FilterChip(
                label: 'Todos',
                isSelected: cubit.currentNivel == null,
                onSelected: (_) => cubit.setNivel(null),
              ),
              _FilterChip(
                label: 'Admin',
                isSelected: cubit.currentNivel == 'admin',
                onSelected: (_) => cubit.setNivel('admin'),
              ),
              _FilterChip(
                label: 'Comercial',
                isSelected: cubit.currentNivel == 'comercial',
                onSelected: (_) => cubit.setNivel('comercial'),
              ),
              _FilterChip(
                label: 'Suporte',
                isSelected: cubit.currentNivel == 'suporte',
                onSelected: (_) => cubit.setNivel('suporte'),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          const TextBody1('Status', fontWeight: FontWeight.bold),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _FilterChip(
                label: 'Todos',
                isSelected: cubit.currentStatus == null,
                onSelected: (_) => cubit.setStatus(null),
              ),
              _FilterChip(
                label: 'Ativos',
                isSelected: cubit.currentStatus == 1,
                onSelected: (_) => cubit.setStatus(1),
              ),
              _FilterChip(
                label: 'Inativos',
                isSelected: cubit.currentStatus == 0,
                onSelected: (_) => cubit.setStatus(0),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Aplicar Filtros'),
            ),
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
