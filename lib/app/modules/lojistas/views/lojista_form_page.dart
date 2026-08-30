import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/back_button_mixin.dart';
import '../bloc/lojista_form_cubit.dart';
import '../bloc/lojista_form_state.dart';
import '../models/lojista_model.dart';
import '../models/loja_option_model.dart';

class LojistaFormPage extends StatefulWidget {
  final int? id;
  const LojistaFormPage({super.key, this.id});

  @override
  State<LojistaFormPage> createState() => _LojistaFormPageState();
}

class _LojistaFormPageState extends State<LojistaFormPage> with BackButtonMixin {
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: buildBackButton(context),
        title: Text(widget.id != null ? 'Editar Lojista' : 'Novo Lojista'),
      ),
      body: BlocConsumer<LojistaFormCubit, LojistaFormState>(
        listener: (context, state) {
          if (state is LojistaFormSuccess) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Salvo com sucesso!',
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
            
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                if (context.canPop()) {
                  Navigator.pop(context, true);
                } else {
                  context.go('/lojistas');
                }
              }
            });
          } else if (state is LojistaFormError) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                ),
                backgroundColor: Colors.red,
              ),
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
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _salvar,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 52),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          child: Text(widget.id != null ? 'Atualizar' : 'Cadastrar'),
        ),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEdit = widget.id != null;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nomeController,
              decoration: _inputDecoration(
                context,
                label: 'Nome *',
                icon: Icons.person_outline,
              ),
              textCapitalization: TextCapitalization.words,
              validator: (v) => v!.trim().isEmpty ? 'Nome obrigatório' : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _emailController,
              decoration: _inputDecoration(
                context,
                label: 'E-mail *',
                icon: Icons.email_outlined,
              ),
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              validator: (v) {
                if (v!.trim().isEmpty) return 'E-mail obrigatório';
                if (!v.contains('@')) return 'E-mail inválido';
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _telefoneController,
              decoration: _inputDecoration(
                context,
                label: 'Telefone',
                icon: Icons.phone_outlined,
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _cpfCnpjController,
              decoration: _inputDecoration(
                context,
                label: 'CPF/CNPJ',
                icon: Icons.badge_outlined,
              ),
            ),
            const SizedBox(height: 16),

            if (!isEdit)
              TextFormField(
                controller: _senhaController,
                decoration: _inputDecoration(
                  context,
                  label: 'Senha',
                  icon: Icons.lock_outline,
                  hint: 'Deixe em branco para gerar automática',
                ),
                obscureText: true,
              ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              initialValue: _funcao,
              decoration: _inputDecoration(
                context,
                label: 'Função *',
                icon: Icons.work_outline,
              ),
              items: const [
                DropdownMenuItem(value: 'proprietario', child: Text('Proprietário')),
                DropdownMenuItem(value: 'gerente', child: Text('Gerente')),
                DropdownMenuItem(value: 'vendedor', child: Text('Vendedor')),
              ],
              onChanged: (v) => setState(() => _funcao = v!),
              validator: (v) => v == null ? 'Selecione uma função' : null,
              dropdownColor: isDark ? Colors.grey[800] : Colors.white,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<int>(
              initialValue: _status,
              decoration: _inputDecoration(
                context,
                label: 'Status',
                icon: Icons.circle_outlined,
              ),
              items: const [
                DropdownMenuItem(value: 1, child: Text('Ativo')),
                DropdownMenuItem(value: 0, child: Text('Inativo')),
              ],
              onChanged: (v) => setState(() => _status = v!),
              dropdownColor: isDark ? Colors.grey[800] : Colors.white,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // Seleção de lojas via modal
            _buildLojasField(context, state.lojas),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
      BuildContext context, {
        required String label,
        IconData? icon,
        String? hint,
      }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon, size: 20) : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: isDark ? Colors.grey[600]! : Colors.grey.shade300,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: theme.primaryColor,
          width: 2,
        ),
      ),
      filled: true,
      fillColor: isDark ? Colors.grey[800] : Colors.grey.shade50,
      labelStyle: TextStyle(
        color: isDark ? Colors.grey[400] : Colors.grey[700],
      ),
      hintStyle: TextStyle(
        color: isDark ? Colors.grey[500] : Colors.grey[500],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }

  Widget _buildLojasField(BuildContext context, List<LojaOptionModel> lojas) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final selecionadas = lojas.where((l) => _lojasSelecionadas.contains(l.id)).toList();

    return InkWell(
      onTap: () => _abrirModalLojas(context, lojas),
      borderRadius: BorderRadius.circular(10),
      child: InputDecorator(
        decoration: _inputDecoration(
          context,
          label: 'Lojas *',
          icon: Icons.store_outlined,
        ),
        child: Row(
          children: [
            Expanded(
              child: selecionadas.isEmpty
                  ? Text(
                'Selecione as lojas',
                style: TextStyle(
                  color: isDark ? Colors.grey[500] : Colors.grey.shade600,
                  fontSize: 14,
                ),
              )
                  : Text(
                selecionadas.map((l) => l.nome).join(', '),
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: isDark ? Colors.grey[400] : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  void _abrirModalLojas(BuildContext context, List<LojaOptionModel> lojas) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        return _LojasSelectionModal(
          lojas: lojas,
          selecionadas: _lojasSelecionadas,
          onConfirm: (selecionadas) {
            setState(() {
              _lojasSelecionadas = selecionadas;
            });
            Navigator.pop(modalContext);
          },
        );
      },
    );
  }

  void _salvar() {
    if (!_formKey.currentState!.validate()) return;
    if (_lojasSelecionadas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Selecione pelo menos uma loja',
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black87,
            ),
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final dados = {
      'nome': _nomeController.text.trim(),
      'email': _emailController.text.trim(),
      'telefone': _telefoneController.text.trim(),
      'cpf_cnpj': _cpfCnpjController.text.trim(),
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

// ==================== MODAL DE SELEÇÃO DE LOJAS ====================

class _LojasSelectionModal extends StatefulWidget {
  final List<LojaOptionModel> lojas;
  final List<int> selecionadas;
  final ValueChanged<List<int>> onConfirm;

  const _LojasSelectionModal({
    required this.lojas,
    required this.selecionadas,
    required this.onConfirm,
  });

  @override
  State<_LojasSelectionModal> createState() => _LojasSelectionModalState();
}

class _LojasSelectionModalState extends State<_LojasSelectionModal> {
  late List<int> _selecionadasTemp;
  final _filtroController = TextEditingController();
  String _filtro = '';

  @override
  void initState() {
    super.initState();
    _selecionadasTemp = List.from(widget.selecionadas);
  }

  @override
  void dispose() {
    _filtroController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final lojasFiltradas = _filtro.isEmpty
        ? widget.lojas
        : widget.lojas.where((loja) {
      return loja.nome.toLowerCase().contains(_filtro.toLowerCase());
    }).toList();

    final todasSelecionadas = _selecionadasTemp.length == widget.lojas.length;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[600] : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),

            // Título
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Selecionar Lojas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Campo de pesquisa
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _filtroController,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: 'Pesquisar lojas...',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.grey[500] : Colors.grey[500],
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    size: 20,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  suffixIcon: _filtro.isNotEmpty
                      ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      size: 18,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    onPressed: () {
                      _filtroController.clear();
                      setState(() => _filtro = '');
                    },
                  )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: isDark ? Colors.grey[600]! : Colors.grey.shade300,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: isDark ? Colors.grey[600]! : Colors.grey.shade300,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: theme.primaryColor,
                      width: 2,
                    ),
                  ),
                  isDense: true,
                  filled: true,
                  fillColor: isDark ? Colors.grey[800] : Colors.grey.shade50,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                onChanged: (value) {
                  setState(() => _filtro = value);
                },
              ),
            ),

            // Botão selecionar todas
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_selecionadasTemp.length} de ${widget.lojas.length} selecionada(s)',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        if (todasSelecionadas) {
                          _selecionadasTemp.clear();
                        } else {
                          _selecionadasTemp = widget.lojas.map((l) => l.id).toList();
                        }
                      });
                    },
                    child: Text(
                      todasSelecionadas ? 'Desmarcar todas' : 'Selecionar todas',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Lista de lojas
            Expanded(
              child: lojasFiltradas.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 48,
                      color: isDark ? Colors.grey[600] : Colors.grey.shade400,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Nenhuma loja encontrada',
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey,
                      ),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                itemCount: lojasFiltradas.length,
                itemBuilder: (context, index) {
                  final loja = lojasFiltradas[index];
                  final selecionada = _selecionadasTemp.contains(loja.id);
                  return CheckboxListTile(
                    dense: true,
                    title: Text(
                      loja.nome,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: selecionada ? FontWeight.bold : FontWeight.normal,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    secondary: Icon(
                      selecionada ? Icons.store : Icons.store_outlined,
                      size: 20,
                      color: selecionada ? theme.primaryColor : (isDark ? Colors.grey[500] : Colors.grey),
                    ),
                    value: selecionada,
                    activeColor: theme.primaryColor,
                    checkColor: isDark ? Colors.white : Colors.black87,
                    onChanged: (selected) {
                      setState(() {
                        if (selected == true) {
                          _selecionadasTemp.add(loja.id);
                        } else {
                          _selecionadasTemp.remove(loja.id);
                        }
                      });
                    },
                  );
                },
              ),
            ),

            // Botão confirmar
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () => widget.onConfirm(_selecionadasTemp),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                child: const Text('Confirmar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}