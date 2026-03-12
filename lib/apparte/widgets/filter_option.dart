import 'package:flutter/material.dart';

class FilterOptionModel {
  final String value;
  final String label;
  final String? emoji;
  final IconData? icon;
  final int? count;
  bool selected;

  FilterOptionModel({
    required this.value,
    required this.label,
    this.emoji,
    this.icon,
    this.count,
    this.selected = false,
  });

  FilterOptionModel copyWith({bool? selected}) {
    return FilterOptionModel(
      value: value,
      label: label,
      emoji: emoji,
      icon: icon,
      count: count,
      selected: selected ?? this.selected,
    );
  }
}

class FilterSectionModel {
  final String id;
  final String title;
  final bool isRadio; // ← TRUE = radio, FALSE = checkbox
  final List<FilterOptionModel> options;

  FilterSectionModel({
    required this.id,
    required this.title,
    required this.isRadio,
    required this.options,
  });

  // Retorna os valores selecionados (sempre como lista, mesmo no modo radio)
  List<String> getSelectedValues() {
    return options.where((opt) => opt.selected).map((opt) => opt.value).toList();
  }

  // Retorna se tem algum selecionado
  bool get hasSelection => getSelectedValues().isNotEmpty;

  // Retorna quantidade de selecionados
  int get selectedCount => getSelectedValues().length;

  // Seleciona/desseleciona uma opção (respeitando o modo isRadio)
  void toggleOption(String value) {
    if (isRadio) {
      // Modo radio: apenas UMA pode estar selecionada
      for (var option in options) {
        option.selected = (option.value == value);
      }
    } else {
      // Modo checkbox: toggle normal
      final index = options.indexWhere((opt) => opt.value == value);
      if (index >= 0) {
        options[index].selected = !options[index].selected;
      }
    }
  }

  // Limpa todas as seleções
  void clearSelection() {
    for (var option in options) {
      option.selected = false;
    }
  }

  // Aplica seleção a partir de uma lista de valores
  void applySelection(List<String> values) {
    if (isRadio) {
      // No modo radio, só o primeiro valor (se houver) é aplicado
      if (values.isNotEmpty) {
        for (var option in options) {
          option.selected = (option.value == values.first);
        }
      } else {
        clearSelection();
      }
    } else {
      for (var option in options) {
        option.selected = values.contains(option.value);
      }
    }
  }
}
