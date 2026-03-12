import 'package:flutter/material.dart';

enum FilterType {
  checkbox,    // múltipla escolha
  radio,       // única escolha
  range,       // intervalo (preço, data)
  search,      // busca textual
  orderBy,     // ordenação
}

class FilterOption {
  final String value;
  final String label;
  final int? count;
  bool selected;

  FilterOption({
    required this.value,
    required this.label,
    this.count,
    this.selected = false,
  });

  Map<String, dynamic> toJson() => {
    'value': value,
    'label': label,
    'count': count,
    'selected': selected,
  };
}

class FilterSection {
  final String id;           // identificador único (ex: 'status', 'nivel')
  final String title;
  final IconData icon;
  final FilterType type;
  final List<FilterOption> options;
  final String? paramName;   // nome do parâmetro na API (ex: 'status', 'nivel[]')
  final bool multiple;       // permite múltipla seleção?

  FilterSection({
    required this.id,
    required this.title,
    required this.icon,
    this.type = FilterType.checkbox,
    required this.options,
    this.paramName,
    this.multiple = true,
  });

  // Retorna os valores selecionados
  List<String> get selectedValues => 
      options.where((opt) => opt.selected).map((opt) => opt.value).toList();

  // Retorna se tem algum selecionado
  bool get hasSelection => selectedValues.isNotEmpty;

  // Aplica seleção a partir de valores
  void applySelection(List<String> values) {
    for (var option in options) {
      option.selected = values.contains(option.value);
    }
  }

  // Limpa seleção
  void clearSelection() {
    for (var option in options) {
      option.selected = false;
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'type': type.toString(),
    'options': options.map((opt) => opt.toJson()).toList(),
    'multiple': multiple,
  };
}

class FilterConfig {
  final String title;
  final List<FilterSection> sections;
  final Map<String, String>? orderByOptions;
  final String? defaultOrderBy;

  FilterConfig({
    required this.title,
    required this.sections,
    this.orderByOptions,
    this.defaultOrderBy,
  });

  // Retorna todos os filtros selecionados como Map para query params
  Map<String, String> getSelectedFilters() {
    final filters = <String, String>{};
    
    for (var section in sections) {
      final selected = section.selectedValues;
      if (selected.isNotEmpty) {
        final paramName = section.paramName ?? section.id;
        
        if (section.multiple) {
          // Para múltipla seleção, o comportamento padrão aqui será concatenar com vírgula
          filters[paramName] = selected.join(',');
        } else if (selected.isNotEmpty) {
          filters[paramName] = selected.first;
        }
      }
    }
    
    return filters;
  }

  // Limpa todos os filtros
  void clearAll() {
    for (var section in sections) {
      section.clearSelection();
    }
  }

  int get activeFilterCount {
    int count = 0;
    for (var section in sections) {
      if (section.multiple) {
        count += section.selectedValues.length;
      } else {
        if (section.hasSelection) count++;
      }
    }
    return count;
  }
}
