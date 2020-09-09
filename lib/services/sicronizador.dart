import 'package:meupatrimonio/models/ativo.dart';
import 'package:meupatrimonio/models/objetivo.dart';
import 'package:meupatrimonio/models/reserva.dart';
import 'package:meupatrimonio/services/bdLocal.dart';
import 'package:meupatrimonio/services/bdRemoto.dart';

class ServicoSincronizador {
  final String uid;
  ServicoBancoLocal _local;
  ServicoBancoRemoto _remoto;

  ServicoSincronizador(this.uid) {
    this._local = ServicoBancoLocal();
    this._remoto = ServicoBancoRemoto(this.uid);
  }

  void sincronizarParaBDRemoto() async {
    sincronizarObjetivosParaRemoto();
    sincronizarAtivosParaRemoto();
    sincronizarReservasParaRemoto();
  }

  Future sincronizarParaBDLocal() async {
    final List<Future> operacoes = [];
    if (await _local.obterUsuario(uid) == null) {
      operacoes.add(_remoto
          .obterUsuario()
          .then((usuario) => _local.adicionarUsuario(usuario)));
    }
    operacoes.addAll([
      sincronizarObjetivosParaLocal(),
      sincronizarAtivosParaLocal(),
      sincronizarReservasParaLocal(),
    ]);
    await Future.wait(operacoes);
  }

  void sincronizarObjetivosParaRemoto() async {
    List<Objetivo> objetivosRemotos = await _remoto.listarObjetivos();
    List<Objetivo> objetivosLocais = await _local.listarObjetivos(uid);
    List<Objetivo> objetivosSomenteRemotos = objetivosRemotos
        .where((cloud) =>
            objetivosLocais.where((local) => local.equalTo(cloud)).length == 0)
        .toList();
    List<Objetivo> objetivosSomenteLocais = objetivosLocais
        .where((local) =>
            objetivosRemotos.where((cloud) => cloud.equalTo(local)).length == 0)
        .toList();
    _remoto.removerObjetivos(objetivosSomenteRemotos);
    _remoto.adicionarObjetivos(objetivosSomenteLocais);
  }

  Future sincronizarObjetivosParaLocal() async {
    List<Objetivo> objetivosRemotos = await _remoto.listarObjetivos();
    List<Objetivo> objetivosLocais = await _local.listarObjetivos(uid);
    List<Objetivo> objetivosSomenteRemotos = objetivosRemotos
        .where((cloud) =>
            objetivosLocais.where((local) => local.equalTo(cloud)).length == 0)
        .toList();
    List<Objetivo> objetivosSomenteLocais = objetivosLocais
        .where((local) =>
            objetivosRemotos.where((cloud) => cloud.equalTo(local)).length == 0)
        .toList();
    await Future.wait([
      _local.removerObjetivos(objetivosSomenteLocais),
      _local.adicionarObjetivos(objetivosSomenteRemotos),
    ]);
  }

  void sincronizarAtivosParaRemoto() async {
    List<Ativo> ativosRemotos = await _remoto.listarAtivos();
    List<Ativo> avitosLocais = await _local.listarTodosAtivos(uid);
    List<Ativo> ativosSomenteRemotos = ativosRemotos
        .where((cloud) =>
            avitosLocais.where((local) => local.equalTo(cloud)).length == 0)
        .toList();
    List<Ativo> ativosSomenteLocais = avitosLocais
        .where((local) =>
            ativosRemotos.where((cloud) => cloud.equalTo(local)).length == 0)
        .toList();
    _remoto.removerAtivos(ativosSomenteRemotos);
    _remoto.adicionarAtivos(ativosSomenteLocais);
  }

  Future sincronizarAtivosParaLocal() async {
    List<Ativo> ativosRemotos = await _remoto.listarAtivos();
    List<Ativo> avitosLocais = await _local.listarTodosAtivos(uid);
    List<Ativo> ativosSomenteRemotos = ativosRemotos
        .where((cloud) =>
            avitosLocais.where((local) => local.equalTo(cloud)).length == 0)
        .toList();
    List<Ativo> ativosSomenteLocais = avitosLocais
        .where((local) =>
            ativosRemotos.where((cloud) => cloud.equalTo(local)).length == 0)
        .toList();
    await Future.wait([
      _local.removerAtivos(ativosSomenteLocais),
      _local.adicionarAtivos(ativosSomenteRemotos),
    ]);
  }

  void sincronizarReservasParaRemoto() async {
    List<Reserva> reservasRemotas = await _remoto.listarReservas();
    List<Reserva> reservasLocais = await _local.listarTodasReservas(uid);
    List<Reserva> reservasSomenteRemotas = reservasRemotas
        .where((cloud) =>
            reservasLocais.where((local) => local.equalTo(cloud)).length == 0)
        .toList();
    List<Reserva> reservasSomenteLocais = reservasLocais
        .where((local) =>
            reservasRemotas.where((cloud) => cloud.equalTo(local)).length == 0)
        .toList();
    _remoto.removerReservas(reservasSomenteRemotas);
    _remoto.adicionarReservas(reservasSomenteLocais);
  }

  Future sincronizarReservasParaLocal() async {
    List<Reserva> reservasRemotas = await _remoto.listarReservas();
    List<Reserva> reservasLocais = await _local.listarTodasReservas(uid);
    List<Reserva> reservasSomenteRemotas = reservasRemotas
        .where((cloud) =>
            reservasLocais.where((local) => local.equalTo(cloud)).length == 0)
        .toList();
    List<Reserva> reservasSomenteLocais = reservasLocais
        .where((local) =>
            reservasRemotas.where((cloud) => cloud.equalTo(local)).length == 0)
        .toList();
    await Future.wait([
      _local.removerReservas(reservasSomenteLocais),
      _local.adicionarReservas(reservasSomenteRemotas),
    ]);
  }
}
