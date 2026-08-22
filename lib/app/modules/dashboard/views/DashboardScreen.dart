import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/dashboard_cubit.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/dashboard_charts.dart';
import '../widgets/dashboard_kpis.dart';
import '../widgets/dashboard_lists.dart';
import '../widgets/dashboard_metrics.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<DashboardCubit>().fetchDashboard();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoading) {
          return const _SkeletonDashboard();
        }

        if (state is DashboardLoaded) {
          return _buildDashboard(state.data);
        }

        if (state is DashboardError) {
          return _buildError(state.message);
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildDashboard(Map<String, dynamic> dados) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<DashboardCubit>().fetchDashboard();
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔥 CABEÇALHO ESTILIZADO (igual ao quiManda)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Visão Geral da Gestão',
                      style: TextStyle(
                        fontSize: isMobile ? 22 : 28,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Acompanhe o desempenho das lojas',
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.business_center, size: 16, color: Colors.blue.shade600),
                      const SizedBox(width: 6),
                      Text(
                        'Gestor',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 🔥 KPIS (cards de métricas)
            DashboardKpis(kpis: dados['kpis'] ?? {}),
            const SizedBox(height: 24),

            // 🔥 CHARTS (gráficos de status e pagamento)
            DashboardCharts(
              pedidosPorDia: dados['pedidos_por_dia'] ?? [],
              faturamentoPorMes: dados['faturamento_por_mes'] ?? [],
              pedidosPorStatus: dados['pedidos_por_status'] ?? [],
              pedidosPorPagamento: dados['pedidos_por_pagamento'] ?? [],
              isMobile: isMobile,
            ),
            const SizedBox(height: 24),

            // 🔥 LISTS (top lojas, produtos, clientes)
            DashboardLists(
              topLojasFaturamento: dados['top_lojas_faturamento'] ?? [],
              topLojasPedidos: dados['top_lojas_pedidos'] ?? [],
              topProdutos: dados['top_produtos'] ?? [],
              topClientes: dados['top_clientes'] ?? [],
              lojasPorCategoria: dados['lojas_por_categoria'] ?? [],
              lojasPorCidade: dados['lojas_por_cidade'] ?? [],
              isMobile: isMobile,
            ),
            const SizedBox(height: 24),

            // 🔥 METRICS (horários pico e satisfação)
            DashboardMetrics(
              horariosPico: dados['horarios_pico'] ?? [],
              satisfacao: dados['satisfacao'] ?? {},
              isMobile: isMobile,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String message) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.red.shade300),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<DashboardCubit>().fetchDashboard(),
              child: const Text('Tentar novamente', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonDashboard extends StatelessWidget {
  const _SkeletonDashboard();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey.shade800 : Colors.grey.shade200;
    final highlightColor = isDark ? Colors.grey.shade700 : Colors.grey.shade100;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Skeleton cabeçalho
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 200,
                    height: 28,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 280,
                    height: 16,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
              Container(
                width: 100,
                height: 36,
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Skeleton KPI cards (grid)
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width < 600 ? 1 : 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            mainAxisExtent: MediaQuery.of(context).size.width < 600 ? 110 : 100,
            children: List.generate(4, (_) => _skeletonKpiCard(baseColor, highlightColor)),
          ),
          const SizedBox(height: 24),

          // Skeleton Charts (2 colunas)
          Row(
            children: List.generate(2, (_) => Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                height: 200,
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            )),
          ),
          const SizedBox(height: 24),

          // Skeleton Lists (3 colunas)
          Row(
            children: List.generate(3, (_) => Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                height: 220,
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            )),
          ),
        ],
      ),
    );
  }

  Widget _skeletonKpiCard(Color baseColor, Color highlightColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: highlightColor,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 18,
                  decoration: BoxDecoration(
                    color: highlightColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 100,
                  height: 14,
                  decoration: BoxDecoration(
                    color: highlightColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}