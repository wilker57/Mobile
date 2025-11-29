import 'package:flutter/foundation.dart';
import '../models/categoria/categoria.dart';
import '../services/dao/categoria_dao.dart';

class CategoriaViewModel extends ChangeNotifier {
  final CategoriaDao _categoriaDao = CategoriaDao();
  List<Categoria> _categorias = [];
  bool _isLoading = false;
  int? _usuarioId;

  List<Categoria> get categorias => List.unmodifiable(_categorias);
  bool get isLoading => _isLoading;

  void setUsuario(int usuarioId) {
    _usuarioId = usuarioId;
  }

  Future<void> carregarCategorias() async {
    if (_usuarioId == null) {
      throw Exception('usuário não definido');
    }
    _isLoading = true;
    notifyListeners();
    _categorias = await _categoriaDao.readAllByUsuario(_usuarioId!);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addCategoria(String nome, String tipo) async {
    if (_usuarioId == null) {
      throw Exception('usuário não definido');
    }
    final novaCategoria =
        Categoria(nome: nome, tipo: tipo, usuarioId: _usuarioId!);
    await _categoriaDao.create(novaCategoria);
    await carregarCategorias();
  }

  Future<void> updateCategoria(Categoria categoria) async {
    await _categoriaDao.update(categoria);
    await carregarCategorias();
  }

  Future<void> deleteCategoria(int id) async {
    await _categoriaDao.delete(id);
    await carregarCategorias();
  }
}
