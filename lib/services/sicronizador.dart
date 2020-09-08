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

  void sincronizarParaBDRemovo() async {
    sincronizarObjetivos();
    sincronizarAtivos();
    sincronizarReservas();
  }

  Future sincronizarParaBDLocal() async {
    if (await _local.obterUsuario(uid) == null) {
      final List<Future> obterEAdicionar = [
        _remoto
            .obterUsuario()
            .then((usuario) => _local.adicionarUsuario(usuario)),
        _remoto.listarObjetivos().then(
            (objetivosRemotos) => _local.adicionarObjetivos(objetivosRemotos)),
        _remoto
            .listarAtivos()
            .then((ativosRemotos) => _local.adicionarAtivos(ativosRemotos)),
        _remoto.listarReservas().then(
            (reservasRemotas) => _local.adicionarReservas(reservasRemotas)),
      ];
      await Future.wait(obterEAdicionar);
    }
  }

  void sincronizarObjetivos() async {
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

  void sincronizarAtivos() async {
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

  void sincronizarReservas() async {
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
}
