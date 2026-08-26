import 'package:flutter_bloc/flutter_bloc.dart';
import 'subcategoria_state.dart';
import '../models/subcategoria.dart';
import '../services/subcategoria_service.dart';

class SubcategoriaCubit extends Cubit<SubcategoriaState> {
  final SubcategoriaService _service;
  Map<String, String> _activeFilters = {};
  Map<String, dynamic>? _filterOptions;

  SubcategoriaCubit(this._service) : super(const SubcategoriaInitial());

  Map<String, dynamic>? get filterOptions => _filterOptions;

  Future<void> carregar({Map<String, String>? filters, int page = 1}) async {
    emit(const SubcategoriaLoading());
    try {
      if (filters != null) {
        _activeFilters = filters;
      }
      final response = await _service.listar(
        filters: _activeFilters,
        page: page,
      );
      final data = response['data'];
      final items = (data['items'] as List)
          .map((json) => Subcategoria.fromJson(json))
          .toList();
      
      _filterOptions = data['filter_options'];

      emit(SubcategoriaLoaded(
        items,
        filterOptions: _filterOptions,
        pagination: data['pagination'],
      ));
    } catch (e) {
      emit(SubcategoriaError(e.toString()));
    }
  }

  Future<bool> salvar(Map<String, dynamic> dados, {int? id}) async {
    emit(const SubcategoriaOperationLoading());
    try {
      if (id == null) {
        await _service.criar(dados);
      } else {
        await _service.atualizar(id, dados);
      }
      emit(SubcategoriaOperationSuccess(id == null ? 'Subcategoria criada com sucesso' : 'Subcategoria atualizada com sucesso'));
      await carregar(); 
      return true;
    } catch (e) {
      emit(SubcategoriaError(e.toString()));
      return false;
    }
  }

  Future<bool> deletar(int id) async {
    emit(const SubcategoriaOperationLoading());
    try {
      await _service.deletar(id);
      emit(const SubcategoriaOperationSuccess('Subcategoria removida com sucesso'));
      await carregar();
      return true;
    } catch (e) {
      emit(SubcategoriaError(e.toString()));
      return false;
    }
  }
}
