import 'package:equatable/equatable.dart';
import '../models/lojista_model.dart';
import '../models/loja_option_model.dart';

abstract class LojistaFormState extends Equatable {
  const LojistaFormState();

  @override
  List<Object?> get props => [];
}

class LojistaFormInitial extends LojistaFormState {
  final LojistaModel? lojista;
  final List<LojaOptionModel> lojas;

  const LojistaFormInitial(this.lojas, [this.lojista]);

  @override
  List<Object?> get props => [lojista, lojas];
}

class LojistaFormLoading extends LojistaFormState {
  const LojistaFormLoading();

  @override
  List<Object?> get props => [];
}

class LojistaFormSuccess extends LojistaFormState {
  final LojistaModel lojista;

  const LojistaFormSuccess(this.lojista);

  @override
  List<Object?> get props => [lojista];
}

class LojistaFormError extends LojistaFormState {
  final String message;

  const LojistaFormError(this.message);

  @override
  List<Object?> get props => [message];
}
