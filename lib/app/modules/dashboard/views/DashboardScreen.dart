import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/dashboard_cubit.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/dashboard_charts.dart';
import '../widgets/dashboard_header.dart';
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

    return RefreshIndicator(
      onRefresh: () async {
        context.read<DashboardCubit>().fetchDashboard();
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const DashboardHeader(),
            const SizedBox(height: 20),
            DashboardKpis(kpis: dados['kpis'] ?? {}),
            _buildDivider(context),
            const SizedBox(height: 20),
            DashboardCharts(
              pedidosPorDia: dados['pedidos_por_dia'] ?? [],
              faturamentoPorMes: dados['faturamento_por_mes'] ?? [],
              pedidosPorStatus: dados['pedidos_por_status'] ?? [],
              pedidosPorPagamento: dados['pedidos_por_pagamento'] ?? [],
              isMobile: isMobile,
            ),
            _buildDivider(context),
            const SizedBox(height: 20),
            DashboardLists(
              topLojasFaturamento: dados['top_lojas_faturamento'] ?? [],
              topLojasPedidos: dados['top_lojas_pedidos'] ?? [],
              topProdutos: dados['top_produtos'] ?? [],
              topClientes: dados['top_clientes'] ?? [],
              lojasPorCategoria: dados['lojas_por_categoria'] ?? [],
              lojasPorCidade: dados['lojas_por_cidade'] ?? [],
              isMobile: isMobile,
            ),
            _buildDivider(context),
            const SizedBox(height: 20),
            DashboardMetrics(
              horariosPico: dados['horarios_pico'] ?? [],
              satisfacao: dados['satisfacao'] ?? {},
              isMobile: isMobile,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      height: 1,
      color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60, color: Colors.red.shade300),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<DashboardCubit>().fetchDashboard(),
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }
}

class _SkeletonDashboard extends StatelessWidget {
  const _SkeletonDashboard();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: List.generate(6, (_) => _skeletonCard()),
          ),
        ],
      ),
    );
  }

  Widget _skeletonCard() {
    return Container(
      width: 200,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}