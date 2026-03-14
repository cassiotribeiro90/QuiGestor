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
  final List<Produto> produtos;
  final Map<String, List<Produto>> produtosAgrupados;
  final Map<String, int> contagens;

  ProdutosLoaded(this.produtos)
      : produtosAgrupados = _agruparPorCategoria(produtos),
        contagens = _calcularContagens(produtos);

  static Map<String, List<Produto>> _agruparPorCategoria(List<Produto> produtos) {
    final agrupados = <String, List<Produto>>{};
    for (var p in produtos) {
      final cat = p.categoria ?? 'Outros';
      if (!agrupados.containsKey(cat)) agrupados[cat] = [];
      agrupados[cat]!.add(p);
    }
    return agrupados;
  }

  static Map<String, int> _calcularContagens(List<Produto> produtos) {
    final contagens = <String, int>{};
    for (var p in produtos) {
      final cat = p.categoria ?? 'Outros';
      contagens[cat] = (contagens[cat] ?? 0) + 1;
    }
    return contagens;
  }

  @override
  List<Object?> get props => [produtos];
}

class ProdutosError extends ProdutosState {
  final String message;
  const ProdutosError(this.message);
  @override
  List<Object?> get props => [message];
}
