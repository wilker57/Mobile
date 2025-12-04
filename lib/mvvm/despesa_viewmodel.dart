import 'package:flutter/foundation.dart';
import '../models/despesa/despesa.dart';
import '../services/dao/despesa_dao.dart';

//gerenciar estado das despesas
class DespesaViewModel extends ChangeNotifier {
  final DespesaDao _despesaDao = DespesaDao();
  List<Despesa> _despesas = [];
  int? _usuarioIdAtual;

//Carrega despesas do usuario atual
  List<Despesa> get despesas => List.unmodifiable(_despesas);

  void setUsuario(int usuarioId) {
    _usuarioIdAtual = usuarioId;
    carregarDespesas();
  }

//Carregar despesas do banco de dados
  Future<void> carregarDespesas() async {
    if (_usuarioIdAtual != null) {
      _despesas = await _despesaDao.readByUsuario(_usuarioIdAtual!);
      notifyListeners();
    }
  }

//Adicionar nova despesa
  Future<void> adicionarDespesa(Despesa despesa) async {
    await _despesaDao.create(despesa);
    await carregarDespesas();
  }

//Deletar despesa existente
  Future<void> deleteDespesa(int id) async {
    await _despesaDao.delete(id);
    await carregarDespesas();
  }

//Atualizar despesa existente
  Future<void> atualizarDespesa(Despesa despesa) async {
    await _despesaDao.update(despesa);
    await carregarDespesas();
  }

//Calcular total de despesas e retorna valor
  Future<double> get totalDespesas async {
    if (_usuarioIdAtual != null) {
      return await _despesaDao.getTotalByUsuario(_usuarioIdAtual!);
    }
    return 0.0;
  }

//Calcular total de despesas entre duas datas
  Future<double> totalDespesasEntre(DateTime from, DateTime to) async {
    if (_usuarioIdAtual != null) {
      return await _despesaDao.getTotalByUsuarioBetween(
          _usuarioIdAtual!, from, to);
    }
    return 0.0;
  }

//Pegar despesas por dia entre duas datas
  Future<List<Map<String, dynamic>>> despesasPorDia(
      DateTime from, DateTime to) async {
    if (_usuarioIdAtual != null) {
      return await _despesaDao.getSumByDay(_usuarioIdAtual!, from, to);
    }
    return [];
  }
}
