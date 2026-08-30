import 'package:equatable/equatable.dart';
import '../../../app_config.dart';
import '../models/loja.dart';

class LojasState extends Equatable {
  final List<Loja> lojas;
  final List<Loja> lojasFiltradas;
  final Map<String, dynamic>? pagination;
  final Map<String, dynamic>? filterOptions;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isFirstLoad;
  final String? error;
  final String? operationMessage;
  final bool isOperationLoading;

  const LojasState({
    this.lojas = const [],
    this.lojasFiltradas = const [],
    this.pagination,
    this.filterOptions,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isFirstLoad = true,
    this.error,
    this.operationMessage,
    this.isOperationLoading = false,
  });

  // 🔥 GETTERS AUXILIARES PARA PAGINAÇÃO
  int get currentPage => pagination?['page'] ?? 1;
  int get totalPages => pagination?['total_pages'] ?? 1;
  int get total => pagination?['total'] ?? 0;
  int get perPage => pagination?['per_page'] ?? AppConfig.defaultPerPage;
  bool get hasMorePages => currentPage < totalPages;

  LojasState copyWith({
    List<Loja>? lojas,
    List<Loja>? lojasFiltradas,
    Map<String, dynamic>? pagination,
    Map<String, dynamic>? filterOptions,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isFirstLoad,
    String? error,
    String? operationMessage,
    bool? isOperationLoading,
  }) {
    return LojasState(
      lojas: lojas ?? this.lojas,
      lojasFiltradas: lojasFiltradas ?? this.lojasFiltradas,
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
    lojas,
    lojasFiltradas,
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
