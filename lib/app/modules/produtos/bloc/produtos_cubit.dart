import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/api/api_client.dart';
import '../models/produto.dart';
import 'produtos_state.dart';

class ProdutosCubit extends Cubit<ProdutosState> {
  final ApiClient _apiClient;
  final int _lojaId;

  ProdutosCubit(this._apiClient, this._lojaId) : super(ProdutosInitial());

  Future<void> fetchProdutos() async {
    emit(ProdutosLoading());
    try {
      final response = await _apiClient.post(
          '/gestor/loja/produtos?id=$_lojaId');

      if (response.data['success'] == true) {
        final data = response.data['data'];

        final sections = <String, List<Produto>>{};

        // ✅ Verifica o tipo de data['items']
        final items = data['items'];

        if (items is Map) {
          // É um mapa: cada chave é uma categoria
          items.forEach((key, value) {
            final produtos = (value as List)
                .map((json) => Produto.fromJson(json))
                .toList();
            sections[key.toString()] = produtos;
          });
        } else if (items is List) {
          // É uma lista (provavelmente vazia ou formato antigo)
          // Se houver itens, podemos agrupar manualmente, mas normalmente estará vazio
          if (items.isNotEmpty) {
            // Fallback: coloca todos em "Outros"
            final produtos = items
                .map((json) => Produto.fromJson(json))
                .toList();
            sections['Outros'] = produtos;
          }
          // Se vazio, sections permanece vazio (o que é correto)
        }

        final categories = (data['categories'] as List?)
            ?.map((c) => Map<String, dynamic>.from(c))
            .toList() ?? [];

        final pagination = data['pagination'];

        emit(ProdutosLoaded(
          sections: sections,
          categories: categories,
          pagination: pagination,
        ));
      } else {
        emit(ProdutosError(
            response.data['message'] ?? 'Erro ao carregar produtos'));
      }
    } catch (e) {
      emit(ProdutosError('Erro de conexão: $e'));
    }
  }
}
