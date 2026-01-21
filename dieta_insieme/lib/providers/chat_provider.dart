import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/chat_message.dart';
import '../services/gemini_service.dart';
import '../services/giorno_dieta_service.dart';
import '../services/storage_service.dart';
import '../models/persona.dart';
import '../models/dieta.dart';
import '../models/pasto.dart';
import '../models/giorno.dart';
import '../models/alimento.dart';
import 'dart:typed_data';

class ChatProvider extends ChangeNotifier {
  final GeminiService _geminiService;
  final GiornoDietaService _giornoDietaService;
  final StorageService _storageService = StorageService();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  List<Persona> _persone = [];

  ChatProvider(this._geminiService, this._giornoDietaService) {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final historyJson = await _storageService.caricaChatHistory();
    if (historyJson.isNotEmpty) {
      _messages.addAll(historyJson.map((json) => ChatMessage.fromJson(json)));
      notifyListeners();
    }
  }

  Future<void> _saveHistory() async {
    final historyJson = _messages.map((m) => m.toJson()).toList();
    await _storageService.salvaChatHistory(historyJson);
  }

  Future<void> clearHistory() async {
    _messages.clear();
    await _saveHistory();
    notifyListeners();
  }

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;

  void updatePersone(List<Persona> persone) {
    _persone = persone;
  }

