// lib/app/modules/clientes/views/cliente_form_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../apparte/widgets/app_text.dart';
import '../../../../apparte/widgets/qui_button.dart';
import '../../../core/constants/icon_constants.dart';
import '../../../core/widgets/back_button_mixin.dart';
import '../bloc/clientes_cubit.dart';
import '../models/cliente.dart';
import '../../../../shared/api/api_client.dart';

class ClienteFormScreen extends StatefulWidget {
  final int clienteId;

  const ClienteFormScreen({super.key, required this.clienteId});

  @override
  State<ClienteFormScreen> createState() => _ClienteFormScreenState();
}

class _ClienteFormScreenState extends State<ClienteFormScreen> with BackButtonMixin {
  final _formKey = GlobalKey<FormState>();
  late final ApiClient _apiClient;
  Cliente? _cliente;
  bool _isLoading = true;
  bool _isSaving = false;

  // Controllers
  late TextEditingController _nomeController;
  late TextEditingController _emailController;
  late TextEditingController _telefoneController;
  late TextEditingController _whatsappController;
  late TextEditingController _cpfController;
  late TextEditingController _dataNascimentoController;
  String _status = 'ativo';
  String _tipo = 'cliente';
  bool _prefEmail = true;
  bool _prefPush = true;
  bool _prefSms = true;
  String _prefTema = 'auto';
  int _pontos = 0;
  int _nivel = 1;

  final List<Map<String, String>> _statusOptions = const [
    {'value': 'ativo', 'label': 'Ativo'},
    {'value': 'inativo', 'label': 'Inativo'},
    {'value': 'bloqueado', 'label': 'Bloqueado'},
    {'value': 'pendente', 'label': 'Pendente'},
    {'value': 'convidado', 'label': 'Convidado'},
  ];

  final List<Map<String, String>> _temaOptions = const [
    {'value': 'claro', 'label': 'Claro'},
    {'value': 'escuro', 'label': 'Escuro'},
    {'value': 'auto', 'label': 'Automático'},
  ];

  @override
  void initState() {
    super.initState();
    _apiClient = context.read<ApiClient>();
    _nomeController = TextEditingController();
    _emailController = TextEditingController();
    _telefoneController = TextEditingController();
    _whatsappController = TextEditingController();
    _cpfController = TextEditingController();
    _dataNascimentoController = TextEditingController();
    _carregarCliente();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _whatsappController.dispose();
    _cpfController.dispose();
    _dataNascimentoController.dispose();
    super.dispose();
  }

