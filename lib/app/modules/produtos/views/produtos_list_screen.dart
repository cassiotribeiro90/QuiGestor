import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../apparte/widgets/app_text.dart';
import '../bloc/produto_cubit.dart';
import '../bloc/produtos_cubit.dart';
import '../bloc/produtos_state.dart';
import '../models/produto.dart';
import '../../../../apparte/widgets/quigestor_card.dart';
import '../../../../apparte/widgets/loading_skeleton.dart';
import '../../../../shared/api/api_client.dart';
import 'produto_form_screen.dart';
import '../../../core/constants/icon_constants.dart';

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

  void _navegarParaForm({int? produtoId}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => ProdutoCubit(
            context.read<ApiClient>(),
          )..loadInitialData(produtoId: produtoId),
          child: ProdutoFormScreen(
            produtoId: produtoId,
            initialLojaId: widget.lojaId,
          ),
        ),
      ),
    );

    // Simplificado: Sempre que voltar da tela de formulário, recarrega a lista
    if (mounted) {
      context.read<ProdutosCubit>().fetchProdutos();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navegarParaForm(),
        label: const TextBody1('Novo Produto', color: Colors.white),
        icon: const Icon(AppIcons.add, color: Colors.white),
      ),
      body: BlocBuilder<ProdutosCubit, ProdutosState>(
        builder: (context, state) {
          if (state is ProdutosLoading) {
            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, __) => const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: LojaCardSkeleton(),
                      ),
                      childCount: 5,
                    ),
                  ),
                ),
              ],
            );
          }

          if (state is ProdutosError) {
            return CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(AppIcons.error, size: 80, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        const TextH3('Erro ao carregar produtos'),
                        const SizedBox(height: 8),
                        TextBody2(state.message, textAlign: TextAlign.center),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => context.read<ProdutosCubit>().fetchProdutos(),
                          icon: const Icon(AppIcons.refresh),
                          label: const TextBody1('Tentar novamente'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          if (state is ProdutosLoaded) {
            final sections = state.sections;

            if (sections.isEmpty || sections.values.every((list) => list.isEmpty)) {
              return CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(AppIcons.fastfood, size: 100, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          const TextH2('Nenhum produto cadastrado'),
                          const SizedBox(height: 8),
                          const TextBody2('Adicione produtos ao cardápio desta loja'),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () => _navegarParaForm(),
                            icon: const Icon(AppIcons.add),
                            label: const TextBody1('Adicionar Produto'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }

            return SelectionArea(
              child: RefreshIndicator(
                onRefresh: () => context.read<ProdutosCubit>().fetchProdutos(),
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // Título opcional caso queira mostrar o nome da loja no corpo
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: TextH2('Cardápio - ${widget.lojaNome}',
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    ...sections.entries.map((entry) {
                      final categoria = entry.key;
                      final produtos = entry.value;

                      if (produtos.isEmpty) {
                        return const SliverToBoxAdapter(child: SizedBox.shrink());
                      }

                      final count = produtos.length;

                      return SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverMainAxisGroup(
                          slivers: [
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  children: [
                                    TextH3(
                                      categoria,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: TextBody3(
                                        '$count',
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) => RepaintBoundary(
                                    child: _buildProdutoCard(produtos[index])),
                                childCount: produtos.length,
                              ),
                            ),
                            const SliverToBoxAdapter(child: SizedBox(height: 16)),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
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
        onTap: () => _navegarParaForm(produtoId: produto.id),
        child: Row(
          children: [
            // Imagem do produto
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                image: produto.imagem != null && produto.imagem!.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(produto.imagem!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: produto.imagem == null || produto.imagem!.isEmpty
                  ? Icon(AppIcons.fastfood, color: theme.colorScheme.primary.withOpacity(0.3))
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
                        child: TextBody1(
                          produto.nome,
                          fontWeight: FontWeight.bold,
                          maxLines: 1,
                        ),
                      ),
                      if (!produto.disponivel)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const TextBody3(
                            'INDISPONÍVEL',
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                  if (produto.descricao != null) ...[
                    const SizedBox(height: 4),
                    TextBody3(
                      produto.descricao!,
                      color: Colors.grey,
                      maxLines: 1,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (produto.emPromocao) ...[
                        TextBody3(
                          'R\$ ${produto.preco.toStringAsFixed(2)}',
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        TextBody2(
                          'R\$ ${produto.precoPromocional!.toStringAsFixed(2)}',
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ] else
                        TextBody2(
                          'R\$ ${produto.preco.toStringAsFixed(2)}',
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Seta
            Icon(AppIcons.chevronRight, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
