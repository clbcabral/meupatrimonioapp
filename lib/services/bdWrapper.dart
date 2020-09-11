import 'package:meupatrimonio/models/objetivo.dart';
import 'package:meupatrimonio/models/usuario.dart';
import 'package:meupatrimonio/services/bdRemoto.dart';
import 'package:meupatrimonio/vals/constantes.dart';
import 'package:uuid/uuid.dart';

class BancoWrapper {
  final String uid;
  ServicoBancoRemoto _remoto;

  BancoWrapper(this.uid) {
    this._remoto = ServicoBancoRemoto(this.uid);
  }

  Future adicionarUsuario(Usuario usuario) async {
    await _remoto.adicionarUsuario(usuario);
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
  }
}
