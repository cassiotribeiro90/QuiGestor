import 'package:flutter/material.dart';

class DashboardKpis extends StatelessWidget {
  final Map<String, dynamic> kpis;

  const DashboardKpis({super.key, required this.kpis});

  @override
  Widget build(BuildContext context) {
    final cards = [
      _KpiCard(
        icon: Icons.storefront,
        color: Colors.blue,
        title: 'Lojas Ativas',
        value: '${kpis['lojas_ativas'] ?? 0}',
        subtitle: 'de ${kpis['lojas_total'] ?? 0} total',
        trend: '+${((kpis['lojas_ativas'] ?? 0) / (kpis['lojas_total'] ?? 1) * 100).toStringAsFixed(1)}%',
      ),
      _KpiCard(
        icon: Icons.receipt_long,
        color: Colors.orange,
        title: 'Pedidos Hoje',
        value: '${kpis['pedidos_hoje'] ?? 0}',
        subtitle: '${kpis['pedidos_semana'] ?? 0} na semana',
        trend: '+15%',
      ),
      _KpiCard(
        icon: Icons.attach_money,
        color: Colors.green,
        title: 'Faturamento (mês)',
        value: 'R\$ ${_formatarNumero(kpis['faturamento_mes'] ?? 0)}',
        subtitle: 'R\$ ${_formatarNumero(kpis['faturamento_hoje'] ?? 0)} hoje',
        trend: '+8%',
      ),
      _KpiCard(
        icon: Icons.star,
        color: Colors.purple,
        title: 'Avaliação Média',
        value: '${(kpis['avaliacao_media'] ?? 0).toStringAsFixed(1)}',
        subtitle: '${kpis['clientes_ativos'] ?? 0} clientes ativos',
        trend: '+0.2',
      ),
      _KpiCard(
        icon: Icons.payments,
        color: Colors.teal,
        title: 'Ticket Médio',
        value: 'R\$ ${_formatarNumero(kpis['ticket_medio'] ?? 0)}',
        subtitle: 'Por pedido',
        trend: '+2%',
      ),
      _KpiCard(
        icon: Icons.cancel,
        color: Colors.red,
        title: 'Taxa Cancelamento',
        value: '${kpis['taxa_cancelamento'] ?? 0}%',
        subtitle: '${kpis['distancia_media'] ?? 0} km média',
        trend: '-1%',
      ),
    ];

    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width > 1200 ? 3 : 2; // Mínimo 2 colunas
    final childAspectRatio = width < 400 ? 1.1 : 1.3;

    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: childAspectRatio,
      children: cards,
    );
  }

  String _formatarNumero(dynamic valor) {
    if (valor == null) return '0';
    final numero = valor is num ? valor.toDouble() : double.tryParse(valor.toString()) ?? 0;
    return numero.toStringAsFixed(2).replaceAll('.', ',');
  }
}

class _KpiCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String value;
  final String subtitle;
  final String trend;

  const _KpiCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.trend,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isPositive = trend.startsWith('+');

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ícone + Trend
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: isPositive
                        ? (isDark ? Colors.green.shade900.withOpacity(0.5) : Colors.green.shade50)
                        : (isDark ? Colors.red.shade900.withOpacity(0.5) : Colors.red.shade50),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    trend,
                    style: TextStyle(
                      color: isPositive
                          ? (isDark ? Colors.green.shade300 : Colors.green.shade700)
                          : (isDark ? Colors.red.shade300 : Colors.red.shade700),
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          // Valor
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                maxLines: 1,
              ),
            ),
          ),
          const SizedBox(height: 2),
          // Título
          Flexible(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 10,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 1),
          // Subtítulo
          Flexible(
            child: Text(
              subtitle,
              style: TextStyle(
                fontSize: 8,
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}