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
  final int? filtroLojaId;
  final String? filtroFuncao;
  final int? filtroStatus;
  final String? filtroSearch;

  const LojistasLoaded({
    required this.lojistas,
    required this.lojas,
    required this.total,
    this.page = 1,
    this.perPage = 20,
    this.filtroLojaId,
    this.filtroFuncao,
    this.filtroStatus,
    this.filtroSearch,
  });

  LojistasLoaded copyWith({
    List<LojistaModel>? lojistas,
    List<LojaOptionModel>? lojas,
    int? total,
    int? page,
    int? perPage,
    int? filtroLojaId,
    String? filtroFuncao,
    int? filtroStatus,
    String? filtroSearch,
  }) {
    return LojistasLoaded(
      lojistas: lojistas ?? this.lojistas,
      lojas: lojas ?? this.lojas,
      total: total ?? this.total,
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
      filtroLojaId: filtroLojaId ?? this.filtroLojaId,
      filtroFuncao: filtroFuncao ?? this.filtroFuncao,
      filtroStatus: filtroStatus ?? this.filtroStatus,
      filtroSearch: filtroSearch ?? this.filtroSearch,
    );
  }

  @override
  List<Object?> get props => [
        lojistas,
        lojas,
        total,
        page,
        perPage,
        filtroLojaId,
        filtroFuncao,
        filtroStatus,
        filtroSearch,
      ];
}

class LojistasError extends LojistasState {
  final String message;
  const LojistasError(this.message);
  @override
  List<Object?> get props => [message];
}
