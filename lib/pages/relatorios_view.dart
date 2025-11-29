import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../mvvm/despesa_viewmodel.dart';
import '../mvvm/receita_viewmodel.dart';
import '../mvvm/usuario_viewmodel.dart';

class RelatoriosView extends StatefulWidget {
  const RelatoriosView({super.key});

  @override
  State<RelatoriosView> createState() => _RelatoriosViewState();
}

class _RelatoriosViewState extends State<RelatoriosView> {
  DateTime _mes = DateTime(DateTime.now().year, DateTime.now().month, 1);
  bool _isLoading = false;
  double _totalReceitas = 0;
  double _totalDespesas = 0;
  double _totalCartao = 0;

  DateTime get _from => DateTime(_mes.year, _mes.month, 1);
  DateTime get _to => DateTime(_mes.year, _mes.month + 1, 0);

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() => _isLoading = true);
    final usuarioVM = context.read<UsuarioViewModel>();
    final receitaVM = context.read<ReceitaViewModel>();
    final despesaVM = context.read<DespesaViewModel>();

    if (usuarioVM.usuarioAtual == null) {
      setState(() => _isLoading = false);
      return;
    }

    _totalReceitas = await receitaVM.totalReceitasEntre(_from, _to);
    _totalDespesas = await despesaVM.totalDespesasEntre(_from, _to);

    // calcula gastos com cartao (parcelado) apenas no mes atual
    _totalCartao = despesaVM.despesas
        .where((d) =>
            d.pagamentoTipo == 'PARCELADO' &&
            d.data.isAfter(_from.subtract(const Duration(days: 1))) &&
            d.data.isBefore(_to.add(const Duration(days: 1))))
        .fold<double>(0, (sum, d) => sum + d.valor);

    if (mounted) setState(() => _isLoading = false);
  }

  void _mudarMes(int delta) {
    setState(() {
      _mes = DateTime(_mes.year, _mes.month + delta, 1);
    });
    _carregar();
  }

  @override
  Widget build(BuildContext context) {
    final mesLabel = DateFormat('MMM yyyy', 'pt_BR').format(_mes);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatorios'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _carregar,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _PeriodoCard(
                    mesLabel: mesLabel,
                    totalReceitas: _totalReceitas,
                    totalDespesas: _totalDespesas,
                    onPrev: () => _mudarMes(-1),
                    onNext: () => _mudarMes(1),
                  ),
                  const SizedBox(height: 16),
                  _PizzaCard(
                    totalReceitas: _totalReceitas,
                    totalDespesas: _totalDespesas,
                  ),
                  const SizedBox(height: 16),
                  _CartaoCard(totalCartao: _totalCartao),
                ],
              ),
            ),
    );
  }
}

class _PeriodoCard extends StatelessWidget {
  final String mesLabel;
  final double totalReceitas;
  final double totalDespesas;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _PeriodoCard({
    required this.mesLabel,
    required this.totalReceitas,
    required this.totalDespesas,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                    onPressed: onPrev, icon: const Icon(Icons.chevron_left)),
                Text(mesLabel,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                IconButton(
                    onPressed: onNext, icon: const Icon(Icons.chevron_right)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    const Text('Receita'),
                    Text(fmt.format(totalReceitas),
                        style: const TextStyle(
                            color: Colors.green, fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  children: [
                    const Text('Despesa'),
                    Text(fmt.format(totalDespesas),
                        style: const TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PizzaCard extends StatelessWidget {
  final double totalReceitas;
  final double totalDespesas;

  const _PizzaCard({required this.totalReceitas, required this.totalDespesas});

  @override
  Widget build(BuildContext context) {
    final total = totalReceitas + totalDespesas;
    final receitaPct = total == 0 ? 0 : totalReceitas / total * 100;
    final despesaPct = total == 0 ? 0 : totalDespesas / total * 100;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Distribuicao geral',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: PieChart(
                PieChartData(sections: [
                  PieChartSectionData(
                    value: totalReceitas,
                    color: const Color(0xFF162E70),
                    title: '${receitaPct.toStringAsFixed(1)}%',
                    radius: 60,
                  ),
                  PieChartSectionData(
                    value: totalDespesas,
                    color: Colors.red,
                    title: '${despesaPct.toStringAsFixed(1)}%',
                    radius: 60,
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                _LegendDot(color: Color(0xFF162E70), label: 'Receitas'),
                SizedBox(width: 12),
                _LegendDot(color: Colors.red, label: 'Despesas'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(6)),
        ),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }
}

class _CartaoCard extends StatelessWidget {
  final double totalCartao;
  const _CartaoCard({required this.totalCartao});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Gastos com cartao de credito',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.credit_card, color: Colors.deepPurple),
                const SizedBox(width: 8),
                Text(fmt.format(totalCartao),
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Somente despesas marcadas como parcelado neste mes.'),
          ],
        ),
      ),
    );
  }
}
