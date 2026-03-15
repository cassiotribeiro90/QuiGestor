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
      // ✅ Alterado para POST com o formato de URL específico solicitado
      final response = await _apiClient.post('/gestor/loja/produtos?id=$_lojaId');

      if (response.data['success'] == true) {
        final items = List<dynamic>.from(response.data['data']['items'] ?? []);
        final produtos = items.map((json) => Produto.fromJson(json)).toList();
        emit(ProdutosLoaded(produtos));
      } else {
        emit(ProdutosError(response.data['message'] ?? 'Erro ao carregar produtos'));
      }
    } catch (e) {
      emit(ProdutosError('Erro de conexão: $e'));
    }
  }
}
