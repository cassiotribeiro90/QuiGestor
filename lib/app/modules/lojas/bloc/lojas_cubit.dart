import 'package:flutter_bloc/flutter_bloc.dart';
import 'lojas_state.dart';
import '../models/loja.dart';
import '../../../../shared/api/api_client.dart';
import '../../../app_config.dart';

class LojasCubit extends Cubit<LojasState> {
  final ApiClient _apiClient;

  List<Loja> _todasLojas = [];
  Map<String, dynamic>? _ultimaPagination;
  Map<String, dynamic>? _filterOptions;

  // ✅ FILTROS ATUAIS (MODO ONLINE)
  List<String> _currentStatusList = [];
  List<String> _currentCategorias = [];
  bool? _currentDestaque;
  bool? _currentVerificado;
  String? _currentSearch;

  LojasCubit(this._apiClient) : super(LojasInitial());

  // ✅ GETTERS
  List<String> get currentStatusList => _currentStatusList;
  List<String> get currentCategorias => _currentCategorias;
  bool? get currentDestaque => _currentDestaque;
  bool? get currentVerificado => _currentVerificado;
  String? get currentSearch => _currentSearch;
  Map<String, dynamic>? get filterOptions => _filterOptions;

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
    bool isLoadMore = false,
  }) async {
    try {
      if (!isLoadMore) {
        emit(LojasLoading());
      }

      final itemsPerPage = perPage ?? AppConfig.defaultPerPage;

      final response = await _apiClient.get(
        AppConfig.LOJAS,
        queryParameters: {
          'page': page,
          'per_page': itemsPerPage,
          if (_currentCategorias.isNotEmpty) 'categoria': _currentCategorias.join(','),
          if (_currentStatusList.isNotEmpty) 'status': _currentStatusList.join(','),
          if (_currentDestaque != null) 'destaque': _currentDestaque! ? 1 : 0,
          if (_currentVerificado != null) 'verificado': _currentVerificado! ? 1 : 0,
          if (_currentSearch != null && _currentSearch!.isNotEmpty) 'search': _currentSearch,
        },
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];
        final items = List<Map<String, dynamic>>.from(data['items']);
        final pagination = data['pagination'];
        _filterOptions = data['filter_options'];

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
          filterOptions: _filterOptions,
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

  // ✅ APLICAR FILTROS
  Future<void> applyFilters({
    List<String>? status,
    bool? destaque,
    bool? verificado,
    List<String>? categorias,
    String? search,
  }) async {
    if (status != null) _currentStatusList = status;
    if (destaque != null || destaque == null) _currentDestaque = destaque;
    if (verificado != null || verificado == null) _currentVerificado = verificado;
    if (categorias != null) _currentCategorias = categorias;
    if (search != null) _currentSearch = search;
    
    await fetchLojas(page: 1);
  }

  void applySearch(String search) {
    _currentSearch = search;
    fetchLojas(page: 1);
  }

  void clearFilters() {
    _currentStatusList = [];
    _currentCategorias = [];
    _currentDestaque = null;
    _currentVerificado = null;
    _currentSearch = null;
    fetchLojas(page: 1);
  }

  Future<void> refreshList() async {
    await fetchLojas(page: 1);
  }

  // ✅ BUSCAR LOJA DETALHADA
  Future<Loja?> fetchLojaDetalhada(int id) async {
    try {
      final response = await _apiClient.get('${AppConfig.LOJAS}/$id');
      if (response.data['success'] == true) {
        return Loja.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      emit(LojasError('Erro ao buscar detalhes da loja: $e'));
      return null;
    }
  }

  // OPERAÇÕES CRUD
  Future<bool> createLoja(Map<String, dynamic> data) async {
    emit(const LojaOperationLoading());
    try {
      final response = await _apiClient.post(AppConfig.LOJA_CREATE, data: data);
      if (response.statusCode == 201 && response.data['success'] == true) {
        await refreshList();
        emit(LojaOperationSuccess(message: 'Loja criada com sucesso'));
        return true;
      }
      emit(LojasError(response.data['message'] ?? 'Erro ao criar loja'));
      return false;
    } catch (e) {
      emit(LojasError('Erro de conexão: $e'));
      return false;
    }
  }

  Future<bool> updateLoja(int id, Map<String, dynamic> data) async {
    emit(const LojaOperationLoading());
    try {
      final response = await _apiClient.post('${AppConfig.LOJA_UPDATE}/$id', data: data);
      if (response.statusCode == 200 && response.data['success'] == true) {
        await refreshList();
        emit(LojaOperationSuccess(message: 'Loja atualizada com sucesso'));
        return true;
      }
      emit(LojasError(response.data['message'] ?? 'Erro ao atualizar loja'));
      return false;
    } catch (e) {
      emit(LojasError('Erro de conexão: $e'));
      return false;
    }
  }

  Future<bool> deleteLoja(int id) async {
    emit(const LojaOperationLoading());
    try {
      final response = await _apiClient.post('${AppConfig.LOJA_DELETE}/$id');
      if (response.statusCode == 200 && response.data['success'] == true) {
        _todasLojas = _todasLojas.where((l) => l.id != id).toList();
        emit(LojasLoaded(lojas: _todasLojas, lojasFiltradas: _todasLojas, pagination: _ultimaPagination, filterOptions: _filterOptions));
        emit(const LojaOperationSuccess(message: 'Loja removida com sucesso'));
        return true;
      }
      emit(LojasError(response.data['message'] ?? 'Erro ao remover loja'));
      return false;
    } catch (e) {
      emit(LojasError('Erro de conexão: $e'));
      return false;
    }
  }
}
