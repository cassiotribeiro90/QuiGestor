import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../../../apparte/widgets/app_text.dart';
import '../../../../apparte/widgets/qui_button.dart';
import '../bloc/categorias_cubit.dart';
import '../bloc/categorias_state.dart';
import '../models/categoria.dart';
import '../../../core/constants/icon_constants.dart';

class CategoriaFormScreen extends StatefulWidget {
  final int? categoriaId;
  final Categoria? categoria;

  const CategoriaFormScreen({
    super.key,
    this.categoriaId,
    this.categoria,
  });

  @override
  State<CategoriaFormScreen> createState() => _CategoriaFormScreenState();
}

class _CategoriaFormScreenState extends State<CategoriaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late TextEditingController _descricaoController;
  late TextEditingController _iconeController;
  late TextEditingController _ordemController;
  late Color _selectedColor;
  bool _ativo = true;
  bool _destaque = false;
  bool _isLoading = false;
  bool _isSaving = false;

  bool get isEditing => widget.categoriaId != null || widget.categoria != null;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController();
    _descricaoController = TextEditingController();
    _iconeController = TextEditingController();
    _ordemController = TextEditingController();
    _selectedColor = const Color(0xFFFF6B6B);

    // Se tiver categoria via widget, preenche os campos
    if (widget.categoria != null) {
      _preencherControllers(widget.categoria!);
    }

    // Se tiver ID, carrega os dados
    if (widget.categoriaId != null && widget.categoria == null) {
      _carregarDados(widget.categoriaId!);
    }

    _nomeController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  Future<void> _carregarDados(int id) async {
    setState(() => _isLoading = true);

    try {
      // Carregar todas as categorias e filtrar pela ID
      await context.read<CategoriasCubit>().fetchCategorias();
      final state = context.read<CategoriasCubit>().state;

      if (state is CategoriasLoaded && mounted) {
        try {
          final categoria = state.categorias.firstWhere(
                (c) => c.id == id,
            orElse: () => throw Exception('Categoria não encontrada'),
          );
          _preencherControllers(categoria);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: TextBody2('Categoria não encontrada'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: TextBody2('Erro ao carregar dados: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  void _preencherControllers(Categoria categoria) {
    _nomeController.text = categoria.nome;
    _descricaoController.text = categoria.descricao ?? '';
    _iconeController.text = categoria.icone ?? '🍔';
    _ordemController.text = categoria.ordem.toString();
    _selectedColor = categoria.colorValue;
    _ativo = categoria.ativo;
    _destaque = categoria.destaque;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _iconeController.dispose();
    _ordemController.dispose();
    super.dispose();
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  void _pickColor() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const TextH3('Selecione uma cor'),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: _selectedColor,
            onColorChanged: (color) {
              setState(() => _selectedColor = color);
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final data = {
      'nome': _nomeController.text.trim(),
      'descricao': _descricaoController.text.trim(),
      'icone': _iconeController.text.trim(),
      'cor': _colorToHex(_selectedColor),
      'ordem': int.tryParse(_ordemController.text) ?? 0,
      'ativo': _ativo ? 1 : 0,
      'destaque': _destaque ? 1 : 0,
    };

    final cubit = context.read<CategoriasCubit>();
    bool success;
    final id = widget.categoriaId ?? widget.categoria?.id;

    if (isEditing && id != null) {
      success = await cubit.updateCategoria(id, data);
    } else {
      success = await cubit.createCategoria(data);
    }

    if (success && mounted) {
      // Recarregar a lista
      await cubit.fetchCategorias();
      if (mounted) {
        context.pop(true);
      }
    }

    if (mounted) setState(() => _isSaving = false);
  }

  void _confirmDelete() async {
    final id = widget.categoriaId ?? widget.categoria?.id;
    if (id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const TextH3('Confirmar exclusão'),
        content: const TextBody2('Deseja realmente excluir esta categoria?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const TextBody2('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const TextBody2('Excluir', color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await context.read<CategoriasCubit>().deleteCategoria(id);
      if (success && mounted) {
        // Recarregar a lista
        await context.read<CategoriasCubit>().fetchCategorias();
        if (mounted) {
          context.pop(true);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    String title = isEditing ? 'Editar Categoria' : 'Nova Categoria';
    if (_nomeController.text.isNotEmpty) {
      title = '${_nomeController.text} - Gerenciar Categoria';
    }

    return Scaffold(
      appBar: AppBar(
        title: TextH2(title, fontWeight: FontWeight.bold),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: _isLoading ? null : _confirmDelete,
            ),
          IconButton(
            icon: _isSaving || _isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(AppIcons.check),
            onPressed: _isSaving || _isLoading ? null : _submit,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TextBody1('Informações Básicas', fontWeight: FontWeight.bold),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nomeController,
                decoration: _inputDecoration(theme, 'Nome da Categoria *', Icons.label_outline, isDark),
                validator: (v) => v == null || v.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descricaoController,
                decoration: _inputDecoration(theme, 'Descrição', Icons.description_outlined, isDark),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              const TextBody1('Configurações Visuais', fontWeight: FontWeight.bold),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _iconeController,
                      decoration: _inputDecoration(theme, 'Ícone (Emoji)', Icons.emoji_emotions_outlined, isDark),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: _pickColor,
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: _selectedColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _selectedColor, width: 2),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.color_lens, color: _selectedColor),
                            TextBody3(
                              _colorToHex(_selectedColor),
                              color: _selectedColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ordemController,
                decoration: _inputDecoration(theme, 'Ordem de exibição', Icons.sort, isDark),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              const TextBody1('Status e Destaque', fontWeight: FontWeight.bold),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? Colors.grey[600]! : Colors.grey[300]!),
                ),
                child: SwitchListTile(
                  title: const TextBody1('Categoria Ativa'),
                  subtitle: TextBody3(
                    'Define se a categoria aparece para os clientes',
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  value: _ativo,
                  onChanged: (v) => setState(() => _ativo = v),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? Colors.grey[600]! : Colors.grey[300]!),
                ),
                child: SwitchListTile(
                  title: const TextBody1('Destaque'),
                  subtitle: TextBody3(
                    'Exibir com prioridade nas listas',
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  value: _destaque,
                  onChanged: (v) => setState(() => _destaque = v),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(height: 40),
              QuiButton(
                label: isEditing ? 'SALVAR ALTERAÇÕES' : 'CRIAR CATEGORIA',
                onPressed: _submit,
                isLoading: _isSaving,
              ),
              if (isEditing) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isSaving ? null : _confirmDelete,
                    icon: const Icon(AppIcons.delete, size: 18, color: Colors.red),
                    label: TextBody1('EXCLUIR', color: Colors.red, fontWeight: FontWeight.bold),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Colors.red, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(ThemeData theme, String label, IconData icon, bool isDark) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? Colors.grey[600]! : Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.primaryColor, width: 2),
      ),
      filled: true,
      fillColor: isDark ? Colors.grey[800] : theme.colorScheme.surface,
      labelStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700]),
    );
  }
}