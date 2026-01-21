import 'pasto.dart';

class Giorno {
  final int numero;
  final Map<TipoPasto, Pasto> pasti;

  Giorno({
    required this.numero,
    required this.pasti,
  });

  factory Giorno.fromJson(Map<String, dynamic> json) {
    final pastiJson = json['pasti'] as Map<String, dynamic>;
    final Map<TipoPasto, Pasto> pasti = {};
    
    final mapping = {
      'colazione': TipoPasto.colazione,
      'spuntino_mattina': TipoPasto.spuntinoMattina,
      'pranzo': TipoPasto.pranzo,
      'merenda': TipoPasto.merenda,
      'cena': TipoPasto.cena,
      'spuntino_sera': TipoPasto.spuntinoSera,
      'durante_giornata': TipoPasto.duranteGiornata,
    };

    pastiJson.forEach((key, value) {
      if (value != null && mapping.containsKey(key)) {
        pasti[mapping[key]!] = Pasto.fromJson(value as Map<String, dynamic>, mapping[key]!);
      }
    });

    return Giorno(
      numero: json['numero'] as int,
      pasti: pasti,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> pastiJson = {};
    
    pasti.forEach((tipo, pasto) {
      String key;
      switch (tipo) {
        case TipoPasto.colazione: key = 'colazione'; break;
        case TipoPasto.spuntinoMattina: key = 'spuntino_mattina'; break;
        case TipoPasto.pranzo: key = 'pranzo'; break;
        case TipoPasto.merenda: key = 'merenda'; break;
        case TipoPasto.cena: key = 'cena'; break;
        case TipoPasto.spuntinoSera: key = 'spuntino_sera'; break;
        case TipoPasto.duranteGiornata: key = 'durante_giornata'; break;
      }
      pastiJson[key] = pasto.toJson();
    });

    return {
      'numero': numero,
      'pasti': pastiJson,
    };
  }

  Pasto? getPasto(TipoPasto tipo) => pasti[tipo];
}
