import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../apparte/widgets/quigestor_card.dart';
import '../../../../apparte/widgets/main_card_dash.dart';
import '../../../../apparte/widgets/app_text.dart';
import '../bloc/dashboard_cubit.dart';
import '../../../../apparte/widgets/responsive_layout.dart';
import '../bloc/dashboard_state.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ScrollController _faturamentoScrollController = ScrollController();
  bool _showLeftFade = false;
  bool _showRightFade = true;

  @override
  void initState() {
    super.initState();
    print('📊 [DashboardScreen] initState - Carregando dados...');
    context.read<DashboardCubit>().fetchDashboard();
    _faturamentoScrollController.addListener(_updateFadeVisibility);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateFadeVisibility());
  }

  @override
  void dispose() {
    _faturamentoScrollController.removeListener(_updateFadeVisibility);
    _faturamentoScrollController.dispose();
    super.dispose();
  }

  void _updateFadeVisibility() {
    if (!_faturamentoScrollController.hasClients) return;

    final maxScroll = _faturamentoScrollController.position.maxScrollExtent;
    final currentScroll = _faturamentoScrollController.offset;

    setState(() {
      _showLeftFade = currentScroll > 0;
      _showRightFade = currentScroll < maxScroll;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    print('📊 [DashboardScreen] build - width: ${MediaQuery.of(context).size.width}');

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
                  TextH2(
                    'Erro ao carregar dashboard',
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 8),
                  TextBody1(
                    state.message,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.read<DashboardCubit>().fetchDashboard(),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const AppTextButton('Tentar novamente'),
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
                  Row(
                    children: [
                      Icon(Icons.analytics, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      TextH2(
                        'Lojas e Pedidos',
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // === CARDS DE RESUMO USANDO WRAP ===
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildWrapItem(
                        context,
                        MainCardDash(
                          titulo: 'Lojas',
                          valor: '${lojas['total']}',
                          icone: Icons.store,
                          cor: Colors.blue,
                        ),
                      ),
                      _buildWrapItem(
                        context,
                        MainCardDash(
                          titulo: 'Lojas Ativas',
                          valor: '${lojas['ativas']}',
                          icone: Icons.check_circle_outline,
                          cor: Colors.indigo,
                        ),
                      ),
                      _buildWrapItem(
                        context,
                        MainCardDash(
                          titulo: 'Pedidos Hoje',
                          valor: '${pedidos['hoje']}',
                          icone: Icons.today,
                          cor: Colors.green,
                        ),
                      ),
                      _buildWrapItem(
                        context,
                        MainCardDash(
                          titulo: 'Esta Semana',
                          valor: '${pedidos['semana']}',
                          icone: Icons.calendar_view_week,
                          cor: Colors.orange,
                        ),
                      ),
                      _buildWrapItem(
                        context,
                        MainCardDash(
                          titulo: 'Este Mês',
                          valor: '${pedidos['mes']}',
                          icone: Icons.calendar_month,
                          cor: Colors.purple,
                        ),
                      ),
                      _buildWrapItem(
                        context,
                        MainCardDash(
                          titulo: 'Este Ano',
                          valor: '${pedidos['ano']}',
                          icone: Icons.calendar_today,
                          cor: Colors.teal,
                        ),
                      ),
                      _buildWrapItem(
                        context,
                        MainCardDash(
                          titulo: 'Total Acumulado',
                          valor: '${pedidos['total']}',
                          icone: Icons.history,
                          cor: Colors.brown,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // === CARD DE FATURAMENTO ===
                  QuiGestorCard(
                    horizontalScroll: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.attach_money, color: theme.colorScheme.primary),
                            const SizedBox(width: 8),
                            TextH2(
                              'Faturamento',
                              color: theme.colorScheme.primary,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return Stack(
                              children: [
                                SingleChildScrollView(
                                  controller: _faturamentoScrollController,
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.only(right: 32),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      _buildFaturamentoItem(context, 'Hoje', data['faturamento']['hoje']),
                                      const SizedBox(width: 16),
                                      _buildFaturamentoItem(context, 'Semana', data['faturamento']['semana']),
                                      const SizedBox(width: 16),
                                      _buildFaturamentoItem(context, 'Mês', data['faturamento']['mes']),
                                      const SizedBox(width: 16),
                                      _buildFaturamentoItem(context, 'Ano', data['faturamento']['ano']),
                                    ],
                                  ),
                                ),
                                if (_showLeftFade)
                                  Positioned(
                                    left: 0,
                                    top: 0,
                                    bottom: 0,
                                    child: Container(
                                      width: 30,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                          colors: [
                                            theme.cardTheme.color ?? theme.colorScheme.surface,
                                            (theme.cardTheme.color ?? theme.colorScheme.surface).withOpacity(0.0),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                if (_showRightFade)
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    bottom: 0,
                                    child: Container(
                                      width: 30,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.centerRight,
                                          end: Alignment.centerLeft,
                                          colors: [
                                            theme.cardTheme.color ?? theme.colorScheme.surface,
                                            (theme.cardTheme.color ?? theme.colorScheme.surface).withOpacity(0.0),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
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
                            TextH2(
                              'Métricas',
                              color: theme.colorScheme.primary,
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
                    child: TextCaption(
                      'Última atualização: ${pedidos['ultima_atualizacao']}',
                      color: Colors.grey[600],
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

  // Função auxiliar para calcular largura responsiva dos cards
  Widget _buildWrapItem(BuildContext context, Widget child) {
    final isWeb = ResponsiveLayout.isWeb(context);
    final screenWidth = MediaQuery.of(context).size.width;

    // 🔥 Web: considera a sidebar de 260px
    // 📱 Mobile: padding padrão de 16px de cada lado (32px total)
    final availableWidth = isWeb
        ? (screenWidth - 260 - 32)  // sidebar 260px + padding 32px
        : (screenWidth - 32);        // apenas padding

    // Log para debug (remover em produção)
    print('📊 [Layout] Screen: $screenWidth, Available: $availableWidth, isWeb: $isWeb');

    int itemsPerRow = 2;
    double maxItemWidth;

    if (isWeb) {
      if (availableWidth > 850) {
        itemsPerRow = 3;
      } else if (availableWidth > 700) {
        itemsPerRow = 3;
      } else if (availableWidth > 500) {
        itemsPerRow = 2;
      } else {
        itemsPerRow = 2;
      }
    } else {
      // Mobile: 1 ou 2 cards
      itemsPerRow = screenWidth > 500 ? 2 : 2;
      maxItemWidth = 200;
    }

    final idealWidth = (availableWidth > 900 ? 220 : (availableWidth / itemsPerRow) - 32).toDouble();



    return SizedBox(
      width: idealWidth,
      child: child,
    );
  }

  Widget _buildFaturamentoItem(BuildContext context, String periodo, String valor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextCaption(periodo, color: Colors.grey[600]),
        const SizedBox(height: 4),
        TextBody1(valor, fontWeight: FontWeight.bold),
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
        TextBody1(valor, fontWeight: FontWeight.bold),
        TextCaption(label, color: Colors.grey[600]),
      ],
    );
  }
}
