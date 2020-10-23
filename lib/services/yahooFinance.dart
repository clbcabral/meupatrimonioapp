import 'dart:convert';

import 'package:http/http.dart';
import 'package:meupatrimonio/models/ativo.dart';
import 'package:meupatrimonio/services/bdRemoto.dart';
import 'package:meupatrimonio/vals/constantes.dart';

class ServicoYahooFinance {
  Future<Map<String, dynamic>> getTickersInfo(List<String> tickers) async {
    String all = tickers.map((e) => e.toUpperCase()).join(',');
    String url =
        "https://query1.finance.yahoo.com/v7/finance/quote?symbols=$all";
    final headers = {
      'User-Agent': 'MeuPatrimonioApp',
      'Accept': 'application/json'
    };
    final resposta = await get(url, headers: headers);
    if (resposta.statusCode == 200) {
      return json.decode(resposta.body);
    }
    return null;
  }

  Future atualizarCotacoes(String uid, List<Ativo> ativos) async {
    if (ativos.isNotEmpty) {
      List tickers = ativos.map((e) => e.ticker.toUpperCase()).toList();
      List<Future> operacoes = [
        this.getTickersInfo([DOLAR_TICKER]),
        this.getTickersInfo(tickers),
      ];
      List<dynamic> response = await Future.wait(operacoes);
      double dolar =
          response[0]['quoteResponse']['result'][0]['regularMarketPrice'];
      List resultados = response[1]['quoteResponse']['result'];
      resultados.forEach((element) {
        double cotacao = element['regularMarketPrice'];
        Ativo ativo =
            ativos[ativos.indexWhere((e) => e.ticker == element['symbol'])];
        ativo.cotacao = ativo.ehAtivoDolarizado() ? cotacao * dolar : cotacao;
      });
      return ServicoBancoRemoto(uid).atualizarAtivos(ativos);
    }
  }
}
