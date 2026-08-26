import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../models/filter_option.dart';

// Estado
class FilterState extends Equatable {
  final Map<String, String> selectedValues; // para radio (um valor por grupo)
  final Map<String, List<String>> selectedMultiValues; // para checkbox
  final String searchQuery;
  final bool isApplied;

  const FilterState({
    this.selectedValues = const {},
    this.selectedMultiValues = const {},
    this.searchQuery = '',
    this.isApplied = false,
  });

  FilterState copyWith({
    Map<String, String>? selectedValues,
    Map<String, List<String>>? selectedMultiValues,
    String? searchQuery,
    bool? isApplied,
  }) {
    return FilterState(
      selectedValues: selectedValues ?? this.selectedValues,
      selectedMultiValues: selectedMultiValues ?? this.selectedMultiValues,
      searchQuery: searchQuery ?? this.searchQuery,
      isApplied: isApplied ?? this.isApplied,
    );
  }

  @override
  List<Object?> get props => [selectedValues, selectedMultiValues, searchQuery, isApplied];
}

// Cubit
class FilterCubit extends Cubit<FilterState> {
  FilterCubit() : super(const FilterState());

  // Seleção única (radio)
  void selectValue(String groupKey, String value) {
    final newSelected = Map<String, String>.from(state.selectedValues);
    if (newSelected[groupKey] == value) {
      newSelected.remove(groupKey); // toggle off
    } else {
      newSelected[groupKey] = value;
    }
    emit(state.copyWith(selectedValues: newSelected, isApplied: false));
  }

  // Seleção múltipla (checkbox)
  void toggleMultiValue(String groupKey, String value) {
    final newSelected = Map<String, List<String>>.from(state.selectedMultiValues);
    if (!newSelected.containsKey(groupKey)) {
      newSelected[groupKey] = [];
    }
    final list = List<String>.from(newSelected[groupKey]!);
    if (list.contains(value)) {
      list.remove(value);
    } else {
      list.add(value);
    }
    if (list.isEmpty) {
      newSelected.remove(groupKey);
    } else {
      newSelected[groupKey] = list;
    }
    emit(state.copyWith(selectedMultiValues: newSelected, isApplied: false));
  }

  // Busca textual
  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query, isApplied: false));
  }

  // Aplica os filtros (notifica a tela para recarregar)
  void applyFilters() {
    emit(state.copyWith(isApplied: true));
  }

  // Limpa todos os filtros
  void clearFilters() {
    emit(const FilterState());
  }

  // Gera os parâmetros de query para a API
  Map<String, String> getFilterParams() {
    final params = <String, String>{};
    // Radio
    for (var entry in state.selectedValues.entries) {
      params[entry.key] = entry.value;
    }
    // Checkbox (converte lista para string separada por vírgula)
    for (var entry in state.selectedMultiValues.entries) {
      if (entry.value.isNotEmpty) {
        params[entry.key] = entry.value.join(',');
      }
    }
    // Search
    if (state.searchQuery.isNotEmpty) {
      params['search'] = state.searchQuery;
    }
    return params;
  }

  // Verifica se algum filtro está ativo
  bool get hasActiveFilters {
    return state.selectedValues.isNotEmpty ||
        state.selectedMultiValues.isNotEmpty ||
        state.searchQuery.isNotEmpty;
  }

  // Retorna o resumo dos filtros aplicados (para exibir na tela)
  String getFilterSummary(List<FilterGroup> groups) {
    final parts = <String>[];
    if (state.searchQuery.isNotEmpty) {
      parts.add('"${state.searchQuery}"');
    }
    for (var group in groups) {
      if (group.type == FilterType.radio) {
        final selected = state.selectedValues[group.key];
        if (selected != null) {
          final label = group.options.firstWhere(
            (o) => o.value == selected,
            orElse: () => FilterOption(value: selected, label: selected),
          ).label;
          parts.add('${group.label}: $label');
        }
      } else {
        final selected = state.selectedMultiValues[group.key];
        if (selected != null && selected.isNotEmpty) {
          final labels = selected.map((v) {
            return group.options.firstWhere(
              (o) => o.value == v,
              orElse: () => FilterOption(value: v, label: v),
            ).label;
          }).join(', ');
          parts.add('${group.label}: $labels');
        }
      }
    }
    return parts.isNotEmpty ? 'Filtros: ${parts.join(' | ')}' : 'Todos os itens';
  }
}
