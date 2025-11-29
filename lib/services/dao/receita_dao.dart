import '../database_helper.dart';
import '../../models/receita/receita.dart';

class ReceitaDao {
  final dbHelper = DatabaseHelper.instance;

  Future<int> create(Receita receita) async {
    final db = await dbHelper.database;
    return await db.insert('Receita', receita.toMap());
  }

  Future<Receita?> read(int id) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'Receita',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Receita.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Receita>> readAll() async {
    final db = await dbHelper.database;
    final result = await db.query('Receita', orderBy: 'data DESC');
    return result.map((map) => Receita.fromMap(map)).toList();
  }

  Future<List<Receita>> readByUsuario(int usuarioId) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'Receita',
      where: 'usuarioId = ?',
      whereArgs: [usuarioId],
      orderBy: 'data DESC',
    );
    return result.map((map) => Receita.fromMap(map)).toList();
  }

  Future<double> getTotalByUsuario(int usuarioId) async {
    final db = await dbHelper.database;
    final result = await db.rawQuery(
      'SELECT SUM(valor) as total FROM Receita WHERE usuarioId = ?',
      [usuarioId],
    );
    return result.first['total'] as double? ?? 0.0;
  }

  Future<double> getTotalByUsuarioBetween(
      int usuarioId, DateTime from, DateTime to) async {
    final db = await dbHelper.database;
    final result = await db.rawQuery(
      'SELECT SUM(valor) as total FROM Receita WHERE usuarioId = ? AND date(data) BETWEEN date(?) AND date(?)',
      [usuarioId, from.toIso8601String(), to.toIso8601String()],
    );
    return result.first['total'] as double? ?? 0.0;
  }

  Future<List<Map<String, dynamic>>> getSumByDay(
      int usuarioId, DateTime from, DateTime to) async {
    final db = await dbHelper.database;
    final result = await db.rawQuery(
      "SELECT date(data) as day, SUM(valor) as total FROM Receita WHERE usuarioId = ? AND date(data) BETWEEN date(?) AND date(?) GROUP BY date(data) ORDER BY date(data)",
      [usuarioId, from.toIso8601String(), to.toIso8601String()],
    );
    return result;
  }

  Future<int> update(Receita receita) async {
    final db = await dbHelper.database;
    return await db.update(
      'Receita',
      receita.toMap(),
      where: 'id = ?',
      whereArgs: [receita.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await dbHelper.database;
    return await db.delete(
      'Receita',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
