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
  late TextEditingController _nomeController;
  late TextEditingController _emailController;
  late TextEditingController _cpfController;
  late TextEditingController _telefoneController;
  late TextEditingController _senhaController;
  
  String _nivel = 'comercial';
  int _status = 1;
  bool _isEditing = false;
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
    _nomeController = TextEditingController(text: widget.gestor?.nome);
    _emailController = TextEditingController(text: widget.gestor?.email);
    _cpfController = TextEditingController(text: widget.gestor?.cpf);
    _telefoneController = TextEditingController(text: widget.gestor?.telefone);
    _senhaController = TextEditingController();
    
    if (_isEditing) {
      _nivel = widget.gestor!.nivel;
      _status = widget.gestor!.status;
    }
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
        Navigator.pop(context, true);
      }
    }
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

    try {
      final success = await context.read<GestoresCubit>().deleteGestor(widget.gestor!.id);
      
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
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return BlocBuilder<GestoresCubit, GestoresState>(
      builder: (context, state) {
        final isLoading = (state is GestoresLoading && state is! GestoresLoaded) || _isDeleting;

        return Scaffold(
          appBar: AppBar(
            title: Text(_isEditing ? 'Editar Gestor' : 'Novo Gestor'),
            centerTitle: false,
            // ✅ Botão de voltar para mobile
            leading: isMobile
                ? IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  )
                : null,
            actions: [
              IconButton(
                icon: isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.save_outlined),
                onPressed: isLoading ? null : _save,
                tooltip: 'Salvar',
              ),
            ],
          ),
          body: Form(
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
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.person_outline,
                                color: theme.colorScheme.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Informações Pessoais',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        TextFormField(
                          controller: _nomeController,
                          decoration: InputDecoration(
                            labelText: 'Nome completo *',
                            prefixIcon: const Icon(Icons.person_outline, size: 20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: theme.colorScheme.surface,
                          ),
                          validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
                          enabled: !isLoading,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'E-mail *',
                            prefixIcon: const Icon(Icons.email_outlined, size: 20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: theme.colorScheme.surface,
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
                          enabled: !isLoading,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _cpfController,
                                decoration: InputDecoration(
                                  labelText: 'CPF',
                                  prefixIcon: const Icon(Icons.badge_outlined, size: 20),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: theme.colorScheme.surface,
                                ),
                                keyboardType: TextInputType.number,
                                enabled: !isLoading,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _telefoneController,
                                decoration: InputDecoration(
                                  labelText: 'Telefone',
                                  prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: theme.colorScheme.surface,
                                ),
                                keyboardType: TextInputType.phone,
                                enabled: !isLoading,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 20),
                        Divider(color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.security_outlined,
                                color: theme.colorScheme.secondary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Segurança e Acesso',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        TextFormField(
                          controller: _senhaController,
                          decoration: InputDecoration(
                            labelText: _isEditing ? 'Nova senha (opcional)' : 'Senha *',
                            prefixIcon: const Icon(Icons.lock_outline, size: 20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: theme.colorScheme.surface,
                            helperText: _isEditing 
                                ? 'Deixe em branco para manter a senha atual'
                                : 'Mínimo 6 caracteres',
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (!_isEditing && (value == null || value.isEmpty)) {
                              return 'Campo obrigatório para novo gestor';
                            }
                            if (value != null && value.isNotEmpty && value.length < 6) {
                              return 'Mínimo 6 caracteres';
                            }
                            return null;
                          },
                          enabled: !isLoading,
                        ),
                        
                        const SizedBox(height: 20),
                        
                        DropdownButtonFormField<String>(
                          value: _nivel,
                          decoration: InputDecoration(
                            labelText: 'Nível de Acesso *',
                            prefixIcon: const Icon(Icons.security_outlined, size: 20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: theme.colorScheme.surface,
                          ),
                          items: _niveis.map((nivel) {
                            return DropdownMenuItem(
                              value: nivel['value'],
                              child: Text(nivel['label']!),
                            );
                          }).toList(),
                          onChanged: isLoading ? null : (value) => setState(() => _nivel = value!),
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
                                _status == 1 ? Icons.check_circle_outline : Icons.cancel_outlined,
                                color: _status == 1 ? Colors.green : Colors.red,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Gestor Ativo',
                                      style: TextStyle(fontWeight: FontWeight.w500),
                                    ),
                                    Text(
                                      'Define se o gestor pode acessar o sistema',
                                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: _status == 1,
                                onChanged: isLoading ? null : (value) => setState(() => _status = value ? 1 : 0),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                if (_isEditing)
                  Center(
                    child: TextButton.icon(
                      onPressed: isLoading ? null : _delete,
                      icon: _isDeleting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                      label: Text(
                        _isDeleting ? 'Excluindo...' : 'Excluir gestor',
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
                
                const SizedBox(height: 32),
                
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _save,
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
                            _isEditing ? 'ATUALIZAR GESTOR' : 'CRIAR GESTOR',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
