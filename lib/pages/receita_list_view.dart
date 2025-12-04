import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/receita/receita.dart';
import '../mvvm/receita_viewmodel.dart';
import 'adicionar_receita_view.dart';

// Tela de listagem de receitas
class ReceitaListView extends StatefulWidget {
  const ReceitaListView({super.key});

  @override
  State<ReceitaListView> createState() => _ReceitaListViewState();
}

// Estado da tela de listagem de receitas
class _ReceitaListViewState extends State<ReceitaListView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReceitaViewModel>().carregarReceitas();
    });
  }

//Constrói a tela
  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ReceitaViewModel>();
    final fmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

//Constrói a interface da tela
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Receitas'),
      ),
      body: RefreshIndicator(
        onRefresh: viewModel.carregarReceitas,
        child: ListView.builder(
          itemCount: viewModel.receitas.length,
          itemBuilder: (context, index) {
            final receita = viewModel.receitas[index];
            return ListTile(
              title: Text(
                receita.descricao,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              subtitle: Text(DateFormat('dd/MM/yyyy').format(receita.data)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    fmt.format(receita.valor),
                    style: const TextStyle(
                        color: Colors.green,
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
                              AdicionarReceitaView(receita: receita),
                        ),
                      );
                      if (mounted) viewModel.carregarReceitas();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteReceita(receita),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdicionarReceitaView()),
          );
          if (mounted) viewModel.carregarReceitas();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

// Função para deletar uma receita com confirmação do usuário
  Future<void> _deleteReceita(Receita receita) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final viewModel = context.read<ReceitaViewModel>();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content:
            Text('Deseja realmente excluir a receita "${receita.descricao}"?'),
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

    if (confirm == true) {
      try {
        await viewModel.deleteReceita(receita.id!);
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Receita excluída com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir receita: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
