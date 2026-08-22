import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../../apparte/widgets/app_text.dart';
import '../../../../apparte/widgets/qui_button.dart';
import '../../../../shared/api/api_client.dart';

class CriarLojaScreen extends StatefulWidget {
  const CriarLojaScreen({super.key});

  @override
  State<CriarLojaScreen> createState() => _CriarLojaScreenState();
}

class _CriarLojaScreenState extends State<CriarLojaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _telefoneController = TextEditingController();
  String? _categoriaSelecionada;
  bool _isLoading = false;

  final List<String> _categorias = [
    'Restaurante',
    'Pizzaria',
    'Hamburgueria',
    'Padaria',
    'Mercado',
    'Outros',
  ];

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _enderecoController.dispose();
    _telefoneController.dispose();
    super.dispose();
  }

  Future<void> _criarLoja() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ApiClient().post('/gestor/lojas', data: {
        'nome': _nomeController.text,
        'descricao': _descricaoController.text,
        'endereco': _enderecoController.text,
        'telefone': _telefoneController.text,
        'categoria': _categoriaSelecionada,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: TextBody2('Loja criada com sucesso!', color: Colors.white)),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        String mensagem = 'Erro ao criar loja';
        if (e is DioException) {
          if (e.response?.statusCode == 422) {
            final errors = e.response?.data['errors'] as Map?;
            if (errors != null) {
              mensagem = errors.values.first?.first ?? mensagem;
            }
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: TextBody2(mensagem, color: Colors.white), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TextH2('Criar Nova Loja', fontWeight: FontWeight.bold),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome da Loja *',
                  prefixIcon: Icon(Icons.store),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Nome obrigatório' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                initialValue: _categoriaSelecionada,
                onChanged: (value) => setState(() => _categoriaSelecionada = value),
                decoration: const InputDecoration(
                  labelText: 'Categoria',
                  prefixIcon: Icon(Icons.category),
                ),
                items: _categorias.map((c) => DropdownMenuItem(value: c, child: TextBody2(c))).toList(),
              ),
              const SizedBox(height: 30),
              QuiButton(
                label: 'Salvar Loja',
                onPressed: _criarLoja,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
