import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/lojas_cubit.dart';
import '../bloc/lojas_state.dart';
import '../../../../apparte/widgets/app_text.dart';

class LojaFilters extends StatefulWidget {
  const LojaFilters({super.key});

  @override
  State<LojaFilters> createState() => _LojaFiltersState();
}

class _LojaFiltersState extends State<LojaFilters> {
  String? _categoria;
  String? _status;
  bool? _verificado;
  bool? _destaque;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextH2(
                'Filtros',
                color: theme.colorScheme.onSurface,
              ),
              TextButton(
                onPressed: () {
                  context.read<LojasCubit>().fetchLojas();
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
          
          TextBody1(
            'Status',
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterChip(
                label: 'Todos',
                isSelected: _status == null,
                onSelected: (_) => setState(() => _status = null),
              ),
              _buildFilterChip(
                label: 'Ativo',
                isSelected: _status == 'ativo',
                onSelected: (_) => setState(() => _status = 'ativo'),
              ),
              _buildFilterChip(
                label: 'Fechado',
                isSelected: _status == 'fechado',
                onSelected: (_) => setState(() => _status = 'fechado'),
              ),
              _buildFilterChip(
                label: 'Revisão',
                isSelected: _status == 'revisao',
                onSelected: (_) => setState(() => _status = 'revisao'),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          TextBody1(
            'Outros',
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChip(
                label: const Text('Verificado'),
                selected: _verificado == true,
                onSelected: (val) => setState(() => _verificado = val ? true : null),
              ),
              FilterChip(
                label: const Text('Destaque'),
                selected: _destaque == true,
                onSelected: (val) => setState(() => _destaque = val ? true : null),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                context.read<LojasCubit>().fetchLojas(
                  status: _status,
                  verificado: _verificado,
                  destaque: _destaque,
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.secondary,
                foregroundColor: theme.colorScheme.onSecondary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Aplicar Filtros',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required Function(bool) onSelected,
  }) {
    final theme = Theme.of(context);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: theme.colorScheme.secondary.withOpacity(0.2),
      checkmarkColor: theme.colorScheme.secondary,
    );
  }
}
