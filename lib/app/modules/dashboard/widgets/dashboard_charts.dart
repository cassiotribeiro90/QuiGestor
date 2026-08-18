import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'flat_section.dart';

class DashboardCharts extends StatelessWidget {
  final List<dynamic> pedidosPorDia;
  final List<dynamic> faturamentoPorMes;
  final List<dynamic> pedidosPorStatus;
  final List<dynamic> pedidosPorPagamento;
  final bool isMobile;

  const DashboardCharts({
    super.key,
    required this.pedidosPorDia,
    required this.faturamentoPorMes,
    required this.pedidosPorStatus,
    required this.pedidosPorPagamento,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return Column(
        children: [
          _buildPedidosPorDia(context),
          const SizedBox(height: 16),
          _buildFaturamentoPorMes(context),
          const SizedBox(height: 16),
          _buildPedidosPorStatus(context),
          const SizedBox(height: 16),
          _buildPedidosPorPagamento(context),
        ],
      );
    }

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 2, child: _buildPedidosPorDia(context)),
            const SizedBox(width: 16),
            Expanded(child: _buildFaturamentoPorMes(context)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildPedidosPorStatus(context)),
            const SizedBox(width: 16),
            Expanded(child: _buildPedidosPorPagamento(context)),
          ],
        ),
      ],
    );
  }

  Widget _buildPedidosPorDia(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.grey.shade300 : Colors.grey.shade600;
    final gridColor = isDark ? Colors.grey.shade800 : Colors.grey.shade200;

    return FlatSection(
      title: 'Pedidos por Dia',
      subtitle: 'Últimos 30 dias',
      height: 320,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: _getMaxY(pedidosPorDia),
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                    '${rod.toY.round()} pedidos',
                    const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) {
                    if (pedidosPorDia.isEmpty) return const SizedBox();
                    final index = value.toInt();
                    if (index >= 0 && index < pedidosPorDia.length) {
                      final dia = pedidosPorDia[index]['dia'] ?? '';
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          dia.substring(8, 10),
                          style: TextStyle(fontSize: 10, color: textColor),
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 35,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toInt().toString(),
                      style: TextStyle(fontSize: 10, color: textColor),
                    );
                  },
                ),
              ),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: _getMaxY(pedidosPorDia) / 5,
              getDrawingHorizontalLine: (value) {
                return FlLine(color: gridColor, strokeWidth: 1);
              },
            ),
            borderData: FlBorderData(show: false),
            barGroups: _getBarGroups(context, pedidosPorDia),
          ),
        ),
      ),
    );
  }

  Widget _buildFaturamentoPorMes(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.grey.shade300 : Colors.grey.shade600;
    final gridColor = isDark ? Colors.grey.shade800 : Colors.grey.shade200;

    return FlatSection(
      title: 'Faturamento por Mês',
      subtitle: 'Últimos 12 meses',
      height: 320,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LineChart(
          LineChartData(
            minY: 0,
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (spots) {
                  return spots.map((spot) {
                    return LineTooltipItem(
                      'R\$ ${_formatarNumero(spot.y)}',
                      const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    );
                  }).toList();
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) {
                    if (faturamentoPorMes.isEmpty) return const SizedBox();
                    final index = value.toInt();
                    if (index >= 0 && index < faturamentoPorMes.length) {
                      final mes = faturamentoPorMes[index]['mes'] ?? '';
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          mes.substring(5, 7),
                          style: TextStyle(fontSize: 10, color: textColor),
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 50,
                  getTitlesWidget: (value, meta) {
                    if (value == 0) return const SizedBox();
                    return Text(
                      'R\$ ${_formatarNumeroCurto(value)}',
                      style: TextStyle(fontSize: 10, color: textColor),
                    );
                  },
                ),
              ),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (value) {
                return FlLine(color: gridColor, strokeWidth: 1);
              },
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: _getLineSpots(faturamentoPorMes),
                isCurved: true,
                color: isDark ? Colors.lightBlue.shade300 : Theme.of(context).primaryColor,
                barWidth: 3,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 4,
                      color: isDark ? Colors.lightBlue.shade300 : Theme.of(context).primaryColor,
                      strokeWidth: 2,
                      strokeColor: isDark ? Colors.grey.shade900 : Colors.white,
                    );
                  },
                ),
                belowBarData: BarAreaData(
                  show: true,
                  color: (isDark ? Colors.lightBlue.shade300 : Theme.of(context).primaryColor).withOpacity(0.1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPedidosPorStatus(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FlatSection(
      title: 'Pedidos por Status',
      subtitle: 'Distribuição atual',
      height: 280,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: PieChart(
          PieChartData(
            sections: _getStatusSections(isDark),
            centerSpaceRadius: 40,
            sectionsSpace: 2,
            pieTouchData: PieTouchData(touchCallback: (event, response) {}),
          ),
        ),
      ),
    );
  }

  Widget _buildPedidosPorPagamento(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FlatSection(
      title: 'Forma de Pagamento',
      subtitle: 'Distribuição',
      height: 280,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: pedidosPorPagamento.map((item) {
          final total = pedidosPorPagamento.fold<int>(0, (sum, i) {
            final raw = i['total'] ?? 0;
            return sum + (raw is num ? raw.toInt() : int.tryParse(raw.toString()) ?? 0);
          });
          final raw = item['total'] ?? 0;
          final valor = raw is num ? raw.toInt() : int.tryParse(raw.toString()) ?? 0;
          final percent = total > 0 ? (valor / total) * 100 : 0.0;
          final label = item['forma_pagamento'] ?? '';

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.grey.shade300 : Colors.black87,
                      ),
                    ),
                    Text(
                      '${percent.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: percent / 100,
                    minHeight: 8,
                    backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(_getPagamentoColor(label, isDark)),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ==================== HELPERS ====================

  double _getMaxY(List<dynamic> dados) {
    if (dados.isEmpty) return 100;
    final max = dados.map((d) {
      final raw = d['total'] ?? 0;
      return raw is num ? raw : double.tryParse(raw.toString()) ?? 0;
    }).fold<num>(0, (a, b) => a > b ? a : b);
    return (max.toDouble() * 1.2).clamp(10, double.infinity);
  }

  List<BarChartGroupData> _getBarGroups(BuildContext context, List<dynamic> dados) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final barColor = isDark ? Colors.lightBlue.shade300 : Theme.of(context).primaryColor;

    return List.generate(dados.length, (index) {
      final raw = dados[index]['total'] ?? 0;
      final valor = raw is num ? raw.toDouble() : double.tryParse(raw.toString()) ?? 0;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: valor,
            borderRadius: BorderRadius.circular(4),
            width: 8,
            gradient: LinearGradient(
              colors: [barColor, barColor.withOpacity(0.5)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ],
      );
    });
  }

  List<FlSpot> _getLineSpots(List<dynamic> dados) {
    return List.generate(dados.length, (index) {
      final raw = dados[index]['total'] ?? 0;
      final valor = raw is num ? raw.toDouble() : double.tryParse(raw.toString()) ?? 0;
      return FlSpot(index.toDouble(), valor);
    });
  }

  List<PieChartSectionData> _getStatusSections(bool isDark) {
    final cores = [
      Colors.blue,
      Colors.orange,
      Colors.green,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];

    return List.generate(pedidosPorStatus.length, (index) {
      final item = pedidosPorStatus[index];
      final raw = item['total'] ?? 0;
      final valor = raw is num ? raw.toDouble() : double.tryParse(raw.toString()) ?? 0;
      final cor = isDark ? cores[index % cores.length].shade300 : cores[index % cores.length];
      final label = item['status'] ?? '';

      return PieChartSectionData(
        value: valor > 0 ? valor : 1,
        title: '$label\n${valor.toInt()}',
        color: cor,
        radius: 60,
        titleStyle: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold),
      );
    });
  }

  String _formatarNumero(dynamic valor) {
    if (valor == null) return '0';
    final numero = valor is num ? valor.toDouble() : double.tryParse(valor.toString()) ?? 0;
    return numero.toStringAsFixed(2).replaceAll('.', ',');
  }

  String _formatarNumeroCurto(double valor) {
    if (valor >= 1000) {
      return '${(valor / 1000).toStringAsFixed(1)}k';
    }
    return valor.toStringAsFixed(0);
  }

  Color _getPagamentoColor(String label, bool isDark) {
    switch (label.toLowerCase()) {
      case 'pix':
        return isDark ? Colors.green.shade400 : Colors.green;
      case 'credito':
        return isDark ? Colors.blue.shade400 : Colors.blue;
      case 'debito':
        return isDark ? Colors.orange.shade400 : Colors.orange;
      case 'dinheiro':
        return isDark ? Colors.teal.shade400 : Colors.teal;
      default:
        return isDark ? Colors.grey.shade400 : Colors.grey;
    }
  }
}