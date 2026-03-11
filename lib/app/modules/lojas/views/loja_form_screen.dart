import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/lojas_cubit.dart';
import '../bloc/lojas_state.dart';
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
  bool _isDeleting = false;
  bool _isLoadingData = false;

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

    _nomeController = TextEditingController(text: widget.loja?.nome);
    _descricaoController = TextEditingController(text: widget.loja?.descricao);
    _categoriaController = TextEditingController(text: widget.loja?.categoria);
    _telefoneController = TextEditingController(text: widget.loja?.telefone);
    _whatsappController = TextEditingController(text: widget.loja?.whatsapp);
    _emailController = TextEditingController(text: widget.loja?.email);
    _instagramController = TextEditingController(text: widget.loja?.instagram);
    _cepController = TextEditingController(text: widget.loja?.cep);
    _logradouroController = TextEditingController(text: widget.loja?.logradouro);
    _numeroController = TextEditingController(text: widget.loja?.numero);
    _complementoController = TextEditingController(text: widget.loja?.complemento);
    _bairroController = TextEditingController(text: widget.loja?.bairro);
    _cidadeController = TextEditingController(text: widget.loja?.cidade);
    _ufController = TextEditingController(text: widget.loja?.uf);
    _tempoEntregaMinController = TextEditingController(
      text: widget.loja?.tempoEntregaMin.toString() ?? '',
    );
    _tempoEntregaMaxController = TextEditingController(
      text: widget.loja?.tempoEntregaMax.toString() ?? '',
    );
    _taxaEntregaController = TextEditingController(
      text: widget.loja?.taxaEntrega.toString() ?? '',
    );
    _pedidoMinimoController = TextEditingController(
      text: widget.loja?.pedidoMinimo.toString() ?? '',
    );

    if (_isEditing) {
      _status = widget.loja!.status;
      _verificado = widget.loja!.verificado;
      _destaque = widget.loja!.destaque;
      
      // Carregar dados completos do backend para garantir campos extras
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _carregarDadosCompletos();
      });
    }
  }

  Future<void> _carregarDadosCompletos() async {
    setState(() => _isLoadingData = true);
    
    final lojaCompleta = await context.read<LojasCubit>().fetchLojaDetalhada(widget.loja!.id);
    
    if (lojaCompleta != null && mounted) {
      setState(() {
        _nomeController.text = lojaCompleta.nome;
        _descricaoController.text = lojaCompleta.descricao ?? '';
        _categoriaController.text = lojaCompleta.categoria;
        _telefoneController.text = lojaCompleta.telefone ?? '';
        _whatsappController.text = lojaCompleta.whatsapp ?? '';
        _emailController.text = lojaCompleta.email ?? '';
        _instagramController.text = lojaCompleta.instagram ?? '';
        _cepController.text = lojaCompleta.cep ?? '';
        _logradouroController.text = lojaCompleta.logradouro ?? '';
        _numeroController.text = lojaCompleta.numero ?? '';
        _complementoController.text = lojaCompleta.complemento ?? '';
        _bairroController.text = lojaCompleta.bairro ?? '';
        _cidadeController.text = lojaCompleta.cidade;
        _ufController.text = lojaCompleta.uf;
        _tempoEntregaMinController.text = lojaCompleta.tempoEntregaMin.toString();
        _tempoEntregaMaxController.text = lojaCompleta.tempoEntregaMax.toString();
        _taxaEntregaController.text = lojaCompleta.taxaEntrega.toString();
        _pedidoMinimoController.text = lojaCompleta.pedidoMinimo.toString();
        _status = lojaCompleta.status;
        _verificado = lojaCompleta.verificado;
        _destaque = lojaCompleta.destaque;
      });
    }
    
    if (mounted) {
      setState(() => _isLoadingData = false);
    }
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
  }

  Future<void> _deletar() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Tem certeza que deseja excluir a loja "${widget.loja!.nome}"? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isDeleting = true);

    try {
      final success = await context.read<LojasCubit>().deleteLoja(widget.loja!.id);
      
      if (success && mounted) {
        if (widget.onSaved != null) {
          widget.onSaved!();
        } else {
          Navigator.pop(context, true);
        }
      }
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<LojasCubit, LojasState>(
      builder: (context, state) {
        final isLoading = state is LojaOperationLoading || _isDeleting;

        return Scaffold(
          appBar: AppBar(
            title: Text(_isEditing ? 'Editar Loja' : 'Nova Loja'),
            centerTitle: false,
            actions: [
              IconButton(
                icon: isLoading || _isLoadingData
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.save_outlined),
                onPressed: isLoading || _isLoadingData ? null : _salvar,
                tooltip: 'Salvar Loja',
              ),
            ],
          ),
          body: _isLoadingData 
            ? const Center(child: CircularProgressIndicator())
            : Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
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
                          _buildSectionHeader(
                            context,
                            icon: Icons.store_outlined,
                            title: 'Informações Básicas',
                          ),
                          const SizedBox(height: 24),

                          TextFormField(
                            controller: _nomeController,
                            decoration: InputDecoration(
                              labelText: 'Nome da Loja *',
                              prefixIcon: const Icon(Icons.store, size: 20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: theme.colorScheme.surface,
                            ),
                            validator: (value) => value == null || value.isEmpty
                                ? 'Campo obrigatório'
                                : null,
                            enabled: !isLoading,
                          ),

                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _categoriaController,
                                  decoration: InputDecoration(
                                    labelText: 'Categoria *',
                                    prefixIcon: const Icon(Icons.category_outlined, size: 20),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: theme.colorScheme.surface,
                                  ),
                                  validator: (value) => value == null || value.isEmpty
                                      ? 'Campo obrigatório'
                                      : null,
                                  enabled: !isLoading,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _telefoneController,
                                  decoration: InputDecoration(
                                    labelText: 'Telefone *',
                                    prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: theme.colorScheme.surface,
                                  ),
                                  validator: (value) => value == null || value.isEmpty
                                      ? 'Campo obrigatório'
                                      : null,
                                  enabled: !isLoading,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _descricaoController,
                            decoration: InputDecoration(
                              labelText: 'Descrição',
                              prefixIcon: const Icon(Icons.description_outlined, size: 20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: theme.colorScheme.surface,
                            ),
                            maxLines: 3,
                            enabled: !isLoading,
                          ),

                          const SizedBox(height: 20),
                          Divider(color: Colors.grey[300]),
                          const SizedBox(height: 16),

                          _buildSectionHeader(
                            context,
                            icon: Icons.location_on_outlined,
                            title: 'Endereço',
                          ),
                          const SizedBox(height: 24),

                          TextFormField(
                            controller: _cepController,
                            decoration: InputDecoration(
                              labelText: 'CEP *',
                              prefixIcon: const Icon(Icons.location_on_outlined, size: 20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: theme.colorScheme.surface,
                            ),
                            enabled: !isLoading,
                          ),

                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: TextFormField(
                                  controller: _logradouroController,
                                  decoration: InputDecoration(
                                    labelText: 'Logradouro *',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: theme.colorScheme.surface,
                                  ),
                                  enabled: !isLoading,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 1,
                                child: TextFormField(
                                  controller: _numeroController,
                                  decoration: InputDecoration(
                                    labelText: 'Número *',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: theme.colorScheme.surface,
                                  ),
                                  enabled: !isLoading,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _complementoController,
                                  decoration: InputDecoration(
                                    labelText: 'Complemento',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: theme.colorScheme.surface,
                                  ),
                                  enabled: !isLoading,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _bairroController,
                                  decoration: InputDecoration(
                                    labelText: 'Bairro *',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: theme.colorScheme.surface,
                                  ),
                                  enabled: !isLoading,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: TextFormField(
                                  controller: _cidadeController,
                                  decoration: InputDecoration(
                                    labelText: 'Cidade *',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: theme.colorScheme.surface,
                                  ),
                                  validator: (value) => value == null || value.isEmpty
                                      ? 'Campo obrigatório'
                                      : null,
                                  enabled: !isLoading,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _ufController,
                                  decoration: InputDecoration(
                                    labelText: 'UF *',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: theme.colorScheme.surface,
                                  ),
                                  validator: (value) => value == null || value.isEmpty
                                      ? 'Campo obrigatório'
                                      : null,
                                  enabled: !isLoading,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),
                          Divider(color: Colors.grey[300]),
                          const SizedBox(height: 16),

                          _buildSectionHeader(
                            context,
                            icon: Icons.delivery_dining_outlined,
                            title: 'Entrega e Valores',
                          ),
                          const SizedBox(height: 24),

                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _tempoEntregaMinController,
                                  decoration: InputDecoration(
                                    labelText: 'Tempo mínimo (min) *',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: theme.colorScheme.surface,
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) => value == null || value.isEmpty
                                      ? 'Campo obrigatório'
                                      : null,
                                  enabled: !isLoading,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _tempoEntregaMaxController,
                                  decoration: InputDecoration(
                                    labelText: 'Tempo máximo (min) *',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: theme.colorScheme.surface,
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) => value == null || value.isEmpty
                                      ? 'Campo obrigatório'
                                      : null,
                                  enabled: !isLoading,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _taxaEntregaController,
                                  decoration: InputDecoration(
                                    labelText: r'Taxa de entrega (R\$) *',
                                    prefixIcon: const Icon(Icons.attach_money, size: 20),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: theme.colorScheme.surface,
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) => value == null || value.isEmpty
                                      ? 'Campo obrigatório'
                                      : null,
                                  enabled: !isLoading,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _pedidoMinimoController,
                                  decoration: InputDecoration(
                                    labelText: r'Pedido mínimo (R\$) *',
                                    prefixIcon: const Icon(Icons.attach_money, size: 20),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: theme.colorScheme.surface,
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) => value == null || value.isEmpty
                                      ? 'Campo obrigatório'
                                      : null,
                                  enabled: !isLoading,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),
                          Divider(color: Colors.grey[300]),
                          const SizedBox(height: 16),

                          _buildSectionHeader(
                            context,
                            icon: Icons.alternate_email_outlined,
                            title: 'Contato Online',
                          ),
                          const SizedBox(height: 24),

                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _emailController,
                                  decoration: InputDecoration(
                                    labelText: 'E-mail',
                                    prefixIcon: const Icon(Icons.email_outlined, size: 20),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: theme.colorScheme.surface,
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  enabled: !isLoading,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _instagramController,
                                  decoration: InputDecoration(
                                    labelText: 'Instagram',
                                    prefixIcon: const Icon(Icons.camera_alt_outlined, size: 20),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: theme.colorScheme.surface,
                                  ),
                                  enabled: !isLoading,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _whatsappController,
                            decoration: InputDecoration(
                              labelText: 'WhatsApp',
                              prefixIcon: const Icon(Icons.chat, size: 20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: theme.colorScheme.surface,
                            ),
                            enabled: !isLoading,
                          ),

                          const SizedBox(height: 20),
                          Divider(color: Colors.grey[300]),
                          const SizedBox(height: 16),

                          _buildSectionHeader(
                            context,
                            icon: Icons.info_outline,
                            title: 'Status e Configurações',
                          ),
                          const SizedBox(height: 24),

                          DropdownButtonFormField<String>(
                            value: _status,
                            decoration: InputDecoration(
                              labelText: 'Status *',
                              prefixIcon: const Icon(Icons.circle_outlined, size: 20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: theme.colorScheme.surface,
                            ),
                            items: _statusOptions.map((option) {
                              return DropdownMenuItem(
                                value: option['value'],
                                child: Text(option['label']!),
                              );
                            }).toList(),
                            onChanged: isLoading ? null : (value) {
                              setState(() => _status = value!);
                            },
                          ),

                          const SizedBox(height: 16),

                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _verificado ? Icons.verified : Icons.verified_outlined,
                                  color: _verificado ? Colors.blue : Colors.grey,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Loja Verificada',
                                        style: TextStyle(fontWeight: FontWeight.w500),
                                      ),
                                      Text(
                                        'Indica que a loja passou por validação',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: _verificado,
                                  onChanged: isLoading ? null : (value) {
                                    setState(() => _verificado = value);
                                  },
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _destaque ? Icons.star : Icons.star_outline,
                                  color: _destaque ? Colors.amber : Colors.grey,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Loja em Destaque',
                                        style: TextStyle(fontWeight: FontWeight.w500),
                                      ),
                                      Text(
                                        'Aparece na página inicial',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: _destaque,
                                  onChanged: isLoading ? null : (value) {
                                    setState(() => _destaque = value);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _salvar,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(
                              _isEditing ? 'ATUALIZAR LOJA' : 'CRIAR LOJA',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                    ),
                  ),
                  if (_isEditing) ...[
                    const SizedBox(height: 24),
                    Center(
                      child: TextButton.icon(
                        onPressed: isLoading ? null : _deletar,
                        icon: _isDeleting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                        label: Text(
                          _isDeleting ? 'Excluindo...' : 'Excluir loja',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.red.withOpacity(0.05),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
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
      },
    );
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
          child: Icon(
            icon,
            color: theme.colorScheme.primary,
            size: 20,
          ),
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
}
