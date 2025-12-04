import 'package:flutter/foundation.dart';
import '../models/receita/receita.dart';
import '../services/dao/receita_dao.dart';

//gerenciar estado das receitas
class ReceitaViewModel extends ChangeNotifier {
  final ReceitaDao _receitaDao = ReceitaDao();
  List<Receita> _receitas = [];
  int? _usuarioIdAtual;

//Carrega receitas do usuario atual
  List<Receita> get receitas => List.unmodifiable(_receitas);

  void setUsuario(int usuarioId) {
    _usuarioIdAtual = usuarioId;
    carregarReceitas();
  }

//Carregar receitas do banco de dados e notifica a atualização
  Future<void> carregarReceitas() async {
    if (_usuarioIdAtual != null) {
      _receitas = await _receitaDao.readByUsuario(_usuarioIdAtual!);
      notifyListeners();
    }
  }

//Adicionar nova receita
  Future<void> adicionarReceita(Receita receita) async {
    await _receitaDao.create(receita);
    await carregarReceitas();
  }

//Deletar receita existente
  Future<void> deleteReceita(int id) async {
    await _receitaDao.delete(id);
    await carregarReceitas();
  }

//Atualizar receita existente
  Future<void> atualizarReceita(Receita receita) async {
    await _receitaDao.update(receita);
    await carregarReceitas();
  }

//Calcular total de receitas e retorna valor
  Future<double> get totalReceitas async {
    if (_usuarioIdAtual != null) {
      return await _receitaDao.getTotalByUsuario(_usuarioIdAtual!);
    }
    return 0.0;
  }

//Calcular total de receitas entre duas datas
  Future<double> totalReceitasEntre(DateTime from, DateTime to) async {
    if (_usuarioIdAtual != null) {
      return await _receitaDao.getTotalByUsuarioBetween(
          _usuarioIdAtual!, from, to);
    }
    return 0.0;
  }

//Pegar receitas por dia entre duas datas
  Future<List<Map<String, dynamic>>> receitasPorDia(
      DateTime from, DateTime to) async {
    if (_usuarioIdAtual != null) {
      return await _receitaDao.getSumByDay(_usuarioIdAtual!, from, to);
    }
    return [];
  }
}
