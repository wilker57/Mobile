import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../mvvm/categoria_viewmodel.dart';
import '../mvvm/despesa_viewmodel.dart';
import '../mvvm/receita_viewmodel.dart';
import '../mvvm/saldo_viewmodel.dart';
import '../mvvm/usuario_viewmodel.dart';
import 'adicionar_despesa_view.dart';
import 'adicionar_receita_view.dart';
import 'categoria_view.dart';
import 'despesa_list_view.dart';
import 'login_view.dart';
import 'receita_list_view.dart';
import 'relatorios_view.dart';

//tela principal apos login
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool _isLoading = true;
  int _selectedIndex = 0;

//Inicializa o estado da tela
//Carrega dados iniciais
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _carregarDados();
    });
  }

//Carrega dados do usuario atual
  Future<void> _carregarDados() async {
    final usuarioVM = context.read<UsuarioViewModel>();

    if (usuarioVM.usuarioAtual != null) {
      final usuarioId = usuarioVM.usuarioAtual!.id!;
      final receitaVM = context.read<ReceitaViewModel>();
      final despesaVM = context.read<DespesaViewModel>();
      final categoriaVM = context.read<CategoriaViewModel>();

      receitaVM.setUsuario(usuarioId);
      despesaVM.setUsuario(usuarioId);
      categoriaVM.setUsuario(usuarioId);
      await Future.wait([
        receitaVM.carregarReceitas(),
        despesaVM.carregarDespesas(),
        categoriaVM.carregarCategorias(),
      ]);
    }

// Atualiza o estado para indicar que o carregamento terminou
    if (mounted) setState(() => _isLoading = false);
  }

//Faz logout do usuario atual e encerra a sessao
  void _logout() {
    context.read<UsuarioViewModel>().logout();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginView()),
    );
  }

//Constrói a interface da tela principal
  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<UsuarioViewModel>().usuarioAtual;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

//Constrói a interface principal com AppBar, Drawer e BottomNavigationBar
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ola, ${usuario?.nome ?? "Usuario"} ',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Sair',
            onPressed: _logout,
          ),
        ],
      ),
      drawer: _buildDrawer(usuario),
      body: RefreshIndicator(
        onRefresh: _carregarDados,
        child: const _DashboardContent(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        showUnselectedLabels: true,
        onTap: (index) async {
          setState(() => _selectedIndex = index);
          if (index == 1) {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ReceitaListView()),
            );
          } else if (index == 2) {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DespesaListView()),
            );
          } else if (index == 3) {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CategoriaView()),
            );
          } else if (index == 4) {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RelatoriosView()),
            );
          }
          if (mounted) setState(() => _selectedIndex = 0);
        },
        items: [
          _navItem(
              icon: Icons.home_outlined, label: 'Home', color: Colors.blue),
          _navItem(
              icon: Icons.arrow_upward, label: 'Receita', color: Colors.green),
          _navItem(
              icon: Icons.arrow_downward, label: 'Despesa', color: Colors.red),
          _navItem(
              icon: Icons.category, label: 'Categoria', color: Colors.indigo),
          _navItem(
              icon: Icons.bar_chart, label: 'Relatorios', color: Colors.orange),
        ],
      ),
    );
  }

//Constrói os itens da barra de navegação inferior
  BottomNavigationBarItem _navItem(
      {required IconData icon, required String label, required Color color}) {
    return BottomNavigationBarItem(
      icon: Icon(icon, color: color.withAlpha(128)),
      activeIcon: Icon(icon, color: color),
      label: label,
    );
  }

  Drawer _buildDrawer(dynamic usuario) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(usuario?.nome ?? 'Usuario'),
            accountEmail: Text(usuario?.email ?? ''),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.blue),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.arrow_upward),
            title: const Text('Receita'),
            onTap: () async {
              Navigator.pop(context);
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReceitaListView()),
              );
              _carregarDados();
            },
          ),
          ListTile(
            leading: const Icon(Icons.arrow_downward),
            title: const Text('Despesa'),
            onTap: () async {
              Navigator.pop(context);
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DespesaListView()),
              );
              _carregarDados();
            },
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Categoria'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CategoriaView()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Relatorios'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RelatoriosView()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Configuracoes'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content:
                        Text('Tela de configuracoes ainda nao disponivel')),
              );
            },
          ),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Sair', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _logout();
            },
          ),
        ],
      ),
    );
  }
}

// Conteúdo do dashboard exibido na tela principal
class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context) {
    final receitaVM = context.watch<ReceitaViewModel>();
    final despesaVM = context.watch<DespesaViewModel>();
    final saldoVM = context.watch<SaldoViewModel>();
    final categoriaVM = context.watch<CategoriaViewModel>();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SaldoCard(
            receitaVM: receitaVM, despesaVM: despesaVM, saldoVM: saldoVM),
        const SizedBox(height: 16),
        _AcessosRapidosCard(),
        const SizedBox(height: 16),
        _GastosPorCategoriaCard(despesaVM: despesaVM, categoriaVM: categoriaVM),
      ],
    );
  }
}

