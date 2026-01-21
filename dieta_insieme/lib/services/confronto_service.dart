import '../models/alimento.dart';
import '../models/pasto.dart';

enum TipoCompatibilita {
  identico,       // Stesso alimento, stessa quantità
  quantitaDiversa, // Stesso alimento, quantità diverse
  alternativaComune, // Alimenti diversi ma hanno alternative in comune
  diverso,        // Completamente diversi
  soloUno,        // Presente solo in una dieta
}

class ConfrontoAlimento {
  final Alimento? alimentoPersona1;
  final Alimento? alimentoPersona2;
  final TipoCompatibilita compatibilita;
  final List<String> alternativeComuni;

  ConfrontoAlimento({
    this.alimentoPersona1,
    this.alimentoPersona2,
    required this.compatibilita,
    this.alternativeComuni = const [],
  });
}

class ConfrontoPasto {
  final Pasto? pastoPersona1;
  final Pasto? pastoPersona2;
  final List<ConfrontoAlimento> confrontoAlimenti;
  final double percentualeCompatibilita;

  ConfrontoPasto({
    this.pastoPersona1,
    this.pastoPersona2,
    required this.confrontoAlimenti,
    required this.percentualeCompatibilita,
  });
}

class ConfrontoService {
  
  /// Confronta due pasti e trova compatibilità
  ConfrontoPasto confrontaPasti(Pasto? pasto1, Pasto? pasto2) {
    if (pasto1 == null || pasto2 == null) {
      return ConfrontoPasto(
        pastoPersona1: pasto1,
        pastoPersona2: pasto2,
        confrontoAlimenti: [],
        percentualeCompatibilita: 0,
      );
    }

    final confronti = <ConfrontoAlimento>[];
    
    // Semplice logica di confronto sequenziale per ora
    // In futuro implementare matching più intelligente basato sui nomi
    
    // Per MVP, assumiamo che gli alimenti siano nello stesso ordine o proviamo a matchare per nome
    // Qui usiamo un approccio semplificato: iteriamo su tutti gli alimenti di p1 e cerchiamo match in p2
    
    final alimenti2Disponibili = List<Alimento>.from(pasto2.alimenti);
    
    for (var a1 in pasto1.alimenti) {
      Alimento? match;
      TipoCompatibilita tipoMatch = TipoCompatibilita.diverso;
      List<String> altComuni = [];
      
      // Cerca corrispondenza esatta nome
      try {
        match = alimenti2Disponibili.firstWhere((a2) => _pulisciNome(a2.nome) == _pulisciNome(a1.nome));
        
        if (match.quantita == a1.quantita) {
          tipoMatch = TipoCompatibilita.identico;
        } else {
          tipoMatch = TipoCompatibilita.quantitaDiversa;
        }
        
        alimenti2Disponibili.remove(match);
      } catch (_) {
        // Se non trova nome esatto, cerca alternative comuni
        for (var a2 in alimenti2Disponibili) {
          final comuni = trovaAlternativeComuni(a1, a2);
          if (comuni.isNotEmpty) {
            match = a2;
            tipoMatch = TipoCompatibilita.alternativaComune;
            altComuni = comuni;
            alimenti2Disponibili.remove(match);
            break;
          }
        }
      }
      
      if (match != null) {
        confronti.add(ConfrontoAlimento(
          alimentoPersona1: a1,
          alimentoPersona2: match,
          compatibilita: tipoMatch,
          alternativeComuni: altComuni,
        ));
      } else {
        confronti.add(ConfrontoAlimento(
          alimentoPersona1: a1,
          alimentoPersona2: null,
          compatibilita: TipoCompatibilita.soloUno,
        ));
      }
    }
    
    // Aggiungi alimenti rimanenti di p2
    for (var a2 in alimenti2Disponibili) {
      confronti.add(ConfrontoAlimento(
        alimentoPersona1: null,
        alimentoPersona2: a2,
        compatibilita: TipoCompatibilita.soloUno,
      ));
    }
    
    return ConfrontoPasto(
      pastoPersona1: pasto1,
      pastoPersona2: pasto2,
      confrontoAlimenti: confronti,
      percentualeCompatibilita: _calcolaPercentuale(confronti),
    );
  }

  /// Trova le alternative comuni tra due alimenti
  List<String> trovaAlternativeComuni(Alimento a1, Alimento a2) {
    final nomi1 = {_pulisciNome(a1.nome), ...a1.alternative.map((a) => _pulisciNome(a.nome))};
    final nomi2 = {_pulisciNome(a2.nome), ...a2.alternative.map((a) => _pulisciNome(a.nome))};
    
    return nomi1.intersection(nomi2).toList();
  }

  String _pulisciNome(String nome) {
    return nome.toLowerCase().trim();
  }

  double _calcolaPercentuale(List<ConfrontoAlimento> confronti) {
    if (confronti.isEmpty) return 0;
    
    int compatibili = confronti.where((c) => 
      c.compatibilita == TipoCompatibilita.identico ||
      c.compatibilita == TipoCompatibilita.quantitaDiversa ||
      c.compatibilita == TipoCompatibilita.alternativaComune
    ).length;
    
    return (compatibili / confronti.length) * 100;
  }
}
