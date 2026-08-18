import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'flat_section.dart';

class DashboardMetrics extends StatelessWidget {
  final List<dynamic> horariosPico;
  final Map<String, dynamic> satisfacao;
  final bool isMobile;

  const DashboardMetrics({
    super.key,
    required this.horariosPico,
    required this.satisfacao,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return Column(
        children: [
          _buildHorariosPico(context),
          const SizedBox(height: 16),
          _buildSatisfacao(context),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildHorariosPico(context)),
        const SizedBox(width: 16),
        Expanded(child: _buildSatisfacao(context)),
      ],
    );
  }

  Widget _buildHorariosPico(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final barColor = isDark ? Colors.orange.shade400 : Colors.orange.shade400;

    return FlatSection(
      title: 'Horários de Pico',
      subtitle: 'Mais pedidos',
      height: 280,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: _getMaxY(horariosPico),
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
                  getTitlesWidget: (value, meta) {
                    final hora = value.toInt();
                    if (hora % 3 == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          '${hora}h',
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          ),
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(show: false),
            borderData: FlBorderData(show: false),
            barGroups: _getHorarioGroups(isDark, barColor),
          ),
        ),
      ),
    );
  }

  Widget _buildSatisfacao(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final total = satisfacao['total'] ?? 0;
    final positivas = satisfacao['positivas'] ?? 0;
    final negativas = satisfacao['negativas'] ?? 0;
    final percentualPositivo = satisfacao['percentual_positivo'] ?? 0;

    return FlatSection(
      title: 'Satisfação',
      subtitle: 'Avaliações aprovadas',
      height: 280,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$percentualPositivo%',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.green.shade400 : Colors.green.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Avaliações positivas',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _satisfacaoItem('Total', total.toString(), isDark ? Colors.blue.shade400 : Colors.blue),
                _satisfacaoItem('Positivas', positivas.toString(), isDark ? Colors.green.shade400 : Colors.green),
                _satisfacaoItem('Negativas', negativas.toString(), isDark ? Colors.red.shade400 : Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _satisfacaoItem(String label, String valor, Color color) {
    return Column(
      children: [
        Text(
          valor,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }

  double _getMaxY(List<dynamic> dados) {
    if (dados.isEmpty) return 100;
    final max = dados.map((d) {
      final raw = d['total'] ?? 0;
      return raw is num ? raw : double.tryParse(raw.toString()) ?? 0;
    }).fold<num>(0, (a, b) => a > b ? a : b);
    return (max.toDouble() * 1.2).clamp(10, double.infinity);
  }

  List<BarChartGroupData> _getHorarioGroups(bool isDark, Color barColor) {
    return List.generate(24, (hora) {
      final item = horariosPico.firstWhere(
            (d) => (d['hora'] ?? 0) == hora,
        orElse: () => {'total': 0},
      );
      final raw = item['total'] ?? 0;
      final valor = raw is num ? raw.toDouble() : double.tryParse(raw.toString()) ?? 0;

      return BarChartGroupData(
        x: hora,
        barRods: [
          BarChartRodData(
            toY: valor,
            borderRadius: BorderRadius.circular(3),
            width: 8,
            color: valor > 0
                ? barColor
                : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
          ),
        ],
      );
    });
  }
}