import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meupatrimonio/models/ativo.dart';
import 'package:meupatrimonio/models/objetivo.dart';
import 'package:meupatrimonio/models/reserva.dart';
import 'package:meupatrimonio/models/usuario.dart';
import 'package:meupatrimonio/vals/constantes.dart';

class ServicoBancoRemoto {
  final String uid;
  DocumentReference db;

  ServicoBancoRemoto(this.uid) {
    this.db = Firestore.instance.collection('usuarios').document(this.uid);
  }

  Future adicionarUsuario(Usuario usuario) async {
    await db.setData(usuario.toMap());
  }

  Future<Usuario> obterUsuario() {
    return db.get().then((snapshot) => Usuario.fromMap(snapshot.data));
  }

  Future adicionarObjetivos(List<Objetivo> objetivos) async {
    WriteBatch batch = Firestore.instance.batch();
    objetivos.forEach((objetivo) {
      batch.setData(
        db.collection('objetivos').document(objetivo.id),
        objetivo.toMap(),
      );
    });
    await batch.commit();
  }

  Future removerAtivo(Ativo ativo) async {
    await db.collection('ativos').document(ativo.id).delete();
  }

  Future removerReserva(Reserva reserva) async {
    await db.collection('reservas').document(reserva.id).delete();
  }

  Future adicionarAtivo(Ativo ativo) async {
    await db.collection('ativos').document(ativo.id).setData(ativo.toMap());
  }

  Future atualizarAtivo(Ativo ativo) async {
    await db.collection('ativos').document(ativo.id).updateData(ativo.toMap());
  }

  Future adicionarReserva(Reserva reserva) async {
    await db
        .collection('reservas')
        .document(reserva.id)
        .setData(reserva.toMap());
  }

  Future atualizarReserva(Reserva reserva) async {
    await db
        .collection('reservas')
        .document(reserva.id)
        .updateData(reserva.toMap());
  }

  Future atualizarObjetivos(List<Objetivo> objetivos) async {
    WriteBatch batch = Firestore.instance.batch();
    objetivos.forEach((objetivo) {
      batch.updateData(
        db.collection('objetivos').document(objetivo.id),
        {'ideal': objetivo.ideal},
      );
    });
    await batch.commit();
  }

  Future atualizarAtivos(List<Ativo> ativos) async {
    WriteBatch batch = Firestore.instance.batch();
    ativos.forEach((ativo) {
      batch.updateData(
        db.collection('ativos').document(ativo.id),
        {'cotacao': ativo.cotacao},
      );
    });
    await batch.commit();
  }

  Future<List<Ativo>> listarAtivos(String tipo) async {
    return db
        .collection('ativos')
        .where('tipo', isEqualTo: tipo)
        .getDocuments()
        .then((snapshot) =>
            snapshot.documents.map((map) => Ativo.fromMap(map.data)).toList());
  }

  Future<List<Ativo>> listarAtivosRendaVariavel() async {
    return db
        .collection('ativos')
        .where('tipo',
            whereIn: [ATIVO_ACAO, ATIVO_FII, ATIVO_REIT, ATIVO_STOCK])
        .getDocuments()
        .then((snapshot) =>
            snapshot.documents.map((map) => Ativo.fromMap(map.data)).toList());
  }

  Future<List<Objetivo>> listarObjetivos() async {
    List<Ativo> ativos = await db.collection('ativos').getDocuments().then(
        (snapshot) =>
            snapshot.documents.map((map) => Ativo.fromMap(map.data)).toList());
    List<Reserva> reservas = await db
        .collection('reservas')
        .getDocuments()
        .then((snapshot) => snapshot.documents
            .map((map) => Reserva.fromMap(map.data))
            .toList());
    double totalAtivos =
        ativos.fold(0.0, (val, ativo) => val + (ativo.valor()));
    double totalReservas =
        reservas.fold(0.0, (val, reserva) => val + (reserva.valor));
    return db
        .collection('objetivos')
        .orderBy('ordem')
        .getDocuments()
        .then((snapshot) => snapshot.documents.map((map) {
              Objetivo objetivo = Objetivo.fromMap(map.data);
              return _preencherValorObjetivo(
                  objetivo, ativos, reservas, totalAtivos, totalReservas);
            }).toList());
  }

  Objetivo _preencherValorObjetivo(Objetivo objetivo, List<Ativo> ativos,
      List<Reserva> reservas, double totalAtivos, double totalReservas) {
    double totalTipoAtivos = ativos
        .where((a) => objetivo.tipo == a.tipo)
        .fold(0.0, (val, a) => val + (a.valor()));
    double totalTipoReservas = reservas
        .where((r) => objetivo.tipo == r.tipo)
        .fold(0.0, (val, r) => val + (r.valor));
    double total = totalTipoAtivos + totalTipoReservas;
    objetivo.valor = total;
    objetivo.atual = total / (total == 0 ? 1 : (totalAtivos + totalReservas));
    objetivo.falta = objetivo.ideal - objetivo.atual;
    return objetivo;
  }

  Future<List<Reserva>> listarReservas(String tipo) async {
    return db
        .collection('reservas')
        .where('tipo', isEqualTo: tipo)
        .getDocuments()
        .then((snapshot) => snapshot.documents
            .map((map) => Reserva.fromMap(map.data))
            .toList());
  }
}
