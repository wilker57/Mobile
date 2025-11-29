import 'package:flutter/foundation.dart';
import '../models/receita/receita.dart';
import '../services/dao/receita_dao.dart';

class ReceitaViewModel extends ChangeNotifier {
  final ReceitaDao _receitaDao = ReceitaDao();
  List<Receita> _receitas = [];
  int? _usuarioIdAtual;

  List<Receita> get receitas => List.unmodifiable(_receitas);

  void setUsuario(int usuarioId) {
    _usuarioIdAtual = usuarioId;
    carregarReceitas();
  }

  Future<void> carregarReceitas() async {
    if (_usuarioIdAtual != null) {
      _receitas = await _receitaDao.readByUsuario(_usuarioIdAtual!);
      notifyListeners();
    }
  }

  Future<void> adicionarReceita(Receita receita) async {
    await _receitaDao.create(receita);
    await carregarReceitas();
  }

  Future<void> deleteReceita(int id) async {
    await _receitaDao.delete(id);
    await carregarReceitas();
  }

  Future<void> atualizarReceita(Receita receita) async {
    await _receitaDao.update(receita);
    await carregarReceitas();
  }

  Future<double> get totalReceitas async {
    if (_usuarioIdAtual != null) {
      return await _receitaDao.getTotalByUsuario(_usuarioIdAtual!);
    }
    return 0.0;
  }

  Future<double> totalReceitasEntre(DateTime from, DateTime to) async {
    if (_usuarioIdAtual != null) {
      return await _receitaDao.getTotalByUsuarioBetween(
          _usuarioIdAtual!, from, to);
    }
    return 0.0;
  }

  Future<List<Map<String, dynamic>>> receitasPorDia(
      DateTime from, DateTime to) async {
    if (_usuarioIdAtual != null) {
      return await _receitaDao.getSumByDay(_usuarioIdAtual!, from, to);
    }
    return [];
  }
}
