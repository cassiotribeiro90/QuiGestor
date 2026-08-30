// lib/app/modules/pedidos/bloc/pedidos_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../shared/api/api_client.dart';
import '../models/pedido_model.dart';
import '../../../models/filter_option.dart';

part 'pedidos_state.dart';

class PedidosCubit extends Cubit<PedidosState> {
  final ApiClient _apiClient;
  Map<String, String> _currentFilters = {};

  PedidosCubit(this._apiClient) : super(const PedidosState());

  // ============================================================
  // 🔥 Busca principal (com parâmetro isRefresh)
  // ============================================================
  Future<void> fetchPedidos({
    int page = 1,
    int perPage = 20,
    Map<String, String>? filters,
    bool isRefresh = false,
    bool showLoading = false, // ⭐ DEFAULT: false (silencioso)
  }) async {
    // ⭐ Só mostra loading central se for solicitado OU se for a primeiríssima carga
    if (showLoading || (state.isFirstLoad && page == 1)) {
      emit(state.copyWith(isLoading: true, error: null, isLoadingMore: false));
    } else if (page > 1) {
      emit(state.copyWith(isLoadingMore: true, error: null));
    }

    if (filters != null) {
      _currentFilters = filters;
    }

    try {
      final params = <String, String>{
        'page': page.toString(),
        'per_page': perPage.toString(),
        ..._currentFilters,
      };

      final response = await _apiClient.get(
        '/gestor/pedidos',
        queryParameters: params,
      );

      final data = response.data['data'];
      final newItems = (data['items'] as List)
          .map((item) => Pedido.fromJson(item))
          .toList();

      // Carrega filter_options (sempre que disponível na resposta)
      List<FilterGroup> filterGroups = state.filterGroups;
      if (data['filter_options'] != null) {
        final options = data['filter_options'] as Map<String, dynamic>;
        filterGroups = options.entries
            .map((entry) => FilterGroup.fromJson(entry.key, entry.value))
            .toList();
        
        // 🔥 LOG PARA DEBUG (Passo 4 do roteiro)
        print('📊 [FILTER] Novos grupos recebidos: ${filterGroups.length}');
        for (var g in filterGroups) {
          final optionsStr = g.options.map((o) => "${o.label}(${o.count})").join(", ");
          print('   - ${g.label}: [$optionsStr]');
        }
      }

      final totalItems = data['pagination']['total'] ?? 0;
      final totalPages = data['pagination']['total_pages'] ?? 0;
      final hasMore = page < totalPages;

      // 🔥 Se for refresh, substitui a lista; senão, acumula
      final items = (isRefresh || page == 1)
          ? newItems
          : [...state.items, ...newItems];

      // 🔥 Marca hasLoaded = true (lista carregada com sucesso) e isFirstLoad = false
      emit(state.copyWith(
        items: items,
        isLoading: false,
        isLoadingMore: false,
        total: totalItems,
        page: page,
        perPage: perPage,
        hasMore: hasMore,
        hasLoaded: true,
        isFirstLoad: false, // ⭐ Seta como false após a carga
        filterGroups: filterGroups,
      ));
    } catch (e) {
      // 🔥 Mesmo em erro, marca como carregado (já tentou)
      emit(state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: e.toString(),
        hasLoaded: true,
        isFirstLoad: false, // ⭐ Seta como false mesmo em erro
      ));
    }
  }

  // ============================================================
  // 🔥 Carrega mais itens (scroll infinito)
  // ============================================================
  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || state.isLoading) return;
    await fetchPedidos(
      page: state.page + 1,
      perPage: state.perPage,
      isRefresh: false,
    );
  }

  // ============================================================
  // 🔥 Aplica novos filtros (reseta para página 1)
  // ============================================================
  Future<void> refreshWithFilters(Map<String, String> filters) async {
    _currentFilters = filters;
    await fetchPedidos(page: 1, perPage: state.perPage, filters: filters, isRefresh: true, showLoading: false);
  }

  // ============================================================
  // 🔥 Busca um único pedido (detalhe)
  // ============================================================
  Future<Pedido?> fetchPedido(int id) async {
    try {
      final response = await _apiClient.get('/gestor/pedidos/$id');
      final data = response.data['data'];
      return Pedido.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  // ============================================================
  // 🔥 Atualiza um pedido
  // ============================================================
  Future<bool> updatePedido(int id, Map<String, dynamic> data) async {
    try {
      await _apiClient.put('/gestor/pedidos/update/$id', data: data);
      await fetchPedidos(page: state.page, perPage: state.perPage, isRefresh: false);
      return true;
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      return false;
    }
  }

  // ============================================================
  // 🔥 Cancela um pedido
  // ============================================================
  Future<bool> deletePedido(int id) async {
    try {
      await _apiClient.delete('/gestor/pedidos/delete/$id');
      await fetchPedidos(page: state.page, perPage: state.perPage, isRefresh: false);
      return true;
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      return false;
    }
  }

  // ============================================================
  // 🔥 Reseta completamente o estado
  // ============================================================
  void reset() {
    _currentFilters = {};
    emit(const PedidosState());
  }

  // ============================================================
  // 🔥 Getter para filtros atuais
  // ============================================================
  Map<String, String> get currentFilters => _currentFilters;
}