  Future<void> _carregarCliente() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiClient.get('/gestor/clientes/${widget.clienteId}');
      if (response.data['success'] == true) {
        final data = response.data['data'];
        _cliente = Cliente.fromJson(data);
        _preencherCampos(_cliente!);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: TextBody2(response.data['message'] ?? 'Erro ao carregar cliente'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: TextBody2('Erro de conexão: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _preencherCampos(Cliente cliente) {
    _nomeController.text = cliente.nome;
    _emailController.text = cliente.email ?? '';
    _telefoneController.text = cliente.telefone ?? '';
    _whatsappController.text = cliente.whatsapp ?? '';
    _cpfController.text = cliente.cpf ?? '';
    _dataNascimentoController.text = cliente.dataNascimento ?? '';
    _status = cliente.status;
    _tipo = cliente.tipo;
    _prefEmail = cliente.prefNotificacoesEmail;
    _prefPush = cliente.prefNotificacoesPush;
    _prefSms = cliente.prefNotificacoesSms;
    _prefTema = cliente.prefTema;
    _pontos = cliente.pontos;
    _nivel = cliente.nivel;
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final data = {
      'nome': _nomeController.text.trim(),
      'email': _emailController.text.trim(),
      'telefone': _telefoneController.text.trim(),
      'whatsapp': _whatsappController.text.trim(),
      'cpf': _cpfController.text.trim(),
      'data_nascimento': _dataNascimentoController.text.trim(),
      'status': _status,
      'tipo': _tipo,
      'pref_notificacoes_email': _prefEmail ? 1 : 0,
      'pref_notificacoes_push': _prefPush ? 1 : 0,
      'pref_notificacoes_sms': _prefSms ? 1 : 0,
      'pref_tema': _prefTema,
      'pontos': _pontos,
      'nivel': _nivel,
    };

    try {
      final response = await _apiClient.put('/gestor/clientes/update/${widget.clienteId}', data: data);
      if (response.data['success'] == true) {
        if (mounted) {
          context.read<ClientesCubit>().refresh();
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: TextBody2('Cliente atualizado com sucesso', color: Colors.white),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/clientes');
              }
            }
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: TextBody2(response.data['message'] ?? 'Erro ao atualizar cliente'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: TextBody2('Erro de conexão: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    String title = _cliente != null ? 'Editar Cliente - ${_cliente!.nome}' : 'Carregando...';

    return Scaffold(
      appBar: AppBar(
        leading: buildBackButton(context),
        title: TextH2(title, fontWeight: FontWeight.bold),
        centerTitle: false,
        actions: [
          IconButton(
            icon: _isSaving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(AppIcons.check),
            onPressed: _isSaving || _isLoading ? null : _salvar,
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
                    // Dados Pessoais
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader(context, Icons.person_outline, 'Dados Pessoais'),
                            const SizedBox(height: 24),
                            TextFormField(
                              controller: _nomeController,
                              decoration: _inputDecoration(theme, 'Nome *', Icons.person_outline, isDark),
                              validator: (v) => v == null || v.isEmpty ? 'Campo obrigatório' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _emailController,
                              decoration: _inputDecoration(theme, 'E-mail', Icons.email_outlined, isDark),
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _telefoneController,
                                    decoration: _inputDecoration(theme, 'Telefone', Icons.phone_outlined, isDark),
                                    keyboardType: TextInputType.phone,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: _whatsappController,
                                    decoration: _inputDecoration(theme, 'WhatsApp', Icons.phone, isDark),
                                    keyboardType: TextInputType.phone,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _cpfController,
                                    decoration: _inputDecoration(theme, 'CPF', Icons.badge_outlined, isDark),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: _dataNascimentoController,
                                    decoration: _inputDecoration(theme, 'Data Nascimento', Icons.calendar_today_outlined, isDark),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Status e Configurações
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader(context, Icons.settings_outlined, 'Status e Configurações'),
                            const SizedBox(height: 24),
                            DropdownButtonFormField<String>(
                              value: _status,
                              decoration: _inputDecoration(theme, 'Status *', Icons.circle_outlined, isDark),
                              items: _statusOptions.map((opt) => DropdownMenuItem(
                                value: opt['value'],
                                child: TextBody2(opt['label']!),
                              )).toList(),
                              onChanged: (v) => setState(() => _status = v!),
                              dropdownColor: isDark ? Colors.grey[800] : Colors.white,
                              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: _prefTema,
                              decoration: _inputDecoration(theme, 'Tema Preferido', Icons.brightness_medium_outlined, isDark),
                              items: _temaOptions.map((opt) => DropdownMenuItem(
                                value: opt['value'],
                                child: TextBody2(opt['label']!),
                              )).toList(),
                              onChanged: (v) => setState(() => _prefTema = v!),
                              dropdownColor: isDark ? Colors.grey[800] : Colors.white,
                              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                            ),
                            const SizedBox(height: 20),
                            _buildSwitchTile('Notificações por E-mail', _prefEmail, (v) => setState(() => _prefEmail = v), isDark),
                            _buildSwitchTile('Notificações Push', _prefPush, (v) => setState(() => _prefPush = v), isDark),
                            _buildSwitchTile('Notificações por SMS', _prefSms, (v) => setState(() => _prefSms = v), isDark),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Pontos e Nível
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader(context, Icons.star_outline, 'Fidelidade'),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    initialValue: _pontos.toString(),
                                    decoration: _inputDecoration(theme, 'Pontos', Icons.star_outline, isDark),
                                    keyboardType: TextInputType.number,
                                    onChanged: (v) => _pontos = int.tryParse(v) ?? 0,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    initialValue: _nivel.toString(),
                                    decoration: _inputDecoration(theme, 'Nível', Icons.trending_up_outlined, isDark),
                                    keyboardType: TextInputType.number,
                                    onChanged: (v) => _nivel = int.tryParse(v) ?? 1,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    QuiButton(
                      label: 'ATUALIZAR CLIENTE',
                      onPressed: _salvar,
                      isLoading: _isSaving,
                    ),
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

  Widget _buildSwitchTile(String title, bool value, ValueChanged<bool> onChanged, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.grey[600]! : Colors.grey[300]!),
      ),
      child: SwitchListTile(
        title: TextBody1(title, fontWeight: FontWeight.w500),
        value: value,
        onChanged: onChanged,
        activeColor: Theme.of(context).primaryColor,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}
