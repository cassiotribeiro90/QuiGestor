import 'package:equatable/equatable.dart';
import '../models/lojista_model.dart';
import '../models/loja_option_model.dart';

class LojistasState extends Equatable {
  final List<LojistaModel> lojistas;
  final List<LojaOptionModel> lojas;
  final int total;
  final int page;
  final int perPage;
  final Map<String, dynamic>? filterOptions;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isFirstLoad;
  final String? error;
  final String? successMessage;

  const LojistasState({
    this.lojistas = const [],
    this.lojas = const [],
    this.total = 0,
    this.page = 1,
    this.perPage = 20,
    this.filterOptions,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isFirstLoad = true,
    this.error,
    this.successMessage,
  });

  LojistasState copyWith({
    List<LojistaModel>? lojistas,
    List<LojaOptionModel>? lojas,
    int? total,
    int? page,
    int? perPage,
    Map<String, dynamic>? filterOptions,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isFirstLoad,
    String? error,
    String? successMessage,
  }) {
    return LojistasState(
      lojistas: lojistas ?? this.lojistas,
      lojas: lojas ?? this.lojas,
      total: total ?? this.total,
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
      filterOptions: filterOptions ?? this.filterOptions,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isFirstLoad: isFirstLoad ?? this.isFirstLoad,
      error: error,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
    lojistas,
    lojas,
    total,
    page,
    perPage,
    filterOptions,
    isLoading,
    isLoadingMore,
    isFirstLoad,
    error,
    successMessage,
  ];
}
