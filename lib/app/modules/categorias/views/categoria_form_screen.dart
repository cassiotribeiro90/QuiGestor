import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../../../apparte/widgets/app_text.dart';
import '../bloc/categorias_cubit.dart';
import '../bloc/categorias_state.dart';
import '../models/categoria.dart';

class CategoriaFormScreen extends StatefulWidget {
  final Categoria? categoria;
  const CategoriaFormScreen({super.key, this.categoria});

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

  bool get isEditing => widget.categoria != null;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.categoria?.nome ?? '');
    _descricaoController = TextEditingController(text: widget.categoria?.descricao ?? '');
    _iconeController = TextEditingController(text: widget.categoria?.icone ?? '🍔');
    _ordemController = TextEditingController(text: widget.categoria?.ordem.toString() ?? '0');
    _selectedColor = widget.categoria?.colorValue ?? const Color(0xFFFF6B6B);
    _ativo = widget.categoria?.ativo ?? true;
    _destaque = widget.categoria?.destaque ?? false;
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
        title: const Text('Selecione uma cor'),
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

    final data = {
      'nome': _nomeController.text,
      'descricao': _descricaoController.text,
      'icone': _iconeController.text,
      'cor': _colorToHex(_selectedColor),
      'ordem': int.tryParse(_ordemController.text) ?? 0,
      'ativo': _ativo ? 1 : 0,
      'destaque': _destaque ? 1 : 0,
    };

    final cubit = context.read<CategoriasCubit>();
    bool success;
    if (isEditing) {
      success = await cubit.updateCategoria(widget.categoria!.id, data);
    } else {
      success = await cubit.createCategoria(data);
    }

    if (success && mounted) {
      Navigator.pop(context, true);
    }
  }

  void _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Deseja realmente excluir esta categoria?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await context.read<CategoriasCubit>().deleteCategoria(widget.categoria!.id);
      if (success && mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Categoria' : 'Nova Categoria'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: BlocConsumer<CategoriasCubit, CategoriasState>(
        listener: (context, state) {
          if (state is CategoriasError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is CategoriaOperationLoading;

          return Form(
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
                    decoration: const InputDecoration(
                      labelText: 'Nome da Categoria *',
                      prefixIcon: Icon(Icons.label_outline),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Campo obrigatório' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descricaoController,
                    decoration: const InputDecoration(
                      labelText: 'Descrição',
                      prefixIcon: Icon(Icons.description_outlined),
                    ),
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
                          decoration: const InputDecoration(
                            labelText: 'Ícone (Emoji)',
                            prefixIcon: Icon(Icons.emoji_emotions_outlined),
                            hintText: 'Ex: 🍔, 🍕, 🍦',
                          ),
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
                                Text(
                                  _colorToHex(_selectedColor),
                                  style: TextStyle(
                                    color: _selectedColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
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
                    decoration: const InputDecoration(
                      labelText: 'Ordem de exibição',
                      prefixIcon: Icon(Icons.sort),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),
                  const TextBody1('Status e Destaque', fontWeight: FontWeight.bold),
                  SwitchListTile(
                    title: const Text('Categoria Ativa'),
                    subtitle: const Text('Define se a categoria aparece para os clientes'),
                    value: _ativo,
                    onChanged: (v) => setState(() => _ativo = v),
                  ),
                  SwitchListTile(
                    title: const Text('Destaque'),
                    subtitle: const Text('Exibir com prioridade nas listas'),
                    value: _destaque,
                    onChanged: (v) => setState(() => _destaque = v),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(isEditing ? 'SALVAR ALTERAÇÕES' : 'CRIAR CATEGORIA'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
