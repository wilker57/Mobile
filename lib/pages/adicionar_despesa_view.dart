import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../mvvm/despesa_viewmodel.dart';
import '../mvvm/categoria_viewmodel.dart';
import '../mvvm/usuario_viewmodel.dart';
import '../models/despesa/despesa.dart';
import '../models/categoria/categoria.dart';

class AdicionarDespesaView extends StatefulWidget {
  final Despesa? despesa;
  const AdicionarDespesaView({super.key, this.despesa});

  @override
  State<AdicionarDespesaView> createState() => _AdicionarDespesaViewState();
}

class _AdicionarDespesaViewState extends State<AdicionarDespesaView> {
  final _formKey = GlobalKey<FormState>();
  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();
  DateTime _data = DateTime.now();
  int? _categoriaId;
  List<Categoria> _categorias = [];
  bool _isLoading = false;
  String _pagamentoTipo = 'AVISTA';
  int _parcelasTotal = 1;

  @override
  void initState() {
    super.initState();
    _loadCategorias();
    if (widget.despesa != null) {
      final d = widget.despesa!;
      _descricaoController.text = d.descricao;
      _valorController.text = d.valor.toString();
      _data = d.data;
      _categoriaId = d.categoriaId;
      _pagamentoTipo = d.pagamentoTipo;
      _parcelasTotal = d.parcelasTotal;
    }
  }

  Future<void> _loadCategorias() async {
    final categoriaVM = context.read<CategoriaViewModel>();
    // Garantir que as categorias estejam carregadas
    if (categoriaVM.categorias.isEmpty) {
      await categoriaVM.carregarCategorias();
    }
    final todasCategorias = categoriaVM.categorias;
    setState(() {
      _categorias = todasCategorias.where((c) => c.tipo == 'DESPESA').toList();
      if (widget.despesa == null && _categorias.isNotEmpty) {
        _categoriaId = _categorias.first.id;
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadCategorias();
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final usuarioVM = Provider.of<UsuarioViewModel>(context, listen: false);
    final despesaVM = Provider.of<DespesaViewModel>(context, listen: false);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    if (usuarioVM.usuarioAtual == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Usuario nao autenticado')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final valorStr = _valorController.text.replaceAll(',', '.');
    final valor = double.tryParse(valorStr) ?? 0.0;

    if (widget.despesa != null) {
      final atual = widget.despesa!;
      atual.descricao = _descricaoController.text.trim();
      atual.valor = valor;
      atual.data = _data;
      atual.categoriaId = _categoriaId;
      atual.pagamentoTipo = _pagamentoTipo;
      atual.parcelasTotal = _parcelasTotal;

      await despesaVM.atualizarDespesa(atual);

      setState(() => _isLoading = false);
      if (!mounted) return;
      navigator.pop();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Despesa atualizada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      return;
    }

    if (_pagamentoTipo == 'PARCELADO') {
      final parcelaValor =
          double.parse((valor / _parcelasTotal).toStringAsFixed(2));
      DateTime parcelaData = _data;
      for (int i = 1; i <= _parcelasTotal; i++) {
        final desp = Despesa(
          usuarioId: usuarioVM.usuarioAtual!.id!,
          categoriaId: _categoriaId,
          descricao:
              '${_descricaoController.text.trim()} (Parcela $i/$_parcelasTotal)',
          valor: parcelaValor,
          data: parcelaData,
          pagamentoTipo: 'PARCELADO',
          parcelasTotal: _parcelasTotal,
          parcelaNumero: i,
        );
        await despesaVM.adicionarDespesa(desp);
        parcelaData =
            DateTime(parcelaData.year, parcelaData.month + 1, parcelaData.day);
      }
    } else {
      final despesa = Despesa(
        usuarioId: usuarioVM.usuarioAtual!.id!,
        categoriaId: _categoriaId,
        descricao: _descricaoController.text.trim(),
        valor: valor,
        data: _data,
        pagamentoTipo: _pagamentoTipo,
        parcelasTotal: _parcelasTotal,
        parcelaNumero: 1,
      );

      await despesaVM.adicionarDespesa(despesa);
    }

    setState(() => _isLoading = false);
    if (!mounted) return;
    navigator.pop();
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Despesa adicionada com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _data,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _data = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.despesa != null ? 'Editar Despesa' : 'Adicionar Despesa'),
        actions: [
          if (widget.despesa != null)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                final despesaVM = context.read<DespesaViewModel>();
                final navigator = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);

                final ok = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirmar Exclusao'),
                    content: Text(
                        'Deseja realmente excluir a despesa "${widget.despesa!.descricao}"?'),
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
                  await despesaVM.deleteDespesa(widget.despesa!.id!);
                  if (!mounted) return;
                  navigator.pop();
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Despesa excluida com sucesso!'),
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
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                key: ValueKey(_pagamentoTipo),
                initialValue: _pagamentoTipo,
                items: const [
                  DropdownMenuItem(value: 'AVISTA', child: Text('A vista')),
                  DropdownMenuItem(
                      value: 'PARCELADO', child: Text('Parcelado')),
                ],
                onChanged: (v) =>
                    setState(() => _pagamentoTipo = v ?? 'AVISTA'),
                decoration:
                    const InputDecoration(labelText: 'Tipo de pagamento'),
              ),
              const SizedBox(height: 12),
              if (_pagamentoTipo == 'PARCELADO') ...[
                TextFormField(
                  initialValue: _parcelasTotal.toString(),
                  decoration:
                      const InputDecoration(labelText: 'Numero de parcelas'),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: false),
                  onChanged: (v) =>
                      setState(() => _parcelasTotal = int.tryParse(v) ?? 1),
                ),
                const SizedBox(height: 12),
              ],
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
