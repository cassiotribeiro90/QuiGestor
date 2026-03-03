import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../shared/api/api_client.dart';
import '../../../injection.dart';

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
      await getIt<ApiClient>().post('/lojas', data: {
        'nome': _nomeController.text,
        'descricao': _descricaoController.text,
        'endereco': _enderecoController.text,
        'telefone': _telefoneController.text,
        'categoria': _categoriaSelecionada,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Loja criada com sucesso!')),
        );
        Navigator.pop(context, true); // Retorna true para sinalizar atualização
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
          } else if (e.type == DioExceptionType.connectionError) {
            mensagem = 'Sem conexão com internet';
          }
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mensagem), backgroundColor: Colors.red),
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
        title: const Text('Criar Nova Loja'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nomeController,
                enabled: !_isLoading,
                decoration: const InputDecoration(
                  labelText: 'Nome da Loja *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.store),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nome obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _descricaoController,
                enabled: !_isLoading,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _enderecoController,
                enabled: !_isLoading,
                decoration: const InputDecoration(
                  labelText: 'Endereço',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _telefoneController,
                enabled: !_isLoading,
                decoration: const InputDecoration(
                  labelText: 'Telefone',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _categoriaSelecionada,
                onChanged: _isLoading ? null : (value) {
                  setState(() {
                    _categoriaSelecionada = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Categoria',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: _categorias.map((categoria) {
                  return DropdownMenuItem(
                    value: categoria,
                    child: Text(categoria),
                  );
                }).toList(),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _criarLoja,
                  child: _isLoading 
                    ? const SizedBox(
                        height: 20, 
                        width: 20, 
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                      )
                    : const Text('Salvar Loja', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
