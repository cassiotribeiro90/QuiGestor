import 'package:equatable/equatable.dart';
import '../models/lojista_model.dart';

import '../models/loja_option_model.dart';

abstract class LojistasState extends Equatable {
  const LojistasState();

  @override
  List<Object?> get props => [];
}

class LojistasInitial extends LojistasState {
  const LojistasInitial();
  @override
  List<Object?> get props => [];
}

class LojistasLoading extends LojistasState {
  const LojistasLoading();
  @override
  List<Object?> get props => [];
}

class LojistasLoaded extends LojistasState {
  final List<LojistaModel> lojistas;
  final List<LojaOptionModel> lojas;
  final int total;
  final int page;
  final int perPage;
  final Map<String, dynamic>? filterOptions;

  const LojistasLoaded({
    required this.lojistas,
    required this.lojas,
    required this.total,
    this.page = 1,
    this.perPage = 20,
    this.filterOptions,
  });

  @override
  List<Object?> get props => [
        lojistas,
        lojas,
        total,
        page,
        perPage,
        filterOptions,
      ];
}

class LojistasError extends LojistasState {
  final String message;
  const LojistasError(this.message);
  @override
  List<Object?> get props => [message];
}
