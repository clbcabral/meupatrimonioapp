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
    Map<String, dynamic> tabelas = {
      'ativos': {
        'model': Ativo.exemplo(),
        'primaryKey': 'id',
      },
      'dividas': {
        'model': Divida.exemplo(),
        'primaryKey': 'id',
      },
      'reservas': {
        'model': Reserva.exemplo(),
        'primaryKey': 'id',
      },
      'objetivos': {
        'model': Objetivo.exemplo(),
        'primaryKey': 'id',
      },
    };

    Batch batch = db.batch();

    tabelas.forEach((nomeTabela, dados) async {
      String query = '';
      for (MapEntry<String, dynamic> coluna in dados['model'].toMap().entries) {
        if (coluna.key.startsWith('sum')) {
          continue;
        }
        query += '${coluna.key} ${getTipoNaDB(coluna.value)}';
        if (coluna.key == dados['primaryKey']) {
          query += ' PRIMARY KEY';
        }
        query += ', ';
      }
      query = query.substring(0, query.length - 2);
      batch.execute('CREATE TABLE $nomeTabela($query)');
    });

    batch.execute(
        'INSERT INTO objetivos (ID, NOME, TIPO, PERCENTUAL, VALOR, ORDEM) VALUES ' +
            '(1, "Reserva de Emergência", "EMERGENCIA", 5.0, 0.0, 1),' +
            '(2, "Ações", "ACAO", 15.0, 0.0, 2),' +
            '(3, "FIIs", "FII", 15.0, 0.0, 3),' +
            '(4, "Renda Fixa", "RF", 30.0, 0.0, 4),' +
            '(5, "Stocks", "STOCK", 15.0, 0.0, 5),' +
            '(6, "REITs", "REIT", 15.0, 0.0, 6),' +
            '(7, "Reserva de Oportunidade", "OPORTUNIDADE", 2.5, 0.0, 7),' +
            '(8, "Reserva de Valor", "VALOR", 2.5, 0.0, 8)');

    await batch.commit();
  }

  void _atualizarBanco(Database db, int oldVersion, int newVersion) {}

  String getTipoNaDB(dynamic column) {
    if (column is String) {
      return 'TEXT';
    } else if (column is int) {
      return 'INTEGER';
    } else if (column is bool) {
      return 'INTEGER'; // 1 - true, 0 - false
    } else if (column is DateTime) {
      return 'TEXT';
    } else if (column is double) {
      return 'REAL';
    } else {
      return 'TEXT';
    }
  }

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
        .rawQuery('SELECT o.*, ' +
            'IFNULL(IFNULL((select sum(a.cotacao * a.quantidade) from ativos a where a.tipo = o.tipo), ' +
            '      (select sum(r.valor) from reservas r where r.tipo = o.tipo)), 0.0) as sumValores ' +
            'FROM objetivos o ' +
            'ORDER BY o.ordem ASC')
        .then((objetivos) =>
            objetivos.map((map) => Objetivo.fromMap(map)).toList());
  }

  Future atualizarObjetivos(List<Objetivo> objetivos) async {
    Database db = await this.db;
    Batch batch = db.batch();
    objetivos.forEach((objetivo) {
      batch.update('objetivos', {'percentual': objetivo.percentual},
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
