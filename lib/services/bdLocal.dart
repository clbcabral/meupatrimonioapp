import 'package:meupatrimonio/models/percentual.dart';
import 'package:meupatrimonio/models/ativo.dart';
import 'package:meupatrimonio/models/objetivo.dart';
import 'package:meupatrimonio/models/reserva.dart';
import 'package:meupatrimonio/models/usuario.dart';
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
        'create table usuarios (id TEXT PRIMARY KEY, email TEXT, nome TEXT)');
    batch.execute(
        'create table ativos (id TEXT PRIMARY KEY, nome TEXT, ticker TEXT, cotacao REAL, quantidade REAL, peso REAL, tipo TEXT, uid TEXT)');
    batch.execute(
        'create table reservas (id TEXT PRIMARY KEY, nome TEXT, valor REAL, tipo TEXT, uid TEXT)');
    batch.execute(
        'create table objetivos (id TEXT PRIMARY KEY, nome TEXT, tipo TEXT, ideal REAL, ordem INTEGER, uid TEXT)');
    await batch.commit();
  }

  void _atualizarBanco(Database db, int oldVersion, int newVersion) {}

  // Operacoes dos modelos

  Future adicionarUsuario(Usuario usuario) async {
    Database db = await this.db;
    await db.insert('usuarios', usuario.toMap());
  }

  Future<Usuario> obterUsuario(String uid) async {
    Database db = await this.db;
    return db.query(
      'usuarios',
      where: 'id = ?',
      whereArgs: [uid],
    ).then((map) => map.length == 1 ? Usuario.fromMap(map[0]) : null);
  }

  Future adicionarObjetivos(List<Objetivo> objetivos) async {
    Database db = await this.db;
    Batch batch = db.batch();
    objetivos.forEach((objetivo) {
      batch.insert('objetivos', {
        'id': objetivo.id,
        'nome': objetivo.nome,
        'tipo': objetivo.tipo,
        'ideal': objetivo.ideal,
        'ordem': objetivo.ordem,
        'uid': objetivo.uid,
      });
    });
    await batch.commit();
  }

  Future adicionarAtivos(List<Ativo> ativos) async {
    Database db = await this.db;
    Batch batch = db.batch();
    ativos.forEach((ativo) {
      batch.insert('ativos', ativo.toMap());
    });
    await batch.commit();
  }

  Future adicionarReservas(List<Reserva> reservas) async {
    Database db = await this.db;
    Batch batch = db.batch();
    reservas.forEach((reserva) {
      batch.insert('reservas', reserva.toMap());
    });
    await batch.commit();
  }

  Future<List<Ativo>> listarAtivos(String uid, String tipo) async {
    Database db = await this.db;
    return db.query(
      'ativos',
      where: 'tipo = ? AND uid = ?',
      whereArgs: [tipo, uid],
    ).then((ativos) => ativos.map((map) => Ativo.fromMap(map)).toList());
  }

  Future<List<Ativo>> listarTodosAtivos(String uid) async {
    Database db = await this.db;
    return db.query(
      'ativos',
      where: 'uid = ?',
      whereArgs: [uid],
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

  Future<List<Objetivo>> listarObjetivos(String uid) async {
    Database db = await this.db;
    return db.rawQuery(
        'SELECT ' +
            '  o.id, ' +
            '  o.nome, ' +
            '  o.tipo, ' +
            '  o.valor, ' +
            '  o.ideal, ' +
            '  IFNULL((o.valor / o.tudo), 0.0) as atual, ' +
            '  IFNULL((o.ideal - o.valor / o.tudo), o.ideal) as falta, ' +
            '  o.ordem, ' +
            '  o.uid ' +
            'FROM ( ' +
            '  SELECT  ' +
            '    o1.*,  ' +
            '    IFNULL( ' +
            '      IFNULL( ' +
            '        (select sum(a.cotacao * a.quantidade) from ativos a where a.tipo = o1.tipo and a.uid = o1.uid),  ' +
            '      (select sum(r.valor) from reservas r where r.tipo = o1.tipo and r.uid = o1.uid) ' +
            '      ),  ' +
            '    0.0) as valor, ' +
            '    (IFNULL((select sum(a.cotacao * a.quantidade) from ativos a where a.uid = o1.uid), 0.0) + ' +
            '    IFNULL((select sum(r.valor) from reservas r where r.uid = o1.uid), 0.0)) as tudo ' +
            '  FROM objetivos o1  ' +
            '  WHERE o1.uid = ?  ' +
            ') AS o ' +
            'ORDER BY o.ordem ASC ',
        [
          uid
        ]).then(
        (objetivos) => objetivos.map((map) => Objetivo.fromMap(map)).toList());
  }

  Future removerObjetivos(List<Objetivo> objetivos) async {
    Database db = await this.db;
    Batch batch = db.batch();
    objetivos.forEach((o) {
      batch.delete('objetivos', where: 'id = ?', whereArgs: [o.id]);
    });
    await batch.commit();
  }

  Future removerAtivos(List<Ativo> ativos) async {
    Database db = await this.db;
    Batch batch = db.batch();
    ativos.forEach((o) {
      batch.delete('ativos', where: 'id = ?', whereArgs: [o.id]);
    });
    await batch.commit();
  }

  Future removerReservas(List<Reserva> reservas) async {
    Database db = await this.db;
    Batch batch = db.batch();
    reservas.forEach((o) {
      batch.delete('reservas', where: 'id = ?', whereArgs: [o.id]);
    });
    await batch.commit();
  }

  Future<List<Percentual>> listarPercentuais(
      String uid, String tipoAtivo) async {
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
            '  (SELECT SUM(A2.cotacao * A2.quantidade) FROM ATIVOS A2 WHERE A2.TIPO = A1.TIPO AND A1.UID = A2.UID) AS TOTAL_ATIVOS, ' +
            '  (SELECT SUM(A2.PESO) FROM ATIVOS A2 WHERE A2.TIPO = A1.TIPO AND A1.UID = A2.UID) AS TOTAL_PESOS ' +
            '  FROM ATIVOS A1 ' +
            '  WHERE A1.TIPO = ? AND A1.UID = ?' +
            ') AS A ' +
            'ORDER BY FALTA DESC',
        [
          tipoAtivo,
          uid
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

  Future atualizarAtivos(List<Ativo> ativos) async {
    Database db = await this.db;
    Batch batch = db.batch();
    ativos.forEach((ativo) {
      batch.update('ativos', ativo.toMap(),
          where: 'id = ?', whereArgs: [ativo.id]);
    });
    await batch.commit();
  }

  Future<List<Reserva>> listarReservas(String uid, String tipo) async {
    Database db = await this.db;
    return db.query(
      'reservas',
      where: 'tipo = ? AND uid = ?',
      whereArgs: [tipo, uid],
    ).then((reservas) => reservas.map((map) => Reserva.fromMap(map)).toList());
  }

  Future<List<Reserva>> listarTodasReservas(String uid) async {
    Database db = await this.db;
    return db.query(
      'reservas',
      where: 'uid = ?',
      whereArgs: [uid],
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
