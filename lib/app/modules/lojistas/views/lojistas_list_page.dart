import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../di/dependencies.dart';
import '../bloc/lojistas_cubit.dart';
import '../bloc/lojistas_state.dart';
import '../widgets/lojista_card.dart';
import '../widgets/filtros_lojistas.dart';
import '../widgets/carregar_mais_button.dart';
import '../bloc/lojista_form_cubit.dart';
import 'lojista_form_page.dart';
import '../../../core/constants/icon_constants.dart';

class LojistasListPage extends StatefulWidget {
  const LojistasListPage({super.key});

  @override
  State<LojistasListPage> createState() => _LojistasListPageState();
}

class _LojistasListPageState extends State<LojistasListPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<LojistasCubit>().reset();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navegarParaForm(context),
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(AppIcons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Expanded(child: FiltrosLojistas()),
                IconButton(
                  icon: const Icon(AppIcons.refresh),
                  onPressed: () => context.read<LojistasCubit>().reset(),
                  tooltip: 'Atualizar',
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocConsumer<LojistasCubit, LojistasState>(
              listener: (context, state) {
                if (state is LojistasError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                }
              },
              builder: (context, state) {
                if (state is LojistasLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is LojistasLoaded) {
                  if (state.lojistas.isEmpty) {
                    return const Center(
                      child: Text('Nenhum lojista encontrado'),
                    );
                  }
                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: state.lojistas.length + 1,
                    itemBuilder: (context, index) {
                      if (index == state.lojistas.length) {
                        return CarregarMaisButton(
                          hasMore: context.read<LojistasCubit>().hasMore,
                          onTap: () {
                            context.read<LojistasCubit>().carregar(
                                  carregarMais: true,
                                );
                          },
                        );
                      }
                      final lojista = state.lojistas[index];
                      return LojistaCard(
                        lojista: lojista,
                        onEdit: () => _navegarParaForm(context, lojista.id),
                        onDelete: () => _confirmarExclusao(context, lojista.id),
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _navegarParaForm(BuildContext context, [int? id]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => getIt<LojistaFormCubit>(),
          child: LojistaFormPage(id: id),
        ),
      ),
    ).then((result) {
      if (result == true && mounted) {
        context.read<LojistasCubit>().reset();
      }
    });
  }

  void _confirmarExclusao(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Tem certeza que deseja excluir este lojista?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<LojistasCubit>().deletar(id);
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}
