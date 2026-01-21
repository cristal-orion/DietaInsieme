import 'package:flutter_test/flutter_test.dart';
import 'package:dieta_insieme/models/alimento.dart';
import 'package:dieta_insieme/models/pasto.dart';
import 'package:dieta_insieme/models/giorno.dart';
import 'package:dieta_insieme/models/dieta.dart';
import 'package:dieta_insieme/models/bodygram.dart';

void main() {
  group('Alimento', () {
    test('fromJson creates correct Alimento', () {
      final json = {
        'nome': 'Pasta',
        'quantita': '80g',
        'alternative': [
          {'nome': 'Riso', 'quantita': '80g'}
        ]
      };
      
      final alimento = Alimento.fromJson(json);
      
      expect(alimento.nome, 'Pasta');
      expect(alimento.quantita, '80g');
      expect(alimento.alternative.length, 1);
      expect(alimento.alternative.first.nome, 'Riso');
      expect(alimento.hasAlternative, true);
    });

    test('toJson creates correct Map', () {
      final alimento = Alimento(
        nome: 'Pasta',
        quantita: '80g',
        alternative: [Alimento(nome: 'Riso', quantita: '80g')],
      );
      
      final json = alimento.toJson();
      
      expect(json['nome'], 'Pasta');
      expect(json['quantita'], '80g');
      expect((json['alternative'] as List).length, 1);
    });
  });

  group('Pasto', () {
    test('fromJson creates correct Pasto', () {
      final json = {
        'alimenti': [
          {'nome': 'Latte', 'quantita': '200ml', 'alternative': []}
        ],
        'nota': 'Senza lattosio'
      };
      
      final pasto = Pasto.fromJson(json, TipoPasto.colazione);
      
      expect(pasto.tipo, TipoPasto.colazione);
      expect(pasto.alimenti.length, 1);
      expect(pasto.alimenti.first.nome, 'Latte');
      expect(pasto.nota, 'Senza lattosio');
      expect(pasto.tipoLabel, 'Colazione');
      expect(pasto.tipoEmoji, '🌅');
    });
  });

  group('Giorno', () {
    test('fromJson creates correct Giorno', () {
      final json = {
        'numero': 1,
        'pasti': {
          'colazione': {
            'alimenti': [
              {'nome': 'Latte', 'quantita': '200ml', 'alternative': []}
            ]
          }
        }
      };
      
      final giorno = Giorno.fromJson(json);
      
      expect(giorno.numero, 1);
      expect(giorno.pasti.containsKey(TipoPasto.colazione), true);
      expect(giorno.getPasto(TipoPasto.colazione)?.alimenti.first.nome, 'Latte');
    });
  });
  
  group('Dieta', () {
    test('fromJson creates correct Dieta', () {
      final json = {
        'persona': 'Mario Rossi',
        'data_caricamento': '2023-01-01T00:00:00.000',
        'giorni': [
          {
            'numero': 1,
            'pasti': {
              'colazione': {
                'alimenti': [
                  {'nome': 'Latte', 'quantita': '200ml', 'alternative': []}
                ]
              }
            }
          }
        ],
        'note_generali': 'Bere molta acqua',
        'integratori': ['Multivitaminico']
      };
      
      final dieta = Dieta.fromJson(json);
      
      expect(dieta.persona, 'Mario Rossi');
      expect(dieta.giorni.length, 1);
      expect(dieta.noteGenerali, 'Bere molta acqua');
      expect(dieta.integratori.length, 1);
      expect(dieta.getGiorno(1)?.numero, 1);
    });
  });

  group('Bodygram', () {
    test('fromJson creates correct Bodygram', () {
      final json = {
        'persona': 'Mario Rossi',
        'data_esame': '2023-01-01',
        'data_nascita': '1990-01-01',
        'sesso': 'M',
        'dati_base': {'peso': 80.0, 'altezza': 180.0, 'bmi': 24.7},
        'fluidi': {
            'acqua_totale': 50.0, 'acqua_totale_percentuale': 60.0,
            'acqua_extracellulare': 20.0, 'acqua_extracellulare_percentuale': 25.0,
            'acqua_intracellulare': 30.0, 'acqua_intracellulare_percentuale': 35.0
        },
        'componenti': {
            'massa_cellulare': 40.0, 'massa_cellulare_percentuale': 50.0,
            'massa_magra': 70.0, 'massa_magra_percentuale': 85.0,
            'massa_muscolo_scheletrica': 35.0, 'massa_muscolo_scheletrica_percentuale': 40.0,
            'massa_muscolare': 65.0, 'massa_muscolare_percentuale': 80.0
        },
        'massa_grassa': 10.0,
        'massa_grassa_percentuale': 15.0,
        'metabolismo_basale': 1800.0,
        'angolo_fase': 6.5,
        'idratazione_tissutale': 73.0
      };
      
      final bodygram = Bodygram.fromJson(json);
      
      expect(bodygram.persona, 'Mario Rossi');
      expect(bodygram.datiBase.peso, 80.0);
      expect(bodygram.massaGrassa, 10.0);
    });
  });
}
