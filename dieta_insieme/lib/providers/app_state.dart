import 'dart:io';
import 'package:flutter/material.dart';
import '../models/persona.dart';
import '../models/dieta.dart';
import '../models/bodygram.dart';
import '../services/storage_service.dart';

class AppState extends ChangeNotifier {
  final List<Persona> _persone = [];
  
  List<Persona> get persone => List.unmodifiable(_persone);

  AppState() {
    _loadData();
  }

  Future<void> _loadData() async {
    final storage = StorageService();
    final personeSalvate = await storage.caricaPersone();
    _persone.addAll(personeSalvate);
    notifyListeners();
  }
  
  Future<void> addPersona(String nome) async {
    final nuovaPersona = Persona(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nome: nome,
    );
    _persone.add(nuovaPersona);
    await _salvaStato();
    notifyListeners();
  }

  Future<void> updateDieta(String nomePersona, Dieta dieta) async {
    final index = _persone.indexWhere((p) => p.nome == nomePersona);
    if (index != -1) {
      // Se è una nuova dieta senza data inizio, impostiamo oggi
      final dietaDaSalvare = dieta.dataInizio == null 
          ? Dieta(
              id: dieta.id,
              persona: dieta.persona,
              dataCaricamento: dieta.dataCaricamento,
              giorni: dieta.giorni,
              noteGenerali: dieta.noteGenerali,
              prossimaVisita: dieta.prossimaVisita,
              integratori: dieta.integratori,
              dataInizio: DateTime.now(),
            )
          : dieta;
          
      _persone[index].dietaAttiva = dietaDaSalvare;
      
      // Salva la dieta su file separato
      final storage = StorageService();
      await storage.salvaDieta(dietaDaSalvare);
      
      // Aggiorna l'indice delle persone
      await _salvaStato();
      
      notifyListeners();
    }
  }

  Future<void> riavviaDieta(String nomePersona) async {
    final index = _persone.indexWhere((p) => p.nome == nomePersona);
    if (index != -1 && _persone[index].dietaAttiva != null) {
      final vecchiaDieta = _persone[index].dietaAttiva!;
      final nuovaDieta = Dieta(
        id: vecchiaDieta.id,
        persona: vecchiaDieta.persona,
        dataCaricamento: vecchiaDieta.dataCaricamento,
        giorni: vecchiaDieta.giorni,
        noteGenerali: vecchiaDieta.noteGenerali,
        prossimaVisita: vecchiaDieta.prossimaVisita,
        integratori: vecchiaDieta.integratori,
        dataInizio: DateTime.now(),
      );
      
      await updateDieta(nomePersona, nuovaDieta);
    }
  }

  Future<void> impostaGiornoCorrente(String nomePersona, int giorno) async {
    if (giorno < 1 || giorno > 7) return;
    
    final index = _persone.indexWhere((p) => p.nome == nomePersona);
    if (index != -1 && _persone[index].dietaAttiva != null) {
      final vecchiaDieta = _persone[index].dietaAttiva!;
      
      final oggi = DateTime.now();
      final oggiDate = DateTime(oggi.year, oggi.month, oggi.day);
      // Se oggi voglio che sia il giorno X, la dieta è iniziata (X-1) giorni fa
      final nuovaDataInizio = oggiDate.subtract(Duration(days: giorno - 1));
      
      final nuovaDieta = Dieta(
        id: vecchiaDieta.id,
        persona: vecchiaDieta.persona,
        dataCaricamento: vecchiaDieta.dataCaricamento,
        giorni: vecchiaDieta.giorni,
        noteGenerali: vecchiaDieta.noteGenerali,
        prossimaVisita: vecchiaDieta.prossimaVisita,
        integratori: vecchiaDieta.integratori,
        dataInizio: nuovaDataInizio,
      );
      
      await updateDieta(nomePersona, nuovaDieta);
    }
  }

  Future<void> updateBodygram(String nomePersona, Bodygram bodygram) async {
    final index = _persone.indexWhere((p) => p.nome == nomePersona);
    if (index != -1) {
      _persone[index].bodygramAttivo = bodygram;
      
      // Salva il bodygram su file separato
      final storage = StorageService();
      await storage.salvaBodygram(bodygram);
      
      // Aggiorna l'indice delle persone
      await _salvaStato();
      
      notifyListeners();
    }
  }
  
  Future<void> _salvaStato() async {
    final storage = StorageService();
    await storage.salvaPersone(_persone);
  }

  Future<File> exportBackup() async {
    final storage = StorageService();
    // Dobbiamo assicurarci che i dati in memoria siano completi (diete caricate)
    // _persone ha già dietaAttiva caricata da _loadData -> caricaPersone -> caricaDieta
    return await storage.exportData(_persone);
  }

  Future<void> importBackup(File file) async {
    final storage = StorageService();
    await storage.importData(file);
    // Ricarica tutto
    _persone.clear();
    await _loadData();
  }
}
