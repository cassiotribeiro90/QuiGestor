import 'package:flutter/material.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 🔥 CARDS ESTILIZADOS (padrão quiManda)
    final cards = [
      _buildCard(
        isDark,
        title: 'Top 5 Lojas - Faturamento',
        subtitle: 'Mais lucrativas',
        child: _buildTopLojasFaturamento(isDark),
      ),
      _buildCard(
        isDark,
        title: 'Top 5 Lojas - Pedidos',
        subtitle: 'Mais movimentadas',
        child: _buildTopLojasPedidos(isDark),
      ),
      _buildCard(
        isDark,
        title: 'Top 5 Produtos',
        subtitle: 'Mais vendidos hoje',
        child: _buildTopProdutos(isDark),
      ),
      _buildCard(
        isDark,
        title: 'Top 5 Clientes',
        subtitle: 'Mais valiosos',
        child: _buildTopClientes(isDark),
      ),
      _buildCard(
        isDark,
        title: 'Lojas por Categoria',
        subtitle: 'Distribuição',
        child: _buildLojasPorCategoria(isDark),
      ),
      _buildCard(
        isDark,
        title: 'Lojas por Cidade',
        subtitle: 'Top 5',
        child: _buildLojasPorCidade(isDark),
      ),
    ];

    if (isMobile) {
      return Column(
        children: cards.map((card) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: card,
        )).toList(),
      );
    }

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: cards[0]),
            const SizedBox(width: 16),
            Expanded(child: cards[1]),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: cards[2]),
            const SizedBox(width: 16),
            Expanded(child: cards[3]),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: cards[4]),
            const SizedBox(width: 16),
            Expanded(child: cards[5]),
          ],
        ),
      ],
    );
  }

  // 🔥 CARD ESTILIZADO (igual ao quiManda)
  Widget _buildCard(bool isDark, {required String title, required String subtitle, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  // 🔥 TOP LOJAS FATURAMENTO
  Widget _buildTopLojasFaturamento(bool isDark) {
    final dados = topLojasFaturamento.take(5).toList();

    if (dados.isEmpty) {
      return Text(
        'Nenhuma loja com faturamento hoje',
        style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
      );
    }

    return Column(
      children: dados.map((loja) {
        final index = dados.indexOf(loja);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: isDark ? Colors.orange.shade900.withOpacity(0.5) : Colors.orange.shade50,
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.orange.shade300 : Colors.orange.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  loja['nome'] ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey.shade300 : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                'R\$ ${_formatarNumero(loja['faturamento'] ?? 0)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // 🔥 TOP LOJAS PEDIDOS
  Widget _buildTopLojasPedidos(bool isDark) {
    final dados = topLojasPedidos.take(5).toList();

    if (dados.isEmpty) {
      return Text(
        'Nenhuma loja com pedidos hoje',
        style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
      );
    }

    return Column(
      children: dados.map((loja) {
        final index = dados.indexOf(loja);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: isDark ? Colors.blue.shade900.withOpacity(0.5) : Colors.blue.shade50,
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.blue.shade300 : Colors.blue.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  loja['nome'] ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey.shade300 : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${loja['total_pedidos'] ?? 0}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // 🔥 TOP PRODUTOS
  Widget _buildTopProdutos(bool isDark) {
    final dados = topProdutos.take(5).toList();

    if (dados.isEmpty) {
      return Text(
        'Nenhum produto vendido hoje',
        style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
      );
    }

    return Column(
      children: dados.map((produto) {
        final index = dados.indexOf(produto);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: isDark ? Colors.green.shade900.withOpacity(0.5) : Colors.green.shade50,
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.green.shade300 : Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  produto['nome'] ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey.shade300 : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${produto['vendas'] ?? 0}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // 🔥 TOP CLIENTES
  Widget _buildTopClientes(bool isDark) {
    final dados = topClientes.take(5).toList();

    if (dados.isEmpty) {
      return Text(
        'Nenhum cliente ainda',
        style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
      );
    }

    return Column(
      children: dados.map((cliente) {
        final index = dados.indexOf(cliente);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: isDark ? Colors.purple.shade900.withOpacity(0.5) : Colors.purple.shade50,
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.purple.shade300 : Colors.purple.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  cliente['nome'] ?? 'Sem nome',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey.shade300 : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                'R\$ ${_formatarNumero(cliente['total_gasto'] ?? 0)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // 🔥 LOJAS POR CATEGORIA
  Widget _buildLojasPorCategoria(bool isDark) {
    final dados = lojasPorCategoria.take(8).toList();

    if (dados.isEmpty) {
      return Text(
        'Nenhuma categoria cadastrada',
        style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
      );
    }

    final total = dados.fold<int>(0, (sum, item) {
      final raw = item['total'] ?? 0;
      return sum + (raw is num ? raw.toInt() : int.tryParse(raw.toString()) ?? 0);
    });

    return Column(
      children: dados.map((item) {
        final raw = item['total'] ?? 0;
        final valor = raw is num ? raw.toInt() : int.tryParse(raw.toString()) ?? 0;
        final percent = total > 0 ? (valor / total) * 100 : 0.0;
        final label = item['categoria'] ?? '';

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey.shade300 : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${percent.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // 🔥 LOJAS POR CIDADE
  Widget _buildLojasPorCidade(bool isDark) {
    final dados = lojasPorCidade.take(5).toList();

    if (dados.isEmpty) {
      return Text(
        'Nenhuma cidade cadastrada',
        style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
      );
    }

    return Column(
      children: dados.map((cidade) {
        final index = dados.indexOf(cidade);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: isDark ? Colors.teal.shade900.withOpacity(0.5) : Colors.teal.shade50,
                child: Icon(
                  Icons.location_city,
                  size: 16,
                  color: isDark ? Colors.teal.shade300 : Colors.teal.shade600,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${cidade['cidade']} - ${cidade['uf']}',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey.shade300 : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${cidade['total'] ?? 0}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _formatarNumero(dynamic valor) {
    if (valor == null) return '0';
    final numero = valor is num ? valor.toDouble() : double.tryParse(valor.toString()) ?? 0;
    return numero.toStringAsFixed(2).replaceAll('.', ',');
  }
}