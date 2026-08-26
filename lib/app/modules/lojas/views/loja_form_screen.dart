import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../apparte/widgets/app_text.dart';
import '../../../../apparte/widgets/qui_button.dart';
import '../bloc/lojas_cubit.dart';
import '../bloc/lojas_state.dart';
import '../models/loja.dart';
import '../../../core/constants/icon_constants.dart';
import '../../../routes/app_router.dart';

class LojaFormScreen extends StatefulWidget {
  final int? lojaId;
  final Loja? loja;
  final VoidCallback? onSaved;

  const LojaFormScreen({
    super.key,
    this.lojaId,
    this.loja,
    this.onSaved,
  });

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
  bool _isSaving = false;
  bool _isDeleting = false;
  bool _isLoading = false;

  final List<Map<String, String>> _statusOptions = const [
    {'value': 'ativo', 'label': 'Ativo'},
    {'value': 'inativo', 'label': 'Inativo'},
    {'value': 'fechado', 'label': 'Fechado'},
    {'value': 'revisao', 'label': 'Em revisão'},
  ];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.lojaId != null || widget.loja != null;

    _inicializarControllers();

    // Se tiver loja via widget, preenche os campos
    if (widget.loja != null) {
      _preencherControllers(widget.loja!);
    }

    // Se tiver ID, carrega os dados
    if (widget.lojaId != null && widget.loja == null) {
      _carregarDados(widget.lojaId!);
    }
  }

  void _inicializarControllers() {
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

    _nomeController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  Future<void> _carregarDados(int id) async {
    setState(() => _isLoading = true);

    try {
      final loja = await context.read<LojasCubit>().fetchLojaDetalhada(id);

      if (loja != null && mounted) {
        _preencherControllers(loja);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: TextBody2('Erro ao carregar dados da loja'),
            backgroundColor: Colors.red,
          ),
        );
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
    final id = widget.lojaId ?? widget.loja?.id;

    if (_isEditing && id != null) {
      success = await context.read<LojasCubit>().updateLoja(id, data);
    } else {
      success = await context.read<LojasCubit>().createLoja(data);
    }

    if (success && mounted) {
      // Recarregar a lista
      await context.read<LojasCubit>().fetchLojas(perPage: 10);
      if (widget.onSaved != null) {
        widget.onSaved!();
      } else {
        context.pop(true);
      }
    }

    if (mounted) setState(() => _isSaving = false);
  }

  Future<void> _deletar() async {
    final id = widget.lojaId ?? widget.loja?.id;
    if (id == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const TextH3('Confirmar exclusão'),
        content: TextBody2('Tem certeza que deseja excluir esta loja? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const TextBody2('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: const TextInverse('Excluir', fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isDeleting = true);

    final success = await context.read<LojasCubit>().deleteLoja(id);

    if (success && mounted) {
      // Recarregar a lista
      await context.read<LojasCubit>().fetchLojas(perPage: 10);
      if (widget.onSaved != null) {
        widget.onSaved!();
      } else {
        context.pop(true);
      }
    }

    if (mounted) setState(() => _isDeleting = false);
  }

  // 🔥 CORRIGIDO: Usando GoRouter para navegar para o cardápio
  void _abrirCardapio(BuildContext context) {
    final id = widget.lojaId ?? widget.loja?.id;
    if (id == null) return;

    context.push(Routes.lojaProdutos(id));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    String title = _isEditing ? 'Editar Loja' : 'Nova Loja';
    if (_nomeController.text.isNotEmpty) {
      title = '${_nomeController.text} - Gerenciar Loja';
    }

    return Scaffold(
      appBar: AppBar(
        title: TextH2(title, fontWeight: FontWeight.bold),
        centerTitle: false,
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(AppIcons.fastfood),
              tooltip: 'Gerenciar Cardápio',
              onPressed: _isLoading ? null : () => _abrirCardapio(context),
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
          : BlocConsumer<LojasCubit, LojasState>(
        listener: (context, state) {
          if (state is LojasError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: TextBody2(state.message, color: Colors.white),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is LojaOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: TextBody2(state.message, color: Colors.white),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Card Principal
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(context, AppIcons.store, 'Informações Básicas'),
                        const SizedBox(height: 24),

                        // Nome
                        TextFormField(
                          controller: _nomeController,
                          decoration: _inputDecoration(theme, 'Nome da Loja *', AppIcons.store, isDark),
                          validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
                        ),
                        const SizedBox(height: 16),

                        // Categoria e Telefone
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _categoriaController,
                                decoration: _inputDecoration(theme, 'Categoria *', AppIcons.category, isDark),
                                validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _telefoneController,
                                decoration: _inputDecoration(theme, 'Telefone *', AppIcons.phone, isDark),
                                validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Descrição
                        TextFormField(
                          controller: _descricaoController,
                          decoration: _inputDecoration(theme, 'Descrição', AppIcons.inventory, isDark),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 20),

                        Divider(color: isDark ? Colors.grey[700] : Colors.grey[300]),
                        const SizedBox(height: 16),

                        // Endereço
                        _buildSectionHeader(context, AppIcons.location, 'Endereço'),
                        const SizedBox(height: 24),

                        // CEP
                        TextFormField(
                          controller: _cepController,
                          decoration: _inputDecoration(theme, 'CEP *', AppIcons.location, isDark),
                        ),
                        const SizedBox(height: 16),

                        // Logradouro e Número
                        Row(
                          children: [
                            Expanded(flex: 3, child: TextFormField(
                              controller: _logradouroController,
                              decoration: _inputDecoration(theme, 'Logradouro *', null, isDark),
                            )),
                            const SizedBox(width: 12),
                            Expanded(flex: 1, child: TextFormField(
                              controller: _numeroController,
                              decoration: _inputDecoration(theme, 'Nº *', null, isDark),
                            )),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Complemento e Bairro
                        Row(
                          children: [
                            Expanded(child: TextFormField(
                              controller: _complementoController,
                              decoration: _inputDecoration(theme, 'Complemento', null, isDark),
                            )),
                            const SizedBox(width: 12),
                            Expanded(child: TextFormField(
                              controller: _bairroController,
                              decoration: _inputDecoration(theme, 'Bairro *', null, isDark),
                            )),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Cidade e UF
                        Row(
                          children: [
                            Expanded(flex: 3, child: TextFormField(
                              controller: _cidadeController,
                              decoration: _inputDecoration(theme, 'Cidade *', null, isDark),
                            )),
                            const SizedBox(width: 12),
                            Expanded(child: TextFormField(
                              controller: _ufController,
                              decoration: _inputDecoration(theme, 'UF *', null, isDark),
                              maxLength: 2,
                            )),
                          ],
                        ),
                        const SizedBox(height: 20),

                        Divider(color: isDark ? Colors.grey[700] : Colors.grey[300]),
                        const SizedBox(height: 16),

                        // Entrega e Valores
                        _buildSectionHeader(context, AppIcons.delivery, 'Entrega e Valores'),
                        const SizedBox(height: 24),

                        // Tempo de Entrega
                        Row(
                          children: [
                            Expanded(child: TextFormField(
                              controller: _tempoEntregaMinController,
                              decoration: _inputDecoration(theme, 'Min (min) *', null, isDark),
                              keyboardType: TextInputType.number,
                            )),
                            const SizedBox(width: 12),
                            Expanded(child: TextFormField(
                              controller: _tempoEntregaMaxController,
                              decoration: _inputDecoration(theme, 'Max (min) *', null, isDark),
                              keyboardType: TextInputType.number,
                            )),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Taxa e Pedido Mínimo
                        Row(
                          children: [
                            Expanded(child: TextFormField(
                              controller: _taxaEntregaController,
                              decoration: _inputDecoration(theme, r'Taxa (R$) *', AppIcons.money, isDark),
                              keyboardType: TextInputType.number,
                            )),
                            const SizedBox(width: 12),
                            Expanded(child: TextFormField(
                              controller: _pedidoMinimoController,
                              decoration: _inputDecoration(theme, r'Pedido Mín (R$) *', AppIcons.money, isDark),
                              keyboardType: TextInputType.number,
                            )),
                          ],
                        ),
                        const SizedBox(height: 20),

                        Divider(color: isDark ? Colors.grey[700] : Colors.grey[300]),
                        const SizedBox(height: 16),

                        // Status e Destaque
                        _buildSectionHeader(context, AppIcons.info, 'Status e Destaque'),
                        const SizedBox(height: 24),

                        // Status Dropdown
                        DropdownButtonFormField<String>(
                          value: _status,
                          decoration: _inputDecoration(theme, 'Status *', AppIcons.info, isDark),
                          items: _statusOptions.map((opt) => DropdownMenuItem(
                            value: opt['value'],
                            child: TextBody2(opt['label']!),
                          )).toList(),
                          onChanged: (val) => setState(() => _status = val!),
                          dropdownColor: isDark ? Colors.grey[800] : Colors.white,
                          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                        ),
                        const SizedBox(height: 16),

                        // Verificado Switch
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isDark ? Colors.grey[600]! : Colors.grey[300]!),
                          ),
                          child: SwitchListTile(
                            title: const TextBody1('Verificada', fontWeight: FontWeight.w500),
                            subtitle: TextBody3(
                              'Loja validada',
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                            value: _verificado,
                            onChanged: (val) => setState(() => _verificado = val),
                            activeColor: theme.primaryColor,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Destaque Switch
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isDark ? Colors.grey[600]! : Colors.grey[300]!),
                          ),
                          child: SwitchListTile(
                            title: const TextBody1('Destaque', fontWeight: FontWeight.w500),
                            subtitle: TextBody3(
                              'Página inicial',
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                            value: _destaque,
                            onChanged: (val) => setState(() => _destaque = val),
                            activeColor: theme.primaryColor,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Card de Cardápio (apenas edição)
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
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  AppIcons.fastfood,
                                  color: theme.colorScheme.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const TextH3(
                                      'Produtos / Cardápio',
                                      fontWeight: FontWeight.bold,
                                    ),
                                    TextBody3(
                                      'Gerencie os produtos e itens do cardápio desta loja',
                                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          QuiButton(
                            label: 'Gerenciar Cardápio',
                            onPressed: _isLoading ? null : () => _abrirCardapio(context),
                            icon: AppIcons.fastfood,
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: TextBody3(
                              'Você será redirecionado para a gestão completa do cardápio',
                              color: isDark ? Colors.grey[500] : Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                // Botão Excluir
                if (_isEditing) ...[
                  const SizedBox(height: 24),
                  _buildDeleteButton(isDark),
                ],

                const SizedBox(height: 32),

                // Botão Salvar
                QuiButton(
                  label: _isEditing ? 'ATUALIZAR LOJA' : 'CRIAR LOJA',
                  onPressed: _salvar,
                  isLoading: _isSaving,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  InputDecoration _inputDecoration(ThemeData theme, String label, IconData? icon, bool isDark) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon, size: 20) : null,
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

  Widget _buildSectionHeader(BuildContext context, IconData icon, String title) {
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
        TextH3(title, fontWeight: FontWeight.bold),
      ],
    );
  }

  Widget _buildDeleteButton(bool isDark) {
    return Center(
      child: TextButton.icon(
        onPressed: _isDeleting ? null : _deletar,
        icon: _isDeleting
            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(AppIcons.delete, size: 18, color: Colors.red),
        label: TextBody2(_isDeleting ? 'Excluindo...' : 'Excluir loja', color: Colors.red),
        style: TextButton.styleFrom(
          backgroundColor: Colors.red.withOpacity(isDark ? 0.15 : 0.05),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }
}