import '../models/pasto.dart';
import '../models/alimento.dart';
import '../models/pasto_comune.dart';

class PastoAnalisiService {
  
  /// Analizza un pasto di due persone e trova compatibilità
  PastoAnalizzato analizzaPasto({
    required Pasto pasto1,
    required Pasto pasto2,
    required String nomePersona1,
    required String nomePersona2,
    required int giorno,
  }) {
    final alimentiComuni = <AlimentoComune>[];
    final scelteDaFare = <SceltaAlternative>[];
    final alimentiSeparati = <AlimentoSeparato>[];
    
    // Raggruppa alimenti per categoria
    final categorie1 = _raggruppaPerCategoria(pasto1.alimenti);
    final categorie2 = _raggruppaPerCategoria(pasto2.alimenti);
    
    // Tutte le categorie presenti
    final tutteCategorie = {...categorie1.keys, ...categorie2.keys};
    
    for (final categoria in tutteCategorie) {
      final alimenti1 = categorie1[categoria] ?? [];
      final alimenti2 = categorie2[categoria] ?? [];
      
      if (alimenti1.isEmpty) {
        // Solo persona 2 ha questa categoria
        for (final a in alimenti2) {
          alimentiSeparati.add(AlimentoSeparato(
            persona: nomePersona2,
            nome: a.nome,
            quantita: a.quantita,
          ));
        }
      } else if (alimenti2.isEmpty) {
        // Solo persona 1 ha questa categoria
        for (final a in alimenti1) {
          alimentiSeparati.add(AlimentoSeparato(
            persona: nomePersona1,
            nome: a.nome,
            quantita: a.quantita,
          ));
        }
      } else {
        // Entrambi hanno questa categoria - cerca compatibilità
        _analizzaCategoria(
          categoria: categoria,
          alimenti1: alimenti1,
          alimenti2: alimenti2,
          nomePersona1: nomePersona1,
          nomePersona2: nomePersona2,
          alimentiComuni: alimentiComuni,
          scelteDaFare: scelteDaFare,
          alimentiSeparati: alimentiSeparati,
        );
      }
    }
    
    return PastoAnalizzato(
      giorno: giorno,
      tipoPasto: pasto1.tipo,
      alimentiComuni: alimentiComuni,
      scelteDaFare: scelteDaFare,
      alimentiSeparati: alimentiSeparati,
    );
  }
  
  void _analizzaCategoria({
    required String categoria,
    required List<Alimento> alimenti1,
    required List<Alimento> alimenti2,
    required String nomePersona1,
    required String nomePersona2,
    required List<AlimentoComune> alimentiComuni,
    required List<SceltaAlternative> scelteDaFare,
    required List<AlimentoSeparato> alimentiSeparati,
  }) {
    // Prendi il primo alimento di ogni persona per questa categoria
    // (In caso di multipli alimenti della stessa categoria, per ora confrontiamo i primi o dovremmo gestire liste)
    // Semplificazione: prendiamo il primo per ora
    final a1 = alimenti1.first;
    final a2 = alimenti2.first;
    
    // Costruisci set di tutte le opzioni possibili
    final opzioni1 = _tutteOpzioni(a1);
    final opzioni2 = _tutteOpzioni(a2);
    
    // Trova intersezione (nomi comuni)
    final nomiComuni = opzioni1.keys
        .toSet()
        .intersection(opzioni2.keys.toSet())
        .toList();
    
    if (nomiComuni.isEmpty) {
      // Nessuna opzione comune - sono separati
      alimentiSeparati.add(AlimentoSeparato(
        persona: nomePersona1,
        nome: a1.nome,
        quantita: a1.quantita,
      ));
      alimentiSeparati.add(AlimentoSeparato(
        persona: nomePersona2,
        nome: a2.nome,
        quantita: a2.quantita,
      ));
    } else if (nomiComuni.length == 1 && 
               a1.nome.toLowerCase() == a2.nome.toLowerCase()) {
      // Stesso alimento esatto (senza alternative o con solo questa opzione) - è comune
      // Se hanno alternative comuni ma l'alimento base è lo stesso, potremmo considerarlo comune
      // o far scegliere. Se l'alimento PRINCIPALE è lo stesso, mettiamolo come comune
      alimentiComuni.add(AlimentoComune(
        nome: a1.nome,
        quantitaPersona1: a1.quantita,
        quantitaPersona2: a2.quantita,
      ));
    } else {
      // Hanno alternative in comune - devono scegliere
      final soloP1 = opzioni1.entries
          .where((e) => !nomiComuni.contains(e.key))
          .map((e) => AlternativaPersonale(nome: e.key, quantita: e.value))
          .toList();
      final soloP2 = opzioni2.entries
          .where((e) => !nomiComuni.contains(e.key))
          .map((e) => AlternativaPersonale(nome: e.key, quantita: e.value))
          .toList();
      
      scelteDaFare.add(SceltaAlternative(
        categoria: categoria,
        alternativeComuni: nomiComuni,
        soloPersona1: soloP1,
        soloPersona2: soloP2,
      ));
    }
  }
  
