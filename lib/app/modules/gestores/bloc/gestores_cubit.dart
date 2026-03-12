import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quigestor/core/config/app_config.dart';
import 'package:quigestor/shared/api/api_client.dart';
import 'package:quigestor/app/modules/gestores/models/gestor.dart';
import 'package:quigestor/app/modules/gestores/bloc/gestores_state.dart';

class GestoresCubit extends Cubit<GestoresState> {
  final ApiClient _apiClient;

  List<Gestor> _todosGestores = [];
  Map<String, dynamic>? _ultimaPagination;

  String? _currentNivel;
  int? _currentStatus;
  String? _currentSearch;

  GestoresCubit(this._apiClient) : super(GestoresInitial());

  String? get currentNivel => _currentNivel;
  int? get currentStatus => _currentStatus;
  String? get currentSearch => _currentSearch;

  Future<void> fetchGestores({
    int page = 1,
    int perPage = AppConfig.defaultPerPage,
    String? nivel,
    int? status,
    String? search,
    bool isLoadMore = false,
  }) async {
    try {
      if (!isLoadMore) {
        emit(GestoresLoading());
      }

      final response = await _apiClient.get(
        '/gestor/gestor-usuarios',
        queryParameters: {
          'page': page,
          'per_page': perPage,
          if (nivel != null) 'nivel': nivel,
          if (status != null) 'status': status,
          if (search != null && search.isNotEmpty) 'search': search,
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

  Future<Gestor?> fetchGestorDetalhado(int id) async {
    try {
      final response = await _apiClient.get('/gestor/gestor-usuarios/$id');

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

  void filtrarGestores(String search) {
    if (_todosGestores.isEmpty) return;

    final filtradas = _todosGestores.where((g) {
      return g.nome.toLowerCase().contains(search.toLowerCase()) ||
          g.email.toLowerCase().contains(search.toLowerCase());
    }).toList();

    emit(GestoresLoaded(
      gestores: _todosGestores,
      gestoresFiltrados: filtradas,
      pagination: _ultimaPagination,
    ));
  }

  Future<void> applyFilters({
    String? nivel,
    int? status,
    String? search,
  }) async {
    _currentNivel = nivel;
    _currentStatus = status;
    _currentSearch = search;

    await fetchGestores(
      page: 1,
      nivel: nivel,
      status: status,
      search: search,
    );
  }

  Future<void> applyNivel(String? nivel) => applyFilters(nivel: nivel, status: _currentStatus, search: _currentSearch);
  Future<void> applyStatus(int? status) => applyFilters(status: status, nivel: _currentNivel, search: _currentSearch);
  Future<void> applySearch(String search) => applyFilters(search: search, nivel: _currentNivel, status: _currentStatus);

  Future<void> clearFilters() async {
    _currentNivel = null;
    _currentStatus = null;
    _currentSearch = null;
    await fetchGestores(page: 1);
  }

  Future<void> refreshList() async {
    await fetchGestores(
      page: 1,
      nivel: _currentNivel,
      status: _currentStatus,
      search: _currentSearch,
    );
  }

  Future<bool> createGestor(Map<String, dynamic> data) async {
    emit(const GestorOperationLoading());
    try {
      final response = await _apiClient.post('/gestor/gestor-usuarios/create', data: data);
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
      final response = await _apiClient.post('/gestor/gestor-usuarios/update/$id', data: data);
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
      final response = await _apiClient.post('/gestor/gestor-usuarios/delete/$id');
      if (response.statusCode == 200 && response.data['success'] == true) {
        _todosGestores.removeWhere((g) => g.id == id);
        emit(GestoresLoaded(gestores: _todosGestores, gestoresFiltrados: _todosGestores, pagination: _ultimaPagination));
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

  bool get hasMorePages {
    if (_ultimaPagination == null) return false;
    final currentPage = _ultimaPagination!['page'] as int;
    final totalPages = _ultimaPagination!['total_pages'] as int;
    return currentPage < totalPages;
  }

  int get currentPage => _ultimaPagination?['page'] ?? 1;
}
