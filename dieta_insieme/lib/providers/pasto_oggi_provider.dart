import 'package:flutter/material.dart';
import '../services/giorno_dieta_service.dart';
import '../services/pasto_analisi_service.dart';
import '../services/pasto_assistant_service.dart';
import '../services/storage_service.dart';
import '../models/persona.dart';
import '../models/pasto.dart';
import '../models/pasto_comune.dart';
import '../models/chat_message.dart';

class PastoOggiProvider extends ChangeNotifier {
  final GiornoDietaService _giornoDietaService;
  final PastoAnalisiService _analisiService;
  final PastoAssistantService _assistantService;
  final StorageService _storage;
  
  int _giornoCorrente = 1;
  TipoPasto _pastoSelezionato = TipoPasto.pranzo;
  PastoAnalizzato? _pastoAnalizzato;
  List<ChatMessage> _chatHistory = [];
  bool _isLoadingChat = false;
  String? _errorMessage;
  
  // Persone
  Persona? _persona1;
  Persona? _persona2;
  
  PastoOggiProvider({
    required GiornoDietaService giornoDietaService,
    required PastoAnalisiService analisiService,
    required PastoAssistantService assistantService,
    required StorageService storage,
  }) : _giornoDietaService = giornoDietaService,
       _analisiService = analisiService,
       _assistantService = assistantService,
       _storage = storage;
  
  // Getters
  int get giornoCorrente => _giornoCorrente;
  TipoPasto get pastoSelezionato => _pastoSelezionato;
  PastoAnalizzato? get pastoAnalizzato => _pastoAnalizzato;
  List<ChatMessage> get chatHistory => _chatHistory;
  bool get isLoadingChat => _isLoadingChat;
  String? get errorMessage => _errorMessage;
  bool get isConfigurato => _persona1 != null && _persona2 != null;
  
  String get nomePersona1 => _persona1?.nome ?? 'Persona 1';
  String get nomePersona2 => _persona2?.nome ?? 'Persona 2';
  
  /// Inizializza con le due persone
  void init(Persona persona1, Persona persona2) {
    _persona1 = persona1;
    _persona2 = persona2;
    _giornoCorrente = _giornoDietaService.getGiornoOggi();
    _analizzaPasto();
  }
  
  /// Cambia giorno
  void setGiorno(int giorno) {
    if (giorno < 1 || giorno > 7) return;
    _giornoCorrente = giorno;
    // Potremmo voler salvare che "oggi" è questo giorno? 
    // Dipende se è una visualizzazione temporanea o un cambio di stato
    // Per ora visualizzazione temporanea, il cambio data inizio si farà altrove
    _analizzaPasto();
    notifyListeners();
  }
  
  /// Imposta oggi come giorno X (cambia data inizio)
  Future<void> impostaOggiComeGiorno(int giorno) async {
    if (giorno < 1 || giorno > 7) return;
    await _giornoDietaService.setOggiComeGiorno(giorno);
    _giornoCorrente = giorno;
    _analizzaPasto();
    notifyListeners();
  }
  
  /// Cambia pasto (pranzo/cena)
  void setPasto(TipoPasto pasto) {
    _pastoSelezionato = pasto;
    _analizzaPasto();
    _chatHistory.clear(); // Reset chat quando cambia pasto
    notifyListeners();
  }
  
  /// Effettua una scelta alternativa
  void effettuaScelta(String categoria, String scelta) {
    final sceltaItem = _pastoAnalizzato?.scelteDaFare
        .firstWhere((s) => s.categoria == categoria);
    if (sceltaItem != null) {
      sceltaItem.sceltaEffettuata = scelta;
      _salvaScelte();
      notifyListeners();
    }
  }
  
  /// Invia messaggio all'assistente
  Future<void> inviaMessaggio(String messaggio) async {
    if (_persona1 == null || _persona2 == null || _pastoAnalizzato == null) return;
    
    _chatHistory.add(ChatMessage(testo: messaggio, isUser: true));
    _isLoadingChat = true;
    notifyListeners();
    
    try {
      final pasto1 = _getPasto(_persona1!, _giornoCorrente, _pastoSelezionato);
      final pasto2 = _getPasto(_persona2!, _giornoCorrente, _pastoSelezionato);
      
      if (pasto1 == null || pasto2 == null) {
        throw Exception('Pasto non trovato');
      }
      
      final risposta = await _assistantService.chiedi(
        domanda: messaggio,
        pasto: _pastoAnalizzato!,
        nomePersona1: _persona1!.nome,
        nomePersona2: _persona2!.nome,
        pastoOriginale1: pasto1,
        pastoOriginale2: pasto2,
        cronologia: _chatHistory.take(_chatHistory.length - 1).toList(),
      );
      
      _chatHistory.add(ChatMessage(testo: risposta, isUser: false));
    } catch (e) {
      _chatHistory.add(ChatMessage(
        testo: 'Mi dispiace, si è verificato un errore: $e',
        isUser: false,
      ));
    } finally {
      _isLoadingChat = false;
      notifyListeners();
    }
  }
  
