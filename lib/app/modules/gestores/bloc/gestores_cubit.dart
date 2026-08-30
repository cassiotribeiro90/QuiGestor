import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quigestor/app/app_config.dart';
import 'package:quigestor/shared/api/api_client.dart';
import 'package:quigestor/app/modules/gestores/models/gestor.dart';
import 'package:quigestor/app/modules/gestores/bloc/gestores_state.dart';

class GestoresCubit extends Cubit<GestoresState> {
  final ApiClient _apiClient;

  Map<String, String> _activeFilters = {};
  String? _currentSearch;

  GestoresCubit(this._apiClient) : super(const GestoresState());

  Map<String, String> get activeFilters => _activeFilters;
  String? get currentSearch => _currentSearch;

  Future<void> fetchGestores({
    int page = 1,
    int perPage = AppConfig.defaultPerPage,
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
        final filterOptions = data['filter_options'];

        final novosGestores = items.map((json) => Gestor.fromJson(json)).toList();

        List<Gestor> currentGestores;
        if (isLoadMore) {
          currentGestores = [...state.gestores, ...novosGestores];
        } else {
          currentGestores = novosGestores;
        }

        emit(state.copyWith(
          gestores: currentGestores,
          gestoresFiltrados: currentGestores,
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
          error: response.data['message'] ?? 'Erro ao carregar gestores'
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

  Future<void> applyFilters(Map<String, String> filters) async {
    _activeFilters = filters;
    await fetchGestores(page: 1, filters: filters, showLoading: false);
  }

  Future<void> applySearch(String search) {
    _activeFilters['search'] = search;
    _currentSearch = search;
    return fetchGestores(page: 1, showLoading: false);
  }

  Future<void> clearFilters() async {
    _activeFilters = {};
    _currentSearch = null;
    await fetchGestores(page: 1, showLoading: false);
  }

  Future<void> refreshList() async {
    await fetchGestores(page: 1, showLoading: true);
  }

  Future<bool> createGestor(Map<String, dynamic> data) async {
    emit(state.copyWith(isOperationLoading: true));
    try {
      final response = await _apiClient.post(AppConfig.GESTOR_CREATE, data: data);
      if (response.statusCode == 201 && response.data['success'] == true) {
        await fetchGestores(page: 1, showLoading: false);
        emit(state.copyWith(operationMessage: 'Gestor criado com sucesso', isOperationLoading: false));
        return true;
      }
      emit(state.copyWith(error: response.data['message'] ?? 'Erro ao criar gestor', isOperationLoading: false));
      return false;
    } catch (e) {
      emit(state.copyWith(error: 'Erro de conexão: $e', isOperationLoading: false));
      return false;
    }
  }

  Future<bool> updateGestor(int id, Map<String, dynamic> data) async {
    emit(state.copyWith(isOperationLoading: true));
    try {
      final response = await _apiClient.post('${AppConfig.GESTOR_UPDATE}/$id', data: data);
      if (response.statusCode == 200 && response.data['success'] == true) {
        await fetchGestores(page: 1, showLoading: false);
        emit(state.copyWith(operationMessage: 'Gestor atualizado com sucesso', isOperationLoading: false));
        return true;
      }
      emit(state.copyWith(error: response.data['message'] ?? 'Erro ao atualizar gestor', isOperationLoading: false));
      return false;
    } catch (e) {
      emit(state.copyWith(error: 'Erro de conexão: $e', isOperationLoading: false));
      return false;
    }
  }

  Future<bool> deleteGestor(int id) async {
    emit(state.copyWith(isOperationLoading: true));
    try {
      final response = await _apiClient.post('${AppConfig.GESTOR_DELETE}/$id');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final newGestores = List<Gestor>.from(state.gestores)..removeWhere((g) => g.id == id);
        emit(state.copyWith(
          gestores: newGestores,
          gestoresFiltrados: newGestores,
          operationMessage: 'Gestor removido com sucesso',
          isOperationLoading: false,
        ));
        return true;
      }
      emit(state.copyWith(error: response.data['message'] ?? 'Erro ao remover gestor', isOperationLoading: false));
      return false;
    } catch (e) {
      emit(state.copyWith(error: 'Erro de conexão: $e', isOperationLoading: false));
      return false;
    }
  }

  Map<String, dynamic> getFilterCounts() {
    final counts = <String, dynamic>{};
    
    final nivelCounts = <String, int>{};
    for (var gestor in state.gestores) {
      nivelCounts[gestor.nivel] = (nivelCounts[gestor.nivel] ?? 0) + 1;
    }
    counts['nivel'] = nivelCounts;
    
    final statusCounts = <int, int>{};
    for (var gestor in state.gestores) {
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
        emit(state.copyWith(error: response.data['message'] ?? 'Erro ao carregar gestor'));
        return null;
      }
    } catch (e) {
      emit(state.copyWith(error: 'Erro de conexão: $e'));
      return null;
    }
  }

  Future<void> resetAndLoad() async {
    _activeFilters = {};
    _currentSearch = null;
    await fetchGestores(perPage: 10, showLoading: true);
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
