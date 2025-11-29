import '../database_helper.dart';
import '../../models/categoria/categoria.dart';

class CategoriaDao {
  final dbHelper = DatabaseHelper.instance;

  Future<int> create(Categoria categoria) async {
    final db = await dbHelper.database;
    return await db.insert('Categoria', categoria.toMap());
  }

  Future<Categoria?> read(int id) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'Categoria',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Categoria.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Categoria>> readAll() async {
    final db = await dbHelper.database;
    final result = await db.query(
      'Categoria',
      orderBy: 'nome ASC',
    );
    return result.map((map) => Categoria.fromMap(map)).toList();
  }

  Future<List<Categoria>> readAllByUsuario(int usuarioId) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'Categoria',
      where: 'usuarioId = ?',
      whereArgs: [usuarioId],
      orderBy: 'nome ASC',
    );
    return result.map((map) => Categoria.fromMap(map)).toList();
  }

  Future<int> update(Categoria categoria) async {
    final db = await dbHelper.database;
    return await db.update(
      'Categoria',
      categoria.toMap(),
      where: 'id = ?',
      whereArgs: [categoria.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await dbHelper.database;
    return await db.delete(
      'Categoria',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
