import 'package:equatable/equatable.dart';
import '../../../app_config.dart';
import '../models/categoria.dart';

abstract class CategoriasState extends Equatable {
  const CategoriasState();

  @override
  List<Object?> get props => [];
}

class CategoriasInitial extends CategoriasState {}

class CategoriasLoading extends CategoriasState {}

class CategoriasLoaded extends CategoriasState {
  final List<Categoria> categorias;
  final List<Categoria> categoriasFiltradas;
  final Map<String, dynamic>? pagination;
  final Map<String, dynamic>? filterOptions;

  const CategoriasLoaded({
    required this.categorias,
    required this.categoriasFiltradas,
    this.pagination,
    this.filterOptions,
  });

  int get currentPage => pagination?['page'] ?? 1;
  int get totalPages => pagination?['total_pages'] ?? 1;
  int get total => pagination?['total'] ?? 0;
  int get perPage => pagination?['per_page'] ?? AppConfig.defaultPerPage;
  bool get hasMorePages => currentPage < totalPages;

  @override
  List<Object?> get props => [categorias, categoriasFiltradas, pagination, filterOptions];
}

class CategoriasError extends CategoriasState {
  final String message;

  const CategoriasError(this.message);

  @override
  List<Object?> get props => [message];
}

class CategoriaOperationSuccess extends CategoriasState {
  final String message;
  final Categoria? categoria;

  const CategoriaOperationSuccess({required this.message, this.categoria});

  @override
  List<Object?> get props => [message, categoria];
}

class CategoriaOperationLoading extends CategoriasState {
  const CategoriaOperationLoading();
}
