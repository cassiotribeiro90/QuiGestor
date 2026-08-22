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
  int? _lojaId;
  String? _funcao;
  int? _status;
  final _searchController = TextEditingController();

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
                        context.read<LojistasCubit>().setFiltroSearch(value);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(AppIcons.clear),
                    onPressed: () {
                      _searchController.clear();
                      context.read<LojistasCubit>().setFiltroSearch('');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Primeira linha de filtros: Todas as lojas (100% de largura)
              DropdownButtonFormField<int>(
                initialValue: _lojaId,
                hint: const Text('Todas lojas'),
                isDense: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
                items: lojaItems,
                onChanged: (value) {
                  setState(() => _lojaId = value);
                  context.read<LojistasCubit>().setFiltroLoja(value);
                },
              ),
              const SizedBox(height: 8),
              // Segunda linha de filtros: Função e Status (lado a lado)
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _funcao,
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
                        setState(() => _funcao = value);
                        context.read<LojistasCubit>().setFiltroFuncao(value);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: _status,
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
                        setState(() => _status = value);
                        context.read<LojistasCubit>().setFiltroStatus(value);
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
