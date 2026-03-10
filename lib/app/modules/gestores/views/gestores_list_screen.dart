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
        context.read<GestoresCubit>().applyFilters(search: value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appBarColor = theme.appBarTheme.foregroundColor ?? AppColors.textPrimary;

    return Scaffold(
      appBar: AppBar(
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
            : const Text('Gestores'),
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
        ],
      ),
      body: BlocConsumer<GestoresCubit, GestoresState>(
        listener: (context, state) {
          if (state is GestorOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
                duration: const Duration(seconds: 2),
              ),
            );
          } else if (state is GestoresError) {
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
        padding: EdgeInsets.zero,
        itemCount: state.gestores.length + 1,
        separatorBuilder: (_, __) => const SizedBox.shrink(),
        itemBuilder: (context, index) {
          if (index < state.gestores.length) {
            final gestor = state.gestores[index];
            return GestorCard(
              gestor: gestor,
              onTap: () => _navigateToDetail(context, gestor),
              onEdit: () => _navigateToEdit(context, gestor),
              onDelete: () => _confirmDelete(context, gestor),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: PaginationWidget(
                currentPage: state.currentPage,
                totalPages: state.totalPages,
                totalItems: state.totalItems,
                onPageChanged: (page) {
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

  void _navigateToCreate(BuildContext context) async {
    final gestoresCubit = context.read<GestoresCubit>();
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: gestoresCubit,
          child: const GestorFormScreen(),
        ),
      ),
    );
  }

  void _navigateToEdit(BuildContext context, Gestor gestor) async {
    final gestoresCubit = context.read<GestoresCubit>();
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: gestoresCubit,
          child: GestorFormScreen(gestor: gestor),
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context, Gestor gestor) {
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

  Future<void> _confirmDelete(BuildContext context, Gestor gestor) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Deseja realmente excluir o gestor ${gestor.nome}?'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                'Excluir',
                style: TextStyle(color: AppColors.error, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(120, 44),
            ),
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      context.read<GestoresCubit>().deleteGestor(gestor.id);
    }
  }
}
