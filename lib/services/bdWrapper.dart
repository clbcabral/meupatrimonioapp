import 'package:meupatrimonio/models/objetivo.dart';
import 'package:meupatrimonio/models/usuario.dart';
import 'package:meupatrimonio/services/bdLocal.dart';
import 'package:meupatrimonio/services/bdRemoto.dart';
import 'package:meupatrimonio/vals/constantes.dart';
import 'package:uuid/uuid.dart';

class BancoWrapper {
  final String uid;
  ServicoBancoRemoto _remoto;
  ServicoBancoLocal _local;

  BancoWrapper(this.uid) {
    this._remoto = ServicoBancoRemoto(this.uid);
    this._local = ServicoBancoLocal();
  }

  Future adicionarUsuario(Usuario usuario) async {
    await _remoto.adicionarUsuario(usuario);
    await _local.adicionarUsuario(usuario);
  }

  Future adicionarObjetivos() async {
    List<Objetivo> objetivos = [];
    objetivosPadrao.asMap().forEach((index, obj) async {
      objetivos.add(Objetivo(
        id: Uuid().v1(),
        nome: obj['nome'],
        tipo: obj['tipo'],
        ideal: obj['ideal'],
        ordem: obj['ordem'],
        uid: uid,
      ));
    });
    await _remoto.adicionarObjetivos(objetivos);
    await _local.adicionarObjetivos(objetivos);
  }
}
