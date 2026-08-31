import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'avaliacoes_state.dart';
import '../services/avaliacao_service.dart';
import '../models/avaliacao_model.dart';

class AvaliacoesCubit extends Cubit<AvaliacoesState> {
  final AvaliacaoService _service;

  Map<String, String> _activeFilters = {};

  AvaliacoesCubit(this._service) : super(const AvaliacoesState());

  Map<String, String> get activeFilters => _activeFilters;
  Map<String, dynamic>? get filterOptions => state.filterOptions;

  Future<void> carregar({
    bool carregarMais = false,
    Map<String, String>? filters,
    bool showLoading = false,
  }) async {
    if (carregarMais && state.avaliacoes.length >= state.total) return;

    int nextPage = carregarMais ? state.page + 1 : 1;

    if (filters != null) {
      _activeFilters = filters;
    }

    if (!carregarMais) {
      if (showLoading || state.isFirstLoad) {
        emit(state.copyWith(isLoading: true, error: null, isLoadingMore: false));
      }
    } else {
      emit(state.copyWith(isLoadingMore: true, error: null));
    }

    try {
      final response = await _service.listar(
        page: nextPage,
        perPage: state.perPage,
        filters: _activeFilters,
      );

      debugPrint('📦 Resposta completa: ${response.keys}');

      // Extrai dados da estrutura correta
      final data = response['data'] as Map<String, dynamic>? ?? response;
      final itemsList = data['data'] as List? ?? [];
      final pagination = data['pagination'] as Map<String, dynamic>? ?? {};
      final filterOptions = data['filter_options'] as Map<String, dynamic>?;

      final items = itemsList
          .map((e) => AvaliacaoModel.fromJson(e as Map<String, dynamic>))
          .toList();
      final total = pagination['total'] ?? 0;

      debugPrint('📦 Avaliações recebidas: ${items.length}, Total: $total');

      List<AvaliacaoModel> currentItems = carregarMais
          ? List<AvaliacaoModel>.from(state.avaliacoes)
          : [];
      currentItems.addAll(items);

      emit(state.copyWith(
        avaliacoes: currentItems,
        total: total,
        page: nextPage,
        filterOptions: filterOptions,
        isLoading: false,
        isLoadingMore: false,
        isFirstLoad: false,
        error: null,
      ));
    } catch (e) {
      debugPrint('❌ Erro ao carregar avaliações: $e');
      emit(state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: e.toString(),
        isFirstLoad: false,
      ));
    }
  }

  Future<AvaliacaoModel> buscarPorId(int id) async {
    try {
      final response = await _service.visualizar(id);

      debugPrint('📦 Resposta do detalhe: ${response.keys}');

      // Extrai dados da estrutura correta
      final data = response['data'] as Map<String, dynamic>? ?? response;
      final avaliacaoData = data['data'] as Map<String, dynamic>? ?? data;

      debugPrint('📦 Dados da avaliação: ${avaliacaoData.keys}');

      return AvaliacaoModel.fromJson(avaliacaoData);
    } catch (e) {
      debugPrint('❌ Erro ao buscar avaliação: $e');
      rethrow;
    }
  }

  Future<void> atualizarStatus(int id, String status) async {
    try {
      await _service.atualizarStatus(id, status);

      // Emitir sucesso e recarregar a lista
      emit(state.copyWith(successMessage: 'Status atualizado com sucesso'));

      // Recarregar a lista silenciosamente
      await carregar(showLoading: false);

    } catch (e) {
      debugPrint('❌ Erro ao atualizar status: $e');
      emit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> deletar(int id) async {
    try {
      await _service.deletar(id);

      // Emitir sucesso e recarregar a lista
      emit(state.copyWith(successMessage: 'Avaliação excluída com sucesso'));

      // Recarregar a lista silenciosamente
      await carregar(showLoading: false);

    } catch (e) {
      debugPrint('❌ Erro ao excluir avaliação: $e');
      emit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  // ⚠️ ADICIONADO: Metodo reset
  void reset() {
    _activeFilters = {};
    emit(const AvaliacoesState());
    carregar();
  }

  bool get hasMore => state.avaliacoes.length < state.total;
}