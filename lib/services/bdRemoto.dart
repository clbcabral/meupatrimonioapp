import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meupatrimonio/models/ativo.dart';
import 'package:meupatrimonio/models/objetivo.dart';
import 'package:meupatrimonio/models/percentual.dart';
import 'package:meupatrimonio/models/reserva.dart';
import 'package:meupatrimonio/models/usuario.dart';

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

  Future removerObjetivos(List<Objetivo> objetivos) async {
    WriteBatch batch = Firestore.instance.batch();
    objetivos.forEach((o) {
      batch.delete(db.collection('objetivos').document(o.id));
    });
    await batch.commit();
  }

  Future removerAtivos(List<Ativo> ativos) async {
    WriteBatch batch = Firestore.instance.batch();
    ativos.forEach((o) {
      batch.delete(db.collection('ativos').document(o.id));
    });
    await batch.commit();
  }

  Future removerReservas(List<Reserva> reservas) async {
    WriteBatch batch = Firestore.instance.batch();
    reservas.forEach((o) {
      batch.delete(db.collection('reservas').document(o.id));
    });
    await batch.commit();
  }

  Future<List<Ativo>> listarAtivos() async {
    return db.collection('ativos').getDocuments().then((snapshot) =>
        snapshot.documents.map((map) => Ativo.fromMap(map.data)).toList());
  }

  Future adicionarAtivos(List<Ativo> ativos) async {
    WriteBatch batch = Firestore.instance.batch();
    ativos.forEach((ativo) {
      batch.setData(
        db.collection('ativos').document(ativo.id),
        ativo.toMap(),
      );
    });
    await batch.commit();
  }

  Future adicionarReservas(List<Reserva> reservas) async {
    WriteBatch batch = Firestore.instance.batch();
    reservas.forEach((reserva) {
      batch.setData(
        db.collection('reservas').document(reserva.id),
        reserva.toMap(),
      );
    });
    await batch.commit();
  }

  Future<List<Objetivo>> listarObjetivos() async {
    return db.collection('objetivos').orderBy('ordem').getDocuments().then(
        (snapshot) => snapshot.documents
            .map((map) => Objetivo.fromMap(map.data))
            .toList());
  }

  Future<List<Reserva>> listarReservas() async {
    return db.collection('reservas').getDocuments().then((snapshot) =>
        snapshot.documents.map((map) => Reserva.fromMap(map.data)).toList());
  }
}