  Future<void> inviaMessaggio(String testo, [Uint8List? imageBytes]) async {
    if (testo.trim().isEmpty && imageBytes == null) return;

    final userMessage = ChatMessage(
      testo: testo,
      isUser: true,
      imageBytes: imageBytes,
    );
      _messages.add(userMessage);
      _isLoading = true;
      _saveHistory(); // Salva dopo messaggio utente
      notifyListeners();

      try {
        // Costruisci il prompt di sistema con il contesto attuale

      final systemPrompt = _buildSystemPrompt();
      
      // Prepara la history per Gemini
      // Nota: Per ora passiamo solo il testo precedente come contesto
      // In una implementazione più avanzata potremmo passare tutta la history strutturata
      final history = _messages
          .where((m) => m != userMessage) // Escludi l'ultimo messaggio appena aggiunto
          .map((m) => "${m.isUser ? 'Utente' : 'Assistente'}: ${m.testo}")
          .join("\n");
      
      final fullPrompt = "$systemPrompt\n\nCronologia Chat:\n$history\n\nUtente: $testo";

      String risposta;
      if (imageBytes != null) {
        risposta = await _geminiService.chatWithImage(fullPrompt, imageBytes);
      } else {
        risposta = await _geminiService.simpleChat(fullPrompt);
      }

      _messages.add(ChatMessage(
        testo: risposta,
        isUser: false,
      ));
      _saveHistory(); // Salva dopo risposta
    } catch (e) {
      _messages.add(ChatMessage(
        testo: "Mi dispiace, si è verificato un errore: $e",
        isUser: false,
      ));
      _saveHistory(); // Salva anche errori
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _buildSystemPrompt() {
    final buffer = StringBuffer();
    final now = DateTime.now();
    final formatter = DateFormat('EEEE d MMMM yyyy', 'it_IT');
    
    // Costruisci l'introduzione in base agli utenti configurati
    if (_persone.isEmpty) {
      buffer.writeln("Sei un assistente nutrizionista esperto.");
      buffer.writeln("L'utente non ha ancora configurato il proprio profilo o caricato una dieta.");
      buffer.writeln("Puoi comunque rispondere a domande generali su nutrizione e alimentazione.");
    } else if (_persone.length == 1) {
      buffer.writeln("Sei un assistente nutrizionista esperto che aiuta ${_persone.first.nome} con la sua dieta.");
      buffer.writeln("Hai accesso ai dati completi della dieta e analisi corporea.");
    } else {
      final nomi = _persone.map((p) => p.nome).join(' e ');
      buffer.writeln("Sei un assistente nutrizionista esperto che aiuta $nomi con le loro diete.");
      buffer.writeln("Hai accesso ai dati completi delle loro diete e analisi corporee.");
    }
    buffer.writeln("Oggi è ${formatter.format(now)}.");
    
    if (_persone.isNotEmpty) {
      buffer.writeln("\n=== DATI UTENTI E DIETE ===");
      for (final p in _persone) {
        buffer.writeln("\nUTENTE: ${p.nome.toUpperCase()}");
        
        // Info Bodygram
        if (p.bodygramAttivo != null) {
          buffer.writeln("ANALISI CORPOREA (Bodygram):");
          buffer.writeln("- Data: ${DateFormat('d/M/yyyy').format(p.bodygramAttivo!.dataEsame)}");
          buffer.writeln("- Somatotipo: ${p.bodygramAttivo!.somatotipo}");
          if (p.bodygramAttivo!.peso != null) buffer.writeln("- Peso: ${p.bodygramAttivo!.peso} kg");
          buffer.writeln("- Obiettivo: ${p.bodygramAttivo!.obiettivo ?? 'Non specificato'}");
        }

        // Info Dieta Completa
        if (p.dietaAttiva != null) {
          final dieta = p.dietaAttiva!;
          // Calcolo del giorno corrente del ciclo (1-7)
          final giornoCorrente = _giornoDietaService.getGiornoOggi(dieta.dataInizio);
          
          buffer.writeln("DIETA ATTIVA:");
          buffer.writeln("- Inizio ciclo: ${dieta.dataInizio != null ? DateFormat('d/M/yyyy').format(dieta.dataInizio!) : 'Non impostato'}");
          buffer.writeln("- OGGI è il GIORNO $giornoCorrente del ciclo settimanale.");
          buffer.writeln("- Note Generali: ${dieta.noteGenerali ?? 'Nessuna'}");
          if (dieta.integratori.isNotEmpty) {
            buffer.writeln("- Integratori: ${dieta.integratori.join(', ')}");
          }

          buffer.writeln("\nPIANO ALIMENTARE SETTIMANALE DI ${p.nome.toUpperCase()}:");
          buffer.writeln(_formatDietaCompleta(dieta));
        } else {
          buffer.writeln("Nessuna dieta attiva caricata.");
        }
      }
    }
    
    buffer.writeln("\n=== ISTRUZIONI COMPORTAMENTALI ===");
    buffer.writeln("1. Rispondi in modo cordiale, empatico e motivante.");
    if (_persone.isNotEmpty) {
      buffer.writeln("2. Se ti chiedono 'cosa mangio oggi?', riferisciti al GIORNO del ciclo calcolato sopra.");
      buffer.writeln("3. Se l'utente invia una foto di un cibo, analizzala, stima calorie/macro approssimativi e dimmi se è compatibile con il pasto previsto o le alternative.");
      buffer.writeln("4. Sei proattivo: se vedi che è ora di pranzo (guarda l'ora attuale), puoi suggerire direttamente il pasto.");
    } else {
      buffer.writeln("2. Se l'utente non ha ancora configurato un profilo, invitalo gentilmente a farlo per ricevere consigli personalizzati.");
      buffer.writeln("3. Se l'utente invia una foto di un cibo, analizzala e stima calorie/macro approssimativi.");
    }
    buffer.writeln("5. Risposte concise se non richiesto diversamente.");
    
    return buffer.toString();
  }

  String _formatDietaCompleta(Dieta dieta) {
    final buffer = StringBuffer();
    // Ordina i giorni per sicurezza
    final giorniOrdinati = List<Giorno>.from(dieta.giorni)..sort((a, b) => a.numero.compareTo(b.numero));

    for (final giorno in giorniOrdinati) {
      buffer.writeln("GIORNO ${giorno.numero}:");
      
      // Ordina i pasti secondo l'ordine logico della giornata
      final ordinePasti = [
        TipoPasto.colazione,
        TipoPasto.spuntinoMattina,
        TipoPasto.pranzo,
        TipoPasto.merenda,
        TipoPasto.cena,
        TipoPasto.spuntinoSera,
        TipoPasto.duranteGiornata
      ];

      for (final tipo in ordinePasti) {
        final pasto = giorno.getPasto(tipo);
        if (pasto != null && pasto.alimenti.isNotEmpty) {
          buffer.write("  ${pasto.tipoLabel.toUpperCase()}: ");
          
          final alimentiDesc = pasto.alimenti.map((a) {
            String desc = "${a.nome} (${a.quantita})";
            if (a.alternative.isNotEmpty) {
              final altDesc = a.alternative.map((alt) => "${alt.nome} (${alt.quantita})").join(" OPPURE ");
              desc += " [Alternative: $altDesc]";
            }
            return desc;
          }).join(", ");
          
          buffer.writeln(alimentiDesc);
          if (pasto.nota != null && pasto.nota!.isNotEmpty) {
            buffer.writeln("    Note pasto: ${pasto.nota}");
          }
        }
      }
      buffer.writeln(""); // riga vuota tra i giorni
    }
    return buffer.toString();
  }
}
