import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/gestores_cubit.dart';
import '../../../../apparte/widgets/app_text.dart';

class GestorFilters extends StatelessWidget {
  const GestorFilters({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header com título e botão limpar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextH2(
                'Filtros',
                color: theme.colorScheme.onSurface,
              ),
              TextButton(
                onPressed: () {
                  context.read<GestoresCubit>().clearFilters();
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.secondary,
                ),
                child: const Text('Limpar'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Seção Nível de Acesso
          TextBody1(
            'Nível de Acesso',
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
          const SizedBox(height: 12),
          
          BlocBuilder<GestoresCubit, GestoresState>(
            builder: (context, state) {
              final cubit = context.read<GestoresCubit>();
              
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildFilterChip(
                    context,
                    label: 'Todos',
                    isSelected: cubit.currentNivel == null,
                    onSelected: (_) => cubit.applyNivel(null),
                  ),
                  _buildFilterChip(
                    context,
                    label: 'Admin',
                    isSelected: cubit.currentNivel == 'admin',
                    onSelected: (_) => cubit.applyNivel('admin'),
                  ),
                  _buildFilterChip(
                    context,
                    label: 'Comercial',
                    isSelected: cubit.currentNivel == 'comercial',
                    onSelected: (_) => cubit.applyNivel('comercial'),
                  ),
                  _buildFilterChip(
                    context,
                    label: 'Suporte',
                    isSelected: cubit.currentNivel == 'suporte',
                    onSelected: (_) => cubit.applyNivel('suporte'),
                  ),
                ],
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          // Seção Status
          TextBody1(
            'Status',
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
          const SizedBox(height: 12),
          
          BlocBuilder<GestoresCubit, GestoresState>(
            builder: (context, state) {
              final cubit = context.read<GestoresCubit>();
              
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildFilterChip(
                    context,
                    label: 'Todos',
                    isSelected: cubit.currentStatus == null,
                    onSelected: (_) => cubit.applyStatus(null),
                  ),
                  _buildFilterChip(
                    context,
                    label: 'Ativos',
                    isSelected: cubit.currentStatus == 1,
                    onSelected: (_) => cubit.applyStatus(1),
                  ),
                  _buildFilterChip(
                    context,
                    label: 'Inativos',
                    isSelected: cubit.currentStatus == 0,
                    onSelected: (_) => cubit.applyStatus(0),
                  ),
                ],
              );
            },
          ),
          
          const SizedBox(height: 32),
          
          // Botão Aplicar Filtros
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.secondary,
                foregroundColor: theme.colorScheme.onSecondary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Aplicar Filtros',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required Function(bool) onSelected,
  }) {
    final theme = Theme.of(context);
    
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected 
              ? theme.colorScheme.onSecondary 
              : theme.colorScheme.onSurface,
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: onSelected,
      backgroundColor: theme.colorScheme.surface,
      selectedColor: theme.colorScheme.secondary,
      checkmarkColor: theme.colorScheme.onSecondary,
      side: BorderSide(
        color: isSelected 
            ? theme.colorScheme.secondary 
            : theme.colorScheme.outline,
        width: 1,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      showCheckmark: true,
    );
  }
}
