import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'despesa_pessoal.db');

    // Para forçar a recriação do banco, descomente a linha abaixo uma vez

    // await deleteDatabase(path);

    return await openDatabase(
      path,
      version: 6,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE Usuario (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT NOT NULL,
            email TEXT NOT NULL UNIQUE,
            senha TEXT NOT NULL,
            dataCriacao TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE Receita (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            descricao TEXT NOT NULL,
            valor REAL NOT NULL,
            data TEXT NOT NULL,
            categoriaId INTEGER,
            usuarioId INTEGER,
            dataCriacao TEXT NOT NULL,
            FOREIGN KEY (categoriaId) REFERENCES Categoria(id),
            FOREIGN KEY (usuarioId) REFERENCES Usuario(id)
          )
        ''');
        await db.execute('''
          CREATE TABLE Despesa (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            descricao TEXT NOT NULL,
            valor REAL NOT NULL,
            data TEXT NOT NULL,
            categoriaId INTEGER,
            usuarioId INTEGER,
            dataCriacao TEXT NOT NULL,
            pagamentoTipo TEXT NOT NULL DEFAULT 'AVISTA',
            parcelasTotal INTEGER NOT NULL DEFAULT 1,
            parcelaNumero INTEGER DEFAULT 1,
            FOREIGN KEY (categoriaId) REFERENCES Categoria(id),
            FOREIGN KEY (usuarioId) REFERENCES Usuario(id)
          )
        ''');
        await db.execute('''
          CREATE TABLE Categoria (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT NOT NULL,
            tipo TEXT NOT NULL,
            usuarioId INTEGER,
            FOREIGN KEY (usuarioId) REFERENCES Usuario(id)
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        print('Upgrading database from version $oldVersion to $newVersion');

        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE Categoria (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              nome TEXT NOT NULL,
              tipo TEXT NOT NULL,
              usuarioId INTEGER,
              FOREIGN KEY (usuarioId) REFERENCES Usuario(id)
            )
          ''');
        }

        if (oldVersion < 3) {
          // Verificar se a coluna 'tipo' já existe
          final result = await db.rawQuery("PRAGMA table_info(Categoria)");
          final hasTypeColumn =
              result.any((column) => column['name'] == 'tipo');

          if (!hasTypeColumn) {
            await db.execute(
                'ALTER TABLE Categoria ADD COLUMN tipo TEXT NOT NULL DEFAULT "despesa"');
          }
        }

        if (oldVersion < 4) {
          // Verificar se a coluna 'usuarioId' já existe
          final result = await db.rawQuery("PRAGMA table_info(Categoria)");
          final hasUserIdColumn =
              result.any((column) => column['name'] == 'usuarioId');

          if (!hasUserIdColumn) {
            await db
                .execute('ALTER TABLE Categoria ADD COLUMN usuarioId INTEGER');
            print('Added usuarioId column to Categoria table');
          } else {
            print('usuarioId column already exists in Categoria table');
          }
        }

        if (oldVersion < 5) {
          // Adicionar coluna dataCriacao à tabela Usuario
          try {
            await db.execute(
                'ALTER TABLE Usuario ADD COLUMN dataCriacao TEXT DEFAULT "${DateTime.now().toIso8601String()}"');
            print('Added dataCriacao column to Usuario table');
          } catch (e) {
            print('dataCriacao column might already exist: $e');
          }
        }

        if (oldVersion < 6) {
          // Adicionar colunas faltantes às tabelas Receita e Despesa
          try {
            await db.execute(
                'ALTER TABLE Receita ADD COLUMN dataCriacao TEXT DEFAULT "${DateTime.now().toIso8601String()}"');
            print('Added dataCriacao column to Receita table');
          } catch (e) {
            print('dataCriacao column might already exist in Receita: $e');
          }

          try {
            await db.execute(
                'ALTER TABLE Despesa ADD COLUMN dataCriacao TEXT DEFAULT "${DateTime.now().toIso8601String()}"');
            await db.execute(
                'ALTER TABLE Despesa ADD COLUMN pagamentoTipo TEXT DEFAULT "AVISTA"');
            await db.execute(
                'ALTER TABLE Despesa ADD COLUMN parcelasTotal INTEGER DEFAULT 1');
            await db.execute(
                'ALTER TABLE Despesa ADD COLUMN parcelaNumero INTEGER DEFAULT 1');
            print('Added missing columns to Despesa table');
          } catch (e) {
            print('Some columns might already exist in Despesa: $e');
          }
        }

        if (oldVersion < 6) {
          // Adicionar colunas faltantes às tabelas Receita e Despesa
          try {
            await db.execute(
                'ALTER TABLE Receita ADD COLUMN dataCriacao TEXT DEFAULT "${DateTime.now().toIso8601String()}"');
            print('Added dataCriacao column to Receita table');
          } catch (e) {
            print('dataCriacao column might already exist in Receita: $e');
          }

          try {
            await db.execute(
                'ALTER TABLE Despesa ADD COLUMN dataCriacao TEXT DEFAULT "${DateTime.now().toIso8601String()}"');
            await db.execute(
                'ALTER TABLE Despesa ADD COLUMN pagamentoTipo TEXT DEFAULT "AVISTA"');
            await db.execute(
                'ALTER TABLE Despesa ADD COLUMN parcelasTotal INTEGER DEFAULT 1');
            await db.execute(
                'ALTER TABLE Despesa ADD COLUMN parcelaNumero INTEGER DEFAULT 1');
            print('Added missing columns to Despesa table');
          } catch (e) {
            print('Some columns might already exist in Despesa: $e');
          }
        }
      },
    );
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
