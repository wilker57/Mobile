import 'package:flutter/foundation.dart';
import '../models/categoria/categoria.dart';
import '../services/dao/categoria_dao.dart';

// gerancia de estado para categorias
class CategoriaViewModel extends ChangeNotifier {
  final CategoriaDao _categoriaDao = CategoriaDao();
  List<Categoria> _categorias = [];
  bool _isLoading = false;
  int? _usuarioId;
// lista e exibicao de categorias
  List<Categoria> get categorias => List.unmodifiable(_categorias);
  bool get isLoading => _isLoading;
// retorna categoria por id
  void setUsuario(int usuarioId) {
    _usuarioId = usuarioId;
  }

//Carrega categorias do usuario
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

//Adiciona nova categoria
  Future<void> addCategoria(String nome, String tipo) async {
    if (_usuarioId == null) {
      throw Exception('usuário não definido');
    }
    final novaCategoria =
        Categoria(nome: nome, tipo: tipo, usuarioId: _usuarioId!);
    await _categoriaDao.create(novaCategoria);
    await carregarCategorias();
  }

//Atualiza categoria existente
  Future<void> updateCategoria(Categoria categoria) async {
    await _categoriaDao.update(categoria);
    await carregarCategorias();
  }

//Deleta categoria por id
  Future<void> deleteCategoria(int id) async {
    await _categoriaDao.delete(id);
    await carregarCategorias();
  }
}
