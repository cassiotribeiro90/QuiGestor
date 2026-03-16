import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/api/api_client.dart';
import '../models/produto.dart';
import '../models/subcategoria.dart';
import '../../categorias/models/categoria.dart';
import '../../lojas/models/loja.dart';
import 'produto_state.dart';

class ProdutoCubit extends Cubit<ProdutoState> {
  final ApiClient _apiClient;

  ProdutoCubit(this._apiClient) : super(ProdutoInitial());

  Future<void> loadInitialData({int? produtoId}) async {
    emit(ProdutoLoading());
    try {
      final futures = [
        _apiClient.get('/gestor/categorias?per_page=100&ativo=1'),
        _apiClient.get('/gestor/lojas?per_page=100'),
      ];

      if (produtoId != null) {
        futures.add(_apiClient.get('/gestor/produto/view?id=$produtoId'));
      }

      final responses = await Future.wait(futures);

      final categoriasRes = responses[0];
      final lojasRes = responses[1];

      List<Categoria> categorias = [];
      if (categoriasRes.data['success'] == true) {
        final items = categoriasRes.data['data'] is Map 
            ? categoriasRes.data['data']['items'] ?? []
            : categoriasRes.data['data'] as List;
        categorias = (items as List)
            .map((json) => Categoria.fromJson(json))
            .toList();
      }

      List<Loja> lojas = [];
      if (lojasRes.data['success'] == true) {
        final items = lojasRes.data['data'] is Map 
            ? lojasRes.data['data']['items'] ?? []
            : lojasRes.data['data'] as List;
        lojas = (items as List)
            .map((json) => Loja.fromJson(json))
            .toList();
      }

      Produto? produto;
      List<Subcategoria> subcategorias = [];
      
      if (produtoId != null && responses.length > 2) {
        final produtoRes = responses[2];
        if (produtoRes.data['success'] == true) {
          final produtoData = produtoRes.data['data']['produto'];
          if (produtoData != null) {
            produto = Produto.fromJson(produtoData);
            
            // Se o produto tem categoria, carregar subcategorias dela
            final catId = produto.categoriaId;
            if (catId != null) {
              final subResponse = await _apiClient.get(
                '/gestor/subcategoria/por-categoria?id=$catId',
              );
              if (subResponse.data['success'] == true) {
                final List<dynamic> subData = subResponse.data['data'];
                subcategorias = subData.map((j) => Subcategoria.fromJson(j)).toList();
              }
            }
          }
        }
      }

      emit(ProdutoLoaded(
        produto: produto,
        categorias: categorias,
        lojas: lojas,
        subcategorias: subcategorias,
      ));
    } catch (e) {
      emit(ProdutoError('Erro ao carregar dados: $e'));
    }
  }

  Future<bool> saveProduto(Map<String, dynamic> data, {int? id}) async {
    emit(ProdutoOperationLoading());
    try {
      final response = id == null
          ? await _apiClient.post('/gestor/produto/create', data: data)
          : await _apiClient.post('/gestor/produto/update?id=$id', data: data);

      if (response.data['success'] == true) {
        emit(ProdutoOperationSuccess(
          id == null ? 'Produto criado com sucesso' : 'Produto atualizado com sucesso',
        ));
        return true;
      } else {
        emit(ProdutoError(response.data['message'] ?? 'Erro ao salvar produto'));
        return false;
      }
    } catch (e) {
      emit(ProdutoError('Erro de conexão: $e'));
      return false;
    }
  }

  Future<bool> deleteProduto(int id) async {
    emit(ProdutoOperationLoading());
    try {
      final response = await _apiClient.delete('/gestor/produto/delete?id=$id');
      if (response.data['success'] == true) {
        emit(ProdutoOperationSuccess('Produto removido com sucesso', isDeletion: true));
        return true;
      } else {
        emit(ProdutoError(response.data['message'] ?? 'Erro ao remover produto'));
        return false;
      }
    } catch (e) {
      emit(ProdutoError('Erro de conexão: $e'));
      return false;
    }
  }
}
