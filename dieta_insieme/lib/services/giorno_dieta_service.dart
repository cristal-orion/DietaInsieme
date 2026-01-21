import 'package:shared_preferences/shared_preferences.dart';

class GiornoDietaService {
  static const String _dataInizioKey = 'data_inizio_dieta';
  
  final SharedPreferences _prefs;
  
  GiornoDietaService(this._prefs);
  
  /// Calcola che giorno della dieta è oggi (1-7, ciclico)
  /// Se [dataInizio] è fornito, usa quella data invece di quella salvata nelle prefs
  int getGiornoOggi([DateTime? dataInizioSpecifica]) {
    final dataInizio = dataInizioSpecifica ?? getDataInizio();
    if (dataInizio == null) return 1;
    
    final oggi = DateTime.now();
    // Normalize to midnight to avoid time issues
    final oggiDate = DateTime(oggi.year, oggi.month, oggi.day);
    final dataInizioDate = DateTime(dataInizio.year, dataInizio.month, dataInizio.day);
    
    final differenza = oggiDate.difference(dataInizioDate).inDays;
    
    if (differenza < 0) return 1; // Future date
    
    // Giorno 1-7 ciclico: (0 % 7) + 1 = 1, (6 % 7) + 1 = 7, (7 % 7) + 1 = 1
    return (differenza % 7) + 1;
  }
  
  /// Ottiene la data di inizio dieta salvata
  DateTime? getDataInizio() {
    final stored = _prefs.getString(_dataInizioKey);
    if (stored == null) return null;
    return DateTime.parse(stored);
  }
  
  /// Salva la data di inizio dieta
  Future<void> setDataInizio(DateTime data) async {
    await _prefs.setString(_dataInizioKey, data.toIso8601String());
  }
  
  /// Imposta che oggi è un giorno specifico (calcola data inizio di conseguenza)
  Future<void> setOggiComeGiorno(int giorno) async {
    if (giorno < 1 || giorno > 7) return;
    
    final oggi = DateTime.now();
    final oggiDate = DateTime(oggi.year, oggi.month, oggi.day);
    
    // Se oggi voglio che sia giorno 3, la dieta è iniziata 2 giorni fa
    final dataInizio = oggiDate.subtract(Duration(days: giorno - 1));
    await setDataInizio(dataInizio);
  }
  
  /// Verifica se la data inizio è stata impostata
  bool isConfigurato() => getDataInizio() != null;
  
  /// Resetta (per nuova dieta)
  Future<void> reset() async {
    await _prefs.remove(_dataInizioKey);
  }
}
