import 'package:flutter_bloc/flutter_bloc.dart';
import 'lojista_form_state.dart';
import '../repositories/lojista_repository.dart';

class LojistaFormCubit extends Cubit<LojistaFormState> {
  final LojistaRepository _repository;
  LojistaFormCubit(this._repository) : super(const LojistaFormInitial([], null));

  Future<void> initCreate() async {
    try {
      final lojas = await _repository.listarLojas();
      emit(LojistaFormInitial(lojas, null));
    } catch (e) {
      emit(LojistaFormError(e.toString()));
    }
  }

  Future<void> initEdit(int id) async {
    emit(const LojistaFormLoading());
    try {
      final lojas = await _repository.listarLojas();
      final lojista = await _repository.visualizar(id);
      emit(LojistaFormInitial(lojas, lojista));
    } catch (e) {
      emit(LojistaFormError(e.toString()));
    }
  }

  Future<void> salvar(Map<String, dynamic> dados, {int? id}) async {
    emit(const LojistaFormLoading());
    try {
      final result = id != null
          ? await _repository.atualizar(id, dados)
          : await _repository.criar(dados);
      emit(LojistaFormSuccess(result));
    } catch (e) {
      emit(LojistaFormError(e.toString()));
    }
  }
}
