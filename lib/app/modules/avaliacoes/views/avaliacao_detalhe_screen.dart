import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/avaliacoes_cubit.dart';
import '../models/avaliacao_model.dart';
import '../widgets/star_display.dart';

class AvaliacaoDetalheScreen extends StatefulWidget {
  final int avaliacaoId;

  const AvaliacaoDetalheScreen({
    super.key,
    required this.avaliacaoId,
  });

  @override
  State<AvaliacaoDetalheScreen> createState() => _AvaliacaoDetalheScreenState();
}

class _AvaliacaoDetalheScreenState extends State<AvaliacaoDetalheScreen> {
  AvaliacaoModel? _avaliacao;
  bool _isLoading = true;
  String? _error;
  bool _isUpdating = false; // ⚠️ Para mostrar progresso durante atualização

  @override
  void initState() {
    super.initState();
    _carregarAvaliacao();
  }

  Future<void> _carregarAvaliacao() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final cubit = context.read<AvaliacoesCubit>();
      final avaliacao = await cubit.buscarPorId(widget.avaliacaoId);

      if (!mounted) return;

      setState(() {
        _avaliacao = avaliacao;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Erro ao carregar avaliação: $e');

      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhe da Avaliação'),
        // ⚠️ ADICIONADO: Botão voltar explícito
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/avaliacoes');
            }
          },
          tooltip: 'Voltar',
        ),
      ),
      body: _buildBody(isDark),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
              const SizedBox(height: 16),
              Text(
                'Erro ao carregar avaliação',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _carregarAvaliacao,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (_avaliacao == null) {
      return Center(
        child: Text(
          'Avaliação não encontrada',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildCardPrincipal(_avaliacao!, isDark),
        const SizedBox(height: 16),
        _buildAcoes(_avaliacao!),
        if (_avaliacao!.pedido != null) ...[
          const SizedBox(height: 24),
          _buildCardPedido(_avaliacao!.pedido!, isDark),
        ],
      ],
    );
  }

  Widget _buildCardPrincipal(AvaliacaoModel avaliacao, bool isDark) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        avaliacao.clienteNome,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Loja: ${avaliacao.lojaNome}',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(avaliacao.status),
              ],
            ),
            const SizedBox(height: 16),
            StarDisplay(nota: avaliacao.nota, size: 30),
            const SizedBox(height: 16),
            if (avaliacao.comentario != null && avaliacao.comentario!.isNotEmpty)
              Text(
                avaliacao.comentario!,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            const SizedBox(height: 16),
            Text(
              'Data: ${_formatDate(avaliacao.criadoEm)}',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[500] : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAcoes(AvaliacaoModel avaliacao) {
    if (_isUpdating) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        if (avaliacao.status == 'pendente') ...[
          ElevatedButton.icon(
            onPressed: () => _atualizarStatus(avaliacao.id, 'aprovado'),
            icon: const Icon(Icons.check),
            label: const Text('Aprovar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _atualizarStatus(avaliacao.id, 'rejeitado'),
            icon: const Icon(Icons.close),
            label: const Text('Rejeitar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ] else if (avaliacao.status == 'aprovado') ...[
          ElevatedButton.icon(
            onPressed: () => _atualizarStatus(avaliacao.id, 'rejeitado'),
            icon: const Icon(Icons.close),
            label: const Text('Rejeitar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ] else if (avaliacao.status == 'rejeitado') ...[
          ElevatedButton.icon(
            onPressed: () => _atualizarStatus(avaliacao.id, 'aprovado'),
            icon: const Icon(Icons.check),
            label: const Text('Aprovar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ],
        IconButton(
          onPressed: () => _confirmarExclusao(avaliacao.id),
          icon: const Icon(Icons.delete),
          color: Colors.red,
          tooltip: 'Excluir',
        ),
      ],
    );
  }

  Widget _buildCardPedido(PedidoInfo pedido, bool isDark) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Produtos do Pedido',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pedido #${pedido.numero}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            if (pedido.produtos.isEmpty)
              Text(
                'Nenhum produto encontrado',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              )
            else
              ...pedido.produtos.map((produto) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${produto.quantidade}x ${produto.nome}',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'R\$ ${produto.subtotal.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              )),
            const Divider(),
            Row(
              children: [
                Text(
                  'Total:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const Spacer(),
                Text(
                  'R\$ ${pedido.total.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;

    switch (status.toLowerCase()) {
      case 'aprovado':
      case 'aprovada':
        color = Colors.green;
        label = 'APROVADA';
        break;
      case 'rejeitado':
      case 'rejeitada':
        color = Colors.red;
        label = 'REJEITADA';
        break;
      default:
        color = Colors.orange;
        label = 'PENDENTE';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // ⚠️ CORRIGIDO: Atualizar status e voltar para a lista
  Future<void> _atualizarStatus(int id, String status) async {
    setState(() {
      _isUpdating = true;
    });

    try {
      final cubit = context.read<AvaliacoesCubit>();
      await cubit.atualizarStatus(id, status);

      if (!mounted) return;

      // Mostra mensagem de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Status atualizado com sucesso'),
          backgroundColor: Colors.green,
        ),
      );

      // ⚠️ Volta para a lista
      context.go('/avaliacoes');
    } catch (e) {
      debugPrint('❌ Erro ao atualizar status: $e');

      if (!mounted) return;

      setState(() {
        _isUpdating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao atualizar status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _confirmarExclusao(int id) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Tem certeza que deseja excluir esta avaliação?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              setState(() {
                _isUpdating = true;
              });

              try {
                final cubit = context.read<AvaliacoesCubit>();
                await cubit.deletar(id);

                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Avaliação excluída com sucesso'),
                    backgroundColor: Colors.green,
                  ),
                );

                context.go('/avaliacoes');
              } catch (e) {
                if (!mounted) return;

                setState(() {
                  _isUpdating = false;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erro ao excluir: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}