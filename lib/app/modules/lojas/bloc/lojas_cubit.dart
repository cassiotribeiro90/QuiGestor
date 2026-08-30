import 'package:flutter_bloc/flutter_bloc.dart';
import 'lojas_state.dart';
import '../models/loja.dart';
import '../../../../shared/api/api_client.dart';
import '../../../app_config.dart';

class LojasCubit extends Cubit<LojasState> {
  final ApiClient _apiClient;

  Map<String, String> _activeFilters = {};
  String? _currentSearch;

  LojasCubit(this._apiClient) : super(const LojasState());

  // ✅ GETTERS
  Map<String, String> get activeFilters => _activeFilters;
  String? get currentSearch => _currentSearch;
  Map<String, dynamic>? get filterOptions => state.filterOptions;

  // 🔍 LISTAR LOJAS COM PAGINAÇÃO E FILTROS
  Future<void> fetchLojas({
    int page = 1,
    int? perPage,
    bool isLoadMore = false,
    Map<String, String>? filters,
    bool showLoading = false,
  }) async {
    try {
      if (!isLoadMore) {
        if (showLoading || state.isFirstLoad) {
          emit(state.copyWith(isLoading: true, error: null, isLoadingMore: false));
        }
      } else {
        emit(state.copyWith(isLoadingMore: true, error: null));
      }

      if (filters != null) {
        _activeFilters = filters;
        if (filters.containsKey('search')) {
          _currentSearch = filters['search'];
        }
      }

      final itemsPerPage = perPage ?? AppConfig.defaultPerPage;

      final queryParams = {
        'page': page,
        'per_page': itemsPerPage,
        ..._activeFilters,
      };

      final response = await _apiClient.get(
        AppConfig.LOJAS,
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];
        final items = List<Map<String, dynamic>>.from(data['items']);
        final pagination = data['pagination'];
        final filterOptions = data['filter_options'];

        final novasLojas = items.map((json) => Loja.fromJson(json)).toList();

        List<Loja> currentLojas;
        if (isLoadMore) {
          currentLojas = [...state.lojas, ...novasLojas];
        } else {
          currentLojas = novasLojas;
        }

        emit(state.copyWith(
          lojas: currentLojas,
          lojasFiltradas: currentLojas,
          pagination: pagination,
          filterOptions: filterOptions,
          isLoading: false,
          isLoadingMore: false,
          isFirstLoad: false,
          error: null,
        ));
      } else {
        emit(state.copyWith(
          isLoading: false, 
          isLoadingMore: false, 
          isFirstLoad: false,
          error: response.data['message'] ?? 'Erro ao carregar lojas'
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false, 
        isLoadingMore: false, 
        isFirstLoad: false,
        error: 'Erro de conexão: $e'
      ));
    }
  }

  // ✅ APLICAR FILTROS
  Future<void> applyFilters(Map<String, String> filters) async {
    _activeFilters = filters;
    await fetchLojas(page: 1, filters: filters, showLoading: false);
  }

  void applySearch(String search) {
    _activeFilters['search'] = search;
    _currentSearch = search;
    fetchLojas(page: 1, showLoading: false);
  }

  void clearFilters() {
    _activeFilters = {};
    _currentSearch = null;
    fetchLojas(page: 1, showLoading: false);
  }

  Future<void> refreshList() async {
    await fetchLojas(page: 1, showLoading: true);
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
      emit(state.copyWith(error: 'Erro ao buscar detalhes da loja: $e'));
      return null;
    }
  }

  // OPERAÇÕES CRUD
  Future<bool> createLoja(Map<String, dynamic> data) async {
    emit(state.copyWith(isOperationLoading: true));
    try {
      final response = await _apiClient.post(AppConfig.LOJA_CREATE, data: data);
      if (response.statusCode == 201 && response.data['success'] == true) {
        await fetchLojas(page: 1, showLoading: false);
        emit(state.copyWith(operationMessage: 'Loja criada com sucesso', isOperationLoading: false));
        return true;
      }
      emit(state.copyWith(error: response.data['message'] ?? 'Erro ao criar loja', isOperationLoading: false));
      return false;
    } catch (e) {
      emit(state.copyWith(error: 'Erro de conexão: $e', isOperationLoading: false));
      return false;
    }
  }

  Future<bool> updateLoja(int id, Map<String, dynamic> data) async {
    emit(state.copyWith(isOperationLoading: true));
    try {
      final response = await _apiClient.post('${AppConfig.LOJA_UPDATE}/$id', data: data);
      if (response.statusCode == 200 && response.data['success'] == true) {
        await fetchLojas(page: 1, showLoading: false);
        emit(state.copyWith(operationMessage: 'Loja atualizada com sucesso', isOperationLoading: false));
        return true;
      }
      emit(state.copyWith(error: response.data['message'] ?? 'Erro ao atualizar loja', isOperationLoading: false));
      return false;
    } catch (e) {
      emit(state.copyWith(error: 'Erro de conexão: $e', isOperationLoading: false));
      return false;
    }
  }

  Future<bool> deleteLoja(int id) async {
    emit(state.copyWith(isOperationLoading: true));
    try {
      final response = await _apiClient.post('${AppConfig.LOJA_DELETE}/$id');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final newLojas = List<Loja>.from(state.lojas)..removeWhere((l) => l.id == id);
        emit(state.copyWith(
          lojas: newLojas, 
          lojasFiltradas: newLojas, 
          operationMessage: 'Loja removida com sucesso',
          isOperationLoading: false,
        ));
        return true;
      }
      emit(state.copyWith(error: response.data['message'] ?? 'Erro ao remover loja', isOperationLoading: false));
      return false;
    } catch (e) {
      emit(state.copyWith(error: 'Erro de conexão: $e', isOperationLoading: false));
      return false;
    }
  }

  Future<void> resetAndLoad() async {
    _activeFilters = {};
    _currentSearch = null;
    await fetchLojas(perPage: 10, showLoading: true);
  }

  String getFiltrosAtivosResumo() {
    final partes = <String>[];

    for (var entry in _activeFilters.entries) {
      if (entry.key == 'search') continue;
      partes.add('${entry.key}: ${entry.value}');
    }

    if (_currentSearch != null && _currentSearch!.isNotEmpty) {
      partes.add('Busca: $_currentSearch');
    }

    if (partes.isEmpty) return '';
    return partes.join(' | ');
  }
}
