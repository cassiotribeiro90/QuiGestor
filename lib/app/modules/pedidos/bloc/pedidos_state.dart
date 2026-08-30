part of 'pedidos_cubit.dart';

class PedidosState extends Equatable {
  final List<Pedido> items;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int total;
  final int page;
  final int perPage;
  final bool hasMore;
  final bool hasLoaded; // 🔥 NOVO: indica se a lista já foi carregada pelo menos uma vez
  final bool isFirstLoad; // ⭐ NOVO: controla se é o primeiro carregamento
  final List<FilterGroup> filterGroups;

  const PedidosState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.total = 0,
    this.page = 1,
    this.perPage = 20,
    this.hasMore = false,
    this.hasLoaded = false, // 🔥 NOVO
    this.isFirstLoad = true, // ⭐ Inicia como true
    this.filterGroups = const [],
  });

  PedidosState copyWith({
    List<Pedido>? items,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? total,
    int? page,
    int? perPage,
    bool? hasMore,
    bool? hasLoaded,
    bool? isFirstLoad,
    List<FilterGroup>? filterGroups,
  }) {
    return PedidosState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      total: total ?? this.total,
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
      hasMore: hasMore ?? this.hasMore,
      hasLoaded: hasLoaded ?? this.hasLoaded,
      isFirstLoad: isFirstLoad ?? this.isFirstLoad,
      filterGroups: filterGroups ?? this.filterGroups,
    );
  }

  @override
  List<Object?> get props => [
    items,
    isLoading,
    isLoadingMore,
    error,
    total,
    page,
    perPage,
    hasMore,
    hasLoaded, // 🔥 NOVO
    isFirstLoad,
    filterGroups,
  ];
}
