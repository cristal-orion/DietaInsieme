import 'pasto.dart';

/// Risultato dell'analisi di un pasto per due persone
class PastoAnalizzato {
  final int giorno;
  final TipoPasto tipoPasto;
  final List<AlimentoComune> alimentiComuni;
  final List<SceltaAlternative> scelteDaFare;
  final List<AlimentoSeparato> alimentiSeparati;
  
  PastoAnalizzato({
    required this.giorno,
    required this.tipoPasto,
    required this.alimentiComuni,
    required this.scelteDaFare,
    required this.alimentiSeparati,
  });
  
  /// Percentuale di compatibilità (0-100)
  double get compatibilita {
    final totale = alimentiComuni.length + scelteDaFare.length + alimentiSeparati.length;
    if (totale == 0) return 0;
    final compatibili = alimentiComuni.length + scelteDaFare.length;
    return (compatibili / totale) * 100;
  }
  
  /// Messaggio riepilogativo
  String get messaggioCompatibilita {
    if (compatibilita >= 80) return "Potete cucinare quasi tutto insieme! 🎉";
    if (compatibilita >= 50) return "Buona compatibilità, alcune cose separate";
    return "Pasti abbastanza diversi oggi";
  }
}

/// Alimento che entrambi possono mangiare (stesso nome)
class AlimentoComune {
  final String nome;
  final String quantitaPersona1;
  final String quantitaPersona2;
  final bool stessaQuantita;
  
  AlimentoComune({
    required this.nome,
    required this.quantitaPersona1,
    required this.quantitaPersona2,
  }) : stessaQuantita = quantitaPersona1 == quantitaPersona2;
}

/// Categoria dove devono scegliere un'alternativa comune
class SceltaAlternative {
  final String categoria; // es. "Verdura", "Primo"
  final List<String> alternativeComuni; // opzioni valide per entrambi
  final List<AlternativaPersonale> soloPersona1;
  final List<AlternativaPersonale> soloPersona2;
  String? sceltaEffettuata; // l'alternativa scelta
  
  SceltaAlternative({
    required this.categoria,
    required this.alternativeComuni,
    required this.soloPersona1,
    required this.soloPersona2,
    this.sceltaEffettuata,
  });
  
  bool get haAlternativeComuni => alternativeComuni.isNotEmpty;
}

class AlternativaPersonale {
  final String nome;
  final String quantita;
  
  AlternativaPersonale({required this.nome, required this.quantita});
}

/// Alimento presente solo per una persona
class AlimentoSeparato {
  final String persona; // "Michele" o "Rossana"
  final String nome;
  final String quantita;
  
  AlimentoSeparato({
    required this.persona,
    required this.nome,
    required this.quantita,
  });
}
