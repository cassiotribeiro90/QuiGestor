import 'package:flutter_bloc/flutter_bloc.dart';
import 'lojas_state.dart';
import '../models/loja.dart';
import '../../../../shared/api/api_client.dart';

class LojasCubit extends Cubit<LojasState> {
  final ApiClient _apiClient;

  List<Loja> _todasLojas = [];
  Map<String, dynamic>? _ultimaPagination;

  LojasCubit(this._apiClient) : super(LojasInitial());

  Future<void> fetchLojas({
    int page = 1,
    int perPage = 10,
    String? categoria,
    String? status,
    bool? verificado,
    bool? destaque,
    String? search,
    bool isLoadMore = false,
  }) async {
    try {
      if (!isLoadMore) {
        emit(LojasLoading());
      }

      final response = await _apiClient.get(
        '/gestor/lojas',
        queryParameters: {
          'page': page,
          'per_page': perPage,
          if (categoria != null) 'categoria': categoria,
          if (status != null) 'status': status,
          if (verificado != null) 'verificado': verificado ? 1 : 0,
          if (destaque != null) 'destaque': destaque ? 1 : 0,
          if (search != null && search.isNotEmpty) 'search': search,
        },
      );

      if (response.data['success'] == true) {
        final items = List<Map<String, dynamic>>.from(response.data['data']['items']);
        final pagination = response.data['data']['pagination'];

        final novasLojas = items.map((json) => Loja.fromJson(json)).toList();

        if (isLoadMore && state is LojasLoaded) {
          final currentState = state as LojasLoaded;
          _todasLojas = [...currentState.lojas, ...novasLojas];
        } else {
          _todasLojas = novasLojas;
        }

        _ultimaPagination = pagination;

        emit(LojasLoaded(
          lojas: _todasLojas,
          lojasFiltradas: _todasLojas,
          pagination: pagination,
        ));
      } else {
        emit(LojasError(response.data['message'] ?? 'Erro ao carregar lojas'));
      }
    } catch (e) {
      emit(LojasError('Erro de conexão: $e'));
    }
  }

  Future<Loja?> fetchLojaDetalhada(int id) async {
    try {
      final response = await _apiClient.get('/gestor/lojas/$id');
      if (response.data['success'] == true) {
        return Loja.fromJson(response.data['data']);
      }
    } catch (e) {
      print('Erro ao buscar loja detalhada: $e');
    }
    return null;
  }

  void filtrarLojas(String search) {
    if (_todasLojas.isEmpty) return;

    final filtradas = _todasLojas.where((l) {
      return l.nome.toLowerCase().contains(search.toLowerCase()) ||
          l.cidade.toLowerCase().contains(search.toLowerCase()) ||
          l.categoria.toLowerCase().contains(search.toLowerCase());
    }).toList();

    emit(LojasLoaded(
      lojas: _todasLojas,
      lojasFiltradas: filtradas,
      pagination: _ultimaPagination,
    ));
  }

  void limparFiltros() {
    if (_todasLojas.isEmpty) return;

    emit(LojasLoaded(
      lojas: _todasLojas,
      lojasFiltradas: _todasLojas,
      pagination: _ultimaPagination,
    ));
  }

  Future<bool> createLoja(Map<String, dynamic> data) async {
    emit(LojaOperationLoading());

    try {
      final response = await _apiClient.post(
        '/gestor/lojas/create',
        data: data,
      );

      if (response.statusCode == 201 && response.data['success'] == true) {
        final novaLoja = Loja.fromJson(response.data['data']);

        await fetchLojas();

        emit(LojaOperationSuccess(
          message: 'Loja criada com sucesso',
          loja: novaLoja,
        ));

        return true;
      } else {
        emit(LojasError(response.data['message'] ?? 'Erro ao criar loja'));
        return false;
      }
    } catch (e) {
      emit(LojasError('Erro de conexão: $e'));
      return false;
    }
  }

  Future<bool> updateLoja(int id, Map<String, dynamic> data) async {
    emit(LojaOperationLoading());

    try {
      final response = await _apiClient.post(
        '/gestor/lojas/update/$id',
        data: data,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final lojaAtualizada = Loja.fromJson(response.data['data']);

        await fetchLojas();

        emit(LojaOperationSuccess(
          message: 'Loja atualizada com sucesso',
          loja: lojaAtualizada,
        ));

        return true;
      } else {
        emit(LojasError(response.data['message'] ?? 'Erro ao atualizar loja'));
        return false;
      }
    } catch (e) {
      emit(LojasError('Erro de conexão: $e'));
      return false;
    }
  }

  Future<bool> deleteLoja(int id) async {
    emit(LojaOperationLoading());

    try {
      final response = await _apiClient.post(
        '/gestor/lojas/delete/$id',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        _todasLojas = _todasLojas.where((l) => l.id != id).toList();

        emit(LojasLoaded(
          lojas: _todasLojas,
          lojasFiltradas: _todasLojas,
          pagination: _ultimaPagination,
        ));

        emit(LojaOperationSuccess(
          message: 'Loja removida com sucesso',
        ));

        return true;
      } else {
        emit(LojasError(response.data['message'] ?? 'Erro ao remover loja'));
        return false;
      }
    } catch (e) {
      emit(LojasError('Erro de conexão: $e'));
      return false;
    }
  }

  Future<void> refreshList() async {
    await fetchLojas();
  }

  bool get hasMorePages {
    if (_ultimaPagination == null) return false;
    final currentPage = _ultimaPagination!['page'] as int;
    final totalPages = _ultimaPagination!['total_pages'] as int;
    return currentPage < totalPages;
  }

  int get currentPage => _ultimaPagination?['page'] ?? 1;
  int get totalPages => _ultimaPagination?['total_pages'] ?? 1;
}