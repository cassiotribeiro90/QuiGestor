import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/lojistas_cubit.dart';
import '../bloc/lojistas_state.dart';
import '../../../core/constants/icon_constants.dart';

class FiltrosLojistas extends StatefulWidget {
  const FiltrosLojistas({super.key});

  @override
  State<FiltrosLojistas> createState() => _FiltrosLojistasState();
}

class _FiltrosLojistasState extends State<FiltrosLojistas> {
  final Map<String, String> _filters = {};
  final _searchController = TextEditingController();

  void _applyFilter(String key, String? value) {
    if (value == null || value.isEmpty) {
      _filters.remove(key);
    } else {
      _filters[key] = value;
    }
    context.read<LojistasCubit>().carregar(filters: _filters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LojistasCubit, LojistasState>(
      builder: (context, state) {
        List<DropdownMenuItem<int>> lojaItems = [
          const DropdownMenuItem(value: null, child: Text('Todas lojas')),
        ];

        if (state is LojistasLoaded) {
          lojaItems.addAll(state.lojas.map((loja) => DropdownMenuItem(
            value: loja.id,
            child: Text(loja.nome),
          )));
        }

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Buscar por nome, email ou CPF',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                      onChanged: (value) {
                        _applyFilter('search', value);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(AppIcons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _applyFilter('search', '');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Primeira linha de filtros: Todas as lojas (100% de largura)
              DropdownButtonFormField<int>(
                value: _filters['loja_id'] != null ? int.tryParse(_filters['loja_id']!) : null,
                hint: const Text('Todas lojas'),
                isDense: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
                items: lojaItems,
                onChanged: (value) {
                  _applyFilter('loja_id', value?.toString());
                },
              ),
              const SizedBox(height: 8),
              // Segunda linha de filtros: Função e Status (lado a lado)
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _filters['funcao'],
                      hint: const Text('Função'),
                      isDense: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('Todas funções')),
                        DropdownMenuItem(value: 'proprietario', child: Text('Proprietário')),
                        DropdownMenuItem(value: 'gerente', child: Text('Gerente')),
                        DropdownMenuItem(value: 'vendedor', child: Text('Vendedor')),
                      ],
                      onChanged: (value) {
                        _applyFilter('funcao', value);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _filters['status'] != null ? int.tryParse(_filters['status']!) : null,
                      hint: const Text('Status'),
                      isDense: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('Todos')),
                        DropdownMenuItem(value: 1, child: Text('Ativo')),
                        DropdownMenuItem(value: 0, child: Text('Inativo')),
                      ],
                      onChanged: (value) {
                        _applyFilter('status', value?.toString());
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
