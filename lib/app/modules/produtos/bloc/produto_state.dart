import 'package:equatable/equatable.dart';
import '../models/produto.dart';
import '../models/subcategoria.dart';
import '../../categorias/models/categoria.dart';
import '../../lojas/models/loja.dart';

abstract class ProdutoState extends Equatable {
  const ProdutoState();
  @override
  List<Object?> get props => [];
}

class ProdutoInitial extends ProdutoState {}

class ProdutoLoading extends ProdutoState {}

class ProdutoLoaded extends ProdutoState {
  final Produto? produto;
  final List<Categoria> categorias;
  final List<Loja> lojas;
  final List<Subcategoria> subcategorias;

  const ProdutoLoaded({
    this.produto,
    required this.categorias,
    required this.lojas,
    this.subcategorias = const [],
  });

  @override
  List<Object?> get props => [produto, categorias, lojas, subcategorias];
}

class ProdutoError extends ProdutoState {
  final String message;
  const ProdutoError(this.message);
  @override
  List<Object?> get props => [message];
}

class ProdutoOperationLoading extends ProdutoState {}

class ProdutoOperationSuccess extends ProdutoState {
  final String message;
  final bool isDeletion;
  const ProdutoOperationSuccess(this.message, {this.isDeletion = false});
  @override
  List<Object?> get props => [message, isDeletion];
}
