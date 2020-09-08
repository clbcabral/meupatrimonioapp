enum MetodoAutenticacao { Login, Registro }
enum Banco { Local, Remoto }

const String LOCAL_DB_FILE = 'v2';
const String ATIVO_ACAO = "ACAO";
const String ATIVO_FII = "FII";
const String ATIVO_RF = "RF";
const String ATIVO_STOCK = "STOCK";
const String ATIVO_REIT = "REIT";
const String REVERSA_EMERGENCIA = "EMERGENCIA";
const String REVERSA_OPORTUNIDADE = "OPORTUNIDADE";
const String REVERSA_VALOR = "VALOR";
const String DOLAR_TICKER = 'BRL=X';

const List<Map<String, dynamic>> objetivosPadrao = [
  {
    'nome': 'Reserva de Emergência',
    'tipo': 'EMERGENCIA',
    'ideal': 0.05,
    'ordem': 1,
  },
  {
    'nome': 'Ações',
    'tipo': 'ACAO',
    'ideal': 0.15,
    'ordem': 2,
  },
  {
    'nome': 'FIIs',
    'tipo': 'FII',
    'ideal': 0.15,
    'ordem': 3,
  },
  {
    'nome': 'Renda Fixa',
    'tipo': 'RF',
    'ideal': 0.3,
    'ordem': 4,
  },
  {
    'nome': 'Stocks',
    'tipo': 'STOCK',
    'ideal': 0.15,
    'ordem': 5,
  },
  {
    'nome': 'REITs',
    'tipo': 'REIT',
    'ideal': 0.15,
    'ordem': 6,
  },
  {
    'nome': 'Reserva de Oportunidade',
    'tipo': 'OPORTUNIDADE',
    'ideal': 0.025,
    'ordem': 7,
  },
  {
    'nome': 'Reserva de Valor',
    'tipo': 'VALOR',
    'ideal': 0.025,
    'ordem': 8,
  }
];
