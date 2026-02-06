import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/dieta.dart';
import '../models/bodygram.dart';
import '../models/persona.dart';
import '../models/peso_giornaliero.dart';

class StorageService {
  
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  // Salva dieta
  Future<void> salvaDieta(Dieta dieta) async {
    final path = await _localPath;
    final file = File('$path/dieta_${dieta.id}.json');
    await file.writeAsString(jsonEncode(dieta.toJson()));
  }

  // Carica dieta
  Future<Dieta?> caricaDieta(String id) async {
    try {
      final path = await _localPath;
      final file = File('$path/dieta_$id.json');
      final contents = await file.readAsString();
      return Dieta.fromJson(jsonDecode(contents));
    } catch (e) {
      return null;
    }
  }

  // Salva bodygram
  Future<void> salvaBodygram(Bodygram bodygram) async {
    final path = await _localPath;
    final file = File('$path/bodygram_${bodygram.id}.json');
    await file.writeAsString(jsonEncode(bodygram.toJson()));
  }

  // Carica bodygram
  Future<Bodygram?> caricaBodygram(String id) async {
    try {
      final path = await _localPath;
      final file = File('$path/bodygram_$id.json');
      final contents = await file.readAsString();
      return Bodygram.fromJson(jsonDecode(contents));
    } catch (e) {
      return null;
    }
  }

  // === PESI GIORNALIERI ===

  // Salva peso giornaliero
  Future<void> salvaPeso(PesoGiornaliero peso) async {
    final path = await _localPath;
    final file = File('$path/peso_${peso.personaId}_${peso.id}.json');
    await file.writeAsString(jsonEncode(peso.toJson()));
  }

  // Carica peso giornaliero
  Future<PesoGiornaliero?> caricaPeso(String personaId, String pesoId) async {
    try {
      final path = await _localPath;
      final file = File('$path/peso_${personaId}_$pesoId.json');
      final contents = await file.readAsString();
      return PesoGiornaliero.fromJson(jsonDecode(contents));
    } catch (e) {
      return null;
    }
  }

  // Carica tutti i pesi di una persona
  Future<List<PesoGiornaliero>> caricaPesiPersona(String personaId) async {
    try {
      final path = await _localPath;
      final dir = Directory(path);
      final List<PesoGiornaliero> pesi = [];

      await for (final entity in dir.list()) {
        if (entity is File && entity.path.contains('peso_${personaId}_')) {
          try {
            final contents = await entity.readAsString();
            pesi.add(PesoGiornaliero.fromJson(jsonDecode(contents)));
          } catch (_) {}
        }
      }

      return pesi;
    } catch (e) {
      return [];
    }
  }

  // Elimina peso giornaliero
  Future<void> eliminaPeso(PesoGiornaliero peso) async {
    try {
      final path = await _localPath;
      final file = File('$path/peso_${peso.personaId}_${peso.id}.json');
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Errore eliminazione peso: $e');
    }
  }

  // Salva l'intera lista delle persone (indice)
  Future<void> salvaPersone(List<Persona> persone) async {
    final path = await _localPath;
    final file = File('$path/persone_index.json');

    // Salviamo solo i metadati essenziali per ricostruire la lista
    // Le diete, bodygram e pesi completi sono salvati in file separati
    final List<Map<String, dynamic>> indexData = persone.map((p) => {
      'id': p.id,
      'nome': p.nome,
      'avatarEmoji': p.avatarEmoji,
      'immagineProfilo': p.immagineProfilo,
      'dietaAttivaId': p.dietaAttiva?.id,
      'bodygramAttivoId': p.bodygramAttivo?.id,
      // Per semplicità nello storico salviamo solo gli ID
      'storicoDieteIds': p.storicoDiete.map((d) => d.id).toList(),
      'storicoBodygramIds': p.storicoBodygram.map((b) => b.id).toList(),
      'storicoPesiIds': p.storicoPesi.map((p) => p.id).toList(),
    }).toList();

    await file.writeAsString(jsonEncode(indexData));
  }

  // Carica l'intera lista persone ricostruendo gli oggetti
  Future<List<Persona>> caricaPersone() async {
    try {
      final path = await _localPath;
      final file = File('$path/persone_index.json');
      if (!await file.exists()) return [];
      
      final contents = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(contents);
      
      final List<Persona> persone = [];
      
      for (final pJson in jsonList) {
        final pMap = pJson as Map<String, dynamic>;
        
        // Carica la dieta attiva se presente
        Dieta? dietaAttiva;
        if (pMap['dietaAttivaId'] != null) {
          dietaAttiva = await caricaDieta(pMap['dietaAttivaId']);
        }
        
        // Carica il bodygram attivo se presente
        Bodygram? bodygramAttivo;
        if (pMap['bodygramAttivoId'] != null) {
          bodygramAttivo = await caricaBodygram(pMap['bodygramAttivoId']);
        }
        
        // Carica storico diete
        final List<Dieta> storicoDiete = [];
        if (pMap['storicoDieteIds'] != null) {
          for (final dietaId in pMap['storicoDieteIds']) {
            final dieta = await caricaDieta(dietaId);
            if (dieta != null) {
              storicoDiete.add(dieta);
            }
          }
        }

        // Carica storico bodygram
        final List<Bodygram> storicoBodygram = [];
        if (pMap['storicoBodygramIds'] != null) {
          for (final bodygramId in pMap['storicoBodygramIds']) {
            final bodygram = await caricaBodygram(bodygramId);
            if (bodygram != null) {
              storicoBodygram.add(bodygram);
            }
          }
        }

        // Carica storico pesi
        final List<PesoGiornaliero> storicoPesi = await caricaPesiPersona(pMap['id']);

        persone.add(Persona(
          id: pMap['id'],
          nome: pMap['nome'],
          avatarEmoji: pMap['avatarEmoji'],
          immagineProfilo: pMap['immagineProfilo'],
          dietaAttiva: dietaAttiva,
          bodygramAttivo: bodygramAttivo,
          storicoDiete: storicoDiete,
          storicoBodygram: storicoBodygram,
          storicoPesi: storicoPesi,
        ));
      }
      
      return persone;
    } catch (e) {
      print('Errore caricamento persone: $e');
      return [];
    }
  }

