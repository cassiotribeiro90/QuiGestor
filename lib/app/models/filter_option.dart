class FilterOption {
  final String value;
  final String label;
  final int? count;
  final String? icon;

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
  final FilterType type;

  FilterGroup({
    required this.key,
    required this.label,
    required this.options,
    this.type = FilterType.radio,
  });

  /// Cria um FilterGroup a partir do JSON do filter_options.
  /// Se o valor for uma lista, cria opções normalmente.
  /// Se o valor for um número (int/double), cria uma única opção com a contagem.
  factory FilterGroup.fromJson(String key, dynamic json) {
    if (json is List) {
      final options = json.map((item) => FilterOption.fromJson(item)).toList();
      return FilterGroup(
        key: key,
        label: _getLabelForKey(key),
        options: options,
        type: FilterType.radio,
      );
    } else if (json is num) {
      // 🔥 Número: transforma em uma única opção com a contagem
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
      // Fallback: grupo vazio
      return FilterGroup(
        key: key,
        label: key,
        options: [],
        type: FilterType.radio,
      );
    }
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
}

enum FilterType { radio, checkbox }