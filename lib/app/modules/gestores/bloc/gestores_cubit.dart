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

  List<String> _currentNiveis = [];
  List<int> _currentStatusList = [];
  String? _currentSearch;

  GestoresCubit(this._apiClient) : super(GestoresInitial());

  List<String> get currentNiveis => _currentNiveis;
  List<int> get currentStatusList => _currentStatusList;
  String? get currentSearch => _currentSearch;

  Future<void> fetchGestores({
    int page = 1,
    int perPage = AppConfig.defaultPerPage,
    bool isLoadMore = false,
  }) async {
    try {
      if (!isLoadMore) {
        emit(GestoresLoading());
      }

      final response = await _apiClient.get(
        AppConfig.GESTORES,
        queryParameters: {
          'page': page,
          'per_page': perPage,
          if (_currentNiveis.isNotEmpty) 'nivel': _currentNiveis.join(','),
          if (_currentStatusList.isNotEmpty) 'status': _currentStatusList.join(','),
          if (_currentSearch != null && _currentSearch!.isNotEmpty) 'search': _currentSearch,
        },
      );

      if (response.data['success'] == true) {
        final items = List<Map<String, dynamic>>.from(response.data['data']['items']);
        final pagination = response.data['data']['pagination'];

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

  Future<void> applyFilters({
    List<String>? niveis,
    List<int>? status,
    String? search,
  }) async {
    if (niveis != null) _currentNiveis = niveis;
    if (status != null) _currentStatusList = status;
    if (search != null) _currentSearch = search;

    await fetchGestores(page: 1);
  }

  Future<void> applySearch(String search) {
    _currentSearch = search;
    return fetchGestores(page: 1);
  }

  Future<void> clearFilters() async {
    _currentNiveis = [];
    _currentStatusList = [];
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
        emit(GestorOperationSuccess(message: 'Gestor criado com sucesso'));
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
        emit(GestorOperationSuccess(message: 'Gestor atualizado com sucesso'));
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
    _currentSearch = null;
    _currentStatusList = [];
    _currentNiveis = [];
    _todosGestores = [];
  }
}
