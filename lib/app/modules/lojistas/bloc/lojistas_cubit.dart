import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'lojistas_state.dart';
import '../repositories/lojista_repository.dart';
import '../models/lojista_model.dart';
import '../models/loja_option_model.dart';

class LojistasCubit extends Cubit<LojistasState> {
  final LojistaRepository _repository;
  
  Map<String, String> _activeFilters = {};
  List<LojaOptionModel> _lojas = [];

  LojistasCubit(this._repository) : super(const LojistasState());

  Map<String, String> get activeFilters => _activeFilters;
  Map<String, dynamic>? get filterOptions => state.filterOptions;

  Future<void> carregar({
    bool carregarMais = false, 
    Map<String, String>? filters,
    bool showLoading = false,
  }) async {
    if (carregarMais && !state.lojistas.length.isNegative && state.lojistas.length >= state.total) return;

    int nextPage = carregarMais ? state.page + 1 : 1;
    
    if (filters != null) {
      _activeFilters = filters;
    }

    // ⭐ SÓ mostra loading central se for solicitado OU se for a primeiríssima carga
    if (!carregarMais) {
      if (showLoading || state.isFirstLoad) {
        emit(state.copyWith(isLoading: true, error: null, isLoadingMore: false));
      }
    } else {
      emit(state.copyWith(isLoadingMore: true, error: null));
    }
    
    try {
      if (_lojas.isEmpty) {
        _lojas = await _repository.listarLojas();
      }

      final (items, total, filterOptions) = await _repository.listar(
        filters: _activeFilters,
        page: nextPage,
        perPage: state.perPage,
      );

      // ignore: avoid_print
      debugPrint('📦 Lojistas recebidos: ${items.length}, Total: $total');

      List<LojistaModel> currentItems = carregarMais ? List<LojistaModel>.from(state.lojistas) : [];
      currentItems.addAll(items);

      emit(state.copyWith(
        lojistas: currentItems,
        lojas: _lojas,
        total: total,
        page: nextPage,
        filterOptions: filterOptions,
        isLoading: false,
        isLoadingMore: false,
        isFirstLoad: false,
        error: null,
      ));
    } catch (e) {
      // ignore: avoid_print
      debugPrint('❌ Erro ao carregar lojistas: $e');
      emit(state.copyWith(
        isLoading: false, 
        isLoadingMore: false, 
        error: e.toString(),
        isFirstLoad: false,
      ));
    }
  }

  Future<void> deletar(int id) async {
    emit(state.copyWith(isLoading: true)); // Deletar normalmente mostra loading
    try {
      await _repository.deletar(id);
      await carregar(showLoading: false);
      emit(state.copyWith(successMessage: 'Lojista removido com sucesso'));
    } catch (e) {
      debugPrint('❌ Erro ao deletar lojista: $e');
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void reset() {
    _activeFilters = {};
    emit(const LojistasState());
    carregar();
  }

  bool get hasMore => state.lojistas.length < state.total;
}