  /// Richiedi ricetta
  Future<void> richiediRicetta() async {
    if (_persona1 == null || _persona2 == null || _pastoAnalizzato == null) return;
    
    _isLoadingChat = true;
    notifyListeners();
    
    try {
      final pasto1 = _getPasto(_persona1!, _giornoCorrente, _pastoSelezionato);
      final pasto2 = _getPasto(_persona2!, _giornoCorrente, _pastoSelezionato);
      
      if (pasto1 == null || pasto2 == null) {
         _isLoadingChat = false;
         notifyListeners();
         return;
      }
      
      _chatHistory.add(ChatMessage(
        testo: 'Suggeriscimi una ricetta con gli ingredienti di oggi',
        isUser: true,
      ));
      notifyListeners();
      
      final risposta = await _assistantService.suggerisciRicetta(
        pasto: _pastoAnalizzato!,
        nomePersona1: _persona1!.nome,
        nomePersona2: _persona2!.nome,
        pastoOriginale1: pasto1,
        pastoOriginale2: pasto2,
      );
      
      _chatHistory.add(ChatMessage(testo: risposta, isUser: false));
    } catch (e) {
      _chatHistory.add(ChatMessage(
        testo: 'Mi dispiace, si è verificato un errore: $e',
        isUser: false,
      ));
    } finally {
      _isLoadingChat = false;
      notifyListeners();
    }
  }
  
  /// Richiedi alternative
  Future<void> richiediAlternative() async {
     if (_persona1 == null || _persona2 == null || _pastoAnalizzato == null) return;
    
    // Per semplicità, chiediamo alternative generiche. 
    // In futuro potremmo far selezionare l'ingrediente mancante.
    const domanda = "Quali sostituzioni possiamo fare se ci manca qualche ingrediente principale?";
    await inviaMessaggio(domanda);
  }
  
  void _analizzaPasto() {
    if (_persona1?.dietaAttiva == null || _persona2?.dietaAttiva == null) return;
    
    final pasto1 = _getPasto(_persona1!, _giornoCorrente, _pastoSelezionato);
    final pasto2 = _getPasto(_persona2!, _giornoCorrente, _pastoSelezionato);
    
    if (pasto1 == null || pasto2 == null) {
      _pastoAnalizzato = null;
      return;
    }
    
    _pastoAnalizzato = _analisiService.analizzaPasto(
      pasto1: pasto1,
      pasto2: pasto2,
      nomePersona1: _persona1!.nome,
      nomePersona2: _persona2!.nome,
      giorno: _giornoCorrente,
    );
    
    // Carica scelte salvate
    _caricaScelteSalvate();
  }
  
  Pasto? _getPasto(Persona persona, int giorno, TipoPasto tipo) {
    return persona.dietaAttiva?.getGiorno(giorno)?.getPasto(tipo);
  }
  
  Future<void> _salvaScelte() async {
    if (_pastoAnalizzato == null) return;
    
    // Raccogli tutte le scelte effettuate
    final scelteMap = <String, String>{};
    for (final scelta in _pastoAnalizzato!.scelteDaFare) {
      if (scelta.sceltaEffettuata != null) {
        scelteMap[scelta.categoria] = scelta.sceltaEffettuata!;
      }
    }
    
    if (scelteMap.isEmpty) return;
    
    // Salva tramite storage service
    await _storage.salvaScelteGiornaliere(
      _giornoCorrente,
      _pastoSelezionato.name, // "pranzo", "cena"...
      scelteMap
    );
  }
  
  Future<void> _caricaScelteSalvate() async {
    final scelteMap = await _storage.caricaScelteGiornaliere(
      _giornoCorrente, 
      _pastoSelezionato.name
    );
    
    if (scelteMap.isEmpty || _pastoAnalizzato == null) return;
    
    // Applica le scelte al modello in memoria
    for (final scelta in _pastoAnalizzato!.scelteDaFare) {
      if (scelteMap.containsKey(scelta.categoria)) {
        scelta.sceltaEffettuata = scelteMap[scelta.categoria];
      }
    }
    notifyListeners();
  }
}
