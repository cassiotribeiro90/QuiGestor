import 'package:flutter/material.dart';
import 'flat_section.dart';

class DashboardLists extends StatelessWidget {
  final List<dynamic> topLojasFaturamento;
  final List<dynamic> topLojasPedidos;
  final List<dynamic> topProdutos;
  final List<dynamic> topClientes;
  final List<dynamic> lojasPorCategoria;
  final List<dynamic> lojasPorCidade;
  final bool isMobile;

  const DashboardLists({
    super.key,
    required this.topLojasFaturamento,
    required this.topLojasPedidos,
    required this.topProdutos,
    required this.topClientes,
    required this.lojasPorCategoria,
    required this.lojasPorCidade,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return Column(
        children: [
          _buildTopLojasFaturamento(context),
          const SizedBox(height: 16),
          _buildTopLojasPedidos(context),
          const SizedBox(height: 16),
          _buildTopProdutos(context),
          const SizedBox(height: 16),
          _buildTopClientes(context),
          const SizedBox(height: 16),
          _buildLojasPorCategoria(context),
          const SizedBox(height: 16),
          _buildLojasPorCidade(context),
        ],
      );
    }

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildTopLojasFaturamento(context)),
            const SizedBox(width: 16),
            Expanded(child: _buildTopLojasPedidos(context)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildTopProdutos(context)),
            const SizedBox(width: 16),
            Expanded(child: _buildTopClientes(context)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildLojasPorCategoria(context)),
            const SizedBox(width: 16),
            Expanded(child: _buildLojasPorCidade(context)),
          ],
        ),
      ],
    );
  }

  Widget _buildTopLojasFaturamento(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dados = topLojasFaturamento.take(5).toList();

    return FlatSection(
      title: 'Top 5 Lojas - Faturamento',
      subtitle: 'Mais lucrativas',
      child: Column(
        children: dados.map((loja) {
          final index = dados.indexOf(loja);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: isDark ? Colors.orange.shade900.withOpacity(0.5) : Colors.orange.shade50,
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.orange.shade300 : Colors.orange.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    loja['nome'] ?? '',
                    style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade300 : Colors.black87),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  'R\$ ${_formatarNumero(loja['faturamento'] ?? 0)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTopLojasPedidos(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dados = topLojasPedidos.take(5).toList();

    return FlatSection(
      title: 'Top 5 Lojas - Pedidos',
      subtitle: 'Mais movimentadas',
      child: Column(
        children: dados.map((loja) {
          final index = dados.indexOf(loja);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: isDark ? Colors.blue.shade900.withOpacity(0.5) : Colors.blue.shade50,
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.blue.shade300 : Colors.blue.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    loja['nome'] ?? '',
                    style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade300 : Colors.black87),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${loja['total_pedidos'] ?? 0}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTopProdutos(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dados = topProdutos.take(5).toList();

    return FlatSection(
      title: 'Top 5 Produtos',
      subtitle: 'Mais vendidos hoje',
      child: Column(
        children: dados.map((produto) {
          final index = dados.indexOf(produto);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: isDark ? Colors.green.shade900.withOpacity(0.5) : Colors.green.shade50,
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.green.shade300 : Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    produto['nome'] ?? '',
                    style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade300 : Colors.black87),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${produto['vendas'] ?? 0}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.green.shade400 : Colors.green.shade700,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTopClientes(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dados = topClientes.take(5).toList();

    return FlatSection(
      title: 'Top 5 Clientes',
      subtitle: 'Mais valiosos',
      child: Column(
        children: dados.map((cliente) {
          final index = dados.indexOf(cliente);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: isDark ? Colors.purple.shade900.withOpacity(0.5) : Colors.purple.shade50,
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.purple.shade300 : Colors.purple.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    cliente['nome'] ?? 'Sem nome',
                    style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade300 : Colors.black87),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  'R\$ ${_formatarNumero(cliente['total_gasto'] ?? 0)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLojasPorCategoria(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dados = lojasPorCategoria.take(8).toList();

    return FlatSection(
      title: 'Lojas por Categoria',
      subtitle: 'Distribuição',
      child: Column(
        children: dados.map((item) {
          final total = lojasPorCategoria.fold<int>(0, (sum, i) {
            final raw = i['total'] ?? 0;
            return sum + (raw is num ? raw.toInt() : int.tryParse(raw.toString()) ?? 0);
          });
          final raw = item['total'] ?? 0;
          final valor = raw is num ? raw.toInt() : int.tryParse(raw.toString()) ?? 0;
          final percent = total > 0 ? (valor / total) * 100 : 0.0;
          final label = item['categoria'] ?? '';

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(fontSize: 11, color: isDark ? Colors.grey.shade300 : Colors.black87),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${percent.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLojasPorCidade(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dados = lojasPorCidade.take(5).toList();

    return FlatSection(
      title: 'Lojas por Cidade',
      subtitle: 'Top 5',
      child: Column(
        children: dados.map((cidade) {
          final index = dados.indexOf(cidade);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: isDark ? Colors.teal.shade900.withOpacity(0.5) : Colors.teal.shade50,
                  child: Icon(
                    Icons.location_city,
                    size: 14,
                    color: isDark ? Colors.teal.shade300 : Colors.teal.shade600,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${cidade['cidade']} - ${cidade['uf']}',
                    style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade300 : Colors.black87),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${cidade['total'] ?? 0}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  String _formatarNumero(dynamic valor) {
    if (valor == null) return '0';
    final numero = valor is num ? valor.toDouble() : double.tryParse(valor.toString()) ?? 0;
    return numero.toStringAsFixed(2).replaceAll('.', ',');
  }
}