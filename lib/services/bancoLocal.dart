import 'package:meupatrimonio/models/percentual.dart';
import 'package:meupatrimonio/models/ativo.dart';
import 'package:meupatrimonio/models/divida.dart';
import 'package:meupatrimonio/models/objetivo.dart';
import 'package:meupatrimonio/models/reserva.dart';
import 'package:meupatrimonio/vals/constantes.dart';
import 'package:sqflite/sqflite.dart';

class ServicoBancoLocal {
  static final ServicoBancoLocal _servicoLocalDB = ServicoBancoLocal.internal();
  factory ServicoBancoLocal() => _servicoLocalDB;
  static Database _localDB;

  Future<Database> get db async {
    if (_localDB == null) {
      _localDB = await inicializarDB();
    }
    return _localDB;
  }

  ServicoBancoLocal.internal();

  Future<Database> inicializarDB() async {
    String directory = await getDatabasesPath();
    return await openDatabase('$directory/$LOCAL_DB_FILE.db',
        version: 1, onCreate: _criarBanco, onUpgrade: _atualizarBanco);
  }

  void _criarBanco(Database db, int version) async {
    Batch batch = db.batch();
    batch.execute(
        'create table ativos (id TEXT PRIMARY KEY, nome TEXT, ticker TEXT, cotacao REAL, quantidade REAL, peso REAL, tipo TEXT)');
    batch.execute(
        'create table dividas (id TEXT PRIMARY KEY, nome TEXT, valor REAL)');
    batch.execute(
        'create table reservas (id TEXT PRIMARY KEY, nome TEXT, valor REAL, tipo TEXT)');
    batch.execute(
        'create table objetivos (id TEXT PRIMARY KEY, nome TEXT, tipo TEXT, ideal REAL, ordem INTEGER)');
    batch.execute(
        'INSERT INTO objetivos (ID, NOME, TIPO, IDEAL, ORDEM) VALUES ' +
            '(1, "Reserva de Emergência", "EMERGENCIA", 0.05, 1),' +
            '(2, "Ações", "ACAO", 0.15, 2),' +
            '(3, "FIIs", "FII", 0.15, 3),' +
            '(4, "Renda Fixa", "RF", 0.30, 4),' +
            '(5, "Stocks", "STOCK", 0.15, 5),' +
            '(6, "REITs", "REIT", 0.15, 6),' +
            '(7, "Reserva de Oportunidade", "OPORTUNIDADE", 0.025, 7),' +
            '(8, "Reserva de Valor", "VALOR", 0.025, 8)');

    await batch.commit();
  }

  void _atualizarBanco(Database db, int oldVersion, int newVersion) {}

  // Operacoes dos modelos

  Future<List<Ativo>> listarAtivos(String tipo) async {
    Database db = await this.db;
    return db.query(
      'ativos',
      where: 'tipo = ?',
      whereArgs: [tipo],
    ).then((ativos) => ativos.map((map) => Ativo.fromMap(map)).toList());
  }

  Future adicionarAtivo(Ativo ativo) async {
    Database db = await this.db;
    await db.insert('ativos', ativo.toMap());
  }

  Future atualizarAtivo(Ativo ativo) async {
    Database db = await this.db;
    await db.update('ativos', ativo.toMap(),
        where: 'id = ?', whereArgs: [ativo.id]);
  }

  Future removerAtivo(Ativo ativo) async {
    Database db = await this.db;
    await db.delete('ativos', where: 'id = ?', whereArgs: [ativo.id]);
  }

  Future<List<Objetivo>> listarObjetivos() async {
    Database db = await this.db;
    return db
        .rawQuery('SELECT ' +
            '  o.id, ' +
            '  o.nome, ' +
            '  o.tipo, ' +
            '  o.valor, ' +
            '  o.ideal, ' +
            '  IFNULL((o.valor / o.tudo), 0.0) as atual, ' +
            '  IFNULL((o.ideal - o.valor / o.tudo), 0.0) as falta, ' +
            '  o.ordem ' +
            'FROM ( ' +
            '  SELECT  ' +
            '    o1.*,  ' +
            '    IFNULL( ' +
            '      IFNULL( ' +
            '        (select sum(a.cotacao * a.quantidade) from ativos a where a.tipo = o1.tipo),  ' +
            '      (select sum(r.valor) from reservas r where r.tipo = o1.tipo) ' +
            '      ),  ' +
            '    0.0) as valor, ' +
            '    (IFNULL((select sum(a.cotacao * a.quantidade) from ativos a), 0.0) + ' +
            '    IFNULL((select sum(r.valor) from reservas r), 0.0)) as tudo ' +
            '  FROM objetivos o1  ' +
            ') AS o ' +
            'ORDER BY o.ordem ASC ')
        .then((objetivos) =>
            objetivos.map((map) => Objetivo.fromMap(map)).toList());
  }

  Future<List<Percentual>> listarPercentuais(String tipoAtivo) async {
    Database db = await this.db;
    return db.rawQuery(
        'SELECT ' +
            '	CASE WHEN A.TIPO == "RF" THEN A.NOME ELSE A.TICKER END AS descricao, ' +
            '    (A.VALOR / A.TOTAL_ATIVOS) atual, ' +
            '    (A.PESO / A.TOTAL_PESOS) ideal, ' +
            '    (A.PESO / A.TOTAL_PESOS - A.VALOR / A.TOTAL_ATIVOS) falta ' +
            'FROM ( ' +
            '  SELECT *, ' +
            '  (A1.cotacao * A1.quantidade) AS VALOR, ' +
            '  (SELECT SUM(A2.cotacao * A2.quantidade) FROM ATIVOS A2 WHERE A2.TIPO = A1.TIPO) AS TOTAL_ATIVOS, ' +
            '  (SELECT SUM(A2.PESO) FROM ATIVOS A2 WHERE A2.TIPO = A1.TIPO) AS TOTAL_PESOS ' +
            '  FROM ATIVOS A1 ' +
            '  WHERE A1.TIPO = ? ' +
            ') AS A ' +
            'ORDER BY FALTA DESC',
        [
          tipoAtivo
        ]).then(
        (aportes) => aportes.map((map) => Percentual.fromMap(map)).toList());
  }

  Future atualizarObjetivos(List<Objetivo> objetivos) async {
    Database db = await this.db;
    Batch batch = db.batch();
    objetivos.forEach((objetivo) {
      batch.update('objetivos', {'ideal': objetivo.ideal},
          where: 'id = ?', whereArgs: [objetivo.id]);
    });
    await batch.commit();
  }

  Future<List<Divida>> listarDividas() async {
    Database db = await this.db;
    return db
        .query('dividas')
        .then((dividas) => dividas.map((map) => Divida.fromMap(map)).toList());
  }

  Future<List<Reserva>> listarReservas(String tipo) async {
    Database db = await this.db;
    return db.query(
      'reservas',
      where: 'tipo = ?',
      whereArgs: [tipo],
    ).then((reservas) => reservas.map((map) => Reserva.fromMap(map)).toList());
  }

  Future adicionarReserva(Reserva reserva) async {
    Database db = await this.db;
    await db.insert('reservas', reserva.toMap());
  }

  Future atualizarReserva(Reserva reserva) async {
    Database db = await this.db;
    await db.update('reservas', reserva.toMap(),
        where: 'id = ?', whereArgs: [reserva.id]);
  }

  Future removerReserva(Reserva reserva) async {
    Database db = await this.db;
    await db.delete('reservas', where: 'id = ?', whereArgs: [reserva.id]);
  }
}
