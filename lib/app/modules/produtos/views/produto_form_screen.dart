import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../apparte/widgets/app_text.dart';
import '../../../../apparte/widgets/qui_button.dart';
import '../bloc/produto_cubit.dart';
import '../bloc/produto_state.dart';
import '../models/produto.dart';
import 'package:quigestor/app/modules/subcategorias/models/subcategoria.dart';
import '../../categorias/models/categoria.dart';
import '../../lojas/models/loja.dart';
import '../../../../apparte/widgets/quigestor_card.dart';
import '../../../../shared/api/api_client.dart';
import '../../../core/constants/icon_constants.dart';
import '../../../core/widgets/back_button_mixin.dart';

class ProdutoFormScreen extends StatefulWidget {
  final int? produtoId;
  final int? initialLojaId;

  const ProdutoFormScreen({super.key, this.produtoId, this.initialLojaId});

  @override
  State<ProdutoFormScreen> createState() => _ProdutoFormScreenState();
}

class _ProdutoFormScreenState extends State<ProdutoFormScreen> with BackButtonMixin {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  late TextEditingController _nomeController;
  late TextEditingController _descricaoController;
  late TextEditingController _precoController;
  late TextEditingController _precoPromocionalController;
  late TextEditingController _imagemController;
  late TextEditingController _ingredientesController;
  late TextEditingController _tempoPreparoController;
  late TextEditingController _ordemController;
  late TextEditingController _estoqueController;

  // IDs e seleções
  int? _lojaId;
  int? _categoriaId;
  int? _subcategoriaId;
  
  // Listas de opções
  List<Categoria> _categorias = [];
  List<Subcategoria> _subcategorias = [];
  bool _loadingSubcategorias = false;
  
  // Status
  bool _disponivel = true;
  bool _ativo = true;
  bool _destaque = false;
  bool _contemGluten = false;
  bool _contemLactose = false;
  bool _vegano = false;
  bool _vegetariano = false;
  bool _apimentado = false;
  
  bool _isEditing = false;
  bool _initialDataLoaded = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.produtoId != null;
    _lojaId = widget.initialLojaId;
    _inicializarControllers();
    
