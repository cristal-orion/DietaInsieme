import 'dieta.dart';
import 'bodygram.dart';
import 'peso_giornaliero.dart';

class Persona {
  final String id;
  final String nome;
  final String? avatarEmoji;
  String? immagineProfilo; // Path locale all'immagine profilo
  Dieta? dietaAttiva;
  Bodygram? bodygramAttivo;
  final List<Dieta> storicoDiete;
  final List<Bodygram> storicoBodygram;
  final List<PesoGiornaliero> storicoPesi;

  Persona({
    required this.id,
    required this.nome,
    this.avatarEmoji,
    this.immagineProfilo,
    this.dietaAttiva,
    this.bodygramAttivo,
    this.storicoDiete = const [],
    this.storicoBodygram = const [],
    this.storicoPesi = const [],
  });

  /// Peso di oggi (se presente)
  PesoGiornaliero? get pesoOggi {
    final now = DateTime.now();
    final oggi = DateTime(now.year, now.month, now.day);
    try {
      return storicoPesi.firstWhere(
        (p) => p.dataNormalizzata == oggi,
      );
    } catch (_) {
      return null;
    }
  }

  /// Ultimo peso registrato
  PesoGiornaliero? get ultimoPeso {
    if (storicoPesi.isEmpty) return null;
    final ordinati = pesiOrdinati;
    return ordinati.isNotEmpty ? ordinati.last : null;
  }

  /// Pesi ordinati per data (dal più vecchio al più recente)
  List<PesoGiornaliero> get pesiOrdinati {
    final lista = List<PesoGiornaliero>.from(storicoPesi);
    lista.sort((a, b) => a.data.compareTo(b.data));
    return lista;
  }

  /// Pesi degli ultimi N giorni
  List<PesoGiornaliero> pesiUltimiGiorni(int giorni) {
    final limite = DateTime.now().subtract(Duration(days: giorni));
    return pesiOrdinati.where((p) => p.data.isAfter(limite)).toList();
  }

  /// Bodygram ordinati per data esame (dal più vecchio al più recente)
  List<Bodygram> get bodygramOrdinati {
    final lista = <Bodygram>[];
    if (bodygramAttivo != null) lista.add(bodygramAttivo!);
    lista.addAll(storicoBodygram);
    lista.sort((a, b) => a.dataEsame.compareTo(b.dataEsame));
    return lista;
  }

  /// Tutti i bodygram (attivo + storico) ordinati per data
  List<Bodygram> get tuttiBodygram => bodygramOrdinati;

  Map<String, dynamic> toJson() => {
    'id': id,
    'nome': nome,
    'avatar_emoji': avatarEmoji,
    'immagine_profilo': immagineProfilo,
    'dieta_attiva': dietaAttiva?.toJson(),
    'bodygram_attivo': bodygramAttivo?.toJson(),
    'storico_bodygram': storicoBodygram.map((b) => b.toJson()).toList(),
    'storico_pesi': storicoPesi.map((p) => p.toJson()).toList(),
  };

  factory Persona.fromJson(Map<String, dynamic> json) {
    return Persona(
      id: json['id'] as String,
      nome: json['nome'] as String,
      avatarEmoji: json['avatar_emoji'] as String?,
      immagineProfilo: json['immagine_profilo'] as String?,
      dietaAttiva: json['dieta_attiva'] != null
          ? Dieta.fromJson(json['dieta_attiva'] as Map<String, dynamic>)
          : null,
      bodygramAttivo: json['bodygram_attivo'] != null
          ? Bodygram.fromJson(json['bodygram_attivo'] as Map<String, dynamic>)
          : null,
      storicoBodygram: json['storico_bodygram'] != null
          ? (json['storico_bodygram'] as List)
              .map((b) => Bodygram.fromJson(b as Map<String, dynamic>))
              .toList()
          : [],
      storicoPesi: json['storico_pesi'] != null
          ? (json['storico_pesi'] as List)
              .map((p) => PesoGiornaliero.fromJson(p as Map<String, dynamic>))
              .toList()
          : [],
    );
  }
}
