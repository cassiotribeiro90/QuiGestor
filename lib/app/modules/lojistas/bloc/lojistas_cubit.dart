import 'package:flutter_bloc/flutter_bloc.dart';
import 'lojistas_state.dart';
import '../repositories/lojista_repository.dart';
import '../models/lojista_model.dart';
import '../models/loja_option_model.dart';

class LojistasCubit extends Cubit<LojistasState> {
  final LojistaRepository _repository;
  int _page = 1;
  int _perPage = 20;
  int? _filtroLojaId;
  String? _filtroFuncao;
  int? _filtroStatus;
  String? _filtroSearch;
  bool _hasMore = true;
  List<LojaOptionModel> _lojas = [];

  LojistasCubit(this._repository) : super(const LojistasInitial());

  void setFiltroLoja(int? lojaId) {
    _filtroLojaId = lojaId;
    _page = 1;
    _hasMore = true;
    carregar();
  }

  void setFiltroFuncao(String? funcao) {
    _filtroFuncao = funcao;
    _page = 1;
    _hasMore = true;
    carregar();
  }

  void setFiltroStatus(int? status) {
    _filtroStatus = status;
    _page = 1;
    _hasMore = true;
    carregar();
  }

  void setFiltroSearch(String? search) {
    _filtroSearch = search;
    _page = 1;
    _hasMore = true;
    carregar();
  }

  Future<void> carregar({bool carregarMais = false}) async {
    if (carregarMais && !_hasMore) return;
    if (carregarMais) _page++;

    if (!carregarMais) emit(const LojistasLoading());
    
    try {
      if (_lojas.isEmpty) {
        _lojas = await _repository.listarLojas();
      }

      final (items, total) = await _repository.listar(
        lojaId: _filtroLojaId,
        funcao: _filtroFuncao,
        status: _filtroStatus,
        search: _filtroSearch,
        page: _page,
        perPage: _perPage,
      );

      // ignore: avoid_print
      print('📦 Lojistas recebidos: ${items.length}, Total: $total');

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
        filtroLojaId: _filtroLojaId,
        filtroFuncao: _filtroFuncao,
        filtroStatus: _filtroStatus,
        filtroSearch: _filtroSearch,
      ));
    } catch (e) {
      // ignore: avoid_print
      print('❌ Erro ao carregar lojistas: $e');
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
      print('❌ Erro ao carregar lojistas: $e');
      emit(LojistasError(e.toString()));
    }
  }

  void reset() {
    _page = 1;
    _hasMore = true;
    _filtroLojaId = null;
    _filtroFuncao = null;
    _filtroStatus = null;
    _filtroSearch = null;
    carregar();
  }

  bool get hasMore => _hasMore;
}
