import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../apparte/widgets/app_text.dart';
import '../../../../apparte/widgets/qui_button.dart';
import '../../../core/constants/icon_constants.dart';
import '../../categorias/bloc/categorias_cubit.dart';
import '../../categorias/bloc/categorias_state.dart';
import '../../categorias/models/categoria.dart';
import '../bloc/subcategoria_cubit.dart';
import '../bloc/subcategoria_state.dart';
import '../models/subcategoria.dart';

class SubcategoriaFormScreen extends StatefulWidget {
  final int? subcategoriaId;
  final Subcategoria? subcategoria;
  final int? initialCategoriaId;

  const SubcategoriaFormScreen({
    super.key,
    this.subcategoriaId,
    this.subcategoria,
    this.initialCategoriaId,
  });

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
  bool _isLoading = false;
  bool _isSaving = false;
  List<Categoria> _categorias = [];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.subcategoriaId != null || widget.subcategoria != null;
    _nomeController = TextEditingController();
    _descricaoController = TextEditingController();

    // Se tiver subcategoria via widget, preenche os campos
    if (widget.subcategoria != null) {
      _preencherControllers(widget.subcategoria!);
    }

    // Se tiver ID, carrega os dados
    if (widget.subcategoriaId != null && widget.subcategoria == null) {
      _carregarDados(widget.subcategoriaId!);
    }

    _categoriaId = widget.initialCategoriaId;

    // Carregar categorias para o dropdown
    _carregarCategorias();
  }

  Future<void> _carregarDados(int id) async {
    setState(() => _isLoading = true);

    try {
      // Carregar todas as subcategorias e filtrar pela ID
      await context.read<SubcategoriaCubit>().carregar();
      final state = context.read<SubcategoriaCubit>().state;

      if (state is SubcategoriaLoaded && mounted) {
        try {
          final subcategoria = state.subcategorias.firstWhere(
                (s) => s.id == id,
            orElse: () => throw Exception('Subcategoria não encontrada'),
          );
          _preencherControllers(subcategoria);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: TextBody2('Subcategoria não encontrada'),
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

  void _preencherControllers(Subcategoria subcategoria) {
    _nomeController.text = subcategoria.nome;
    _descricaoController.text = subcategoria.descricao ?? '';
    _categoriaId = subcategoria.categoriaId;
    _ativo = subcategoria.ativo;
  }

  Future<void> _carregarCategorias() async {
    final cubit = context.read<CategoriasCubit>();
    // Se já tiver categorias carregadas, usa elas
    if (cubit.state is CategoriasLoaded) {
      final state = cubit.state as CategoriasLoaded;
      if (mounted) {
        setState(() => _categorias = state.categorias);
      }
    } else {
      // Busca categorias
      await cubit.fetchCategorias();
      if (mounted && cubit.state is CategoriasLoaded) {
        final state = cubit.state as CategoriasLoaded;
        setState(() => _categorias = state.categorias);
      }
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  void _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoriaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: TextBody2('Selecione uma categoria', color: Colors.white),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final dados = {
      'nome': _nomeController.text.trim(),
      'descricao': _descricaoController.text.trim(),
      'categoria_id': _categoriaId,
      'status': _ativo ? 1 : 0,
    };

    final cubit = context.read<SubcategoriaCubit>();
    bool success;
    final id = widget.subcategoriaId ?? widget.subcategoria?.id;

    // Usando o metodo salvar do Cubit (que aceita id opcional)
    success = await cubit.salvar(dados, id: id);

    if (success && mounted) {
      context.pop(true);
    }

    if (mounted) setState(() => _isSaving = false);
  }

  void _confirmarExclusao() async {
    final id = widget.subcategoriaId ?? widget.subcategoria?.id;
    if (id == null) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const TextH3('Excluir Subcategoria'),
        content: TextBody2('Deseja realmente excluir esta subcategoria?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const TextBody2('Cancelar')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              // Usando o metodo deletar do Cubit
              final success = await context.read<SubcategoriaCubit>().deletar(id);
              if (success && mounted) {
                context.pop(true);
              }
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
    final isDark = theme.brightness == Brightness.dark;

    String title = _isEditing ? 'Editar Subcategoria' : 'Nova Subcategoria';

    return Scaffold(
      appBar: AppBar(
        title: TextH2(title, fontWeight: FontWeight.bold),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(AppIcons.delete, color: Colors.red, size: 22),
              onPressed: _isLoading ? null : _confirmarExclusao,
              tooltip: 'Excluir subcategoria',
            ),
          IconButton(
            icon: _isSaving || _isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(AppIcons.check),
            onPressed: _isSaving || _isLoading ? null : _salvar,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nome
              TextFormField(
                controller: _nomeController,
                decoration: _inputDecoration(theme, 'Nome *', AppIcons.category, isDark),
                validator: (val) => val == null || val.isEmpty ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 16),

              // Categoria Pai (Dropdown)
              BlocBuilder<CategoriasCubit, CategoriasState>(
                builder: (context, state) {
                  if (state is CategoriasLoading) {
                    return _buildLoadingDropdown(isDark);
                  }
                  if (state is CategoriasLoaded) {
                    // Atualiza lista de categorias
                    if (_categorias.isEmpty && state.categorias.isNotEmpty) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          setState(() => _categorias = state.categorias);
                        }
                      });
                    }
                    return DropdownButtonFormField<int>(
                      value: _categoriaId,
                      decoration: _inputDecoration(theme, 'Categoria Pai *', Icons.account_tree, isDark),
                      hint: Text(
                        'Selecione uma categoria',
                        style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                      ),
                      items: _categorias.map((cat) => DropdownMenuItem(
                        value: cat.id,
                        child: TextBody2(cat.nome),
                      )).toList(),
                      onChanged: (val) => setState(() => _categoriaId = val),
                      validator: (val) => val == null ? 'Selecione uma categoria' : null,
                      dropdownColor: isDark ? Colors.grey[800] : Colors.white,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    );
                  }
                  if (state is CategoriasError) {
                    return TextBody2(
                      'Erro ao carregar categorias: ${state.message}',
                      color: Colors.red,
                    );
                  }
                  return _buildLoadingDropdown(isDark);
                },
              ),
              const SizedBox(height: 16),

              // Descrição
              TextFormField(
                controller: _descricaoController,
                decoration: _inputDecoration(theme, 'Descrição', AppIcons.inventory, isDark),
                maxLines: 3,
              ),
              const SizedBox(height: 20),

              // Ativo Switch
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? Colors.grey[600]! : Colors.grey[300]!),
                ),
                child: SwitchListTile(
                  title: const TextBody1('Ativo', fontWeight: FontWeight.bold),
                  subtitle: TextBody3(
                    'Define se a subcategoria está visível',
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  value: _ativo,
                  onChanged: (val) => setState(() => _ativo = val),
                  activeColor: theme.primaryColor,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(height: 32),

              // Botão Salvar
              QuiButton(
                label: _isEditing ? 'ATUALIZAR' : 'CRIAR',
                onPressed: _salvar,
                isLoading: _isSaving,
              ),

              // Botão Excluir (quando em edição)
              if (_isEditing) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isSaving ? null : _confirmarExclusao,
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

  Widget _buildLoadingDropdown(bool isDark) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.grey[600]! : Colors.grey[300]!),
      ),
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
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