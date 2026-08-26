import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../apparte/widgets/app_text.dart';
import '../../../core/widgets/back_button_mixin.dart';
import '../../../routes/app_router.dart';
import '../bloc/produtos_cubit.dart';
import '../bloc/produtos_state.dart';
import '../models/produto.dart';
import '../../../../apparte/widgets/quigestor_card.dart';
import '../../../../apparte/widgets/loading_skeleton.dart';
import '../../../core/constants/icon_constants.dart';
import '../../../widgets/conditional_selection_area.dart';

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

class _ProdutosListScreenState extends State<ProdutosListScreen> with BackButtonMixin { // 🔥 ADICIONAR{
  late final ProdutosCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<ProdutosCubit>();
    _cubit.fetchProdutos();
  }

  void _navegarParaForm({int? produtoId}) {
    if (produtoId != null) {
      context.go(Routes.produtoEditar(widget.lojaId, produtoId));
    } else {
      context.go(Routes.produtoNovo(widget.lojaId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: buildBackButton(context),
        title: Text('Produtos'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navegarParaForm(),
        label: const TextBody1('Novo Produto', color: Colors.white),
        icon: const Icon(AppIcons.add, color: Colors.white),
      ),
      body: BlocConsumer<ProdutosCubit, ProdutosState>(
        listener: (context, state) {
          if (state is ProdutosError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: TextBody2(state.message, color: Colors.white),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is ProdutosOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: TextBody2(state.message, color: Colors.white),
                backgroundColor: Colors.green,
              ),
            );
            _cubit.fetchProdutos();
          }
        },
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
                        TextH3(
                          'Erro ao carregar produtos',
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        const SizedBox(height: 8),
                        TextBody2(
                          state.message,
                          textAlign: TextAlign.center,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => _cubit.fetchProdutos(),
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

            if (sections.isEmpty) {
              return CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            AppIcons.fastfood,
                            size: 100,
                            color: isDark ? Colors.grey[600] : Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          TextH2(
                            'Nenhum produto cadastrado',
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          const SizedBox(height: 8),
                          TextBody2(
                            'Adicione produtos ao cardápio desta loja',
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
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

            return ConditionalSelectionArea(
              child: RefreshIndicator(
                onRefresh: () => _cubit.fetchProdutos(),
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [

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
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary.withOpacity(0.1),
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
                                  child: _buildProdutoCard(produtos[index]),
                                ),
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
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.grey[400] : Colors.grey[600];
    final isDisponivel = produto.disponivel ?? true;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: QuiGestorCard(
        onTap: () => _navegarParaForm(produtoId: produto.id),
        child: Row(
          children: [
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
                  ? Icon(
                AppIcons.fastfood,
                color: theme.colorScheme.primary.withOpacity(0.3),
              )
                  : null,
            ),
            const SizedBox(width: 12),

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
                          color: textColor,
                        ),
                      ),
                      if (!isDisponivel)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[700] : Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: TextBody3(
                            'INDISPONÍVEL',
                            color: isDark ? Colors.grey[400] : Colors.grey,
                          ),
                        ),
                    ],
                  ),
                  if (produto.descricao != null && produto.descricao!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    TextBody3(
                      produto.descricao!,
                      color: subtitleColor,
                      maxLines: 1,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (produto.emPromocao == true) ...[
                        TextBody3(
                          'R\$ ${produto.preco.toStringAsFixed(2)}',
                          color: isDark ? Colors.grey[400] : Colors.grey,
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

            Icon(
              AppIcons.chevronRight,
              color: isDark ? Colors.grey[500] : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}