class PesoGiornaliero {
  final String id;
  final String personaId;
  final DateTime data;
  final double peso; // kg
  final String? nota; // opzionale ("a digiuno", "dopo allenamento", etc.)

  PesoGiornaliero({
    required this.id,
    required this.personaId,
    required this.data,
    required this.peso,
    this.nota,
  });

  /// Crea un nuovo PesoGiornaliero per oggi
  factory PesoGiornaliero.oggi({
    required String personaId,
    required double peso,
    String? nota,
  }) {
    final now = DateTime.now();
    return PesoGiornaliero(
      id: '${personaId}_${now.millisecondsSinceEpoch}',
      personaId: personaId,
      data: DateTime(now.year, now.month, now.day),
      peso: peso,
      nota: nota,
    );
  }

  /// Verifica se questo peso è di oggi
  bool get isOggi {
    final now = DateTime.now();
    return data.year == now.year &&
        data.month == now.month &&
        data.day == now.day;
  }

  /// Restituisce la data normalizzata (solo giorno, senza ora)
  DateTime get dataNormalizzata => DateTime(data.year, data.month, data.day);

  /// Crea una copia con valori aggiornati
  PesoGiornaliero copyWith({
    String? id,
    String? personaId,
    DateTime? data,
    double? peso,
    String? nota,
  }) {
    return PesoGiornaliero(
      id: id ?? this.id,
      personaId: personaId ?? this.personaId,
      data: data ?? this.data,
      peso: peso ?? this.peso,
      nota: nota ?? this.nota,
    );
  }

  factory PesoGiornaliero.fromJson(Map<String, dynamic> json) {
    return PesoGiornaliero(
      id: json['id'] as String,
      personaId: json['persona_id'] as String,
      data: DateTime.parse(json['data'] as String),
      peso: (json['peso'] as num).toDouble(),
      nota: json['nota'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'persona_id': personaId,
        'data': data.toIso8601String(),
        'peso': peso,
        'nota': nota,
      };

  @override
  String toString() => 'PesoGiornaliero($data: $peso kg)';
}
