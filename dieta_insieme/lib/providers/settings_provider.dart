import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pasto.dart';

class SettingsProvider extends ChangeNotifier {
  final SharedPreferences _prefs;

  // Orari di default
  static const Map<TipoPasto, TimeOfDay> _defaultOrari = {
    TipoPasto.colazione: TimeOfDay(hour: 7, minute: 0),
    TipoPasto.spuntinoMattina: TimeOfDay(hour: 10, minute: 30),
    TipoPasto.pranzo: TimeOfDay(hour: 13, minute: 0),
    TipoPasto.merenda: TimeOfDay(hour: 16, minute: 30),
    TipoPasto.cena: TimeOfDay(hour: 20, minute: 0),
    TipoPasto.spuntinoSera: TimeOfDay(hour: 22, minute: 30),
    // DuranteGiornata non ha un orario specifico, lo ignoriamo per il calcolo automatico
  };

  final Map<TipoPasto, TimeOfDay> _orariPasti = {};

  SettingsProvider(this._prefs) {
    _loadOrari();
  }

  void _loadOrari() {
    for (final tipo in TipoPasto.values) {
      if (tipo == TipoPasto.duranteGiornata) continue;
      
      final key = 'orario_${tipo.name}';
      final savedHour = _prefs.getInt('${key}_hour');
      final savedMinute = _prefs.getInt('${key}_minute');

      if (savedHour != null && savedMinute != null) {
        _orariPasti[tipo] = TimeOfDay(hour: savedHour, minute: savedMinute);
      } else {
        _orariPasti[tipo] = _defaultOrari[tipo]!;
      }
    }
    notifyListeners();
  }

  TimeOfDay getOrario(TipoPasto tipo) {
    return _orariPasti[tipo] ?? const TimeOfDay(hour: 0, minute: 0);
  }

  Future<void> setOrario(TipoPasto tipo, TimeOfDay orario) async {
    _orariPasti[tipo] = orario;
    final key = 'orario_${tipo.name}';
    await _prefs.setInt('${key}_hour', orario.hour);
    await _prefs.setInt('${key}_minute', orario.minute);
    notifyListeners();
  }

  /// Restituisce il TipoPasto corrente basato sull'ora fornita (o adesso)
  TipoPasto getPastoCorrente([TimeOfDay? now]) {
    final nowTime = now ?? TimeOfDay.now();
    final nowMinutes = nowTime.hour * 60 + nowTime.minute;

    // Ordiniamo i pasti per orario
    final sortedPasti = _orariPasti.entries.toList()
      ..sort((a, b) {
        final aMin = a.value.hour * 60 + a.value.minute;
        final bMin = b.value.hour * 60 + b.value.minute;
        return aMin.compareTo(bMin);
      });

    // Troviamo l'ultimo pasto che è già "passato" o è adesso
    // Logica: Se sono le 18:00 e il pranzo è alle 13:00 e la merenda alle 16:30 e cena alle 20:00.
    // Dobbiamo mostrare quello che sta per arrivare o quello in corso?
    // Richiesta utente: "ore 18 mostrare la cena". Quindi il *prossimo* pasto o quello corrente se siamo vicini?
    // Utente dice: "ore 18 mostrare la cena".
    // Merenda (16:30) < 18:00 < Cena (20:00).
    // Quindi se ho superato l'orario di un pasto, mostro il successivo?
    // Se sono le 8:00 e colazione è alle 7:00, mostro Spuntino? O Colazione finché non è passata un'ora?
    // Interpretazione "Smart": Mostriamo il pasto che "sta arrivando" o è "appena iniziato".
    // Se sono le 18:00, la merenda delle 16:30 è passata. La cena delle 20:00 deve ancora arrivare. Quindi Cena.
    
    for (int i = 0; i < sortedPasti.length; i++) {
      final pastoTime = sortedPasti[i].value;
      final pastoMinutes = pastoTime.hour * 60 + pastoTime.minute;
      
      // Se l'ora attuale è PRIMA di questo pasto, allora questo è il prossimo pasto (o quello corrente da preparare)
      if (nowMinutes < pastoMinutes) {
        return sortedPasti[i].key;
      }
    }

    // Se siamo dopo l'ultimo pasto (es. dopo cena), o è tardi notte o è il primo pasto di domani.
    // Per semplicità, se è dopo l'ultimo orario (es. 23:00), torniamo Colazione (per domani) o Spuntino Sera se ancora valido?
    // Torniamo l'ultimo della lista (spesso spuntino sera) o Colazione se molto tardi?
    // Se sono le 23:00 e spuntino sera era 22:30.
    // Facciamo che torniamo l'ultimo se siamo ancora in giornata, o colazione.
    // Per ora torniamo il primo della lista (Colazione) così uno si prepara per domani, oppure l'ultimo.
    // Mettiamo che dopo l'ultimo orario mostriamo comunque l'ultimo finché non scatta la notte fonda.
    // Ma per "anticipare", forse meglio Colazione.
    
    return TipoPasto.colazione; // Default fallback (ciclico)
  }
}
