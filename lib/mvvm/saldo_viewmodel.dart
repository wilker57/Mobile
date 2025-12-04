import 'package:flutter/foundation.dart';

//gerenciar estado do saldo
class SaldoViewModel extends ChangeNotifier {
  double _saldoInicial = 0;

  double get saldoInicial => _saldoInicial;

//Atualizar saldo inicial e notifica a atualização
  void setSaldoInicial(double valor) {
    _saldoInicial = valor;
    notifyListeners();
  }

//retornar saldo atual com base em receitas e despesas
  double calcularSaldoAtual(double totalReceitas, double totalDespesas) {
    return _saldoInicial + totalReceitas - totalDespesas;
  }
}
