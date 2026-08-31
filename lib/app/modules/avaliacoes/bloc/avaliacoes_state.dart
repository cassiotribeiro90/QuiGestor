import 'package:equatable/equatable.dart';
import '../models/avaliacao_model.dart';

class AvaliacoesState extends Equatable {
  final List<AvaliacaoModel> avaliacoes;
  final Map<String, dynamic>? filterOptions;
  final int page;
  final int perPage;
  final int total;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isFirstLoad;
  final String? error;
  final String? successMessage;

  const AvaliacoesState({
    this.avaliacoes = const [],
    this.filterOptions,
    this.page = 1,
    this.perPage = 20,
    this.total = 0,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isFirstLoad = true,
    this.error,
    this.successMessage,
  });

  AvaliacoesState copyWith({
    List<AvaliacaoModel>? avaliacoes,
    Map<String, dynamic>? filterOptions,
    int? page,
    int? perPage,
    int? total,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isFirstLoad,
    String? error,
    String? successMessage,
  }) {
    return AvaliacoesState(
      avaliacoes: avaliacoes ?? this.avaliacoes,
      filterOptions: filterOptions ?? this.filterOptions,
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
      total: total ?? this.total,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isFirstLoad: isFirstLoad ?? this.isFirstLoad,
      error: error,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
    avaliacoes,
    filterOptions,
    page,
    perPage,
    total,
    isLoading,
    isLoadingMore,
    isFirstLoad,
    error,
    successMessage,
  ];
}
