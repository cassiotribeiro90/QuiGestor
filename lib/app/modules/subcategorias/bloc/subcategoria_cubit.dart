import 'package:flutter_bloc/flutter_bloc.dart';
import 'subcategoria_state.dart';
import '../models/subcategoria.dart';
import '../services/subcategoria_service.dart';

class SubcategoriaCubit extends Cubit<SubcategoriaState> {
  final SubcategoriaService _service;

  SubcategoriaCubit(this._service) : super(const SubcategoriaInitial());

  Future<void> carregar({int? categoriaId, String? search, int? status}) async {
    emit(const SubcategoriaLoading());
    try {
      final response = await _service.listar(
        categoriaId: categoriaId,
        search: search,
        status: status,
      );
      final items = (response['data']['items'] as List)
          .map((json) => Subcategoria.fromJson(json))
          .toList();
      emit(SubcategoriaLoaded(items));
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
