class Alimento {
  final String nome;
  final String quantita;
  final List<Alimento> alternative;

  Alimento({
    required this.nome,
    required this.quantita,
    this.alternative = const [],
  });

  factory Alimento.fromJson(Map<String, dynamic> json) => Alimento(
    nome: json['nome'] as String,
    quantita: json['quantita'] as String,
    alternative: (json['alternative'] as List<dynamic>?)
        ?.map((e) => Alimento.fromJson(e as Map<String, dynamic>))
        .toList() ?? [],
  );

  Map<String, dynamic> toJson() => {
    'nome': nome,
    'quantita': quantita,
    'alternative': alternative.map((e) => e.toJson()).toList(),
  };

  bool get hasAlternative => alternative.isNotEmpty;
}
