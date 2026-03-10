import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/gestores_cubit.dart';
import '../models/gestor.dart';
import '../widgets/gestor_card.dart';
import '../widgets/gestor_filters.dart';
import 'gestor_form_screen.dart';
import 'gestor_detail_screen.dart';
import '../../../../apparte/widgets/app_text.dart';
import '../../../../apparte/widgets/pagination_widget.dart';
import '../../../../app/theme/app_colors.dart';
import '../../theme/bloc/theme_cubit.dart';
import '../../theme/bloc/theme_state.dart';
import '../../home/views/home_screen.dart';

class GestoresListScreen extends StatefulWidget {
  const GestoresListScreen({super.key});

  @override
  State<GestoresListScreen> createState() => _GestoresListScreenState();
}

class _GestoresListScreenState extends State<GestoresListScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    print('🔄 [GestoresList] Carregando dados iniciais...');
    context.read<GestoresCubit>().fetchGestores(page: 1);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        print('🔍 [GestoresList] Buscando por: $value');
        context.read<GestoresCubit>().applyFilters(search: value);
      }
    });
  }

  String _getFiltersSummary(GestoresCubit cubit) {
    if (cubit.currentNivel == null && cubit.currentStatus == null) {
      return 'Todos';
    }

    final nivel = cubit.currentNivel?.toUpperCase() ?? 'Todos';
    final status = cubit.currentStatus == null 
        ? 'Todos' 
        : (cubit.currentStatus == 1 ? 'ATIVOS' : 'INATIVOS');

    final summary = '$nivel, $status';
    print('📊 [GestoresList] Resumo dos filtros: $summary');
    return summary;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appBarColor = theme.appBarTheme.foregroundColor ?? AppColors.textPrimary;
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: isMobile ? AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: _onSearchChanged,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: appBarColor,
                ),
                decoration: InputDecoration(
                  hintText: 'Buscar por nome, email ou CPF...',
                  hintStyle: theme.textTheme.titleMedium?.copyWith(
                    color: appBarColor.withOpacity(0.6),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
                  fillColor: Colors.transparent,
                ),
              )
            : BlocBuilder<GestoresCubit, GestoresState>(
                builder: (context, state) {
                  final cubit = context.read<GestoresCubit>();
                  final summary = _getFiltersSummary(cubit);
                  return Text(
                    summary,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: appBarColor,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  );
                },
              ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search, color: AppColors.iconPrimary),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  context.read<GestoresCubit>().applyFilters(search: '');
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list_rounded, color: AppColors.iconPrimary),
            onPressed: () => _showFilters(context),
          ),
          BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, themeState) {
              return IconButton(
                icon: Icon(
                  themeState.themeMode == ThemeMode.dark
                      ? Icons.light_mode_outlined
                      : Icons.dark_mode_outlined,
                  color: AppColors.iconPrimary,
                ),
                onPressed: () => context.read<ThemeCubit>().toggleTheme(),
              );
            },
          ),
        ],
      ) : null,
      body: Column(
        children: [
          if (!isMobile)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'Buscar por nome, email ou CPF...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.filter_list_rounded),
                    onPressed: () => _showFilters(context),
                    tooltip: 'Filtros',
                  ),
                ],
              ),
            ),
          Expanded(
            child: BlocConsumer<GestoresCubit, GestoresState>(
              listener: (context, state) {
                if (state is GestorOperationSuccess) {
                  print('✅ [GestoresList] Sucesso: ${state.message}');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppColors.success,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                } else if (state is GestoresError) {
                  print('❌ [GestoresList] Erro: ${state.message}');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              builder: (context, state) {
                return RefreshIndicator(
                  onRefresh: () async => _loadInitialData(),
                  child: _buildStateContent(context, state, theme),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToCreate(context),
        icon: const Icon(Icons.add),
        label: const Text('Novo Gestor'),
      ),
    );
  }

  Widget _buildStateContent(BuildContext context, GestoresState state, ThemeData theme) {
    if (state is GestoresLoading && state is! GestoresLoaded) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state is GestoresError && state is! GestoresLoaded) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: AppColors.error),
            const SizedBox(height: 16),
            TextBody1(state.message),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadInitialData,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (state is GestoresLoaded) {
      if (state.gestores.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_outline, size: 100, color: AppColors.textHint),
              const SizedBox(height: 16),
              const TextH3('Nenhum gestor encontrado'),
              const SizedBox(height: 8),
              TextBody2('Tente outros termos de busca ou filtros'),
            ],
          ),
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: state.gestores.length + 1,
        separatorBuilder: (_, __) => const SizedBox.shrink(),
        itemBuilder: (context, index) {
          if (index < state.gestores.length) {
            final gestor = state.gestores[index];
            return GestorCard(
              gestor: gestor,
              onTap: () => _navigateToDetail(context, gestor),
              onEdit: () => _navigateToEdit(context, gestor),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: PaginationWidget(
                currentPage: state.currentPage,
                totalPages: state.totalPages,
                totalItems: state.totalItems,
                onPageChanged: (page) {
                  print('📄 [GestoresList] Mudando para página: $page');
                  context.read<GestoresCubit>().goToPage(page);
                },
                isLoading: state is GestoresLoading,
              ),
            );
          }
        },
      );
    }

    return const SizedBox();
  }

  void _showFilters(BuildContext context) {
    final gestoresCubit = context.read<GestoresCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => BlocProvider.value(
        value: gestoresCubit,
        child: const GestorFilters(),
      ),
    );
  }

  void _navigateToCreate(BuildContext context) {
    final homeState = context.findAncestorStateOfType<HomeScreenState>();
    if (homeState != null) {
      homeState.openGestorForm();
    } else {
      final gestoresCubit = context.read<GestoresCubit>();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: gestoresCubit,
            child: const GestorFormScreen(),
          ),
        ),
      );
    }
  }

  void _navigateToEdit(BuildContext context, Gestor gestor) {
    final homeState = context.findAncestorStateOfType<HomeScreenState>();
    if (homeState != null) {
      homeState.openGestorForm(gestor: gestor);
    } else {
      final gestoresCubit = context.read<GestoresCubit>();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: gestoresCubit,
            child: GestorFormScreen(gestor: gestor),
          ),
        ),
      );
    }
  }

  void _navigateToDetail(BuildContext context, Gestor gestor) {
    final homeState = context.findAncestorStateOfType<HomeScreenState>();
    if (homeState != null) {
      homeState.openGestorDetail(gestor);
    } else {
      final gestoresCubit = context.read<GestoresCubit>();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: gestoresCubit,
            child: GestorDetailScreen(gestor: gestor),
          ),
        ),
      );
    }
  }
}
