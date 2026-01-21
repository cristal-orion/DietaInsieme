import 'dieta.dart';
import 'bodygram.dart';

class Persona {
  final String id;
  final String nome;
  final String? avatarEmoji;
  Dieta? dietaAttiva;
  Bodygram? bodygramAttivo;
  final List<Dieta> storicoDiete;
  final List<Bodygram> storicoBodygram;

  Persona({
    required this.id,
    required this.nome,
    this.avatarEmoji,
    this.dietaAttiva,
    this.bodygramAttivo,
    this.storicoDiete = const [],
    this.storicoBodygram = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'nome': nome,
    'dieta_attiva': dietaAttiva?.toJson(),
    'bodygram_attivo': bodygramAttivo?.toJson(),
  };

  factory Persona.fromJson(Map<String, dynamic> json) {
    return Persona(
      id: json['id'] as String,
      nome: json['nome'] as String,
      dietaAttiva: json['dieta_attiva'] != null 
          ? Dieta.fromJson(json['dieta_attiva'] as Map<String, dynamic>) 
          : null,
      bodygramAttivo: json['bodygram_attivo'] != null
          ? Bodygram.fromJson(json['bodygram_attivo'] as Map<String, dynamic>)
          : null,
    );
  }
}
