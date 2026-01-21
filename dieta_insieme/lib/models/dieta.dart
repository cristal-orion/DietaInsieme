import 'giorno.dart';

class Dieta {
  final String id;
  final String persona;
  final DateTime dataCaricamento;
  final List<Giorno> giorni;
  final String? noteGenerali;
  final String? prossimaVisita;
  final List<String> integratori;
  final DateTime? dataInizio;

  Dieta({
    required this.id,
    required this.persona,
    required this.dataCaricamento,
    required this.giorni,
    this.noteGenerali,
    this.prossimaVisita,
    this.integratori = const [],
    this.dataInizio,
  });

  factory Dieta.fromJson(Map<String, dynamic> json) => Dieta(
    id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
    persona: json['persona'] as String,
    dataCaricamento: DateTime.tryParse(json['data_caricamento'] ?? '') ?? DateTime.now(),
    giorni: (json['giorni'] as List<dynamic>)
        .map((e) => Giorno.fromJson(e as Map<String, dynamic>))
        .toList(),
    noteGenerali: json['note_generali'] as String?,
    prossimaVisita: json['prossima_visita'] as String?,
    integratori: (json['integratori'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList() ?? [],
    dataInizio: DateTime.tryParse(json['data_inizio'] ?? ''),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'persona': persona,
    'data_caricamento': dataCaricamento.toIso8601String(),
    'giorni': giorni.map((g) => g.toJson()).toList(),
    'note_generali': noteGenerali,
    'prossima_visita': prossimaVisita,
    'integratori': integratori,
    'data_inizio': dataInizio?.toIso8601String(),
  };
  
  // Helper method for local storage serialization if needed later, 
  // but strictly following the provided snippet for now.

  Giorno? getGiorno(int numero) {
    try {
      return giorni.firstWhere((g) => g.numero == numero);
    } catch (_) {
      return null;
    }
  }
}
