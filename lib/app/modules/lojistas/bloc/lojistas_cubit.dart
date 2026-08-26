import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'lojistas_state.dart';
import '../repositories/lojista_repository.dart';
import '../models/lojista_model.dart';
import '../models/loja_option_model.dart';

class LojistasCubit extends Cubit<LojistasState> {
  final LojistaRepository _repository;
  int _page = 1;
  final int _perPage = 20;
  Map<String, String> _activeFilters = {};
  Map<String, dynamic>? _filterOptions;
  bool _hasMore = true;
  List<LojaOptionModel> _lojas = [];

  LojistasCubit(this._repository) : super(const LojistasInitial());

  Map<String, dynamic>? get filterOptions => _filterOptions;

  Future<void> carregar({bool carregarMais = false, Map<String, String>? filters}) async {
    if (carregarMais && !_hasMore) return;
    if (carregarMais) {
      _page++;
    } else {
      _page = 1;
      _hasMore = true;
      if (filters != null) {
        _activeFilters = filters;
      }
    }

    if (!carregarMais) emit(const LojistasLoading());
    
    try {
      if (_lojas.isEmpty) {
        _lojas = await _repository.listarLojas();
      }

      final (items, total, filterOptions) = await _repository.listar(
        filters: _activeFilters,
        page: _page,
        perPage: _perPage,
      );

      _filterOptions = filterOptions;

      // ignore: avoid_print
      debugPrint('📦 Lojistas recebidos: ${items.length}, Total: $total');

      List<LojistaModel> currentItems = [];
      if (state is LojistasLoaded && carregarMais) {
        currentItems = List<LojistaModel>.from((state as LojistasLoaded).lojistas);
      }
      currentItems.addAll(items);

      _hasMore = currentItems.length < total;

      emit(LojistasLoaded(
        lojistas: currentItems,
        lojas: _lojas,
        total: total,
        page: _page,
        perPage: _perPage,
        filterOptions: filterOptions,
      ));
    } catch (e) {
      // ignore: avoid_print
      debugPrint('❌ Erro ao carregar lojistas: $e');
      emit(LojistasError(e.toString()));
    }
  }

  Future<void> deletar(int id) async {
    try {
      await _repository.deletar(id);
      // Recarrega a lista atual
      _page = 1;
      _hasMore = true;
      await carregar();
    } catch (e) {
      // ignore: avoid_print
      debugPrint('❌ Erro ao carregar lojistas: $e');
      emit(LojistasError(e.toString()));
    }
  }

  void reset() {
    _page = 1;
    _hasMore = true;
    _activeFilters = {};
    carregar();
  }

  bool get hasMore => _hasMore;
}
