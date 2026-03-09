import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
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
  final List<Gestor> filteredGestores;
  final bool hasMore;
  final int page;

  const GestoresLoaded({
    required this.gestores,
    required this.filteredGestores,
    this.hasMore = false,
    this.page = 1,
  });

  @override
  List<Object?> get props => [gestores, filteredGestores, hasMore, page];
}

class GestoresLoadingMore extends GestoresLoaded {
  const GestoresLoadingMore({
    required super.gestores,
    required super.filteredGestores,
    super.hasMore,
    super.page,
  });
}

class GestoresError extends GestoresState {
  final String message;

  const GestoresError(this.message);

  @override
  List<Object?> get props => [message];
}

class GestorDetailLoaded extends GestoresState {
  final Gestor gestor;

  const GestorDetailLoaded(this.gestor);

  @override
  List<Object?> get props => [gestor];
}

class GestorOperationSuccess extends GestoresState {
  final String message;
  final Gestor? gestor;

  const GestorOperationSuccess({required this.message, this.gestor});

  @override
  List<Object?> get props => [message, gestor];
}

// ========== CUBIT ==========
class GestoresCubit extends Cubit<GestoresState> {
  final ApiClient _apiClient;
  List<Gestor> _allGestores = [];
  String _currentSearch = '';
  String? _currentNivel;
  int? _currentStatus;

  GestoresCubit(this._apiClient) : super(GestoresInitial());

  String get currentSearch => _currentSearch;
  String? get currentNivel => _currentNivel;
  int? get currentStatus => _currentStatus;

  // ===== LISTAGEM COM PAGINAÇÃO =====
  Future<void> fetchGestores({int page = 1, bool loadMore = false}) async {
    try {
      if (page == 1) {
        emit(GestoresLoading());
      } else if (state is GestoresLoaded && loadMore) {
        emit(GestoresLoadingMore(
          gestores: (state as GestoresLoaded).gestores,
          filteredGestores: (state as GestoresLoaded).filteredGestores,
          hasMore: (state as GestoresLoaded).hasMore,
          page: page,
        ));
      }

      final response = await _apiClient.get('/gestor/gestor-usuarios?page=$page');
      
      print('📥 [Gestores] Resposta: ${response.data}');

      if (response.data['success'] == true) {
        final data = response.data['data'];
        final List<dynamic> items = data['items'] ?? [];
        final pagination = data['pagination'] ?? {};
        
        final hasMore = (pagination['currentPage'] ?? 1) < (pagination['totalPages'] ?? 1);

        final novosGestores = items.map((json) {
          try {
            print('📥 [Gestores] Mapeando item: $json');
            return Gestor.fromJson(json);
          } catch (e) {
            print('❌ [Gestores] Erro ao mapear item: $e');
            rethrow;
          }
        }).toList();

        if (page == 1) {
          _allGestores = novosGestores;
        } else {
          _allGestores.addAll(novosGestores);
        }

        _applyFilters();

        emit(GestoresLoaded(
          gestores: _allGestores,
          filteredGestores: _getFilteredList(),
          hasMore: hasMore,
          page: page,
        ));
      } else {
        emit(GestoresError(response.data['message'] ?? 'Erro ao carregar gestores'));
      }
    } catch (e, stacktrace) {
      print('❌ [Gestores] Erro: $e');
      print('❌ [Gestores] Stacktrace: $stacktrace');
      emit(GestoresError('Erro de conexão: $e'));
    }
  }

  // ... (outros métodos permanecem iguais, apenas atualizando se necessário para GestorOperationSuccess)
  
  Future<void> loadMore() async {
    if (state is GestoresLoaded) {
      final currentState = state as GestoresLoaded;
      if (currentState.hasMore && !(state is GestoresLoadingMore)) {
        await fetchGestores(page: currentState.page + 1, loadMore: true);
      }
    }
  }

  Future<void> fetchGestorById(int id) async {
    try {
      emit(GestoresLoading());
      final response = await _apiClient.get('/gestor/gestor-usuarios/$id');
      if (response.data['success'] == true) {
        final gestor = Gestor.fromJson(response.data['data']);
        emit(GestorDetailLoaded(gestor));
      } else {
        emit(GestoresError(response.data['message'] ?? 'Gestor não encontrado'));
      }
    } catch (e) {
      emit(GestoresError('Erro de conexão: $e'));
    }
  }

  Future<bool> createGestor(Map<String, dynamic> data) async {
    try {
      emit(GestoresLoading());
      final response = await _apiClient.post('/gestor/gestor-usuarios', data: data);
      if (response.data['success'] == true) {
        await fetchGestores(page: 1);
        emit(const GestorOperationSuccess(message: 'Gestor criado com sucesso'));
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

  Future<bool> updateGestor(int id, Map<String, dynamic> data) async {
    try {
      emit(GestoresLoading());
      final response = await _apiClient.put('/gestor/gestor-usuarios/$id', data: data);
      if (response.data['success'] == true) {
        final gestorAtualizado = Gestor.fromJson(response.data['data']);
        final index = _allGestores.indexWhere((g) => g.id == id);
        if (index != -1) _allGestores[index] = gestorAtualizado;
        _applyFilters();
        emit(GestorOperationSuccess(message: 'Gestor atualizado com sucesso', gestor: gestorAtualizado));
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

  Future<bool> deleteGestor(int id) async {
    try {
      emit(GestoresLoading());
      final response = await _apiClient.delete('/gestor/gestor-usuarios/$id');
      if (response.data['success'] == true) {
        _allGestores.removeWhere((g) => g.id == id);
        _applyFilters();
        emit(const GestorOperationSuccess(message: 'Gestor deletado com sucesso'));
        return true;
      } else {
        emit(GestoresError(response.data['message'] ?? 'Erro ao deletar gestor'));
        return false;
      }
    } catch (e) {
      emit(GestoresError('Erro de conexão: $e'));
      return false;
    }
  }

  void setSearch(String search) { _currentSearch = search; _applyFilters(); }
  void setNivel(String? nivel) { _currentNivel = nivel; _applyFilters(); }
  void setStatus(int? status) { _currentStatus = status; _applyFilters(); }
  void clearFilters() { _currentSearch = ''; _currentNivel = null; _currentStatus = null; _applyFilters(); }

  void _applyFilters() {
    if (state is GestoresLoaded) {
      emit(GestoresLoaded(
        gestores: _allGestores,
        filteredGestores: _getFilteredList(),
        hasMore: (state as GestoresLoaded).hasMore,
        page: (state as GestoresLoaded).page,
      ));
    }
  }

  List<Gestor> _getFilteredList() {
    return _allGestores.where((g) {
      if (_currentSearch.isNotEmpty) {
        final searchLower = _currentSearch.toLowerCase();
        final match = g.nome.toLowerCase().contains(searchLower) ||
                     g.email.toLowerCase().contains(searchLower) ||
                     (g.cpf?.contains(_currentSearch) ?? false);
        if (!match) return false;
      }
      if (_currentNivel != null && g.nivel != _currentNivel) return false;
      if (_currentStatus != null && g.status != _currentStatus) return false;
      return true;
    }).toList();
  }
}
