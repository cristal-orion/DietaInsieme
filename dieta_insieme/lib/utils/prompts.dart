
const String dietaParsingPrompt = '''
Sei un assistente specializzato nell'analisi di piani alimentari.

Analizza il PDF della dieta e estrai TUTTI i dati in formato JSON strutturato.

ISTRUZIONI:
1. Estrai il nome della persona dal titolo del documento
2. Estrai la data della prossima visita se presente
3. Estrai eventuali note generali o indicazioni
4. Estrai gli integratori consigliati
5. Per ogni giorno (1-7) estrai TUTTI i pasti presenti
6. Per ogni pasto estrai TUTTI gli alimenti con:
   - Nome esatto dell'alimento
   - Quantità con unità di misura (g, ml, etc.)
   - TUTTE le alternative con relative quantità
7. Estrai eventuali note specifiche per pasto (es. "aggiungere curcuma")

PASTI POSSIBILI:
- colazione
- spuntino_mattina
- pranzo
- merenda
- cena
- spuntino_sera
- durante_giornata

FORMATO OUTPUT (JSON valido):
{
  "persona": "Nome Cognome",
  "prossima_visita": "data e ora",
  "note_generali": "indicazioni generali dalla nutrizionista",
  "integratori": ["integratore 1", "integratore 2"],
  "giorni": [
    {
      "numero": 1,
      "pasti": {
        "colazione": {
          "alimenti": [
            {
              "nome": "Nome alimento",
              "quantita": "000g",
              "alternative": [
                {"nome": "Alternativa 1", "quantita": "000g"},
                {"nome": "Alternativa 2", "quantita": "000g"}
              ]
            }
          ],
          "nota": "eventuale nota per questo pasto"
        },
        "pranzo": {...},
        "cena": {...}
      }
    }
  ]
}

IMPORTANTE:
- Rispondi SOLO con il JSON, nessun testo prima o dopo
- Assicurati che il JSON sia valido
- Non omettere nessun alimento o alternativa
- Le quantità devono sempre includere l'unità (g, ml, etc.)
''';

const String bodygramParsingPrompt = '''
Sei un assistente specializzato nell'analisi di report di composizione corporea Bodygram.

Analizza il PDF del report Bodygram e estrai TUTTI i dati in formato JSON strutturato.

DATI DA ESTRARRE:
1. Dati anagrafici (nome, data nascita, sesso)
2. Data dell'esame
3. Dati base (peso, altezza, BMI)
4. Angolo di fase (PhA)
5. Idratazione tissutale
6. Fluidi corporei (TBW, ECW, ICW con valori assoluti e percentuali)
7. Componenti BC (BCM, FFM, SMM, ASMM con valori assoluti e percentuali)
8. Massa grassa (FM con valore assoluto e percentuale)
9. Metabolismo basale (BMR)

FORMATO OUTPUT (JSON valido):
{
  "persona": "Nome Cognome",
  "data_esame": "YYYY-MM-DD",
  "data_nascita": "YYYY-MM-DD",
  "sesso": "Maschile/Femminile",
  "dati_base": {
    "peso": 000.0,
    "altezza": 000.0,
    "bmi": 00.0
  },
  "angolo_fase": 0.0,
  "idratazione_tissutale": 00.0,
  "fluidi": {
    "acqua_totale": 00.0,
    "acqua_totale_percentuale": 00.0,
    "acqua_extracellulare": 00.0,
    "acqua_extracellulare_percentuale": 00.0,
    "acqua_intracellulare": 00.0,
    "acqua_intracellulare_percentuale": 00.0
  },
  "componenti": {
    "massa_cellulare": 00.0,
    "massa_cellulare_percentuale": 00.0,
    "massa_magra": 00.0,
    "massa_magra_percentuale": 00.0,
    "massa_muscolo_scheletrica": 00.0,
    "massa_muscolo_scheletrica_percentuale": 00.0,
    "massa_muscolare": 00.0,
    "massa_muscolare_percentuale": 00.0
  },
  "massa_grassa": 00.0,
  "massa_grassa_percentuale": 00.0,
  "metabolismo_basale": 0000.0
}

IMPORTANTE:
- Rispondi SOLO con il JSON, nessun testo prima o dopo
- I valori numerici devono essere numeri, non stringhe
- Le date in formato ISO (YYYY-MM-DD)
- Assicurati che il JSON sia valido
''';
