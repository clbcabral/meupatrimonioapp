import 'package:firebase_auth/firebase_auth.dart';

class ServicoAutenticacao {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<FirebaseUser> get user {
    return _auth.onAuthStateChanged;
  }

  Future registrar(String email, String senha) async {
    try {
      AuthResult result = await _auth.createUserWithEmailAndPassword(
          email: email, password: senha);
      return result.user;
    } catch (e) {
      return e.message;
    }
  }

  Future recuperarSenha(String email) async {
    try {
      return _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      return e.message;
    }
  }

  Future login(String email, String senha) async {
    try {
      AuthResult result =
          await _auth.signInWithEmailAndPassword(email: email, password: senha);
      return result.user;
    } catch (e) {
      return e.message;
    }
  }

  Future logout() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      return e.message;
    }
  }
}
