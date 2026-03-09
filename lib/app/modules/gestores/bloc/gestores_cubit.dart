import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';
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
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final Map<String, dynamic> appliedFilters;

  const GestoresLoaded({
    required this.gestores,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.appliedFilters,
  });

  @override
  List<Object?> get props => [gestores, currentPage, totalPages, totalItems, appliedFilters];
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

class GestorOperationSuccess extends GestoresLoaded {
  final String message;
  final Gestor? operatonGestor;

  const GestorOperationSuccess({
    required this.message,
    this.operatonGestor,
    required super.gestores,
    required super.currentPage,
    required super.totalPages,
    required super.totalItems,
    required super.appliedFilters,
  });

  @override
  List<Object?> get props => [message, operatonGestor, ...super.props];
}

// ========== CUBIT ==========
class GestoresCubit extends Cubit<GestoresState> {
  final ApiClient _apiClient;
  
  String _currentSearch = '';
  String? _currentNivel;
  int? _currentStatus;

  GestoresCubit(this._apiClient) : super(GestoresInitial());

  Future<void> fetchGestores({int page = 1}) async {
    // Só emite loading total se não houver dados anteriores
    if (state is! GestoresLoaded) {
      emit(GestoresLoading());
    }

    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': 10,
      };

      if (_currentSearch.isNotEmpty) queryParams['search'] = _currentSearch;
      if (_currentNivel != null) queryParams['nivel'] = _currentNivel;
      if (_currentStatus != null) queryParams['status'] = _currentStatus;

      final response = await _apiClient.get(
        '/gestor/gestor-usuarios',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];
        final List<dynamic> items = data['items'] ?? [];
        final pagination = data['pagination'] ?? {};
        
        emit(GestoresLoaded(
          gestores: items.map((json) => Gestor.fromJson(json)).toList(),
          currentPage: pagination['page'] ?? 1,
          totalPages: pagination['total_pages'] ?? 1,
          totalItems: pagination['total'] ?? 0,
          appliedFilters: {
            'search': _currentSearch,
            'nivel': _currentNivel,
            'status': _currentStatus,
          },
        ));
      } else {
        emit(GestoresError(response.data['message'] ?? 'Erro ao carregar gestores'));
      }
    } catch (e) {
      emit(GestoresError('Erro de conexão: $e'));
    }
  }

  void applyFilters({String? search, String? nivel, int? status}) {
    if (search != null) _currentSearch = search;
    if (nivel != null) _currentNivel = nivel;
    if (status != null) _currentStatus = status;
    fetchGestores(page: 1);
  }

  void applySearch(String search) => applyFilters(search: search);
  void applyNivel(String? nivel) { _currentNivel = nivel; fetchGestores(page: 1); }
  void applyStatus(int? status) { _currentStatus = status; fetchGestores(page: 1); }

  void clearFilters() {
    _currentSearch = '';
    _currentNivel = null;
    _currentStatus = null;
    fetchGestores(page: 1);
  }

  void goToPage(int page) => fetchGestores(page: page);

  String get currentSearch => _currentSearch;
  String? get currentNivel => _currentNivel;
  int? get currentStatus => _currentStatus;

  Future<bool> createGestor(Map<String, dynamic> data) async {
    try {
      emit(GestoresLoading());
      final response = await _apiClient.post('/gestor/gestor-usuarios/create', data: data);

      if (response.data['success'] == true) {
        await fetchGestores(page: 1);
        if (state is GestoresLoaded) {
          final s = state as GestoresLoaded;
          emit(GestorOperationSuccess(
            message: 'Gestor criado com sucesso',
            gestores: s.gestores,
            currentPage: s.currentPage,
            totalPages: s.totalPages,
            totalItems: s.totalItems,
            appliedFilters: s.appliedFilters,
          ));
        }
        return true;
      } else {
        emit(GestoresError(response.data['message'] ?? 'Erro ao criar gestor'));
        return false;
      }
    } on DioException catch (e) {
      emit(GestoresError(e.response?.data?['message'] ?? 'Erro de conexão'));
      return false;
    } catch (e) {
      emit(GestoresError('Erro inesperado: $e'));
      return false;
    }
  }

  Future<bool> updateGestor(int id, Map<String, dynamic> data) async {
    try {
      final currentState = state; // Preserva estado antes do loading
      emit(GestoresLoading());
      
      final response = await _apiClient.put('/gestor/gestor-usuarios/update/$id', data: data);

      if (response.data['success'] == true) {
        int pageToReload = 1;
        if (currentState is GestoresLoaded) pageToReload = currentState.currentPage;
        
        await fetchGestores(page: pageToReload);
        
        if (state is GestoresLoaded) {
          final s = state as GestoresLoaded;
          emit(GestorOperationSuccess(
            message: 'Gestor atualizado com sucesso',
            gestores: s.gestores,
            currentPage: s.currentPage,
            totalPages: s.totalPages,
            totalItems: s.totalItems,
            appliedFilters: s.appliedFilters,
          ));
        }
        return true;
      } else {
        emit(GestoresError(response.data['message'] ?? 'Erro ao atualizar gestor'));
        return false;
      }
    } on DioException catch (e) {
      emit(GestoresError(e.response?.data?['message'] ?? 'Erro de conexão'));
      return false;
    } catch (e) {
      emit(GestoresError('Erro inesperado: $e'));
      return false;
    }
  }

  Future<bool> deleteGestor(int id) async {
    try {
      final currentState = state;
      emit(GestoresLoading());
      final response = await _apiClient.delete('/gestor/gestor-usuarios/$id');
      if (response.data['success'] == true) {
        int pageToReload = 1;
        if (currentState is GestoresLoaded) {
          pageToReload = currentState.gestores.length == 1 && currentState.currentPage > 1 ? currentState.currentPage - 1 : currentState.currentPage;
        }
        await fetchGestores(page: pageToReload);
        if (state is GestoresLoaded) {
          final s = state as GestoresLoaded;
          emit(GestorOperationSuccess(
            message: 'Gestor deletado com sucesso',
            gestores: s.gestores,
            currentPage: s.currentPage,
            totalPages: s.totalPages,
            totalItems: s.totalItems,
            appliedFilters: s.appliedFilters,
          ));
        }
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
}
