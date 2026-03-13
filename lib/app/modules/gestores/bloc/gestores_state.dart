import 'package:equatable/equatable.dart';
import 'package:quigestor/app/app_config.dart';
import 'package:quigestor/app/modules/gestores/models/gestor.dart';

abstract class GestoresState extends Equatable {
  const GestoresState();

  @override
  List<Object?> get props => [];
}

class GestoresInitial extends GestoresState {}

class GestoresLoading extends GestoresState {}

class GestoresLoaded extends GestoresState {
  final List<Gestor> gestores;
  final List<Gestor> gestoresFiltrados;
  final Map<String, dynamic>? pagination;

  const GestoresLoaded({
    required this.gestores,
    required this.gestoresFiltrados,
    this.pagination,
  });

  // 🔥 GETTERS DE PAGINAÇÃO
  int get currentPage => pagination?['page'] ?? 1;
  int get totalPages => pagination?['total_pages'] ?? 1;
  int get total => pagination?['total'] ?? 0;
  int get perPage => pagination?['per_page'] ?? AppConfig.defaultPerPage;
  bool get hasMorePages => currentPage < totalPages;

  @override
  List<Object?> get props => [gestores, gestoresFiltrados, pagination];
}

class GestoresError extends GestoresState {
  final String message;

  const GestoresError(this.message);

  @override
  List<Object?> get props => [message];
}

class GestorOperationSuccess extends GestoresState {
  final String message;
  final Gestor? gestor;

  const GestorOperationSuccess({required this.message, this.gestor});

  @override
  List<Object?> get props => [message, gestor];
}

class GestorOperationLoading extends GestoresState {
  const GestorOperationLoading();
}
