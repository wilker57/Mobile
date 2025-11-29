import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/categoria/categoria.dart';
import '../mvvm/categoria_viewmodel.dart';

class CategoriaView extends StatefulWidget {
  const CategoriaView({super.key});

  @override
  State<CategoriaView> createState() => _CategoriaViewState();
}

class _CategoriaViewState extends State<CategoriaView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoriaViewModel>().carregarCategorias();
    });
  }

  Future<void> _showAddEditDialog({Categoria? categoria}) async {
    final nomeController = TextEditingController(text: categoria?.nome);
    final formKey = GlobalKey<FormState>();
    final isEditing = categoria != null;
    String currentTipo = categoria?.tipo ?? 'DESPESA';

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title:
                  Text(isEditing ? 'Editar Categoria' : 'Adicionar Categoria'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nomeController,
                      decoration: const InputDecoration(labelText: 'Nome'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira um nome';
                        }
                        return null;
                      },
                    ),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Tipo'),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            currentTipo = value;
                          });
                        }
                      },
                      items: const [
                        DropdownMenuItem(
                            value: 'DESPESA', child: Text('Despesa')),
                        DropdownMenuItem(
                            value: 'RECEITA', child: Text('Receita')),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final nome = nomeController.text;
                      final viewModel = context.read<CategoriaViewModel>();
                      final navigator = Navigator.of(context);
                      final messenger = ScaffoldMessenger.of(context);

                      try {
                        if (isEditing) {
                          final updatedCategoria = Categoria(
                            id: categoria.id,
                            nome: nome,
                            tipo: currentTipo,
                            usuarioId: categoria.usuarioId,
                          );
                          await viewModel.updateCategoria(updatedCategoria);
                        } else {
                          await viewModel.addCategoria(nome, currentTipo);
                        }

                        navigator.pop();
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                                'Categoria ${isEditing ? 'atualizada' : 'adicionada'} com sucesso!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } catch (e) {
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text('Erro ao salvar categoria: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  IconData _iconForCategory(String nome) {
    final lower = nome.toLowerCase();
    if (lower.contains('aliment')) return Icons.restaurant;
    if (lower.contains('transp')) return Icons.directions_bus;
    if (lower.contains('saude')) return Icons.local_hospital;
    if (lower.contains('educa')) return Icons.school;
    if (lower.contains('lazer')) return Icons.beach_access;
    if (lower.contains('moradia')) return Icons.home;
    if (lower.contains('invest')) return Icons.trending_up;
    if (lower.contains('salario')) return Icons.attach_money;
    return Icons.category;
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CategoriaViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Categorias'),
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: viewModel.carregarCategorias,
              child: ListView.builder(
                itemCount: viewModel.categorias.length,
                itemBuilder: (context, index) {
                  final categoria = viewModel.categorias[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          Theme.of(context).primaryColor.withAlpha(30),
                      child: Icon(
                        _iconForCategory(categoria.nome),
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    title: Text(categoria.nome),
                    subtitle: Text(
                        'Tipo: ${categoria.tipo == 'DESPESA' ? 'Despesa' : 'Receita'}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          onPressed: () =>
                              _showAddEditDialog(categoria: categoria),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final navigator = Navigator.of(context);
                            final messenger = ScaffoldMessenger.of(context);
                            final viewModel =
                                context.read<CategoriaViewModel>();

                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Confirmar Exclusao'),
                                content: Text(
                                    'Deseja realmente excluir a categoria "${categoria.nome}"?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => navigator.pop(false),
                                    child: const Text('Cancelar'),
                                  ),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                        foregroundColor: Colors.red),
                                    onPressed: () => navigator.pop(true),
                                    child: const Text('Excluir'),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              try {
                                await viewModel.deleteCategoria(categoria.id!);
                                messenger.showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Categoria excluída com sucesso!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } catch (e) {
                                messenger.showSnackBar(
                                  SnackBar(
                                    content:
                                        Text('Erro ao excluir categoria: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
