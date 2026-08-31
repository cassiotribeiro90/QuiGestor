import 'package:equatable/equatable.dart';

class FilterOption extends Equatable {
  final String value;
  final String label;
  final int? count;
  final String? icon;

  const FilterOption({
    required this.value,
    required this.label,
    this.count,
    this.icon,
  });

  factory FilterOption.fromJson(Map<String, dynamic> json) {
    return FilterOption(
      value: json['value']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      count: json['count'] != null ? int.tryParse(json['count'].toString()) : null,
      icon: json['icon'] as String?,
    );
  }

  @override
  List<Object?> get props => [value, label, count, icon];
}

class FilterGroup extends Equatable {
  final String key;
  final String label;
  final List<FilterOption> options;
  final FilterType type;
  final String? selectedValue; // ⭐ NOVO CAMPO

  const FilterGroup({
    required this.key,
    required this.label,
    required this.options,
    this.type = FilterType.radio,
    this.selectedValue, // ⭐ Inicializa como null por padrão
  });

  /// Cria um FilterGroup a partir do JSON do filter_options.
  factory FilterGroup.fromJson(String key, dynamic json) {
    if (json is List) {
      final options = json.map((item) => FilterOption.fromJson(item)).toList();
      return FilterGroup(
        key: key,
        label: _getLabelForKey(key),
        options: options,
        type: FilterType.radio,
        // ⭐ selectedValue vem null; será definido depois via copyWith
      );
    } else if (json is num) {
      final option = FilterOption(
        value: key,
        label: _getLabelForKey(key),
        count: json.toInt(),
      );
      return FilterGroup(
        key: key,
        label: _getLabelForKey(key),
        options: [option],
        type: FilterType.radio,
      );
    } else {
      return FilterGroup(
        key: key,
        label: key,
        options: const [],
        type: FilterType.radio,
      );
    }
  }

  // ⭐ METODO copyWith ADICIONADO
  FilterGroup copyWith({
    String? key,
    String? label,
    List<FilterOption>? options,
    FilterType? type,
    String? selectedValue,
  }) {
    return FilterGroup(
      key: key ?? this.key,
      label: label ?? this.label,
      options: options ?? this.options,
      type: type ?? this.type,
      selectedValue: selectedValue ?? this.selectedValue,
    );
  }

  static String _getLabelForKey(String key) {
    const labels = {
      'status': 'Status',
      'categoria_id': 'Categoria',
      'ativo': 'Ativo',
      'destaque': 'Destaque',
      'verificado': 'Verificado',
      'funcao': 'Função',
      'nivel': 'Nível',
      'loja_id': 'Loja',
      'categoria': 'Categoria',
      'categorias': 'Categorias',
      'periodo': 'Período',
    };
    return labels[key] ?? key;
  }

  @override
  List<Object?> get props => [key, label, options, type, selectedValue];
}

enum FilterType { radio, checkbox }