    context.read<ProdutoCubit>().loadInitialData(produtoId: widget.produtoId);
  }

  void _inicializarControllers() {
    _nomeController = TextEditingController();
    _descricaoController = TextEditingController();
    _precoController = TextEditingController();
    _precoPromocionalController = TextEditingController();
    _imagemController = TextEditingController();
    _ingredientesController = TextEditingController();
    _tempoPreparoController = TextEditingController();
    _ordemController = TextEditingController();
    _estoqueController = TextEditingController();
    
    _nomeController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  void _preencherControllers(Produto produto) {
    _nomeController.text = produto.nome;
    _descricaoController.text = produto.descricao ?? '';
    _precoController.text = produto.preco.toString();
    _precoPromocionalController.text = produto.precoPromocional?.toString() ?? '';
    _imagemController.text = produto.imagem ?? '';
    _ingredientesController.text = produto.ingredientesTexto ?? '';
    _tempoPreparoController.text = produto.tempoPreparo?.toString() ?? '';
    _ordemController.text = produto.ordem.toString();
    _estoqueController.text = produto.estoque.toString();
    
    _lojaId = produto.lojaId;
    
    // Prioriza o categoria_id do produto ou do objeto categoria (join)
    _categoriaId = produto.categoriaId ?? produto.categoriaId;
    _subcategoriaId = produto.subcategoriaId;
    
    _disponivel = produto.disponivel;
    _ativo = produto.ativo;
    _destaque = produto.destaque;
    _contemGluten = produto.contemGluten;
    _contemLactose = produto.contemLactose;
    _vegano = produto.vegano;
    _vegetariano = produto.vegetariano;
    _apimentado = produto.apimentado;
  }

  Future<void> _carregarSubcategorias(int categoriaId, {bool resetSelection = true}) async {
    setState(() {
      _loadingSubcategorias = true;
      if (resetSelection) {
        _subcategoriaId = null;
      }
      _subcategorias = [];
    });

    try {
      final response = await context.read<ApiClient>().get(
        '/gestor/subcategoria/por-categoria?id=$categoriaId',
      );

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        setState(() {
          _subcategorias = data.map((json) => Subcategoria.fromJson(json)).toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: TextInverse('Erro ao carregar subcategorias: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loadingSubcategorias = false);
      }
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _precoController.dispose();
    _precoPromocionalController.dispose();
    _imagemController.dispose();
    _ingredientesController.dispose();
    _tempoPreparoController.dispose();
    _ordemController.dispose();
    _estoqueController.dispose();
    super.dispose();
  }

  String _getLojaNome(List<Loja> lojas) {
    if (_lojaId == null) return '';
    try {
      return lojas.firstWhere((l) => l.id == _lojaId).nome;
    } catch (_) {
      return '';
    }
  }

  Widget _buildSectionHeader(BuildContext context, {
    required IconData icon,
    required String title,
  }) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: theme.colorScheme.primary, size: 20),
        ),
        const SizedBox(width: 12),
        TextH3(
          title,
          fontWeight: FontWeight.bold,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProdutoCubit, ProdutoState>(
      listener: (context, state) {
        if (state is ProdutoLoaded) {
          setState(() {
            _categorias = {for (var cat in state.categorias) cat.id: cat}.values.toList();
            
            if (!_initialDataLoaded) {
              if (state.produto != null) {
                _preencherControllers(state.produto!);
                _subcategorias = {for (var sub in state.subcategorias) sub.id: sub}.values.toList();
              }
              _initialDataLoaded = true;
            }
          });
        } else if (state is ProdutoOperationSuccess) {
          // SnackBar removido daqui e movido para _salvar/_deletar com delay antes do pop
        } else if (state is ProdutoError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: TextInverse(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is ProdutoLoading || state is ProdutoOperationLoading;
        
        if (state is ProdutoLoading && !_initialDataLoaded) {
           return Scaffold(
             appBar: AppBar(
               leading: buildBackButton(context),
               title: TextH2(_isEditing ? 'Editar Produto' : 'Novo Produto'),
             ),
             body: const Center(child: CircularProgressIndicator())
           );
        }

        String title = _isEditing ? 'Editar Produto' : 'Novo Produto';
        if (state is ProdutoLoaded) {
          final lojaNome = _getLojaNome(state.lojas);
          final nomeProd = _nomeController.text.trim().isNotEmpty 
              ? _nomeController.text.trim() 
              : (_isEditing ? '...' : 'Novo Produto');
          
          if (lojaNome.isNotEmpty) {
            title = '$nomeProd - $lojaNome';
          } else {
            title = nomeProd;
          }
        }

        return Scaffold(
          appBar: AppBar(
            leading: buildBackButton(context),
            title: TextH2(title, fontWeight: FontWeight.bold),
            centerTitle: false,
            actions: [
              if (!isLoading)
                IconButton(
                  icon: const Icon(Icons.save_outlined),
                  onPressed: _salvar,
                ),
            ],
          ),
          body: isLoading && !_initialDataLoaded
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        if (state is ProdutoLoaded || state is ProdutoOperationLoading || state is ProdutoOperationSuccess) ...[
                          _buildBasicInfoCard(context),
                          const SizedBox(height: 20),
                          _buildCategorizationCard(context),
                          const SizedBox(height: 20),
                          _buildImageCard(context),
                          const SizedBox(height: 20),
                          _buildStatusCard(context),
                          const SizedBox(height: 20),
                          _buildAdditionalInfoCard(context),
                          const SizedBox(height: 20),
                          _buildStockAndPrepCard(context),
                          const SizedBox(height: 32),
                          
                          if (_isEditing)
                            _buildDeleteButton(context, isLoading),
                          
                          const SizedBox(height: 16),
                          
                          QuiButton(
                            label: _isEditing ? 'ATUALIZAR PRODUTO' : 'CRIAR PRODUTO',
                            onPressed: _salvar,
                            isLoading: isLoading,
                          ),
                        ]
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildBasicInfoCard(BuildContext context) {
    return QuiGestorCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context, icon: Icons.fastfood_outlined, title: 'Informações Básicas'),
          const SizedBox(height: 20),
          TextFormField(
            controller: _nomeController,
            decoration: const InputDecoration(labelText: 'Nome do Produto *', prefixIcon: Icon(Icons.fastfood_outlined)),
            validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descricaoController,
            decoration: const InputDecoration(labelText: 'Descrição', prefixIcon: Icon(Icons.description_outlined)),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _precoController,
                  decoration: const InputDecoration(labelText: 'Preço (R\$) *', prefixIcon: Icon(Icons.attach_money)),
                  keyboardType: TextInputType.number,
                  validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _precoPromocionalController,
                  decoration: const InputDecoration(labelText: 'Preço Promocional', prefixIcon: Icon(Icons.attach_money)),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategorizationCard(BuildContext context) {
    // 1. Remove duplicatas e garante que o valor selecionado existe
    final uniqueCategorias = {for (var cat in _categorias) cat.id: cat}.values.toList();
    
    int? effectiveCategoriaId = _categoriaId;
    if (effectiveCategoriaId != null && !uniqueCategorias.any((cat) => cat.id == effectiveCategoriaId)) {
      effectiveCategoriaId = null;
    }

    final uniqueSubcategorias = {for (var sub in _subcategorias) sub.id: sub}.values.toList();
    
    int? effectiveSubcategoriaId = _subcategoriaId;
    if (effectiveSubcategoriaId != null && !uniqueSubcategorias.any((sub) => sub.id == effectiveSubcategoriaId)) {
      effectiveSubcategoriaId = null;
    }

    return QuiGestorCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context, icon: Icons.category_outlined, title: 'Categorização'),
          const SizedBox(height: 20),
          
          if (uniqueCategorias.isNotEmpty)
            DropdownButtonFormField<int?>(
              initialValue: effectiveCategoriaId,
              decoration: const InputDecoration(labelText: 'Categoria *', prefixIcon: Icon(Icons.category_outlined)),
              items: [
                const DropdownMenuItem(value: null, child: TextBody2('Selecione uma categoria')),
                ...uniqueCategorias.map((cat) => DropdownMenuItem(
                  value: cat.id,
                  child: Row(children: [TextBody2(cat.icone ?? ''), const SizedBox(width: 8), TextBody2(cat.nome)]),
                )),
              ],
              onChanged: (id) {
                setState(() {
                  _categoriaId = id;
                  _subcategoriaId = null;
                  _subcategorias = [];
                });
                if (id != null) {
                  _carregarSubcategorias(id);
                }
              },
              validator: (value) => value == null ? 'Selecione uma categoria' : null,
            )
          else 
            const Center(child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            )),

          const SizedBox(height: 16),

          if (_loadingSubcategorias)
            const Center(child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ))
          else if (uniqueSubcategorias.isNotEmpty || _categoriaId != null)
            DropdownButtonFormField<int?>(
              initialValue: effectiveSubcategoriaId,
              decoration: const InputDecoration(labelText: 'Subcategoria', prefixIcon: Icon(Icons.account_tree_outlined)),
              items: [
                const DropdownMenuItem(value: null, child: TextBody2('Sem subcategoria')),
                ...uniqueSubcategorias.map((sub) => DropdownMenuItem(
                  value: sub.id,
                  child: TextBody2(sub.nome),
                )),
              ],
              onChanged: (value) => setState(() => _subcategoriaId = value),
            ),
          
          if (!_loadingSubcategorias && uniqueSubcategorias.isEmpty && _categoriaId != null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: TextBody3(
                'Nenhuma subcategoria disponível',
                color: Colors.grey,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageCard(BuildContext context) {
    return QuiGestorCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context, icon: Icons.image_outlined, title: 'Imagem'),
          const SizedBox(height: 20),
          TextFormField(
            controller: _imagemController,
            decoration: const InputDecoration(labelText: 'URL da Imagem', prefixIcon: Icon(Icons.link)),
            onChanged: (_) => setState(() {}),
          ),
          if (_imagemController.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  _imagemController.text,
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 100,
                    color: Colors.grey[200],
                    child: const Center(child: TextBody2('Imagem inválida')),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    return QuiGestorCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context, icon: Icons.info_outline, title: 'Status e Disponibilidade'),
          const SizedBox(height: 20),
          SwitchListTile(
            title: const TextBody1('Disponível para venda'),
            value: _disponivel,
            onChanged: (value) => setState(() => _disponivel = value),
          ),
          SwitchListTile(
            title: const TextBody1('Produto Ativo'),
            value: _ativo,
            onChanged: (value) => setState(() => _ativo = value),
          ),
          SwitchListTile(
            title: const TextBody1('Produto em Destaque'),
            value: _destaque,
            onChanged: (value) => setState(() => _destaque = value),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfoCard(BuildContext context) {
    return QuiGestorCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context, icon: Icons.health_and_safety_outlined, title: 'Informações Adicionais'),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChip(label: const TextBody3('Contém Glúten'), selected: _contemGluten, onSelected: (v) => setState(() => _contemGluten = v)),
              FilterChip(label: const TextBody3('Contém Lactose'), selected: _contemLactose, onSelected: (v) => setState(() => _contemLactose = v)),
              FilterChip(label: const TextBody3('Vegano'), selected: _vegano, onSelected: (v) => setState(() => _vegano = v)),
              FilterChip(label: const TextBody3('Vegetariano'), selected: _vegetariano, onSelected: (v) => setState(() => _vegetariano = v)),
              FilterChip(label: const TextBody3('Apimentado'), selected: _apimentado, onSelected: (v) => setState(() => _apimentado = v)),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _ingredientesController,
            decoration: const InputDecoration(labelText: 'Ingredientes', prefixIcon: Icon(Icons.food_bank_outlined)),
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildStockAndPrepCard(BuildContext context) {
    return QuiGestorCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context, icon: Icons.inventory_outlined, title: 'Estoque e Preparo'),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _tempoPreparoController,
                  decoration: const InputDecoration(labelText: 'Tempo de preparo (min)', prefixIcon: Icon(Icons.timer_outlined)),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _ordemController,
                  decoration: const InputDecoration(labelText: 'Ordem', prefixIcon: Icon(Icons.sort)),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _estoqueController,
            decoration: const InputDecoration(labelText: 'Estoque', prefixIcon: Icon(Icons.inventory_outlined)),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context, bool isLoading) {
    return Center(
      child: TextButton.icon(
        onPressed: isLoading ? null : _deletar,
        icon: const Icon(Icons.delete_outline, color: Colors.red),
        label: const TextBody2('Excluir produto', color: Colors.red),
        style: TextButton.styleFrom(
          backgroundColor: Colors.red.withOpacity(0.05),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'nome': _nomeController.text,
      'descricao': _descricaoController.text,
      'preco': double.tryParse(_precoController.text.replaceAll(',', '.')) ?? 0,
      'preco_promocional': _precoPromocionalController.text.isNotEmpty 
          ? double.tryParse(_precoPromocionalController.text.replaceAll(',', '.')) 
          : null,
      'imagem': _imagemController.text,
      'loja_id': _lojaId,
      'subcategoria_id': _subcategoriaId,
      'disponivel': _disponivel ? 1 : 0,
      'ativo': _ativo ? 1 : 0,
      'destaque': _destaque ? 1 : 0,
      'tempo_preparo_min': int.tryParse(_tempoPreparoController.text),
      'ordem': int.tryParse(_ordemController.text) ?? 0,
      'ingredientes_texto': _ingredientesController.text,
      'contem_gluten': _contemGluten ? 1 : 0,
      'contem_lactose': _contemLactose ? 1 : 0,
      'vegano': _vegano ? 1 : 0,
      'vegetariano': _vegetariano ? 1 : 0,
      'apimentado': _apimentado ? 1 : 0,
      'estoque': int.tryParse(_estoqueController.text) ?? 0,
    };

    final success = await context.read<ProdutoCubit>().saveProduto(data, id: widget.produtoId);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: TextInverse(
            widget.produtoId != null ? 'Produto atualizado com sucesso' : 'Produto criado com sucesso',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          if (context.canPop()) {
            context.pop(true);
          } else if (_lojaId != null) {
            context.go('/lojas/$_lojaId/produtos');
          } else {
            context.go('/lojas');
          }
        }
      });
    }
  }

  Future<void> _deletar() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const TextH3('Excluir Produto'),
        content: const TextBody2('Tem certeza que deseja excluir este produto? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const TextBody2('CANCELAR')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const TextBody2('EXCLUIR', fontWeight: FontWeight.bold, color: Colors.red),
          ),
        ],
      ),
    );

    if (confirm == true && widget.produtoId != null) {
      final success = await context.read<ProdutoCubit>().deleteProduto(widget.produtoId!);
      if (success && mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: TextInverse('Produto removido com sucesso'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            if (context.canPop()) {
              context.pop(true);
            } else if (_lojaId != null) {
              context.go('/lojas/$_lojaId/produtos');
            } else {
              context.go('/lojas');
            }
          }
        });
      }
    }
  }
}