  /// Restituisce mappa nome -> quantità per alimento + sue alternative
  Map<String, String> _tutteOpzioni(Alimento alimento) {
    final opzioni = <String, String>{
      alimento.nome.toLowerCase(): alimento.quantita,
    };
    for (final alt in alimento.alternative) {
      opzioni[alt.nome.toLowerCase()] = alt.quantita;
    }
    return opzioni;
  }
  
  /// Raggruppa alimenti per categoria (Primo, Proteina, Verdura, etc)
  Map<String, List<Alimento>> _raggruppaPerCategoria(List<Alimento> alimenti) {
    final result = <String, List<Alimento>>{};
    
    for (final alimento in alimenti) {
      final categoria = _determinaCategoria(alimento.nome);
      result.putIfAbsent(categoria, () => []).add(alimento);
    }
    
    return result;
  }
  
  String _determinaCategoria(String nome) {
    final nomeLower = nome.toLowerCase();
    
    // Carboidrati / Primi
    final carboidrati = [
      'polenta', 'riso', 'pasta', 'spaghetti', 'farro', 
      'pane', 'grano', 'orzo', 'fette biscottate'
    ];
    if (carboidrati.any((c) => nomeLower.contains(c))) {
      return 'Primo / Carboidrati';
    }
    
    // Proteine
    final proteine = [
      'uova', 'uovo', 'pollo', 'tacchino', 'manzo', 'vitello',
      'maiale', 'pesce', 'merluzzo', 'spigola', 'orata', 'tonno',
      'salmone', 'parmigiano', 'formaggio', 'mozzarella', 'ricotta',
      'lenticchie', 'ceci', 'fagioli', 'prosciutto', 'bresaola',
      'burger vegetale', 'tofu', 'seitan'
    ];
    if (proteine.any((p) => nomeLower.contains(p))) {
      return 'Proteina';
    }
    
    // Verdure
    final verdure = [
      'bieta', 'spinaci', 'scarola', 'insalata', 'lattuga',
      'finocchi', 'finocchio', 'carote', 'carota', 'zucca',
      'zucchine', 'melanzane', 'peperoni', 'pomodori',
      'cicoria', 'radicchio', 'cavolo', 'verza', 'broccoli',
      'cavolfiore', 'fagiolini', 'asparagi', 'carciofi'
    ];
    if (verdure.any((v) => nomeLower.contains(v))) {
      return 'Verdura';
    }
    
    // Frutta
    final frutta = [
      'mela', 'mele', 'pera', 'pere', 'banana', 'arancia', 'arance',
      'mandarini', 'kiwi', 'fragole', 'mirtilli', 'ananas', 'pesca',
      'albicocca', 'uva', 'melone', 'anguria', 'ribes'
    ];
    if (frutta.any((f) => nomeLower.contains(f))) {
      return 'Frutta';
    }
    
    // Condimenti
    final condimenti = [
      'olio', 'aceto', 'sale', 'pepe', 'curcuma', 'spezie',
      'erbe', 'basilico', 'prezzemolo', 'aglio', 'cipolla'
    ];
    if (condimenti.any((c) => nomeLower.contains(c))) {
      return 'Condimento';
    }
    
    // Bevande
    final bevande = [
      'acqua', 'latte', 'tisana', 'the', 'caffè', 'succo', 'spremuta'
    ];
    if (bevande.any((b) => nomeLower.contains(b))) {
      return 'Bevanda';
    }
    
    return 'Altro';
  }
}
