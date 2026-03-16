import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/produto_cubit.dart';
import '../bloc/produto_state.dart';
import '../models/produto.dart';
import '../../categorias/models/categoria.dart';
import '../../lojas/models/loja.dart';
import '../../../../apparte/widgets/quigestor_card.dart';
import '../../../../shared/api/api_client.dart';

class ProdutoFormScreen extends StatefulWidget {
  final int? produtoId;
  final int? initialLojaId;

  const ProdutoFormScreen({super.key, this.produtoId, this.initialLojaId});

  @override
  State<ProdutoFormScreen> createState() => _ProdutoFormScreenState();
}

class _ProdutoFormScreenState extends State<ProdutoFormScreen> {
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
    
    // Atualiza o título em tempo real ao digitar o nome
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
    _categoriaId = produto.categoria?.id;
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
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<ProdutoCubit, ProdutoState>(
      listener: (context, state) {
        if (state is ProdutoOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true);
        } else if (state is ProdutoError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        } else if (state is ProdutoLoaded && state.produto != null) {
          _preencherControllers(state.produto!);
        }
      },
      builder: (context, state) {
        final isLoading = state is ProdutoLoading || state is ProdutoOperationLoading;
        
        // Configuração dinâmica do título: nome_produto - nome_loja
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
            title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            centerTitle: false,
            actions: [
              if (!isLoading)
                IconButton(
                  icon: const Icon(Icons.save_outlined),
                  onPressed: _salvar,
                ),
            ],
          ),
          body: isLoading && state is ProdutoLoading
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
                          _buildCategorizationCard(
                            context, 
                            state is ProdutoLoaded ? state.lojas : [], 
                            state is ProdutoLoaded ? state.categorias : []
                          ),
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
                          
                          _buildSubmitButton(theme, isLoading),
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

  Widget _buildCategorizationCard(BuildContext context, List<Loja> lojas, List<Categoria> categorias) {
    final lojaNome = _getLojaNome(lojas);

    return QuiGestorCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context, icon: Icons.category_outlined, title: 'Categorização'),
          const SizedBox(height: 20),
          
          // Campo de Loja apenas leitura (Não editável)
          TextFormField(
            initialValue: lojaNome.isNotEmpty ? lojaNome : 'Carregando...',
            key: ValueKey('loja_$lojaNome'),
            enabled: false,
            decoration: InputDecoration(
              labelText: 'Loja', 
              prefixIcon: const Icon(Icons.store_outlined),
              fillColor: Colors.grey.withOpacity(0.05),
              filled: true,
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          if (categorias.isNotEmpty)
            DropdownButtonFormField<int>(
              value: _categoriaId,
              decoration: const InputDecoration(labelText: 'Categoria', prefixIcon: Icon(Icons.category_outlined)),
              items: categorias.map((cat) => DropdownMenuItem(
                value: cat.id,
                child: Row(children: [Text(cat.icone ?? ''), const SizedBox(width: 8), Text(cat.nome)]),
              )).toList(),
              onChanged: (value) => setState(() => _categoriaId = value),
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
                    child: const Center(child: Text('Imagem inválida')),
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
            title: const Text('Disponível para venda'),
            value: _disponivel,
            onChanged: (value) => setState(() => _disponivel = value),
          ),
          SwitchListTile(
            title: const Text('Produto Ativo'),
            value: _ativo,
            onChanged: (value) => setState(() => _ativo = value),
          ),
          SwitchListTile(
            title: const Text('Produto em Destaque'),
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
              FilterChip(label: const Text('Contém Glúten'), selected: _contemGluten, onSelected: (v) => setState(() => _contemGluten = v)),
              FilterChip(label: const Text('Contém Lactose'), selected: _contemLactose, onSelected: (v) => setState(() => _contemLactose = v)),
              FilterChip(label: const Text('Vegano'), selected: _vegano, onSelected: (v) => setState(() => _vegano = v)),
              FilterChip(label: const Text('Vegetariano'), selected: _vegetariano, onSelected: (v) => setState(() => _vegetariano = v)),
              FilterChip(label: const Text('Apimentado'), selected: _apimentado, onSelected: (v) => setState(() => _apimentado = v)),
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
        label: const Text('Excluir produto', style: TextStyle(color: Colors.red)),
        style: TextButton.styleFrom(
          backgroundColor: Colors.red.withOpacity(0.05),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(ThemeData theme, bool isLoading) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : _salvar,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text(_isEditing ? 'ATUALIZAR PRODUTO' : 'CRIAR PRODUTO', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
      'categoria_id': _categoriaId,
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

    await context.read<ProdutoCubit>().saveProduto(data, id: widget.produtoId);
  }

  Future<void> _deletar() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Produto'),
        content: const Text('Tem certeza que deseja excluir este produto? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCELAR')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('EXCLUIR'),
          ),
        ],
      ),
    );

    if (confirm == true && widget.produtoId != null) {
      await context.read<ProdutoCubit>().deleteProduto(widget.produtoId!);
    }
  }
}
