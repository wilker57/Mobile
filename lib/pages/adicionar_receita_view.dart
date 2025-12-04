import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../mvvm/receita_viewmodel.dart';
import '../mvvm/categoria_viewmodel.dart';
import '../mvvm/usuario_viewmodel.dart';
import '../models/receita/receita.dart';
import '../models/categoria/categoria.dart';

// Tela para adicionar ou editar uma receita

class AdicionarReceitaView extends StatefulWidget {
  final Receita? receita;
  const AdicionarReceitaView({super.key, this.receita});

//Cria o estado da tela
  @override
  State<AdicionarReceitaView> createState() => _AdicionarReceitaViewState();
}

// Estado da tela de adicionar ou editar receita
class _AdicionarReceitaViewState extends State<AdicionarReceitaView> {
  final _formKey = GlobalKey<FormState>();
  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();
  DateTime _data = DateTime.now();
  int? _categoriaId;
  List<Categoria> _categorias = [];
  bool _isLoading = false;

//Inicializa o estado da tela
  @override
  void initState() {
    super.initState();
    _loadCategorias();
    if (widget.receita != null) {
      final r = widget.receita!;
      _descricaoController.text = r.descricao;
      _valorController.text = r.valor.toString();
      _data = r.data;
      _categoriaId = r.categoriaId;
    }
  }

  //Carrega categorias do ViewModel
  Future<void> _loadCategorias() async {
    final categoriaVM = context.read<CategoriaViewModel>();
    // Garantir que as categorias estejam carregadas
    if (categoriaVM.categorias.isEmpty) {
      await categoriaVM.carregarCategorias();
    }
    final todasCategorias = categoriaVM.categorias;
    setState(() {
      _categorias = todasCategorias.where((c) => c.tipo == 'RECEITA').toList();
      if (widget.receita == null && _categorias.isNotEmpty) {
        _categoriaId = _categorias.first.id;
      }
    });
  }

  //Atualiza dependencias quando mudam
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadCategorias();
  }

//Descarta controladores ao finalizar
  @override
  void dispose() {
    _descricaoController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  //Submit do formulário e validação
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final usuarioVM = Provider.of<UsuarioViewModel>(context, listen: false);
    final receitaVM = Provider.of<ReceitaViewModel>(context, listen: false);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    if (usuarioVM.usuarioAtual == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Usuario nao autenticado')),
      );
      return;
    }

    //atualiza estado para mostrar carregamento
    setState(() => _isLoading = true);

    final valorStr = _valorController.text.replaceAll(',', '.');
    final valor = double.tryParse(valorStr) ?? 0.0;

    if (widget.receita != null) {
      final atual = widget.receita!;
      atual.descricao = _descricaoController.text.trim();
      atual.valor = valor;
      atual.data = _data;
      atual.categoriaId = _categoriaId;

      await receitaVM.atualizarReceita(atual);

      setState(() => _isLoading = false);
      if (!mounted) return;
      navigator.pop();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Receita atualizada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      return;
    }

//Cria nova receita
    final receita = Receita(
      usuarioId: usuarioVM.usuarioAtual!.id!,
      categoriaId: _categoriaId,
      descricao: _descricaoController.text.trim(),
      valor: valor,
      data: _data,
    );

    await receitaVM.adicionarReceita(receita);

    setState(() => _isLoading = false);
    if (!mounted) return;
    navigator.pop();
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Receita adicionada com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  ///Abre um seletor de data e atualiza a data selecionada
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _data,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _data = picked);
  }

//Constrói a interface da tela de adicionar ou editar receita
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.receita != null ? 'Editar Receita' : 'Adicionar Receita'),
        actions: [
          if (widget.receita != null)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                final receitaVM = context.read<ReceitaViewModel>();
                final navigator = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);

                final ok = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirmar Exclusaoo'),
                    content: Text(
                        'Deseja realmente excluir a receita "${widget.receita!.descricao}"?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        style:
                            TextButton.styleFrom(foregroundColor: Colors.red),
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Excluir'),
                      ),
                    ],
                  ),
                );
                if (ok == true) {
                  await receitaVM.deleteReceita(widget.receita!.id!);
                  if (!mounted) return;
                  navigator.pop();
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Receita excluida com sucesso!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(labelText: 'Descricao'),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Informe a descricao' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _valorController,
                decoration:
                    const InputDecoration(labelText: 'Valor (ex: 1000.50)'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Informe o valor';
                  final parsed = double.tryParse(v.replaceAll(',', '.'));
                  if (parsed == null) return 'Valor invalido';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Data: ${_data.day}/${_data.month}/${_data.year}'),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_month),
                  onPressed: _pickDate,
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int?>(
                key: ValueKey(_categoriaId),
                initialValue: _categorias.any((c) => c.id == _categoriaId)
                    ? _categoriaId
                    : null,
                items: _categorias.map((c) {
                  return DropdownMenuItem<int?>(
                    value: c.id,
                    child: Text(c.nome),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _categoriaId = v),
                decoration: const InputDecoration(labelText: 'Categoria'),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _isLoading ? null : () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _isLoading ? null : _submit,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Salvar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
