import 'alimento.dart';

enum TipoPasto {
  colazione,
  spuntinoMattina,
  pranzo,
  merenda,
  cena,
  spuntinoSera,
  duranteGiornata,
}

extension TipoPastoExtension on TipoPasto {
  String get label {
    switch (this) {
      case TipoPasto.colazione: return 'Colazione';
      case TipoPasto.spuntinoMattina: return 'Spuntino Mattina';
      case TipoPasto.pranzo: return 'Pranzo';
      case TipoPasto.merenda: return 'Merenda';
      case TipoPasto.cena: return 'Cena';
      case TipoPasto.spuntinoSera: return 'Spuntino Sera';
      case TipoPasto.duranteGiornata: return 'Durante la Giornata';
    }
  }

  String get tipoEmoji {
    switch (this) {
      case TipoPasto.colazione: return '🌅';
      case TipoPasto.spuntinoMattina: return '🍊';
      case TipoPasto.pranzo: return '🍽️';
      case TipoPasto.merenda: return '🍎';
      case TipoPasto.cena: return '🌙';
      case TipoPasto.spuntinoSera: return '🍵';
      case TipoPasto.duranteGiornata: return '✨';
    }
  }
}

class Pasto {
  final TipoPasto tipo;
  final List<Alimento> alimenti;
  final String? nota;

  Pasto({
    required this.tipo,
    required this.alimenti,
    this.nota,
  });

  factory Pasto.fromJson(Map<String, dynamic> json, TipoPasto tipo) => Pasto(
    tipo: tipo,
    alimenti: (json['alimenti'] as List<dynamic>)
        .map((e) => Alimento.fromJson(e as Map<String, dynamic>))
        .toList(),
    nota: json['nota'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'alimenti': alimenti.map((e) => e.toJson()).toList(),
    'nota': nota,
  };

  String get tipoLabel {
    switch (tipo) {
      case TipoPasto.colazione: return 'Colazione';
      case TipoPasto.spuntinoMattina: return 'Spuntino Mattina';
      case TipoPasto.pranzo: return 'Pranzo';
      case TipoPasto.merenda: return 'Merenda';
      case TipoPasto.cena: return 'Cena';
      case TipoPasto.spuntinoSera: return 'Spuntino Sera';
      case TipoPasto.duranteGiornata: return 'Durante la Giornata';
    }
  }

  String get tipoEmoji {
    switch (tipo) {
      case TipoPasto.colazione: return '🌅';
      case TipoPasto.spuntinoMattina: return '🍊';
      case TipoPasto.pranzo: return '🍽️';
      case TipoPasto.merenda: return '🍎';
      case TipoPasto.cena: return '🌙';
      case TipoPasto.spuntinoSera: return '🍵';
      case TipoPasto.duranteGiornata: return '✨';
    }
  }
}
