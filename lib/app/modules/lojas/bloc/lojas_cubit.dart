import 'package:flutter_bloc/flutter_bloc.dart';
import 'lojas_state.dart';
import '../models/loja.dart';
import '../../../../shared/api/api_client.dart';
import '../../../../core/config/app_config.dart';

class LojasCubit extends Cubit<LojasState> {
  final ApiClient _apiClient;

  List<Loja> _todasLojas = [];
  Map<String, dynamic>? _ultimaPagination;

  // ✅ FILTROS ATUAIS
  String? _currentStatus;
  bool? _currentDestaque;
  String? _currentCategoria;
  String? _currentSearch;

  LojasCubit(this._apiClient) : super(LojasInitial());

  // ✅ GETTERS
  String? get currentStatus => _currentStatus;
  bool? get currentDestaque => _currentDestaque;
  String? get currentCategoria => _currentCategoria;
  String? get currentSearch => _currentSearch;

  bool get hasMorePages {
    if (_ultimaPagination == null) return false;
    final currentPage = _ultimaPagination!['page'] as int;
    final totalPages = _ultimaPagination!['total_pages'] as int;
    return currentPage < totalPages;
  }

  int get currentPage => _ultimaPagination?['page'] ?? 1;
  int get totalPages => _ultimaPagination?['total_pages'] ?? 1;

  // 🔍 LISTAR LOJAS COM PAGINAÇÃO E FILTROS
  Future<void> fetchLojas({
    int page = 1,
    int? perPage,
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

      final itemsPerPage = perPage ?? AppConfig.defaultPerPage;

      final response = await _apiClient.get(
        '/gestor/lojas',
        queryParameters: {
          'page': page,
          'per_page': itemsPerPage,
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
      if (!isLoadMore) {
        emit(LojasError('Erro de conexão: $e'));
      }
    }
  }

  // ✅ APLICAR FILTROS (versão unificada)
  Future<void> applyFilters({
    String? status,
    bool? destaque,
    String? categoria,
    String? search,
  }) async {
    _currentStatus = status;
    _currentDestaque = destaque;
    _currentCategoria = categoria;
    _currentSearch = search;
    
    await fetchLojas(
      page: 1, // 🔥 RESETA PARA PÁGINA 1 AO APLICAR FILTROS
      status: status,
      destaque: destaque,
      categoria: categoria,
      search: search,
    );
  }

  // ✅ WRAPPERS PARA FILTROS
  void applySearch(String search) => applyFilters(search: search, status: _currentStatus, destaque: _currentDestaque, categoria: _currentCategoria);
  
  // ✅ BUSCAR LOJA DETALHADA
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
    _currentStatus = null;
    _currentDestaque = null;
    _currentCategoria = null;
    _currentSearch = null;
    
    if (_todasLojas.isEmpty) return;

    emit(LojasLoaded(
      lojas: _todasLojas,
      lojasFiltradas: _todasLojas,
      pagination: _ultimaPagination,
    ));
  }

  void clearFilters() {
    limparFiltros();
    fetchLojas();
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

        await refreshList();

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

        await refreshList();

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
    await fetchLojas(
      page: 1, // 🔥 RESETA PARA PÁGINA 1 AO REFRESCAR
      status: _currentStatus,
      destaque: _currentDestaque,
      categoria: _currentCategoria,
      search: _currentSearch,
    );
  }
}
