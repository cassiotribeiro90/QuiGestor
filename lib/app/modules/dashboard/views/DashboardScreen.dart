import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../apparte/widgets/quigestor_card.dart';
import '../bloc/dashboard_cubit.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardCubit>().fetchDashboard();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is DashboardError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 80, color: theme.colorScheme.error),
                  const SizedBox(height: 16),
                  Text(
                    'Erro ao carregar dashboard',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(state.message),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.read<DashboardCubit>().fetchDashboard(),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Tentar novamente'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is DashboardLoaded) {
          final data = state.data;
          final lojas = data['lojas'] as Map;
          final pedidos = data['pedidos'] as Map;
          final metricas = data['metricas'] as Map;

          return RefreshIndicator(
            onRefresh: () => context.read<DashboardCubit>().fetchDashboard(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // === CARDS DE RESUMO ===
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    children: [
                      _buildMetricCard(
                        context,
                        'Lojas',
                        '${lojas['total']}',
                        Icons.store,
                        Colors.blue,
                        subtitulo: '${lojas['ativas']} ativas',
                      ),
                      _buildMetricCard(
                        context,
                        'Pedidos Hoje',
                        '${pedidos['hoje']}',
                        Icons.today,
                        Colors.green,
                      ),
                      _buildMetricCard(
                        context,
                        'Esta Semana',
                        '${pedidos['semana']}',
                        Icons.calendar_view_week,
                        Colors.orange,
                      ),
                      _buildMetricCard(
                        context,
                        'Este Mês',
                        '${pedidos['mes']}',
                        Icons.calendar_month,
                        Colors.purple,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // === SEGUNDA LINHA DE CARDS ===
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.4,
                    children: [
                      _buildMetricCard(
                        context,
                        'Este Ano',
                        '${pedidos['ano']}',
                        Icons.calendar_today,
                        Colors.teal,
                      ),
                      _buildMetricCard(
                        context,
                        'Total Acumulado',
                        '${pedidos['total']}',
                        Icons.history,
                        Colors.brown,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // === CARD DE FATURAMENTO ===
                  QuiGestorCard(
                    horizontalScroll: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.attach_money, color: theme.colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              'Faturamento',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            _buildFaturamentoItem(context, 'Hoje', data['faturamento']['hoje']),
                            const SizedBox(width: 48),
                            _buildFaturamentoItem(context, 'Semana', data['faturamento']['semana']),
                            const SizedBox(width: 48),
                            _buildFaturamentoItem(context, 'Mês', data['faturamento']['mes']),
                            const SizedBox(width: 48),
                            _buildFaturamentoItem(context, 'Ano', data['faturamento']['ano']),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // === CARD DE MÉTRICAS ===
                  QuiGestorCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.analytics, color: theme.colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              'Métricas',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildMetricaItem(
                              context,
                              'Ticket Médio',
                              metricas['ticket_medio'],
                              Icons.receipt,
                            ),
                            _buildMetricaItem(
                              context,
                              'Lojas Ativas',
                              '${metricas['lojas_ativas_percent']}%',
                              Icons.percent,
                            ),
                            _buildMetricaItem(
                              context,
                              'Crescimento',
                              metricas['crescimento_mensal'],
                              Icons.trending_up,
                              cor: Colors.green,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'Última atualização: ${pedidos['ultima_atualizacao']}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildMetricCard(BuildContext context, String titulo, String valor, IconData icone, Color cor, {String? subtitulo}) {
    return QuiGestorCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: cor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icone, color: cor, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(titulo, style: const TextStyle(fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 12),
          Text(valor, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          if (subtitulo != null) ...[
            const SizedBox(height: 4),
            Text(subtitulo, style: TextStyle(color: Colors.grey[600], fontSize: 11)),
          ],
        ],
      ),
    );
  }

  Widget _buildFaturamentoItem(BuildContext context, String periodo, String valor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(periodo, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        const SizedBox(height: 4),
        Text(valor, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildMetricaItem(BuildContext context, String label, String valor, IconData icone, {Color? cor}) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: (cor ?? theme.colorScheme.primary).withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icone, color: cor ?? theme.colorScheme.primary, size: 20),
        ),
        const SizedBox(height: 8),
        Text(valor, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }
}