  // Esporta dati - Versione 2 con storico completo
  Future<File> exportData(List<Persona> persone) async {
    final path = await _localPath;
    final Map<String, dynamic> exportData = {
      'version': 2,
      'timestamp': DateTime.now().toIso8601String(),
      'persone': persone.map((p) => p.toJson()).toList(),
    };

    // Usiamo l'estensione .dieta per l'associazione automatica
    final file = File('$path/backup_dieta_insieme.dieta');
    await file.writeAsString(jsonEncode(exportData));
    return file;
  }

  // Importa dati - Compatibile con versione 1 e 2
  Future<void> importData(File file) async {
    try {
      final contents = await file.readAsString();
      final Map<String, dynamic> data = jsonDecode(contents);

      // Verifica versione
      final version = data['version'] as int;
      if (version != 1 && version != 2) {
        throw Exception('Versione file non supportata');
      }

      final List<dynamic> personeJson = data['persone'];
      final List<Persona> personeImportate = personeJson
          .map((p) => Persona.fromJson(p as Map<String, dynamic>))
          .toList();

      // Carica le persone esistenti per fare merge
      final personeEsistenti = await caricaPersone();

      for (final nuovaPersona in personeImportate) {
        // Cerca se esiste già una persona con questo nome (case insensitive)
        final index = personeEsistenti.indexWhere(
            (p) => p.nome.toLowerCase() == nuovaPersona.nome.toLowerCase());

        if (index != -1) {
          // Aggiorna esistente
          final personaEsistente = personeEsistenti[index];

          // Sovrascriviamo dieta e bodygram se presenti nel backup
          if (nuovaPersona.dietaAttiva != null) {
            personaEsistente.dietaAttiva = nuovaPersona.dietaAttiva;
            await salvaDieta(nuovaPersona.dietaAttiva!);
          }
          if (nuovaPersona.bodygramAttivo != null) {
            personaEsistente.bodygramAttivo = nuovaPersona.bodygramAttivo;
            await salvaBodygram(nuovaPersona.bodygramAttivo!);
          }
          // Salva storico bodygram
          for (final bodygram in nuovaPersona.storicoBodygram) {
            await salvaBodygram(bodygram);
          }
          // Salva storico pesi
          for (final peso in nuovaPersona.storicoPesi) {
            await salvaPeso(peso);
          }
        } else {
          // Aggiungi nuova
          personeEsistenti.add(nuovaPersona);
          if (nuovaPersona.dietaAttiva != null) {
            await salvaDieta(nuovaPersona.dietaAttiva!);
          }
          if (nuovaPersona.bodygramAttivo != null) {
            await salvaBodygram(nuovaPersona.bodygramAttivo!);
          }
          // Salva storico bodygram
          for (final bodygram in nuovaPersona.storicoBodygram) {
            await salvaBodygram(bodygram);
          }
          // Salva storico pesi
          for (final peso in nuovaPersona.storicoPesi) {
            await salvaPeso(peso);
          }
        }
      }

      // Salva l'indice aggiornato
      await salvaPersone(personeEsistenti);
    } catch (e) {
      print('Errore importazione: $e');
      rethrow;
    }
  }

  // Salva scelte giornaliere
  Future<void> salvaScelteGiornaliere(int giorno, String tipoPasto, Map<String, String> scelte) async {
    final path = await _localPath;
    final file = File('$path/scelte_${giorno}_$tipoPasto.json');
    await file.writeAsString(jsonEncode(scelte));
  }

  // Carica scelte giornaliere
  Future<Map<String, String>> caricaScelteGiornaliere(int giorno, String tipoPasto) async {
    try {
      final path = await _localPath;
      final file = File('$path/scelte_${giorno}_$tipoPasto.json');
      if (!await file.exists()) return {};
      
      final contents = await file.readAsString();
      final Map<String, dynamic> json = jsonDecode(contents);
      return Map<String, String>.from(json);
    } catch (e) {
      return {};
    }
  }

  // Salva chat history
  Future<void> salvaChatHistory(List<dynamic> messagesJson) async {
    final path = await _localPath;
    final file = File('$path/chat_history.json');
    await file.writeAsString(jsonEncode(messagesJson));
  }

  // Carica chat history
  Future<List<dynamic>> caricaChatHistory() async {
    try {
      final path = await _localPath;
      final file = File('$path/chat_history.json');
      if (!await file.exists()) return [];
      
      final contents = await file.readAsString();
      return jsonDecode(contents) as List<dynamic>;
    } catch (e) {
      print('Errore caricamento chat: $e');
      return [];
    }
  }
}
