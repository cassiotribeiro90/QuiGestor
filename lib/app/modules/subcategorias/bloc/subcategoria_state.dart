import 'package:equatable/equatable.dart';
import '../models/subcategoria.dart';

abstract class SubcategoriaState extends Equatable {
  const SubcategoriaState();
  @override
  List<Object?> get props => [];
}

class SubcategoriaInitial extends SubcategoriaState {
  const SubcategoriaInitial();
}

class SubcategoriaLoading extends SubcategoriaState {
  const SubcategoriaLoading();
}

class SubcategoriaLoaded extends SubcategoriaState {
  final List<Subcategoria> subcategorias;
  final Map<String, dynamic>? filterOptions;
  final Map<String, dynamic>? pagination;

  const SubcategoriaLoaded(
    this.subcategorias, {
    this.filterOptions,
    this.pagination,
  });

  @override
  List<Object?> get props => [subcategorias, filterOptions, pagination];
}

class SubcategoriaError extends SubcategoriaState {
  final String message;
  const SubcategoriaError(this.message);
  @override
  List<Object?> get props => [message];
}

class SubcategoriaOperationLoading extends SubcategoriaState {
  const SubcategoriaOperationLoading();
}

class SubcategoriaOperationSuccess extends SubcategoriaState {
  final String message;
  const SubcategoriaOperationSuccess(this.message);
  @override
  List<Object?> get props => [message];
}
