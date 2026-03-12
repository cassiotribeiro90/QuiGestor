import 'package:flutter/material.dart';
import 'filter_option.dart';
import 'filter_section_widget.dart';
import 'app_text.dart';

class FilterBottomSheetGeneric extends StatefulWidget {
  final String title;
  final List<FilterSectionModel> sections;
  final VoidCallback? onClear;
  final Function(List<FilterSectionModel>) onApply;

  const FilterBottomSheetGeneric({
    super.key,
    required this.title,
    required this.sections,
    this.onClear,
    required this.onApply,
  });

  @override
  State<FilterBottomSheetGeneric> createState() => _FilterBottomSheetGenericState();

  static Future<void> show({
    required BuildContext context,
    required String title,
    required List<FilterSectionModel> sections,
    VoidCallback? onClear,
    required Function(List<FilterSectionModel>) onApply,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => FilterBottomSheetGeneric(
        title: title,
        sections: sections.map((s) {
          return FilterSectionModel(
            id: s.id,
            title: s.title,
            isRadio: s.isRadio,
            options: s.options.map((opt) => opt.copyWith()).toList(),
          );
        }).toList(),
        onClear: onClear,
        onApply: onApply,
      ),
    );
  }
}

class _FilterBottomSheetGenericState extends State<FilterBottomSheetGeneric> {
  late List<FilterSectionModel> _sections;

  @override
  void initState() {
    super.initState();
    _sections = widget.sections;
  }

  void _handleOptionTap(String sectionId, String value) {
    setState(() {
      final section = _sections.firstWhere((s) => s.id == sectionId);
      section.toggleOption(value);
    });
  }

  void _clearAll() {
    setState(() {
      for (var section in _sections) {
        section.clearSelection();
      }
    });
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextH2(widget.title),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _sections.map((section) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: FilterSectionWidget(
                      section: section,
                      onOptionTap: (value) => _handleOptionTap(section.id, value),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _clearAll,
                    child: const Text('Limpar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onApply(_sections);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Aplicar'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
