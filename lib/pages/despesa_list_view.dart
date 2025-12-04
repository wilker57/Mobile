import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/despesa/despesa.dart';
import '../mvvm/despesa_viewmodel.dart';
import 'adicionar_despesa_view.dart';

// Tela para listar despesas do usuário

class DespesaListView extends StatefulWidget {
  const DespesaListView({super.key});

  @override
  State<DespesaListView> createState() => _DespesaListViewState();
}

// Estado da tela de listar despesas

class _DespesaListViewState extends State<DespesaListView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DespesaViewModel>().carregarDespesas();
    });
  }

// Constrói a interface da tela de listar despesas
  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DespesaViewModel>();
    final fmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

// Scaffold com AppBar, lista de despesas e botão flutuante para adicionar despesa
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Despesas'),
      ),
      body: RefreshIndicator(
        onRefresh: viewModel.carregarDespesas,
        child: ListView.builder(
          itemCount: viewModel.despesas.length,
          itemBuilder: (context, index) {
            final despesa = viewModel.despesas[index];
            return ListTile(
              title: Text(
                despesa.descricao,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              subtitle: Text(DateFormat('dd/MM/yyyy').format(despesa.data)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    fmt.format(despesa.valor),
                    style: const TextStyle(
                        color: Colors.red,
                        fontSize: 20,
                        fontWeight: FontWeight.w600),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orange),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              AdicionarDespesaView(despesa: despesa),
                        ),
                      );
                      if (mounted) viewModel.carregarDespesas();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteDespesa(despesa),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdicionarDespesaView()),
          );
          if (mounted) viewModel.carregarDespesas();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

// Mostra diálogo de confirmação e exclui a despesa se confirmado
  Future<void> _deleteDespesa(Despesa despesa) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final viewModel = context.read<DespesaViewModel>();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content:
            Text('Deseja realmente excluir a despesa "${despesa.descricao}"?'),
        actions: [
          TextButton(
            onPressed: () => navigator.pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => navigator.pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

// Exclui a despesa e mostra mensagem de sucesso ou erro
    if (confirm == true) {
      try {
        await viewModel.deleteDespesa(despesa.id!);
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Despesa excluída com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir despesa: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
