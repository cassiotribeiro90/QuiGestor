import 'package:equatable/equatable.dart';
import 'package:quigestor/app/app_config.dart';
import 'package:quigestor/app/modules/gestores/models/gestor.dart';

class GestoresState extends Equatable {
  final List<Gestor> gestores;
  final List<Gestor> gestoresFiltrados;
  final Map<String, dynamic>? pagination;
  final Map<String, dynamic>? filterOptions;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isFirstLoad;
  final String? error;
  final String? operationMessage;
  final bool isOperationLoading;

  const GestoresState({
    this.gestores = const [],
    this.gestoresFiltrados = const [],
    this.pagination,
    this.filterOptions,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isFirstLoad = true,
    this.error,
    this.operationMessage,
    this.isOperationLoading = false,
  });

  // 🔥 GETTERS DE PAGINAÇÃO
  int get currentPage => pagination?['page'] ?? 1;
  int get totalPages => pagination?['total_pages'] ?? 1;
  int get total => pagination?['total'] ?? 0;
  int get perPage => pagination?['per_page'] ?? AppConfig.defaultPerPage;
  bool get hasMorePages => currentPage < totalPages;

  GestoresState copyWith({
    List<Gestor>? gestores,
    List<Gestor>? gestoresFiltrados,
    Map<String, dynamic>? pagination,
    Map<String, dynamic>? filterOptions,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isFirstLoad,
    String? error,
    String? operationMessage,
    bool? isOperationLoading,
  }) {
    return GestoresState(
      gestores: gestores ?? this.gestores,
      gestoresFiltrados: gestoresFiltrados ?? this.gestoresFiltrados,
      pagination: pagination ?? this.pagination,
      filterOptions: filterOptions ?? this.filterOptions,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isFirstLoad: isFirstLoad ?? this.isFirstLoad,
      error: error,
      operationMessage: operationMessage,
      isOperationLoading: isOperationLoading ?? this.isOperationLoading,
    );
  }

  @override
  List<Object?> get props => [
    gestores,
    gestoresFiltrados,
    pagination,
    filterOptions,
    isLoading,
    isLoadingMore,
    isFirstLoad,
    error,
    operationMessage,
    isOperationLoading,
  ];
}
