import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/persona.dart';
import '../models/pasto.dart';
import '../models/giorno.dart';
import '../widgets/giorno_selector.dart';
import '../widgets/pasto_card.dart';
import '../theme/app_theme.dart';
import '../providers/app_state.dart';
import '../services/giorno_dieta_service.dart';

class DietaScreen extends StatefulWidget {
  final Persona persona;

  const DietaScreen({
    super.key,
    required this.persona,
  });

  @override
  State<DietaScreen> createState() => _DietaScreenState();
}

class _DietaScreenState extends State<DietaScreen> {
  late int _selectedDay;

  @override
  void initState() {
    super.initState();
    // Inizializza col giorno calcolato reale
    final service = Provider.of<GiornoDietaService>(context, listen: false);
    _selectedDay = service.getGiornoOggi(widget.persona.dietaAttiva?.dataInizio);
  }

  void _onDayChanged(int day) {
    setState(() {
      _selectedDay = day;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Ricarichiamo la persona dallo state per avere i dati aggiornati
    final appState = Provider.of<AppState>(context);
    final persona = appState.persone.firstWhere(
      (p) => p.id == widget.persona.id, 
      orElse: () => widget.persona
    );
    
    final dieta = persona.dietaAttiva;
    final giornoDietaService = Provider.of<GiornoDietaService>(context);
    final giornoRealeOggi = giornoDietaService.getGiornoOggi(dieta?.dataInizio);
    
    // Se non c'è dieta, mostra messaggio (safety check)
    if (dieta == null) {
      return Scaffold(
        appBar: AppBar(title: Text(persona.nome)),
        body: const Center(child: Text('Nessuna dieta caricata.')),
      );
    }

    final giorno = dieta.getGiorno(_selectedDay);
    
    // Ordine visualizzazione pasti
    final orderedPasti = [
      TipoPasto.colazione,
      TipoPasto.spuntinoMattina,
      TipoPasto.pranzo,
      TipoPasto.merenda,
      TipoPasto.cena,
      TipoPasto.spuntinoSera,
      TipoPasto.duranteGiornata,
    ];

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: Text('Dieta ${persona.nome}'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              // TODO: Implementare condivisione dieta
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Condivisione non ancora implementata')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            color: AppColors.bgPrimary,
            child: Column(
              children: [
                GiornoSelector(
                  selectedDay: _selectedDay,
                  onDayChanged: _onDayChanged,
                ),
                
                // Bottone per impostare oggi
                if (_selectedDay != giornoRealeOggi)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: TextButton.icon(
                      icon: const Icon(Icons.today, size: 16),
                      label: Text('Imposta Giorno $_selectedDay come OGGI'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        visualDensity: VisualDensity.compact,
                      ),
                      onPressed: () async {
                        await appState.impostaGiornoCorrente(persona.nome, _selectedDay);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Dieta aggiornata: Oggi è il Giorno $_selectedDay')),
                        );
                      },
                    ),
                  ),
                  
                if (_selectedDay == giornoRealeOggi)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, size: 14, color: Colors.green[700]),
                        const SizedBox(width: 4),
                        Text(
                          'Questo è il giorno di oggi',
                          style: TextStyle(color: Colors.green[700], fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: giorno == null
                ? const Center(child: Text('Nessun piano per questo giorno'))
                : ListView(
                    padding: const EdgeInsets.only(bottom: 24),
                    children: [
                      // Genera le card solo per i pasti presenti nel giorno
                      ...orderedPasti
                          .where((tipo) => giorno.pasti.containsKey(tipo))
                          .map((tipo) => PastoCard(pasto: giorno.pasti[tipo]!)),
                      
                      const SizedBox(height: 20),
                      if (dieta.noteGenerali != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Card(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: const BorderSide(color: Color(0xFFEEEEEE)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'NOTE GENERALI',
                                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(dieta.noteGenerali!),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
