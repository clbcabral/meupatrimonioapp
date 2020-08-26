import 'dart:convert';

import 'package:http/http.dart';

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
}
