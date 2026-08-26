import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quigestor/app/app_config.dart';
import 'package:quigestor/shared/api/api_client.dart';
import 'package:quigestor/app/modules/gestores/models/gestor.dart';
import 'package:quigestor/app/modules/gestores/bloc/gestores_state.dart';

class GestoresCubit extends Cubit<GestoresState> {
  final ApiClient _apiClient;

  List<Gestor> _todosGestores = [];
  Map<String, dynamic>? _ultimaPagination;
  Map<String, dynamic>? _filterOptions;

  Map<String, String> _activeFilters = {};
  String? _currentSearch;

  GestoresCubit(this._apiClient) : super(GestoresInitial());

  Map<String, String> get activeFilters => _activeFilters;
  String? get currentSearch => _currentSearch;
  Map<String, dynamic>? get filterOptions => _filterOptions;

  Future<void> fetchGestores({
    int page = 1,
    int perPage = AppConfig.defaultPerPage,
    bool isLoadMore = false,
    Map<String, String>? filters,
  }) async {
    try {
      if (!isLoadMore) {
        emit(GestoresLoading());
      }

      if (filters != null) {
        _activeFilters = filters;
        if (filters.containsKey('search')) {
          _currentSearch = filters['search'];
        }
      }

      final queryParams = {
        'page': page,
        'per_page': perPage,
        ..._activeFilters,
      };

      final response = await _apiClient.get(
        AppConfig.GESTORES,
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];
        final items = List<Map<String, dynamic>>.from(data['items']);
        final pagination = data['pagination'];
        _filterOptions = data['filter_options'];

        final novosGestores = items.map((json) => Gestor.fromJson(json)).toList();

        if (isLoadMore && state is GestoresLoaded) {
          final currentState = state as GestoresLoaded;
          _todosGestores = [...currentState.gestores, ...novosGestores];
        } else {
          _todosGestores = novosGestores;
        }

        _ultimaPagination = pagination;

        emit(GestoresLoaded(
          gestores: _todosGestores,
          gestoresFiltrados: _todosGestores,
          pagination: pagination,
          filterOptions: _filterOptions,
        ));
      } else {
        emit(GestoresError(response.data['message'] ?? 'Erro ao carregar gestores'));
      }
    } catch (e) {
      if (!isLoadMore) {
        emit(GestoresError('Erro de conexão: $e'));
      }
    }
  }

  Future<void> applyFilters(Map<String, String> filters) async {
    _activeFilters = filters;
    await fetchGestores(page: 1, filters: filters);
  }

  Future<void> applySearch(String search) {
    _activeFilters['search'] = search;
    _currentSearch = search;
    return fetchGestores(page: 1);
  }

  Future<void> clearFilters() async {
    _activeFilters = {};
    _currentSearch = null;
    await fetchGestores(page: 1);
  }

  Future<void> refreshList() async {
    await fetchGestores(page: 1);
  }

  Future<bool> createGestor(Map<String, dynamic> data) async {
    emit(const GestorOperationLoading());
    try {
      final response = await _apiClient.post(AppConfig.GESTOR_CREATE, data: data);
      if (response.statusCode == 201 && response.data['success'] == true) {
        await refreshList();
        emit(const GestorOperationSuccess(message: 'Gestor criado com sucesso'));
        return true;
      }
      emit(GestoresError(response.data['message'] ?? 'Erro ao criar gestor'));
      return false;
    } catch (e) {
      emit(GestoresError('Erro de conexão: $e'));
      return false;
    }
  }

  Future<bool> updateGestor(int id, Map<String, dynamic> data) async {
    emit(const GestorOperationLoading());
    try {
      final response = await _apiClient.post('${AppConfig.GESTOR_UPDATE}/$id', data: data);
      if (response.statusCode == 200 && response.data['success'] == true) {
        await refreshList();
        emit(const GestorOperationSuccess(message: 'Gestor atualizado com sucesso'));
        return true;
      }
      emit(GestoresError(response.data['message'] ?? 'Erro ao atualizar gestor'));
      return false;
    } catch (e) {
      emit(GestoresError('Erro de conexão: $e'));
      return false;
    }
  }

  Future<bool> deleteGestor(int id) async {
    emit(const GestorOperationLoading());
    try {
      final response = await _apiClient.post('${AppConfig.GESTOR_DELETE}/$id');
      if (response.statusCode == 200 && response.data['success'] == true) {
        _todosGestores.removeWhere((g) => g.id == id);
        emit(GestoresLoaded(
          gestores: _todosGestores,
          gestoresFiltrados: _todosGestores,
          pagination: _ultimaPagination,
        ));
        emit(const GestorOperationSuccess(message: 'Gestor removido com sucesso'));
        return true;
      }
      emit(GestoresError(response.data['message'] ?? 'Erro ao remover gestor'));
      return false;
    } catch (e) {
      emit(GestoresError('Erro de conexão: $e'));
      return false;
    }
  }

  Map<String, dynamic> getFilterCounts() {
    final counts = <String, dynamic>{};
    
    final nivelCounts = <String, int>{};
    for (var gestor in _todosGestores) {
      nivelCounts[gestor.nivel] = (nivelCounts[gestor.nivel] ?? 0) + 1;
    }
    counts['nivel'] = nivelCounts;
    
    final statusCounts = <int, int>{};
    for (var gestor in _todosGestores) {
      statusCounts[gestor.status] = (statusCounts[gestor.status] ?? 0) + 1;
    }
    counts['status'] = statusCounts;
    
    return counts;
  }

  Future<Gestor?> fetchGestorDetalhado(int id) async {
    try {
      final response = await _apiClient.get('${AppConfig.GESTORES}/$id');

      if (response.data['success'] == true) {
        return Gestor.fromJson(response.data['data']);
      } else {
        emit(GestoresError(response.data['message'] ?? 'Erro ao carregar gestor'));
        return null;
      }
    } catch (e) {
      emit(GestoresError('Erro de conexão: $e'));
      return null;
    }
  }

  bool get hasMorePages {
    if (_ultimaPagination == null) return false;
    final currentPage = _ultimaPagination!['page'] as int;
    final totalPages = _ultimaPagination!['total_pages'] as int;
    return currentPage < totalPages;
  }

  int get currentPage => _ultimaPagination?['page'] ?? 1;

  /// 🔥 Versão que já carrega os dados (opcional)
  Future<void> resetAndLoad() async {
    resetFilters();
    await fetchGestores(perPage: 10);
  }

  void resetFilters() {
    _activeFilters = {};
    _currentSearch = null;
    _todosGestores = [];
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
