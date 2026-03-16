import 'package:equatable/equatable.dart';
import '../models/produto.dart';

abstract class ProdutosState extends Equatable {
  const ProdutosState();
  @override
  List<Object?> get props => [];
}

class ProdutosInitial extends ProdutosState {}

class ProdutosLoading extends ProdutosState {}

class ProdutosLoaded extends ProdutosState {
  final Map<String, List<Produto>> sections; // ← Agora é um Map
  final List<Map<String, dynamic>> categories; // ← Metadados
  final Map<String, dynamic>? pagination;

  const ProdutosLoaded({
    required this.sections,
    required this.categories,
    this.pagination,
  });

  // Getter para lista plana (se necessário)
  List<Produto> get allItems =>
      sections.values.expand((list) => list).toList();

  @override
  List<Object?> get props => [sections, categories, pagination];
}

class ProdutosError extends ProdutosState {
  final String message;
  const ProdutosError(this.message);
  @override
  List<Object?> get props => [message];
}
