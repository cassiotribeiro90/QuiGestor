import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../apparte/widgets/app_text.dart';
import '../../../../apparte/widgets/qui_button.dart';
import '../../../../shared/api/api_client.dart';
import '../../../core/constants/icon_constants.dart';
import '../../categorias/bloc/categorias_cubit.dart';
import '../../categorias/bloc/categorias_state.dart';
import '../bloc/subcategoria_cubit.dart';
import '../models/subcategoria.dart';

class SubcategoriaFormScreen extends StatefulWidget {
  final Subcategoria? subcategoria;
  final int? initialCategoriaId;

  const SubcategoriaFormScreen({super.key, this.subcategoria, this.initialCategoriaId});

  @override
  State<SubcategoriaFormScreen> createState() => _SubcategoriaFormScreenState();
}

class _SubcategoriaFormScreenState extends State<SubcategoriaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late TextEditingController _descricaoController;
  int? _categoriaId;
  bool _ativo = true;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.subcategoria != null;
    _nomeController = TextEditingController(text: widget.subcategoria?.nome ?? '');
    _descricaoController = TextEditingController(text: widget.subcategoria?.descricao ?? '');
    _categoriaId = widget.subcategoria?.categoriaId ?? widget.initialCategoriaId;
    _ativo = widget.subcategoria?.ativo ?? true;

    // Carregar categorias para o dropdown
    context.read<CategoriasCubit>().fetchCategorias();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  void _salvar() {
    if (!_formKey.currentState!.validate()) return;
    if (_categoriaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: TextBody2('Selecione uma categoria', color: Colors.white), backgroundColor: Colors.red),
      );
      return;
    }

    final dados = {
      'nome': _nomeController.text.trim(),
      'descricao': _descricaoController.text.trim(),
      'categoria_id': _categoriaId,
      'status': _ativo ? 1 : 0,
    };

    context.read<SubcategoriaCubit>().salvar(dados, id: widget.subcategoria?.id).then((success) {
      if (success && mounted) {
        Navigator.pop(context);
      }
    });
  }

  void _confirmarExclusao() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const TextH3('Excluir Subcategoria'),
        content: TextBody2('Deseja realmente excluir a subcategoria "${widget.subcategoria?.nome}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const TextBody2('Cancelar')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<SubcategoriaCubit>().deletar(widget.subcategoria!.id).then((success) {
                if (success && mounted) {
                  Navigator.pop(context); // Volta para a listagem
                }
              });
            },
            child: const TextBody2('Excluir', color: Colors.red),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: TextH2(_isEditing ? 'Editar Subcategoria' : 'Nova Subcategoria', fontWeight: FontWeight.bold),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(AppIcons.delete, color: Colors.red, size: 22),
              onPressed: _confirmarExclusao,
              tooltip: 'Excluir subcategoria',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: _inputDecoration(theme, 'Nome *', AppIcons.category),
                validator: (val) => val == null || val.isEmpty ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 16),
              BlocBuilder<CategoriasCubit, CategoriasState>(
                builder: (context, state) {
                  if (state is CategoriasLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is CategoriasLoaded) {
                    return DropdownButtonFormField<int>(
                      value: _categoriaId,
                      decoration: _inputDecoration(theme, 'Categoria Pai *', Icons.account_tree),
                      items: state.categorias.map((cat) => DropdownMenuItem(
                        value: cat.id,
                        child: TextBody2(cat.nome),
                      )).toList(),
                      onChanged: (val) => setState(() => _categoriaId = val),
                      validator: (val) => val == null ? 'Obrigatório' : null,
                    );
                  }
                  return const TextBody2('Erro ao carregar categorias');
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descricaoController,
                decoration: _inputDecoration(theme, 'Descrição', AppIcons.inventory),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              SwitchListTile(
                title: const TextBody1('Ativo', fontWeight: FontWeight.bold),
                subtitle: const TextBody3('Define se a subcategoria está visível'),
                value: _ativo,
                onChanged: (val) => setState(() => _ativo = val),
              ),
              const SizedBox(height: 32),
              QuiButton(
                label: 'SALVAR',
                onPressed: _salvar,
              ),
              if (_isEditing) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _confirmarExclusao,
                    icon: const Icon(AppIcons.delete, size: 18, color: Colors.red),
                    label: const TextBody1('EXCLUIR', color: Colors.red, fontWeight: FontWeight.bold),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Colors.red, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  InputDecoration _inputDecoration(ThemeData theme, String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: theme.colorScheme.surface,
    );
  }
}