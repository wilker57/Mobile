import '../database_helper.dart';
import '../../models/despesa/despesa.dart';

class DespesaDao {
  final dbHelper = DatabaseHelper.instance;

  Future<int> create(Despesa despesa) async {
    final db = await dbHelper.database;
    return await db.insert('Despesa', despesa.toMap());
  }

  Future<Despesa?> read(int id) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'Despesa',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Despesa.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Despesa>> readAll() async {
    final db = await dbHelper.database;
    final result = await db.query('Despesa', orderBy: 'data DESC');
    return result.map((map) => Despesa.fromMap(map)).toList();
  }

  Future<List<Despesa>> readByUsuario(int usuarioId) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'Despesa',
      where: 'usuarioId = ?',
      whereArgs: [usuarioId],
      orderBy: 'data DESC',
    );
    return result.map((map) => Despesa.fromMap(map)).toList();
  }

  Future<double> getTotalByUsuario(int usuarioId) async {
    final db = await dbHelper.database;
    final result = await db.rawQuery(
      'SELECT SUM(valor) as total FROM Despesa WHERE usuarioId = ?',
      [usuarioId],
    );
    return result.first['total'] as double? ?? 0.0;
  }

  Future<double> getTotalByUsuarioBetween(
      int usuarioId, DateTime from, DateTime to) async {
    final db = await dbHelper.database;
    final result = await db.rawQuery(
      'SELECT SUM(valor) as total FROM Despesa WHERE usuarioId = ? AND date(data) BETWEEN date(?) AND date(?)',
      [usuarioId, from.toIso8601String(), to.toIso8601String()],
    );
    return result.first['total'] as double? ?? 0.0;
  }

  Future<List<Map<String, dynamic>>> getSumByDay(
      int usuarioId, DateTime from, DateTime to) async {
    final db = await dbHelper.database;
    final result = await db.rawQuery(
      "SELECT date(data) as day, SUM(valor) as total FROM Despesa WHERE usuarioId = ? AND date(data) BETWEEN date(?) AND date(?) GROUP BY date(data) ORDER BY date(data)",
      [usuarioId, from.toIso8601String(), to.toIso8601String()],
    );
    return result;
  }

  Future<int> update(Despesa despesa) async {
    final db = await dbHelper.database;
    return await db.update(
      'Despesa',
      despesa.toMap(),
      where: 'id = ?',
      whereArgs: [despesa.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await dbHelper.database;
    return await db.delete(
      'Despesa',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
