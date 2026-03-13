import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/api/api_client.dart';
import '../../../app_config.dart';
import '../models/categoria.dart';
import 'categorias_state.dart';

class CategoriasCubit extends Cubit<CategoriasState> {
  final ApiClient _apiClient;

  List<Categoria> _todasCategorias = [];
  Map<String, dynamic>? _ultimaPagination;
  Map<String, dynamic>? _filterOptions;

  // Filtros atuais
  bool? _currentAtivo;
  bool? _currentDestaque;
  String? _currentSearch;

  CategoriasCubit(this._apiClient) : super(CategoriasInitial());

  bool? get currentAtivo => _currentAtivo;
  bool? get currentDestaque => _currentDestaque;
  String? get currentSearch => _currentSearch;
  Map<String, dynamic>? get filterOptions => _filterOptions;

  bool get hasMorePages {
    if (_ultimaPagination == null) return false;
    final currentPage = _ultimaPagination!['page'] as int;
    final totalPages = _ultimaPagination!['total_pages'] as int;
    return currentPage < totalPages;
  }

  int get currentPage => _ultimaPagination?['page'] ?? 1;

  Future<void> fetchCategorias({
    int page = 1,
    int? perPage,
    bool isLoadMore = false,
  }) async {
    try {
      if (!isLoadMore) {
        emit(CategoriasLoading());
      }

      final itemsPerPage = perPage ?? AppConfig.defaultPerPage;

      final response = await _apiClient.get(
        AppConfig.CATEGORIAS,
        queryParameters: {
          'page': page,
          'per_page': itemsPerPage,
          if (_currentAtivo != null) 'ativo': _currentAtivo! ? 1 : 0,
          if (_currentDestaque != null) 'destaque': _currentDestaque! ? 1 : 0,
          if (_currentSearch != null && _currentSearch!.isNotEmpty) 'search': _currentSearch,
        },
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];
        final items = List<Map<String, dynamic>>.from(data['items']);
        final pagination = data['pagination'];
        _filterOptions = data['filter_options'];

        final novasCategorias = items.map((json) => Categoria.fromJson(json)).toList();

        if (isLoadMore && state is CategoriasLoaded) {
          final currentState = state as CategoriasLoaded;
          _todasCategorias = [...currentState.categorias, ...novasCategorias];
        } else {
          _todasCategorias = novasCategorias;
        }

        _ultimaPagination = pagination;

        emit(CategoriasLoaded(
          categorias: _todasCategorias,
          categoriasFiltradas: _todasCategorias,
          pagination: pagination,
          filterOptions: _filterOptions,
        ));
      } else {
        emit(CategoriasError(response.data['message'] ?? 'Erro ao carregar categorias'));
      }
    } catch (e) {
      if (!isLoadMore) {
        emit(CategoriasError('Erro de conexão: $e'));
      }
    }
  }

  Future<void> applyFilters({
    bool? ativo,
    bool? destaque,
    String? search,
  }) async {
    _currentAtivo = ativo;
    _currentDestaque = destaque;
    if (search != null) _currentSearch = search;

    await fetchCategorias(page: 1);
  }

  void applySearch(String search) {
    _currentSearch = search;
    fetchCategorias(page: 1);
  }

  void clearFilters() {
    _currentAtivo = null;
    _currentDestaque = null;
    _currentSearch = null;
    fetchCategorias(page: 1);
  }

  Future<void> refreshList() async {
    await fetchCategorias(page: 1);
  }

  Future<Categoria?> fetchCategoriaDetalhada(int id) async {
    try {
      final response = await _apiClient.get('${AppConfig.CATEGORIAS}/$id');
      if (response.data['success'] == true) {
        return Categoria.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      emit(CategoriasError('Erro ao buscar detalhes da categoria: $e'));
      return null;
    }
  }

  Future<bool> createCategoria(Map<String, dynamic> data) async {
    emit(const CategoriaOperationLoading());
    try {
      final response = await _apiClient.post(AppConfig.CATEGORIA_CREATE, data: data);
      if (response.statusCode == 201 && response.data['success'] == true) {
        await refreshList();
        emit(CategoriaOperationSuccess(
          message: 'Categoria criada com sucesso',
          categoria: Categoria.fromJson(response.data['data']),
        ));
        return true;
      }
      emit(CategoriasError(response.data['message'] ?? 'Erro ao criar categoria'));
      return false;
    } catch (e) {
      emit(CategoriasError('Erro de conexão: $e'));
      return false;
    }
  }

  Future<bool> updateCategoria(int id, Map<String, dynamic> data) async {
    emit(const CategoriaOperationLoading());
    try {
      final response = await _apiClient.post('${AppConfig.CATEGORIA_UPDATE}/$id', data: data);
      if (response.statusCode == 200 && response.data['success'] == true) {
        await refreshList();
        emit(CategoriaOperationSuccess(
          message: 'Categoria atualizada com sucesso',
          categoria: Categoria.fromJson(response.data['data']),
        ));
        return true;
      }
      emit(CategoriasError(response.data['message'] ?? 'Erro ao atualizar categoria'));
      return false;
    } catch (e) {
      emit(CategoriasError('Erro de conexão: $e'));
      return false;
    }
  }

  Future<bool> deleteCategoria(int id) async {
    emit(const CategoriaOperationLoading());
    try {
      final response = await _apiClient.post('${AppConfig.CATEGORIA_DELETE}/$id');
      if (response.statusCode == 200 && response.data['success'] == true) {
        _todasCategorias = _todasCategorias.where((c) => c.id != id).toList();
        emit(CategoriasLoaded(
          categorias: _todasCategorias,
          categoriasFiltradas: _todasCategorias,
          pagination: _ultimaPagination,
          filterOptions: _filterOptions,
        ));
        emit(const CategoriaOperationSuccess(message: 'Categoria removida com sucesso'));
        return true;
      }
      emit(CategoriasError(response.data['message'] ?? 'Erro ao remover categoria'));
      return false;
    } catch (e) {
      emit(CategoriasError('Erro de conexão: $e'));
      return false;
    }
  }
}
