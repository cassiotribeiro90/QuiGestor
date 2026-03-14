import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/produtos_cubit.dart';
import '../bloc/produtos_state.dart';
import '../models/produto.dart';
import '../../../../apparte/widgets/quigestor_card.dart';
import '../../../../apparte/widgets/loading_skeleton.dart';

class ProdutosListScreen extends StatefulWidget {
  final int lojaId;
  final String lojaNome;

  const ProdutosListScreen({
    super.key,
    required this.lojaId,
    required this.lojaNome,
  });

  @override
  State<ProdutosListScreen> createState() => _ProdutosListScreenState();
}

class _ProdutosListScreenState extends State<ProdutosListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProdutosCubit>().fetchProdutos();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Cardápio - ${widget.lojaNome}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Navegar para criar produto
            },
          ),
        ],
      ),
      body: BlocBuilder<ProdutosCubit, ProdutosState>(
        builder: (context, state) {
          if (state is ProdutosLoading) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 5,
              itemBuilder: (_, __) => const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: LojaCardSkeleton(),
              ),
            );
          }

          if (state is ProdutosError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('Erro ao carregar produtos', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(state.message, textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.read<ProdutosCubit>().fetchProdutos(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          if (state is ProdutosLoaded) {
            if (state.produtos.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.restaurant_menu_outlined, size: 100, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text('Nenhum produto cadastrado', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    const Text('Adicione produtos ao cardápio desta loja'),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Criar produto
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Adicionar Produto'),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => context.read<ProdutosCubit>().fetchProdutos(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: state.produtosAgrupados.entries.map((entry) {
                  final categoria = entry.key;
                  final produtos = entry.value;
                  final count = state.contagens[categoria] ?? 0;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Text(
                              categoria,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$count',
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ...produtos.map((produto) => _buildProdutoCard(produto)),
                      const SizedBox(height: 16),
                    ],
                  );
                }).toList(),
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildProdutoCard(Produto produto) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: QuiGestorCard(
        onTap: () {
          // TODO: Editar produto
        },
        child: Row(
          children: [
            // Imagem do produto
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                image: produto.imagem != null
                    ? DecorationImage(
                        image: NetworkImage(produto.imagem!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: produto.imagem == null
                  ? Icon(Icons.fastfood, color: theme.colorScheme.primary.withOpacity(0.3))
                  : null,
            ),
            const SizedBox(width: 12),

            // Informações
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          produto.nome,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (!produto.disponivel)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'INDISPONÍVEL',
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ),
                    ],
                  ),
                  if (produto.descricao != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      produto.descricao!,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (produto.emPromocao) ...[
                        Text(
                          'R\$ ${produto.preco.toStringAsFixed(2)}',
                          style: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'R\$ ${produto.precoPromocional!.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ] else
                        Text(
                          'R\$ ${produto.preco.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Seta
            Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
