import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/config/app_config.dart';
import '../../../../shared/api/api_client.dart';
import '../models/gestor.dart';

// ========== ESTADOS ==========
abstract class GestoresState extends Equatable {
  const GestoresState();

  @override
  List<Object?> get props => [];
}

class GestoresInitial extends GestoresState {}

class GestoresLoading extends GestoresState {}

class GestoresLoaded extends GestoresState {
  final List<Gestor> gestores;
  final List<Gestor> gestoresFiltrados;
  final Map<String, dynamic>? pagination;

  const GestoresLoaded({
    required this.gestores,
    required this.gestoresFiltrados,
    this.pagination,
  });

  @override
  List<Object?> get props => [gestores, gestoresFiltrados, pagination];
}

class GestoresError extends GestoresState {
  final String message;

  const GestoresError(this.message);

  @override
  List<Object?> get props => [message];
}

class GestorOperationSuccess extends GestoresState {
  final String message;
  final Gestor? gestor;

  const GestorOperationSuccess({required this.message, this.gestor});

  @override
  List<Object?> get props => [message, gestor];
}

class GestorOperationLoading extends GestoresState {
  const GestorOperationLoading();
}

// ========== CUBIT ==========
class GestoresCubit extends Cubit<GestoresState> {
  final ApiClient _apiClient;

  List<Gestor> _todosGestores = [];
  Map<String, dynamic>? _ultimaPagination;

  // ✅ FILTROS ATUAIS
  String? _currentNivel;
  int? _currentStatus;
  String? _currentSearch;

  GestoresCubit(this._apiClient) : super(GestoresInitial());

  // ✅ GETTERS
  String? get currentNivel => _currentNivel;
  int? get currentStatus => _currentStatus;
  String? get currentSearch => _currentSearch;

  // 🔍 LISTAR GESTORES COM PAGINAÇÃO E FILTROS
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
      emit(GestoresError('Erro de conexão: $e'));
    }
  }

  // ✅ FILTRAR GESTORES LOCALMENTE (para busca instantânea)
  void filtrarGestores(String search) {
    if (_todosGestores.isEmpty) return;

    final filtradas = _todosGestores.where((g) {
      return g.nome.toLowerCase().contains(search.toLowerCase()) ||
          g.email.toLowerCase().contains(search.toLowerCase()) ||
          (g.cpf?.contains(search) ?? false);
    }).toList();

    emit(GestoresLoaded(
      gestores: _todosGestores,
      gestoresFiltrados: filtradas,
      pagination: _ultimaPagination,
    ));
  }

  // ✅ LIMPAR FILTROS (voltar à lista completa)
  void limparFiltros() {
    if (_todosGestores.isEmpty) return;

    emit(GestoresLoaded(
      gestores: _todosGestores,
      gestoresFiltrados: _todosGestores,
      pagination: _ultimaPagination,
    ));
  }

  // ✅ APLICAR FILTROS (versão unificada)
  Future<void> applyFilters({
    String? nivel,
    int? status,
    String? search,
  }) async {
    _currentNivel = nivel;
    _currentStatus = status;
    _currentSearch = search;

    await fetchGestores(
      nivel: nivel,
      status: status,
      search: search,
    );
  }

  // ✅ WRAPPERS PARA FILTROS
  Future<void> applyNivel(String? nivel) => applyFilters(
      nivel: nivel,
      status: _currentStatus,
      search: _currentSearch
  );

  Future<void> applyStatus(int? status) => applyFilters(
      status: status,
      nivel: _currentNivel,
      search: _currentSearch
  );

  Future<void> applySearch(String search) => applyFilters(
      search: search,
      nivel: _currentNivel,
      status: _currentStatus
  );

  // ✅ LIMPAR FILTROS (versão Future)
  Future<void> clearFilters() async {
    _currentNivel = null;
    _currentStatus = null;
    _currentSearch = null;
    await fetchGestores();
  }

  // ➕ CRIAR GESTOR
  Future<bool> createGestor(Map<String, dynamic> data) async {
    emit(const GestorOperationLoading());

    try {
      final response = await _apiClient.post(
        '/gestor/gestor-usuarios/create',
        data: data,
      );

      if (response.statusCode == 201 && response.data['success'] == true) {
        final novoGestor = Gestor.fromJson(response.data['data']);

        await refreshList();

        emit(GestorOperationSuccess(
          message: 'Gestor criado com sucesso',
          gestor: novoGestor,
        ));

        return true;
      } else {
        emit(GestoresError(response.data['message'] ?? 'Erro ao criar gestor'));
        return false;
      }
    } catch (e) {
      emit(GestoresError('Erro de conexão: $e'));
      return false;
    }
  }

  // ✏️ ATUALIZAR GESTOR
  Future<bool> updateGestor(int id, Map<String, dynamic> data) async {
    emit(const GestorOperationLoading());

    try {
      final response = await _apiClient.post(
        '/gestor/gestor-usuarios/update/$id',
        data: data,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final gestorAtualizado = Gestor.fromJson(response.data['data']);

        await refreshList();

        emit(GestorOperationSuccess(
          message: 'Gestor atualizado com sucesso',
          gestor: gestorAtualizado,
        ));

        return true;
      } else {
        emit(GestoresError(response.data['message'] ?? 'Erro ao atualizar gestor'));
        return false;
      }
    } catch (e) {
      emit(GestoresError('Erro de conexão: $e'));
      return false;
    }
  }

  // 🗑️ DELETAR GESTOR
  Future<bool> deleteGestor(int id) async {
    emit(const GestorOperationLoading());

    try {
      final response = await _apiClient.post(
        '/gestor/gestor-usuarios/delete/$id',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        _todosGestores = _todosGestores.where((g) => g.id != id).toList();

        emit(GestoresLoaded(
          gestores: _todosGestores,
          gestoresFiltrados: _todosGestores,
          pagination: _ultimaPagination,
        ));

        emit(const GestorOperationSuccess(
          message: 'Gestor removido com sucesso',
        ));

        return true;
      } else {
        emit(GestoresError(response.data['message'] ?? 'Erro ao remover gestor'));
        return false;
      }
    } catch (e) {
      emit(GestoresError('Erro de conexão: $e'));
      return false;
    }
  }

  // 🔍 BUSCAR GESTOR DETALHADO
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

  // 🔄 RECARREGAR LISTA (mantendo filtros atuais)
  Future<void> refreshList() async {
    await fetchGestores(
      nivel: _currentNivel,
      status: _currentStatus,
      search: _currentSearch,
    );
  }

  // ✅ GETTERS DE PAGINAÇÃO
  bool get hasMorePages {
    if (_ultimaPagination == null) return false;
    final currentPage = _ultimaPagination!['page'] as int;
    final totalPages = _ultimaPagination!['total_pages'] as int;
    return currentPage < totalPages;
  }

  int get currentPage => _ultimaPagination?['page'] ?? 1;
  int get totalPages => _ultimaPagination?['total_pages'] ?? 1;
}