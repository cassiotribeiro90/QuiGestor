import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/lojista_form_cubit.dart';
import '../bloc/lojista_form_state.dart';
import '../models/lojista_model.dart';
import '../models/loja_option_model.dart';

class LojistaFormPage extends StatefulWidget {
  final int? id;
  const LojistaFormPage({Key? key, this.id}) : super(key: key);

  @override
  State<LojistaFormPage> createState() => _LojistaFormPageState();
}

class _LojistaFormPageState extends State<LojistaFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _cpfCnpjController = TextEditingController();
  final _senhaController = TextEditingController();

  String _funcao = 'vendedor';
  int _status = 1;
  List<int> _lojasSelecionadas = [];
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<LojistaFormCubit>();
    if (widget.id != null) {
      cubit.initEdit(widget.id!);
    } else {
      cubit.initCreate();
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _cpfCnpjController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.id != null ? 'Editar Lojista' : 'Novo Lojista'),
      ),
      body: BlocConsumer<LojistaFormCubit, LojistaFormState>(
        listener: (context, state) {
          if (state is LojistaFormSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Salvo com sucesso!')),
            );
            Navigator.pop(context, true);
          } else if (state is LojistaFormError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is LojistaFormInitial) {
            if (!_initialized && state.lojista != null) {
              _preencherCampos(state.lojista!);
              _initialized = true;
            }
            return _buildForm(context, state);
          }
          if (state is LojistaFormLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _preencherCampos(LojistaModel lojista) {
    _nomeController.text = lojista.nome;
    _emailController.text = lojista.email;
    _telefoneController.text = lojista.telefone ?? '';
    _cpfCnpjController.text = lojista.cpfCnpj ?? '';
    _funcao = lojista.funcao;
    _status = lojista.status;
    _lojasSelecionadas = lojista.lojaIds ?? [];
  }

  Widget _buildForm(BuildContext context, LojistaFormInitial state) {
    final isEdit = widget.id != null;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome *',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Nome obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'E-mail *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v!.isEmpty ? 'E-mail obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _telefoneController,
                decoration: const InputDecoration(
                  labelText: 'Telefone',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cpfCnpjController,
                decoration: const InputDecoration(
                  labelText: 'CPF/CNPJ',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              if (!isEdit)
                TextFormField(
                  controller: _senhaController,
                  decoration: const InputDecoration(
                    labelText: 'Senha',
                    border: OutlineInputBorder(),
                    hintText: 'Deixe em branco para gerar automática',
                  ),
                  obscureText: true,
                ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _funcao,
                decoration: const InputDecoration(
                  labelText: 'Função *',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'proprietario', child: Text('Proprietário')),
                  DropdownMenuItem(value: 'gerente', child: Text('Gerente')),
                  DropdownMenuItem(value: 'vendedor', child: Text('Vendedor')),
                ],
                onChanged: (v) => setState(() => _funcao = v!),
                validator: (v) => v == null ? 'Selecione uma função' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('Ativo')),
                  DropdownMenuItem(value: 0, child: Text('Inativo')),
                ],
                onChanged: (v) => setState(() => _status = v!),
              ),
              const SizedBox(height: 16),
              _buildLojasSelection(state.lojas),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _salvar,
                  child: Text(isEdit ? 'Atualizar' : 'Cadastrar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLojasSelection(List<LojaOptionModel> lojas) {
    if (lojas.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Lojas *', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: lojas.length,
            itemBuilder: (context, index) {
              final loja = lojas[index];
              return CheckboxListTile(
                title: Text(loja.nome),
                value: _lojasSelecionadas.contains(loja.id),
                onChanged: (selected) {
                  setState(() {
                    if (selected == true) {
                      _lojasSelecionadas.add(loja.id);
                    } else {
                      _lojasSelecionadas.remove(loja.id);
                    }
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _salvar() {
    if (!_formKey.currentState!.validate()) return;
    if (_lojasSelecionadas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione pelo menos uma loja')),
      );
      return;
    }

    final dados = {
      'nome': _nomeController.text,
      'email': _emailController.text,
      'telefone': _telefoneController.text,
      'cpf_cnpj': _cpfCnpjController.text,
      'funcao': _funcao,
      'status': _status,
      'loja_ids': _lojasSelecionadas,
    };

    if (widget.id == null && _senhaController.text.isNotEmpty) {
      dados['senha'] = _senhaController.text;
    }

    context.read<LojistaFormCubit>().salvar(
          dados,
          id: widget.id,
        );
  }
}
