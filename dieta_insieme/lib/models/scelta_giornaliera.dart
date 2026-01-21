import 'pasto_comune.dart';

/// Scelte effettuate per un giorno/pasto
class SceltaGiornaliera {
  final int giorno;
  final String tipoPasto; // 'pranzo' o 'cena'
  final Map<String, String> scelte; // categoria -> alternativa scelta
  final DateTime dataScelta;
  
  SceltaGiornaliera({
    required this.giorno,
    required this.tipoPasto,
    required this.scelte,
    required this.dataScelta,
  });
  
  factory SceltaGiornaliera.fromJson(Map<String, dynamic> json) => SceltaGiornaliera(
    giorno: json['giorno'] as int,
    tipoPasto: json['tipo_pasto'] as String,
    scelte: Map<String, String>.from(json['scelte'] as Map),
    dataScelta: DateTime.parse(json['data_scelta'] as String),
  );
  
  Map<String, dynamic> toJson() => {
    'giorno': giorno,
    'tipo_pasto': tipoPasto,
    'scelte': scelte,
    'data_scelta': dataScelta.toIso8601String(),
  };
}
