import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../apparte/widgets/app_text.dart';
import '../../../../apparte/widgets/qui_button.dart';
import '../bloc/gestores_cubit.dart';
import '../models/gestor.dart';
import '../../../core/constants/icon_constants.dart';

class GestorFormScreen extends StatefulWidget {
  final int? gestorId;
  final Gestor? gestor;
  final VoidCallback? onSaved;

  const GestorFormScreen({
    super.key,
    this.gestorId,
    this.gestor,
    this.onSaved,
  });

  @override
  State<GestorFormScreen> createState() => _GestorFormScreenState();
}

class _GestorFormScreenState extends State<GestorFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _nomeController;
  late TextEditingController _emailController;
  late TextEditingController _cpfController;
  late TextEditingController _telefoneController;
  late TextEditingController _senhaController;

  String _nivel = 'comercial';
  int _status = 1;
  bool _isEditing = false;
  bool _isSaving = false;
  bool _isDeleting = false;
  bool _isLoading = false;

  final List<Map<String, String>> _niveis = const [
    {'value': 'admin', 'label': 'Administrador'},
    {'value': 'comercial', 'label': 'Comercial'},
    {'value': 'suporte', 'label': 'Suporte'},
    {'value': 'financeiro', 'label': 'Financeiro'},
  ];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.gestorId != null || widget.gestor != null;

    _inicializarControllers();

    // Se tiver ID, carregar dados usando fetchGestorDetalhado
    if (widget.gestorId != null) {
      _carregarDados(widget.gestorId!);
    } else if (widget.gestor != null) {
      _preencherControllers(widget.gestor!);
    }
  }

  void _inicializarControllers() {
    _nomeController = TextEditingController();
    _emailController = TextEditingController();
    _cpfController = TextEditingController();
    _telefoneController = TextEditingController();
    _senhaController = TextEditingController();

    _nomeController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  Future<void> _carregarDados(int id) async {
    setState(() => _isLoading = true);

    final gestor = await context.read<GestoresCubit>().fetchGestorDetalhado(id);

    if (gestor != null && mounted) {
      _preencherControllers(gestor);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: TextBody2('Erro ao carregar dados do gestor'),
          backgroundColor: Colors.red,
        ),
      );
    }

    if (mounted) setState(() => _isLoading = false);
  }

  void _preencherControllers(Gestor gestor) {
    _nomeController.text = gestor.nome;
    _emailController.text = gestor.email;
    _cpfController.text = gestor.cpf ?? '';
    _telefoneController.text = gestor.telefone ?? '';
    _nivel = gestor.nivel;
    _status = gestor.status;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _cpfController.dispose();
    _telefoneController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final data = {
      'nome': _nomeController.text.trim(),
      'email': _emailController.text.trim(),
      'nivel': _nivel,
      'status': _status,
      if (_cpfController.text.isNotEmpty) 'cpf': _cpfController.text.trim(),
      if (_telefoneController.text.isNotEmpty) 'telefone': _telefoneController.text.trim(),
    };

    if (_senhaController.text.isNotEmpty) {
      data['senha'] = _senhaController.text;
    }

    bool success;
    final id = widget.gestorId ?? widget.gestor?.id;
    if (_isEditing && id != null) {
      success = await context.read<GestoresCubit>().updateGestor(id, data);
    } else {
      success = await context.read<GestoresCubit>().createGestor(data);
    }

    if (success && mounted) {
      if (widget.onSaved != null) {
        widget.onSaved!();
      } else {
        context.pop(true);
      }
    }

    if (mounted) setState(() => _isSaving = false);
  }

  Future<void> _delete() async {
    final id = widget.gestorId ?? widget.gestor?.id;
    if (id == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const TextH3('Confirmar exclusão'),
        content: TextBody2('Tem certeza que deseja excluir este gestor? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const TextBody2('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const TextBody2('Excluir', fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isDeleting = true);

    final success = await context.read<GestoresCubit>().deleteGestor(id);

    if (success && mounted) {
      if (widget.onSaved != null) {
        widget.onSaved!();
      } else {
        context.pop(true);
      }
    }

    if (mounted) setState(() => _isDeleting = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    String title = _isEditing ? 'Editar Gestor' : 'Novo Gestor';
    if (_nomeController.text.isNotEmpty) {
      title = '${_nomeController.text} - Gerenciar Gestor';
    }

    return Scaffold(
      appBar: AppBar(
        title: TextH2(title, fontWeight: FontWeight.bold),
        centerTitle: false,
        actions: [
          IconButton(
            icon: _isSaving || _isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(AppIcons.check),
            onPressed: _isSaving || _isLoading ? null : _save,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
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
                    _buildSectionHeader(context, AppIcons.person, 'Informações Pessoais'),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _nomeController,
                      decoration: _inputDecoration(theme, 'Nome completo *', AppIcons.person, isDark),
                      validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: _inputDecoration(theme, 'E-mail *', AppIcons.email, isDark),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _cpfController,
                            decoration: _inputDecoration(theme, 'CPF', AppIcons.person, isDark),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _telefoneController,
                            decoration: _inputDecoration(theme, 'Telefone', AppIcons.phone, isDark),
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Divider(color: isDark ? Colors.grey[700] : Colors.grey[300]),
                    const SizedBox(height: 16),
                    _buildSectionHeader(context, AppIcons.admin, 'Segurança e Acesso'),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _senhaController,
                      decoration: _inputDecoration(
                        theme,
                        _isEditing ? 'Nova senha (opcional)' : 'Senha *',
                        AppIcons.settings,
                        isDark,
                        helperText: _isEditing ? 'Mantenha vazio para não alterar' : 'Mínimo 6 caracteres',
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (!_isEditing && (value == null || value.isEmpty)) return 'Campo obrigatório';
                        if (value != null && value.isNotEmpty && value.length < 6) return 'Mínimo 6 caracteres';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      initialValue: _nivel,
                      decoration: _inputDecoration(theme, 'Nível de Acesso *', AppIcons.admin, isDark),
                      items: _niveis.map((nivel) => DropdownMenuItem(
                        value: nivel['value'],
                        child: TextBody2(nivel['label']!),
                      )).toList(),
                      onChanged: (value) => setState(() => _nivel = value!),
                      dropdownColor: isDark ? Colors.grey[800] : Colors.white,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    ),
                    const SizedBox(height: 16),
                    _buildStatusToggle(theme, isDark),
                  ],
                ),
              ),
            ),
            if (_isEditing) ...[
              const SizedBox(height: 24),
              _buildDeleteButton(isDark),
            ],
            const SizedBox(height: 32),
            QuiButton(
              label: _isEditing ? 'ATUALIZAR GESTOR' : 'CRIAR GESTOR',
              onPressed: _save,
              isLoading: _isSaving,
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(ThemeData theme, String label, IconData icon, bool isDark, {String? helperText}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon, size: 20) : null,
      helperText: helperText,
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
      helperStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[600]),
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

  Widget _buildStatusToggle(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.grey[600]! : Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(_status == 1 ? AppIcons.check : AppIcons.close, color: _status == 1 ? Colors.green : Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TextBody1('Gestor Ativo', fontWeight: FontWeight.w500),
                TextBody3('Define se o gestor pode acessar o sistema', color: isDark ? Colors.grey[400] : Colors.grey[600]),
              ],
            ),
          ),
          Switch(value: _status == 1, onChanged: (value) => setState(() => _status = value ? 1 : 0)),
        ],
      ),
    );
  }

  Widget _buildDeleteButton(bool isDark) {
    return Center(
      child: TextButton.icon(
        onPressed: _isDeleting ? null : _delete,
        icon: _isDeleting
            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(AppIcons.delete, size: 18, color: Colors.red),
        label: TextBody2(_isDeleting ? 'Excluindo...' : 'Excluir gestor', color: Colors.red),
        style: TextButton.styleFrom(
          backgroundColor: Colors.red.withOpacity(isDark ? 0.15 : 0.05),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }
}