// Card que exibe o saldo atual
class _SaldoCard extends StatelessWidget {
  final ReceitaViewModel receitaVM;
  final DespesaViewModel despesaVM;
  final SaldoViewModel saldoVM;

  const _SaldoCard({
    required this.receitaVM,
    required this.despesaVM,
    required this.saldoVM,
  });

//Constrói a interface do card de saldo atual
  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return FutureBuilder<List<double>>(
      future: Future.wait([receitaVM.totalReceitas, despesaVM.totalDespesas]),
      builder: (context, snapshot) {
        final receitas = snapshot.data?[0] ?? 0.0;
        final despesas = snapshot.data?[1] ?? 0.0;
        final saldo = saldoVM.calcularSaldoAtual(receitas, despesas);

        return Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Saldo atual',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text(
                      formatter.format(saldo),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: saldo >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
                Icon(
                  saldo >= 0 ? Icons.trending_up : Icons.trending_down,
                  color: saldo >= 0 ? Colors.green : Colors.red,
                  size: 42,
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

// Card que exibe os acessos rápidos
class _AcessosRapidosCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Acessos rapidos',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _QuickButton(
                    label: 'Receita',
                    icon: Icons.arrow_upward,
                    color: Colors.green,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AdicionarReceitaView()),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickButton(
                    label: 'Despesa',
                    icon: Icons.arrow_downward,
                    color: Colors.red,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AdicionarDespesaView()),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _QuickButton(
                    label: 'Relatorios',
                    icon: Icons.bar_chart,
                    color: Colors.blue,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RelatoriosView()),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickButton(
                    label: 'Categoria',
                    icon: Icons.category,
                    color: Colors.orange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const CategoriaView()),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Botão rápido usado no card de acessos rápidos
class _QuickButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickButton(
      {required this.label,
      required this.icon,
      required this.color,
      required this.onTap});

// Botão rápido usado no card de acessos rápidos
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 64) / 2,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: color),
        label: Text(label, style: TextStyle(color: color)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color.withAlpha(153)),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

//classe que exibe gastos por categoria
class _GastosPorCategoriaCard extends StatelessWidget {
  final DespesaViewModel despesaVM;
  final CategoriaViewModel categoriaVM;

  const _GastosPorCategoriaCard(
      {required this.despesaVM, required this.categoriaVM});

//Constrói a interface do card de gastos por categoria
  @override
  Widget build(BuildContext context) {
    final totalDespesas =
        despesaVM.despesas.fold<double>(0.0, (sum, d) => sum + d.valor);
    final categoriaMap = {for (var c in categoriaVM.categorias) c.id: c};
    final Map<int?, double> somaPorCat = {};
    for (final d in despesaVM.despesas) {
      somaPorCat[d.categoriaId] = (somaPorCat[d.categoriaId] ?? 0) + d.valor;
    }

//Ordena categorias por valor gasto
    final items = somaPorCat.entries.toList();
    items.sort((a, b) => (b.value).compareTo(a.value));
    final colorList = List<MaterialColor>.from(Colors.primaries);
    colorList.shuffle();
    final palette = colorList.map((c) => c.shade400).toList();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Gastos por categoria',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text('Nenhuma despesa cadastrada',
                    style: TextStyle(color: Colors.grey)),
              )
            else
              ...items.asMap().entries.map((entry) {
                final e = entry.value;
                final color = palette[entry.key % palette.length];
                final percent =
                    totalDespesas == 0 ? 0 : (e.value / totalDespesas) * 100;
                final cat = categoriaMap[e.key];
                final icon = _iconForCategory(cat?.nome ?? 'Outros');
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: color.withAlpha(30),
                        child: Icon(icon, color: color),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(cat?.nome ?? 'Sem categoria',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: percent / 100,
                                minHeight: 8,
                                backgroundColor: Colors.grey.shade200,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(color),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text('${percent.toStringAsFixed(1)}%',
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

//Retorna o icone apropriado para a categoria
  IconData _iconForCategory(String nome) {
    final lower = nome.toLowerCase();
    if (lower.contains('aliment')) return Icons.restaurant;
    if (lower.contains('transp')) return Icons.directions_bus;
    if (lower.contains('saude')) return Icons.favorite;
    if (lower.contains('edu')) return Icons.school;
    if (lower.contains('lazer')) return Icons.beach_access;
    if (lower.contains('morad')) return Icons.home;
    if (lower.contains('invest')) return Icons.trending_up;
    if (lower.contains('cart')) return Icons.credit_card;
    return Icons.category;
  }
}
