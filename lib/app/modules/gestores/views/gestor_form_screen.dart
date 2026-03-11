import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/gestores_cubit.dart';
import '../models/gestor.dart';

class GestorFormScreen extends StatefulWidget {
  final Gestor? gestor;
  final VoidCallback? onSaved;

  const GestorFormScreen({super.key, this.gestor, this.onSaved});

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
  bool _isLoadingData = false;
  bool _isSaving = false;
  bool _isDeleting = false;

  final List<Map<String, String>> _niveis = const [
    {'value': 'admin', 'label': 'Administrador'},
    {'value': 'comercial', 'label': 'Comercial'},
    {'value': 'suporte', 'label': 'Suporte'},
    {'value': 'financeiro', 'label': 'Financeiro'},
  ];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.gestor != null;
    
    // ✅ Inicializa controllers VAZIOS (conforme roteiro)
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
    _emailController = TextEditingController();
    _cpfController = TextEditingController();
    _telefoneController = TextEditingController();
    _senhaController = TextEditingController();
  }

  Future<void> _carregarDadosCompletos() async {
    setState(() => _isLoadingData = true);
    
    final gestorCompleto = await context.read<GestoresCubit>()
        .fetchGestorDetalhado(widget.gestor!.id);
    
    if (gestorCompleto != null && mounted) {
      setState(() {
        _preencherControllers(gestorCompleto);
      });
    } else if (mounted) {
      // Fallback: usa os dados da lista se falhar
      _preencherControllers(widget.gestor!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alguns campos podem estar incompletos'),
          backgroundColor: Colors.orange,
        ),
      );
    }
    
    if (mounted) setState(() => _isLoadingData = false);
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
    if (_isEditing) {
      success = await context.read<GestoresCubit>().updateGestor(widget.gestor!.id, data);
    } else {
      success = await context.read<GestoresCubit>().createGestor(data);
    }

    if (success && mounted) {
      if (widget.onSaved != null) {
        widget.onSaved!();
      } else {
        Navigator.pop(context, true); // ✅ Retorna true
      }
    }
    
    if (mounted) setState(() => _isSaving = false);
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Tem certeza que deseja excluir ${widget.gestor!.nome}? Esta ação não pode ser desfeita.'),
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

    final success = await context.read<GestoresCubit>().deleteGestor(widget.gestor!.id);
    
    if (success && mounted) {
      if (widget.onSaved != null) {
        widget.onSaved!();
      } else {
        Navigator.pop(context, true); // ✅ Retorna true
      }
    }
    
    if (mounted) setState(() => _isDeleting = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Gestor' : 'Novo Gestor'),
        actions: [
          IconButton(
            icon: _isSaving || _isLoadingData
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.save_outlined),
            onPressed: _isSaving || _isLoadingData ? null : _save,
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(context, Icons.person_outline, 'Informações Pessoais'),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _nomeController,
                          decoration: _inputDecoration(theme, 'Nome completo *', Icons.person_outline),
                          validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          decoration: _inputDecoration(theme, 'E-mail *', Icons.email_outlined),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _cpfController,
                                decoration: _inputDecoration(theme, 'CPF', Icons.badge_outlined),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _telefoneController,
                                decoration: _inputDecoration(theme, 'Telefone', Icons.phone_outlined),
                                keyboardType: TextInputType.phone,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Divider(color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        _buildSectionHeader(context, Icons.security_outlined, 'Segurança e Acesso'),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _senhaController,
                          decoration: _inputDecoration(
                            theme, 
                            _isEditing ? 'Nova senha (opcional)' : 'Senha *', 
                            Icons.lock_outline,
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
                          value: _nivel,
                          decoration: _inputDecoration(theme, 'Nível de Acesso *', Icons.security_outlined),
                          items: _niveis.map((nivel) => DropdownMenuItem(value: nivel['value'], child: Text(nivel['label']!))).toList(),
                          onChanged: (value) => setState(() => _nivel = value!),
                        ),
                        const SizedBox(height: 16),
                        _buildStatusToggle(theme),
                      ],
                    ),
                  ),
                ),
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

  InputDecoration _inputDecoration(ThemeData theme, String label, IconData icon, {String? helperText}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20),
      helperText: helperText,
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

  Widget _buildStatusToggle(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(_status == 1 ? Icons.check_circle_outline : Icons.cancel_outlined, color: _status == 1 ? Colors.green : Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Gestor Ativo', style: TextStyle(fontWeight: FontWeight.w500)),
                Text('Define se o gestor pode acessar o sistema', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
          Switch(value: _status == 1, onChanged: (value) => setState(() => _status = value ? 1 : 0)),
        ],
      ),
    );
  }

  Widget _buildDeleteButton() {
    return Center(
      child: TextButton.icon(
        onPressed: _isDeleting ? null : _delete,
        icon: _isDeleting ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.delete_outline, size: 18, color: Colors.red),
        label: Text(_isDeleting ? 'Excluindo...' : 'Excluir gestor', style: const TextStyle(color: Colors.red)),
        style: TextButton.styleFrom(backgroundColor: Colors.red.withOpacity(0.05), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
      ),
    );
  }

  Widget _buildSubmitButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isSaving || _isLoadingData ? null : _save,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
        ),
        child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : Text(_isEditing ? 'ATUALIZAR GESTOR' : 'CRIAR GESTOR'),
      ),
    );
  }
}
