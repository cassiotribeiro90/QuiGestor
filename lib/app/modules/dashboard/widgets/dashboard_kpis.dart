import 'package:flutter/material.dart';

class DashboardKpis extends StatelessWidget {
  final Map<String, dynamic> kpis;

  const DashboardKpis({
    super.key,
    required this.kpis,
  });

  String _formatarNumero(dynamic valor) {
    if (valor == null) return '0';
    final numero = valor is num ? valor.toDouble() : double.tryParse(valor.toString()) ?? 0;
    return numero.toStringAsFixed(2).replaceAll('.', ',');
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 🔥 CARDS DO DASHBOARD DO GESTOR (PADRÃO QUI MANDA)
    final cards = [
      _KpiCard(
        icon: Icons.storefront,
        color: Colors.blue,
        title: 'Lojas Ativas',
        value: '${kpis['lojas_ativas'] ?? 0}',
        subtitle: '${kpis['lojas_total'] ?? 0} total cadastradas',
      ),
      _KpiCard(
        icon: Icons.receipt_long,
        color: Colors.orange,
        title: 'Pedidos Hoje',
        value: '${kpis['pedidos_hoje'] ?? 0}',
        subtitle: '${kpis['pedidos_semana'] ?? 0} na semana',
      ),
      _KpiCard(
        icon: Icons.attach_money,
        color: Colors.green,
        title: 'Faturamento (mês)',
        value: 'R\$ ${_formatarNumero(kpis['faturamento_mes'] ?? 0)}',
        subtitle: 'R\$ ${_formatarNumero(kpis['faturamento_hoje'] ?? 0)} hoje',
      ),
      _KpiCard(
        icon: Icons.people,
        color: Colors.purple,
        title: 'Clientes Ativos',
        value: '${kpis['clientes_ativos'] ?? 0}',
        subtitle: '${kpis['clientes_totais'] ?? 0} total cadastrados',
      ),
    ];

    final crossAxisCount = isMobile ? 1 : 2;

    if (isMobile) {
      return Column(
        children: cards
            .map((card) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: card,
                ))
            .toList(),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: cards[0]),
            const SizedBox(width: 12),
            Expanded(child: cards[1]),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: cards[2]),
            const SizedBox(width: 12),
            Expanded(child: cards[3]),
          ],
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String value;
  final String subtitle;

  const _KpiCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // 🔥 ÍCONE ESTILIZADO
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),

          const SizedBox(width: 12),

          // 🔥 CONTEÚDO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}