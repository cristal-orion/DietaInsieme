class Bodygram {
  final String id;
  final String persona;
  final DateTime dataEsame;
  final DateTime dataNascita;
  final String sesso;
  final DatiBase datiBase;
  final Fluidi fluidi;
  final ComponentiBC componenti;
  final double massaGrassa;
  final double massaGrassaPercentuale;
  final double metabolismoBasale;
  final double angoloFase;
  final double idratazioneTissutale;
  final String? somatotipo; // Added field

  Bodygram({
    required this.id,
    required this.persona,
    required this.dataEsame,
    required this.dataNascita,
    required this.sesso,
    required this.datiBase,
    required this.fluidi,
    required this.componenti,
    required this.massaGrassa,
    required this.massaGrassaPercentuale,
    required this.metabolismoBasale,
    required this.angoloFase,
    required this.idratazioneTissutale,
    this.somatotipo,
  });

  int get eta => DateTime.now().difference(dataNascita).inDays ~/ 365;
  String get dataAnalisi => dataEsame.toIso8601String();
  
  // Helpers per accesso facilitato
  double get peso => datiBase.peso;
  double get altezza => datiBase.altezza;
  double get bmi => datiBase.bmi;
  String? get obiettivo => null; // Placeholder, non presente nel JSON attuale

  factory Bodygram.fromJson(Map<String, dynamic> json) => Bodygram(
    id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
    persona: json['persona'] as String,
    dataEsame: DateTime.parse(json['data_esame'] as String),
    dataNascita: DateTime.parse(json['data_nascita'] as String),
    sesso: json['sesso'] as String,
    datiBase: DatiBase.fromJson(json['dati_base'] as Map<String, dynamic>),
    fluidi: Fluidi.fromJson(json['fluidi'] as Map<String, dynamic>),
    componenti: ComponentiBC.fromJson(json['componenti'] as Map<String, dynamic>),
    massaGrassa: (json['massa_grassa'] as num).toDouble(),
    massaGrassaPercentuale: (json['massa_grassa_percentuale'] as num).toDouble(),
    metabolismoBasale: (json['metabolismo_basale'] as num).toDouble(),
    angoloFase: (json['angolo_fase'] as num).toDouble(),
    idratazioneTissutale: (json['idratazione_tissutale'] as num).toDouble(),
    somatotipo: json['somatotipo'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'persona': persona,
    'data_esame': dataEsame.toIso8601String(),
    'data_nascita': dataNascita.toIso8601String(),
    'sesso': sesso,
    'dati_base': datiBase.toJson(),
    'fluidi': fluidi.toJson(),
    'componenti': componenti.toJson(),
    'massa_grassa': massaGrassa,
    'massa_grassa_percentuale': massaGrassaPercentuale,
    'metabolismo_basale': metabolismoBasale,
    'angolo_fase': angoloFase,
    'idratazione_tissutale': idratazioneTissutale,
    'somatotipo': somatotipo,
  };
}

class DatiBase {
  final double peso;
  final double altezza;
  final double bmi;

  DatiBase({
    required this.peso,
    required this.altezza,
    required this.bmi,
  });

  factory DatiBase.fromJson(Map<String, dynamic> json) => DatiBase(
    peso: (json['peso'] as num).toDouble(),
    altezza: (json['altezza'] as num).toDouble(),
    bmi: (json['bmi'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'peso': peso,
    'altezza': altezza,
    'bmi': bmi,
  };
}

class Fluidi {
  final double acquaTotale;
  final double acquaTotalePercentuale;
  final double acquaExtracellulare;
  final double acquaExtracellularePercentuale;
  final double acquaIntracellulare;
  final double acquaIntracellularePercentuale;

  Fluidi({
    required this.acquaTotale,
    required this.acquaTotalePercentuale,
    required this.acquaExtracellulare,
    required this.acquaExtracellularePercentuale,
    required this.acquaIntracellulare,
    required this.acquaIntracellularePercentuale,
  });

  factory Fluidi.fromJson(Map<String, dynamic> json) => Fluidi(
    acquaTotale: (json['acqua_totale'] as num).toDouble(),
    acquaTotalePercentuale: (json['acqua_totale_percentuale'] as num).toDouble(),
    acquaExtracellulare: (json['acqua_extracellulare'] as num).toDouble(),
    acquaExtracellularePercentuale: (json['acqua_extracellulare_percentuale'] as num).toDouble(),
    acquaIntracellulare: (json['acqua_intracellulare'] as num).toDouble(),
    acquaIntracellularePercentuale: (json['acqua_intracellulare_percentuale'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'acqua_totale': acquaTotale,
    'acqua_totale_percentuale': acquaTotalePercentuale,
    'acqua_extracellulare': acquaExtracellulare,
    'acqua_extracellulare_percentuale': acquaExtracellularePercentuale,
    'acqua_intracellulare': acquaIntracellulare,
    'acqua_intracellulare_percentuale': acquaIntracellularePercentuale,
  };
}

class ComponentiBC {
  final double massaCellulare;
  final double massaCellularePercentuale;
  final double massaMagra;
  final double massaMagraPercentuale;
  final double massaMuscoloScheletrica;
  final double massaMuscoloScheletricaPercentuale;
  final double massaMuscolare;
  final double massaMuscolarePercentuale;

  ComponentiBC({
    required this.massaCellulare,
    required this.massaCellularePercentuale,
    required this.massaMagra,
    required this.massaMagraPercentuale,
    required this.massaMuscoloScheletrica,
    required this.massaMuscoloScheletricaPercentuale,
    required this.massaMuscolare,
    required this.massaMuscolarePercentuale,
  });

  factory ComponentiBC.fromJson(Map<String, dynamic> json) => ComponentiBC(
    massaCellulare: (json['massa_cellulare'] as num).toDouble(),
    massaCellularePercentuale: (json['massa_cellulare_percentuale'] as num).toDouble(),
    massaMagra: (json['massa_magra'] as num).toDouble(),
    massaMagraPercentuale: (json['massa_magra_percentuale'] as num).toDouble(),
    massaMuscoloScheletrica: (json['massa_muscolo_scheletrica'] as num).toDouble(),
    massaMuscoloScheletricaPercentuale: (json['massa_muscolo_scheletrica_percentuale'] as num).toDouble(),
    massaMuscolare: (json['massa_muscolare'] as num).toDouble(),
    massaMuscolarePercentuale: (json['massa_muscolare_percentuale'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'massa_cellulare': massaCellulare,
    'massa_cellulare_percentuale': massaCellularePercentuale,
    'massa_magra': massaMagra,
    'massa_magra_percentuale': massaMagraPercentuale,
    'massa_muscolo_scheletrica': massaMuscoloScheletrica,
    'massa_muscolo_scheletrica_percentuale': massaMuscoloScheletricaPercentuale,
    'massa_muscolare': massaMuscolare,
    'massa_muscolare_percentuale': massaMuscolarePercentuale,
  };
}
