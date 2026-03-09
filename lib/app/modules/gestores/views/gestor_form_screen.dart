import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/gestores_cubit.dart';
import '../models/gestor.dart';
import '../../../../apparte/widgets/app_text.dart';

class GestorFormScreen extends StatefulWidget {
  final Gestor? gestor;

  const GestorFormScreen({super.key, this.gestor});

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
      'cpf': _cpfController.text.isNotEmpty ? _cpfController.text.trim() : null,
      'telefone': _telefoneController.text.isNotEmpty ? _telefoneController.text.trim() : null,
      'nivel': _nivel,
      'status': _status,
    };

    // 🔥 SÓ ADICIONA SENHA SE FOI PREENCHIDA
    if (_senhaController.text.isNotEmpty) {
      data['senha'] = _senhaController.text;
    }

    print('📝 [FORM] Dados a enviar: $data');

    bool success;
    if (_isEditing) {
      success = await context.read<GestoresCubit>().updateGestor(widget.gestor!.id, data);
    } else {
      success = await context.read<GestoresCubit>().createGestor(data);
    }

    if (success && mounted) {
      print('📝 [FORM] Operação bem-sucedida, voltando...');
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Gestor' : 'Novo Gestor'),
      ),
      body: BlocBuilder<GestoresCubit, GestoresState>(
        builder: (context, state) {
          final isLoading = state is GestoresLoading;

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                TextFormField(
                  controller: _nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome completo *',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'E-mail *',
                    prefixIcon: Icon(Icons.email_outlined),
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
                        decoration: const InputDecoration(
                          labelText: 'CPF',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                        keyboardType: TextInputType.number,
                        enabled: !isLoading,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _telefoneController,
                        decoration: const InputDecoration(
                          labelText: 'Telefone',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                        keyboardType: TextInputType.phone,
                        enabled: !isLoading,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _senhaController,
                  decoration: InputDecoration(
                    labelText: _isEditing ? 'Nova Senha (deixe em branco para manter)' : 'Senha *',
                    prefixIcon: const Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (!_isEditing && (value == null || value.isEmpty)) {
                      return 'Campo obrigatório para novo gestor';
                    }
                    return null;
                  },
                  enabled: !isLoading,
                ),
                const SizedBox(height: 24),
                const TextBody1('Nível de Acesso', fontWeight: FontWeight.bold),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _nivel,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.security_outlined),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'admin', child: Text('Administrador')),
                    DropdownMenuItem(value: 'comercial', child: Text('Comercial')),
                    DropdownMenuItem(value: 'suporte', child: Text('Suporte')),
                  ],
                  onChanged: isLoading ? null : (value) => setState(() => _nivel = value!),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const TextBody1('Gestor Ativo'),
                  subtitle: const TextCaption('Define se o gestor pode acessar o sistema'),
                  value: _status == 1,
                  onChanged: isLoading ? null : (value) => setState(() => _status = value ? 1 : 0),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(_isEditing ? 'Atualizar Gestor' : 'Criar Gestor'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
