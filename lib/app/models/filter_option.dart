class FilterOption {
  final String value;
  final String label;
  final int? count;
  final String? icon; // opcional (para emojis)

  FilterOption({
    required this.value,
    required this.label,
    this.count,
    this.icon,
  });

  factory FilterOption.fromJson(Map<String, dynamic> json) {
    return FilterOption(
      value: json['value']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      count: json['count'] as int?,
      icon: json['icon'] as String?,
    );
  }
}

class FilterGroup {
  final String key;
  final String label;
  final List<FilterOption> options;
  final FilterType type; // radio ou checkbox

  FilterGroup({
    required this.key,
    required this.label,
    required this.options,
    this.type = FilterType.radio,
  });

  static FilterGroup? fromJson(String key, dynamic json) {
    if (json is! List) return null;

    final options = json
        .map((item) => FilterOption.fromJson(item as Map<String, dynamic>))
        .toList();

    // Define o tipo com base na chave ou no número de opções
    FilterType type = FilterType.radio;
    if (key == 'categoria_id' || key == 'loja_id' || key == 'status') {
      type = FilterType.radio; // seleção única
    } else if (key == 'ativo' || key == 'destaque' || key == 'verificado') {
      type = FilterType.radio; // booleano
    } else {
      type = FilterType.radio; // fallback
    }

    return FilterGroup(
      key: key,
      label: _getLabelForKey(key),
      options: options,
      type: type,
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
    };
    return labels[key] ?? key;
  }
}

enum FilterType { radio, checkbox }
