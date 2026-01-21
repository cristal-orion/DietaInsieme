import 'package:google_generative_ai/google_generative_ai.dart';
import 'gemini_service.dart';
import '../models/pasto_comune.dart';
import '../models/pasto.dart';
import '../models/chat_message.dart';

class PastoAssistantService {
  final GeminiService _gemini;
  
  PastoAssistantService(this._gemini);
  
  /// Invia una domanda all'assistente con tutto il contesto
  Future<String> chiedi({
    required String domanda,
    required PastoAnalizzato pasto,
    required String nomePersona1,
    required String nomePersona2,
    required Pasto pastoOriginale1,
    required Pasto pastoOriginale2,
    List<ChatMessage>? cronologia,
  }) async {
    final context = _buildContext(
      pasto: pasto,
      nomePersona1: nomePersona1,
      nomePersona2: nomePersona2,
      pastoOriginale1: pastoOriginale1,
      pastoOriginale2: pastoOriginale2,
    );
    
    final messages = <Content>[];
    
    // Aggiungi cronologia se presente
    if (cronologia != null) {
      for (final msg in cronologia) {
        messages.add(Content(
          msg.isUser ? 'user' : 'model',
          [TextPart(msg.testo)],
        ));
      }
    }
    
    // Aggiungi domanda corrente con contesto
    final promptCompleto = '''
$context

---

DOMANDA: $domanda

ISTRUZIONI:
- Rispondi in italiano, in modo pratico e conciso
- Se suggerisci ricette, usa SOLO gli ingredienti permessi nelle diete
- Indica sempre le quantità diverse per le due persone
- Se $nomePersona2 ha la curcuma, ricorda di menzionarla
- Se suggerisci sostituzioni, devono essere nutrizionalmente simili
- Sii amichevole e diretto
''';
    
    messages.add(Content('user', [TextPart(promptCompleto)]));
    
    final response = await _gemini.chat(messages);
    return response.text ?? 'Mi dispiace, non sono riuscito a rispondere.';
  }
  
  /// Genera suggerimento ricetta automatico
  Future<String> suggerisciRicetta({
    required PastoAnalizzato pasto,
    required String nomePersona1,
    required String nomePersona2,
    required Pasto pastoOriginale1,
    required Pasto pastoOriginale2,
  }) async {
    final ingredientiComuni = pasto.alimentiComuni.map((a) => a.nome).toList();
    final scelte = pasto.scelteDaFare
        .where((s) => s.sceltaEffettuata != null)
        .map((s) => s.sceltaEffettuata!)
        .toList();
    
    final tuttiIngredienti = [...ingredientiComuni, ...scelte];
    
    final domanda = '''
Suggeriscimi una ricetta semplice e veloce per ${pasto.tipoPasto.label} 
usando questi ingredienti: ${tuttiIngredienti.join(', ')}.

Deve essere un piatto unico che possiamo cucinare insieme, 
indicando le porzioni diverse per $nomePersona1 e $nomePersona2.
''';
    
    return chiedi(
      domanda: domanda,
      pasto: pasto,
      nomePersona1: nomePersona1,
      nomePersona2: nomePersona2,
      pastoOriginale1: pastoOriginale1,
      pastoOriginale2: pastoOriginale2,
    );
  }
  
  /// Suggerisce alternative per un ingrediente mancante
  Future<String> suggerisciAlternativa({
    required String ingredienteMancante,
    required PastoAnalizzato pasto,
    required String nomePersona1,
    required String nomePersona2,
    required Pasto pastoOriginale1,
    required Pasto pastoOriginale2,
  }) async {
    final domanda = '''
Non abbiamo "$ingredienteMancante". 
Con cosa possiamo sostituirlo restando nelle nostre diete?
Considera sia le alternative già presenti nel piano che eventuali 
sostituzioni nutrizionalmente equivalenti.
''';
    
    return chiedi(
      domanda: domanda,
      pasto: pasto,
      nomePersona1: nomePersona1,
      nomePersona2: nomePersona2,
      pastoOriginale1: pastoOriginale1,
      pastoOriginale2: pastoOriginale2,
    );
  }
  
  String _buildContext({
    required PastoAnalizzato pasto,
    required String nomePersona1,
    required String nomePersona2,
    required Pasto pastoOriginale1,
    required Pasto pastoOriginale2,
  }) {
    final buffer = StringBuffer();
    
    buffer.writeln('=== CONTESTO PASTO ===');
    buffer.writeln('');
    buffer.writeln('Giorno ${pasto.giorno} della dieta');
    buffer.writeln('Pasto: ${pasto.tipoPasto.label}');
    buffer.writeln('');
    
    buffer.writeln('--- DIETA $nomePersona1 (${pasto.tipoPasto.label}) ---');
    for (final alimento in pastoOriginale1.alimenti) {
      buffer.writeln('• ${alimento.nome}: ${alimento.quantita}');
      if (alimento.hasAlternative) {
        buffer.writeln('  Alternative: ${alimento.alternative.map((a) => "${a.nome} ${a.quantita}").join(", ")}');
      }
    }
    buffer.writeln('');
    
    buffer.writeln('--- DIETA $nomePersona2 (${pasto.tipoPasto.label}) ---');
    for (final alimento in pastoOriginale2.alimenti) {
      buffer.writeln('• ${alimento.nome}: ${alimento.quantita}');
      if (alimento.hasAlternative) {
        buffer.writeln('  Alternative: ${alimento.alternative.map((a) => "${a.nome} ${a.quantita}").join(", ")}');
      }
    }
    buffer.writeln('');
    
    buffer.writeln('--- ANALISI COMPATIBILITÀ ---');
    buffer.writeln('');
    
    if (pasto.alimentiComuni.isNotEmpty) {
      buffer.writeln('IN COMUNE (possono mangiare insieme):');
      for (final a in pasto.alimentiComuni) {
        buffer.writeln('• ${a.nome}: $nomePersona1 ${a.quantitaPersona1}, $nomePersona2 ${a.quantitaPersona2}');
      }
      buffer.writeln('');
    }
    
    if (pasto.scelteDaFare.isNotEmpty) {
      buffer.writeln('ALTERNATIVE COMUNI (possono scegliere una):');
      for (final s in pasto.scelteDaFare) {
        buffer.writeln('• ${s.categoria}: ${s.alternativeComuni.join(", ")}');
        if (s.sceltaEffettuata != null) {
          buffer.writeln('  → Hanno scelto: ${s.sceltaEffettuata}');
        }
      }
      buffer.writeln('');
    }
    
    if (pasto.alimentiSeparati.isNotEmpty) {
      buffer.writeln('SEPARATI (solo una persona):');
      for (final a in pasto.alimentiSeparati) {
        buffer.writeln('• ${a.persona}: ${a.nome} ${a.quantita}');
      }
      buffer.writeln('');
    }
    
    buffer.writeln('NOTE IMPORTANTI:');
    buffer.writeln('- $nomePersona1 ha porzioni generalmente più grandi');
    buffer.writeln('- Entrambi seguono un piano nutrizionale personalizzato');
    buffer.writeln('- Le sostituzioni devono essere nutrizionalmente equivalenti');
    
    return buffer.toString();
  }
}
