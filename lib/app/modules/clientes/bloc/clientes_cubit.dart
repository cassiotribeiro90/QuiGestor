// lib/app/modules/clientes/bloc/clientes_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'clientes_state.dart';
import '../models/cliente.dart';
import '../../../../shared/api/api_client.dart';

class ClientesCubit extends Cubit<ClientesState> {
  final ApiClient _apiClient;
  Map<String, String> _activeFilters = {};
  Map<String, dynamic>? _filterOptions;
  List<Cliente> _allClientes = [];
  int _currentPage = 1;
  int _perPage = 20;
  bool _hasMore = true;
  int _total = 0;

  ClientesCubit(this._apiClient) : super(ClientesInitial());

  Map<String, dynamic>? get filterOptions => _filterOptions;
  bool get hasMore => _hasMore;

  Future<void> fetchClientes({
    Map<String, String>? filters,
    int? perPage,
    bool isLoadMore = false,
  }) async {
    if (isLoadMore && !_hasMore) return;

    if (isLoadMore) {
      _currentPage++;
    } else if (filters != null) {
      _activeFilters = filters;
      _currentPage = 1;
      _allClientes = [];
      _hasMore = true;
    }

    emit(ClientesLoading());

    try {
      final response = await _apiClient.get(
        '/gestor/clientes',
        queryParameters: {
          'page': _currentPage,
          'per_page': _perPage,
          ..._activeFilters,
        },
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];
        final items = (data['items'] as List)
            .map((json) => Cliente.fromJson(json))
            .toList();

        if (isLoadMore) {
          _allClientes = [..._allClientes, ...items];
        } else {
          _allClientes = items;
        }

        _filterOptions = data['filter_options'];
        _total = data['pagination']?['total'] ?? 0;
        _hasMore = data['pagination']?['total_pages'] > _currentPage;

        emit(ClientesLoaded(
          clientes: _allClientes,
          total: _total,
          filterOptions: _filterOptions,
          hasMore: _hasMore,
        ));
      } else {
        emit(ClientesError(response.data['message'] ?? 'Erro ao carregar clientes'));
      }
    } catch (e) {
      emit(ClientesError('Erro de conexão: $e'));
    }
  }

  Future<void> refresh() async {
    _currentPage = 1;
    _allClientes = [];
    _hasMore = true;
    await fetchClientes(filters: _activeFilters);
  }

  Future<void> loadMore() async {
    if (!_hasMore || state is ClientesLoading) return;
    await fetchClientes(isLoadMore: true);
  }

  void reset() {
    _currentPage = 1;
    _allClientes = [];
    _hasMore = true;
    _activeFilters = {};
    _filterOptions = null;
    emit(ClientesInitial());
  }
}
