import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../home/views/home_screen.dart';
import '../bloc/lojas_cubit.dart';
import '../models/loja.dart';

class LojaFormScreen extends StatefulWidget {
  final Loja? loja;
  final VoidCallback? onSaved;

  const LojaFormScreen({super.key, this.loja, this.onSaved});

  @override
  State<LojaFormScreen> createState() => _LojaFormScreenState();
}

class _LojaFormScreenState extends State<LojaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  late TextEditingController _nomeController;
  late TextEditingController _descricaoController;
  late TextEditingController _categoriaController;
  late TextEditingController _telefoneController;
  late TextEditingController _whatsappController;
  late TextEditingController _emailController;
  late TextEditingController _instagramController;
  late TextEditingController _cepController;
  late TextEditingController _logradouroController;
  late TextEditingController _numeroController;
  late TextEditingController _complementoController;
  late TextEditingController _bairroController;
  late TextEditingController _cidadeController;
  late TextEditingController _ufController;
  late TextEditingController _tempoEntregaMinController;
  late TextEditingController _tempoEntregaMaxController;
  late TextEditingController _taxaEntregaController;
  late TextEditingController _pedidoMinimoController;

  // Status
  String _status = 'ativo';
  bool _verificado = false;
  bool _destaque = false;
  
  bool _isEditing = false;
  bool _isLoadingData = false;
  bool _isSaving = false;
  bool _isDeleting = false;

  final List<Map<String, String>> _statusOptions = const [
    {'value': 'ativo', 'label': 'Ativo'},
    {'value': 'inativo', 'label': 'Inativo'},
    {'value': 'fechado', 'label': 'Fechado'},
    {'value': 'revisao', 'label': 'Em revisão'},
  ];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.loja != null;

    // ✅ Inicializa controllers VAZIOS (importante!)
    _inicializarControllersVazios();

    if (_isEditing) {
      // ✅ Carrega dados completos do backend
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _carregarDadosCompletos();
      });
    }
  }

  void _inicializarControllersVazios() {
    _nomeController = TextEditingController();
    _descricaoController = TextEditingController();
    _categoriaController = TextEditingController();
    _telefoneController = TextEditingController();
    _whatsappController = TextEditingController();
    _emailController = TextEditingController();
    _instagramController = TextEditingController();
    _cepController = TextEditingController();
    _logradouroController = TextEditingController();
    _numeroController = TextEditingController();
    _complementoController = TextEditingController();
    _bairroController = TextEditingController();
    _cidadeController = TextEditingController();
    _ufController = TextEditingController();
    _tempoEntregaMinController = TextEditingController();
    _tempoEntregaMaxController = TextEditingController();
    _taxaEntregaController = TextEditingController();
    _pedidoMinimoController = TextEditingController();
  }

  Future<void> _carregarDadosCompletos() async {
    setState(() => _isLoadingData = true);
    
    final lojaCompleta = await context.read<LojasCubit>()
        .fetchLojaDetalhada(widget.loja!.id);
    
    if (lojaCompleta != null && mounted) {
      setState(() {
        _preencherControllers(lojaCompleta);
      });
    } else if (mounted) {
      // Fallback: usa os dados da lista
      _preencherControllers(widget.loja!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alguns campos podem estar incompletos'),
          backgroundColor: Colors.orange,
        ),
      );
    }
    
    if (mounted) setState(() => _isLoadingData = false);
  }

  void _preencherControllers(Loja loja) {
    _nomeController.text = loja.nome;
    _descricaoController.text = loja.descricao ?? '';
    _categoriaController.text = loja.categoria;
    _telefoneController.text = loja.telefone ?? '';
    _whatsappController.text = loja.whatsapp ?? '';
    _emailController.text = loja.email ?? '';
    _instagramController.text = loja.instagram ?? '';
    _cepController.text = loja.cep ?? '';
    _logradouroController.text = loja.logradouro ?? '';
    _numeroController.text = loja.numero ?? '';
    _complementoController.text = loja.complemento ?? '';
    _bairroController.text = loja.bairro ?? '';
    _cidadeController.text = loja.cidade;
    _ufController.text = loja.uf;
    _tempoEntregaMinController.text = loja.tempoEntregaMin.toString();
    _tempoEntregaMaxController.text = loja.tempoEntregaMax.toString();
    _taxaEntregaController.text = loja.taxaEntrega.toString();
    _pedidoMinimoController.text = loja.pedidoMinimo.toString();
    _status = loja.status;
    _verificado = loja.verificado;
    _destaque = loja.destaque;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _categoriaController.dispose();
    _telefoneController.dispose();
    _whatsappController.dispose();
    _emailController.dispose();
    _instagramController.dispose();
    _cepController.dispose();
    _logradouroController.dispose();
    _numeroController.dispose();
    _complementoController.dispose();
    _bairroController.dispose();
    _cidadeController.dispose();
    _ufController.dispose();
    _tempoEntregaMinController.dispose();
    _tempoEntregaMaxController.dispose();
    _taxaEntregaController.dispose();
    _pedidoMinimoController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final data = {
      'nome': _nomeController.text.trim(),
      'descricao': _descricaoController.text.isNotEmpty ? _descricaoController.text.trim() : null,
      'categoria': _categoriaController.text.trim(),
      'telefone': _telefoneController.text.trim(),
      'whatsapp': _whatsappController.text.isNotEmpty ? _whatsappController.text.trim() : null,
      'email': _emailController.text.isNotEmpty ? _emailController.text.trim() : null,
      'instagram': _instagramController.text.isNotEmpty ? _instagramController.text.trim() : null,
      'cep': _cepController.text.trim(),
      'logradouro': _logradouroController.text.trim(),
      'numero': _numeroController.text.trim(),
      'complemento': _complementoController.text.isNotEmpty ? _complementoController.text.trim() : null,
      'bairro': _bairroController.text.trim(),
      'cidade': _cidadeController.text.trim(),
      'uf': _ufController.text.trim().toUpperCase(),
      'tempo_entrega_min': int.tryParse(_tempoEntregaMinController.text) ?? 0,
      'tempo_entrega_max': int.tryParse(_tempoEntregaMaxController.text) ?? 0,
      'taxa_entrega': double.tryParse(_taxaEntregaController.text) ?? 0,
      'pedido_minimo': double.tryParse(_pedidoMinimoController.text) ?? 0,
      'status': _status,
      'verificado': _verificado ? 1 : 0,
      'destaque': _destaque ? 1 : 0,
    };

    bool success;
    if (_isEditing) {
      success = await context.read<LojasCubit>().updateLoja(widget.loja!.id, data);
    } else {
      success = await context.read<LojasCubit>().createLoja(data);
    }

    if (success && mounted) {
      if (widget.onSaved != null) {
        widget.onSaved!();
      } else {
        Navigator.pop(context, true);
      }
    }
    
    if (mounted) setState(() => _isSaving = false);
  }

  Future<void> _deletar() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Tem certeza que deseja excluir a loja "${widget.loja!.nome}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isDeleting = true);

    final success = await context.read<LojasCubit>().deleteLoja(widget.loja!.id);
    
    if (success && mounted) {
      if (widget.onSaved != null) {
        widget.onSaved!();
      } else {
        Navigator.pop(context, true);
      }
    }
    
    if (mounted) setState(() => _isDeleting = false);
  }

  void _abrirCardapio(BuildContext context) {
    // ✅ Navegação correta usando o HomeScreenState para manter o menu lateral
    final homeState = context.findAncestorStateOfType<HomeScreenState>();
    if (homeState != null) {
      homeState.openProdutosList(
        lojaId: widget.loja!.id,
        lojaNome: widget.loja!.nome,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Loja' : 'Nova Loja'),
        actions: [
          IconButton(
            icon: _isSaving || _isLoadingData
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.save_outlined),
            onPressed: _isSaving || _isLoadingData ? null : _salvar,
          ),
        ],
      ),
      body: _isLoadingData 
        ? const Center(child: CircularProgressIndicator())
        : Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(context, Icons.store_outlined, 'Informações Básicas'),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _nomeController,
                          decoration: _inputDecoration(theme, 'Nome da Loja *', Icons.store),
                          validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _categoriaController,
                                decoration: _inputDecoration(theme, 'Categoria *', Icons.category_outlined),
                                validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _telefoneController,
                                decoration: _inputDecoration(theme, 'Telefone *', Icons.phone_outlined),
                                validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descricaoController,
                          decoration: _inputDecoration(theme, 'Descrição', Icons.description_outlined),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 20),
                        Divider(color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        _buildSectionHeader(context, Icons.location_on_outlined, 'Endereço'),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _cepController,
                          decoration: _inputDecoration(theme, 'CEP *', Icons.location_on_outlined),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(flex: 3, child: TextFormField(controller: _logradouroController, decoration: _inputDecoration(theme, 'Logradouro *', null))),
                            const SizedBox(width: 12),
                            Expanded(flex: 1, child: TextFormField(controller: _numeroController, decoration: _inputDecoration(theme, 'Nº *', null))),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: TextFormField(controller: _complementoController, decoration: _inputDecoration(theme, 'Complemento', null))),
                            const SizedBox(width: 12),
                            Expanded(child: TextFormField(controller: _bairroController, decoration: _inputDecoration(theme, 'Bairro *', null))),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(flex: 3, child: TextFormField(controller: _cidadeController, decoration: _inputDecoration(theme, 'Cidade *', null))),
                            const SizedBox(width: 12),
                            Expanded(child: TextFormField(controller: _ufController, decoration: _inputDecoration(theme, 'UF *', null))),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Divider(color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        _buildSectionHeader(context, Icons.delivery_dining_outlined, 'Entrega e Valores'),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(child: TextFormField(controller: _tempoEntregaMinController, decoration: _inputDecoration(theme, 'Min (min) *', null), keyboardType: TextInputType.number)),
                            const SizedBox(width: 12),
                            Expanded(child: TextFormField(controller: _tempoEntregaMaxController, decoration: _inputDecoration(theme, 'Max (min) *', null), keyboardType: TextInputType.number)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: TextFormField(controller: _taxaEntregaController, decoration: _inputDecoration(theme, r'Taxa (R$) *', Icons.attach_money), keyboardType: TextInputType.number)),
                            const SizedBox(width: 12),
                            Expanded(child: TextFormField(controller: _pedidoMinimoController, decoration: _inputDecoration(theme, r'Pedido Mín (R$) *', Icons.attach_money), keyboardType: TextInputType.number)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Divider(color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        _buildSectionHeader(context, Icons.info_outline, 'Status e Destaque'),
                        const SizedBox(height: 24),
                        DropdownButtonFormField<String>(
                          value: _status,
                          decoration: _inputDecoration(theme, 'Status *', Icons.circle_outlined),
                          items: _statusOptions.map((opt) => DropdownMenuItem(value: opt['value'], child: Text(opt['label']!))).toList(),
                          onChanged: (val) => setState(() => _status = val!),
                        ),
                        const SizedBox(height: 16),
                        _buildSwitchTile('Verificada', 'Loja validada', _verificado, (val) => setState(() => _verificado = val)),
                        const SizedBox(height: 12),
                        _buildSwitchTile('Destaque', 'Página inicial', _destaque, (val) => setState(() => _destaque = val)),
                      ],
                    ),
                  ),
                ),
                
                // ===== SEÇÃO PRODUTOS/CARDÁPIO =====
                if (_isEditing) ...[
                  const SizedBox(height: 24),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Título da seção
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.restaurant_menu,
                                  color: theme.colorScheme.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Produtos / Cardápio',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Gerencie os produtos e itens do cardápio desta loja',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Botão para acessar cardápio
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => _abrirCardapio(context),
                              icon: const Icon(Icons.restaurant_menu_outlined),
                              label: const Text('Gerenciar Cardápio'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Informação adicional
                          Center(
                            child: Text(
                              'Você será redirecionado para a gestão completa do cardápio',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                if (_isEditing) ...[
                  const SizedBox(height: 24),
                  _buildDeleteButton(),
                ],
                const SizedBox(height: 32),
                _buildSubmitButton(theme),
              ],
            ),
          ),
    );
  }

  InputDecoration _inputDecoration(ThemeData theme, String label, IconData? icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon, size: 20) : null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: theme.colorScheme.surface,
    );
  }

  Widget _buildSectionHeader(BuildContext context, IconData icon, String title) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: theme.colorScheme.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)),
      child: SwitchListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        value: value,
        onChanged: onChanged,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildDeleteButton() {
    return Center(
      child: TextButton.icon(
        onPressed: _isDeleting ? null : _deletar,
        icon: _isDeleting ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.delete_outline, size: 18, color: Colors.red),
        label: Text(_isDeleting ? 'Excluindo...' : 'Excluir loja', style: const TextStyle(color: Colors.red)),
        style: TextButton.styleFrom(backgroundColor: Colors.red.withOpacity(0.05), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
      ),
    );
  }

  Widget _buildSubmitButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isSaving || _isLoadingData ? null : _salvar,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
        ),
        child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : Text(_isEditing ? 'ATUALIZAR LOJA' : 'CRIAR LOJA'),
      ),
    );
  }
}
