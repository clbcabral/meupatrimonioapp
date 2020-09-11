import 'package:flutter/material.dart';
import 'package:meupatrimonio/models/usuario.dart';
import 'package:meupatrimonio/services/autenticacao.dart';
import 'package:meupatrimonio/services/bdWrapper.dart';
import 'package:meupatrimonio/shared/componentes.dart';
import 'package:meupatrimonio/vals/constantes.dart';
import 'package:meupatrimonio/vals/strings.dart';

class AutenticacaoForm extends StatefulWidget {
  final Function callback;
  final MetodoAutenticacao metodo;

  AutenticacaoForm({this.callback, this.metodo});

  @override
  _AutenticacaoFormState createState() => _AutenticacaoFormState();
}

class _AutenticacaoFormState extends State<AutenticacaoForm> {
  final ServicoAutenticacao _servico = ServicoAutenticacao();
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmacaoSenhaController = TextEditingController();
  final _nomeController = TextEditingController();

  final FocusNode _emailFocus = new FocusNode();
  final FocusNode _senhaFocus = new FocusNode();
  final FocusNode _confirmacaoSenhaFocus = new FocusNode();
  final FocusNode _nomeFocus = new FocusNode();

  bool _emailEmFoco = false;
  bool _senhaEmFoco = false;
  bool _confirmacaoSenhaEmFoco = false;
  bool _nomeEmFoco = false;

  String _email = '';
  String _senha = '';
  String _confirmacaoSenha = '';
  String _nome = '';
  String _error = '';
  bool _carregando = false;
  bool _obscurePassword = true;
  bool _obscurePasswordConfirm = true;

  Widget title(bool isRegister) {
    return Text(
      isRegister ? Strings.registro : Strings.login,
      style: TextStyle(
        color: Colors.white,
      ),
    );
  }

  Widget titulo(bool isRegistro) {
    return Text(isRegistro ? Strings.login : Strings.registro);
  }

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(_checkFocus);
    _senhaFocus.addListener(_checkFocus);
    _confirmacaoSenhaFocus.addListener(_checkFocus);
    _nomeFocus.addListener(_checkFocus);
  }

  void _checkFocus() {
    setState(() {
      _emailEmFoco = _emailFocus.hasFocus;
      _senhaEmFoco = _senhaFocus.hasFocus;
      _confirmacaoSenhaEmFoco = _confirmacaoSenhaFocus.hasFocus;
      _nomeEmFoco = _nomeFocus.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isRegistro = widget.metodo == MetodoAutenticacao.Registro;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: title(isRegistro),
        actions: <Widget>[
          FlatButton(
            textColor: Colors.white,
            child: titulo(isRegistro),
            onPressed: () {
              widget.callback();
            },
          )
        ],
      ),
      body: _carregando
          ? Loader()
          : Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 25.0,
                ),
                children: <Widget>[
                  SizedBox(height: 10.0),
                  Center(
                    child: Text(
                      Strings.meuPatrimonio,
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  TextFormField(
                    controller: _emailController,
                    focusNode: _emailFocus,
                    autovalidate: _email.isNotEmpty,
                    validator: validadorEmail,
                    decoration: InputDecoration(
                      labelText: Strings.email,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (val) {
                      setState(() => _email = val);
                    },
                  ),
                  TextFormField(
                    controller: _senhaController,
                    focusNode: _senhaFocus,
                    autovalidate: _senha.isNotEmpty,
                    validator: validadorSenha,
                    decoration: InputDecoration(
                      labelText: Strings.senha,
                    ),
                    obscureText: _obscurePassword,
                    onChanged: (val) => setState(() => _senha = val),
                  ),
                  isRegistro
                      ? TextFormField(
                          controller: _confirmacaoSenhaController,
                          focusNode: _confirmacaoSenhaFocus,
                          autovalidate: _confirmacaoSenha.isNotEmpty,
                          validator: (val) =>
                              validadorConfirmacaoSenha(val, _senha),
                          decoration: InputDecoration(
                            labelText: Strings.senhaConfirmacao,
                          ),
                          obscureText: _obscurePasswordConfirm,
                          onChanged: (val) {
                            setState(() => _confirmacaoSenha = val);
                          },
                        )
                      : Container(),
                  isRegistro
                      ? TextFormField(
                          controller: _nomeController,
                          focusNode: _nomeFocus,
                          autovalidate: _nome.isNotEmpty,
                          validator: validadorNome,
                          decoration: InputDecoration(
                            labelText: Strings.nomeCompleto,
                          ),
                          textCapitalization: TextCapitalization.words,
                          onChanged: (val) => setState(() => _nome = val),
                        )
                      : Container(),
                  SizedBox(height: 10.0),
                  RaisedButton(
                    color: Theme.of(context).primaryColor,
                    child: title(isRegistro),
                    onPressed: () async {
                      setState(() => _error = '');
                      if (_formKey.currentState.validate()) {
                        setState(() => _carregando = true);
                        dynamic _usuario = isRegistro
                            ? await _servico.registrar(_email, _senha)
                            : await _servico.login(_email, _senha);
                        if (_usuario is String) {
                          setState(() {
                            _carregando = false;
                            _error = _usuario;
                          });
                        } else if (isRegistro) {
                          BancoWrapper(_usuario.uid).adicionarUsuario(
                            Usuario(
                              id: _usuario.uid,
                              email: _email,
                              nome: _nome,
                            ),
                          );
                          BancoWrapper(_usuario.uid).adicionarObjetivos();
                        }
                      }
                    },
                  ),
                  SizedBox(height: 12.0),
                  Text(
                    _error,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 14.0,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

String validadorEmail(val) {
  if (val.isEmpty) {
    return Strings.validacaoEmailObrigatorio;
  }
  if (!RegExp(
          r'^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
      .hasMatch(val)) {
    return Strings.validacaoEmailInvalido;
  }
  return null;
}

String validadorSenha(val) {
  if (val.length < 6) {
    return Strings.validacaoTamanhoSenha;
  }
  return null;
}

String validadorConfirmacaoSenha(val, senha) {
  if (val.isEmpty) {
    return Strings.validacaoCampoRequerido;
  }
  if (val != senha) {
    return Strings.validacaoSenhasIguais;
  }
  return null;
}

String validadorNome(val) {
  if (val.isEmpty) {
    return Strings.validacaoCampoRequerido;
  }
  return null;
}

extension on TextEditingController {
  void safeClear() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      this.clear();
    });
  }
}
