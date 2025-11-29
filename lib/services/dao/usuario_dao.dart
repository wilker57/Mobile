import '../database_helper.dart';
import '../../models/usuario/usuario.dart';

class UsuarioDao {
  final dbHelper = DatabaseHelper.instance;

  Future<int> create(Usuario usuario) async {
    final db = await dbHelper.database;
    return await db.insert('Usuario', usuario.toMap());
  }

  Future<Usuario?> read(int id) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'Usuario',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Usuario.fromMap(maps.first);
    }
    return null;
  }

  Future<Usuario?> findByEmail(String email) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'Usuario',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return Usuario.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Usuario>> readAll() async {
    final db = await dbHelper.database;
    final result = await db.query('Usuario');
    return result.map((map) => Usuario.fromMap(map)).toList();
  }

  Future<int> update(Usuario usuario) async {
    final db = await dbHelper.database;
    return await db.update(
      'Usuario',
      usuario.toMap(),
      where: 'id = ?',
      whereArgs: [usuario.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await dbHelper.database;
    return await db.delete(
      'Usuario',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
