import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/persona.dart';
import '../models/pasto.dart';

import '../models/bodygram.dart';
import '../widgets/giorno_selector.dart';
import '../widgets/pasto_card.dart';
import '../widgets/stat_card.dart';
import '../widgets/progress_indicator_bar.dart';
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

class _DietaScreenState extends State<DietaScreen> with SingleTickerProviderStateMixin {
  late int _selectedDay;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Inizializza col giorno calcolato reale
    final service = Provider.of<GiornoDietaService>(context, listen: false);
    _selectedDay = service.getGiornoOggi(widget.persona.dietaAttiva?.dataInizio);
    
    // Inizializza TabController con 2 tab
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
    
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: Text(persona.nome),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Condivisione non ancora implementata')),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(
              icon: Icon(Icons.restaurant_menu_outlined),
              text: 'Dieta',
            ),
            Tab(
              icon: Icon(Icons.monitor_heart_outlined),
              text: 'Bodygram',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 0: Dieta
          _buildDietaContent(context, appState, persona),
          
          // Tab 1: Bodygram
          _buildBodygramContent(context, persona),
        ],
      ),
    );
  }

  /// Contenuto del tab Dieta (contenuto originale della schermata)
  Widget _buildDietaContent(BuildContext context, AppState appState, Persona persona) {
    final dieta = persona.dietaAttiva;
    final giornoDietaService = Provider.of<GiornoDietaService>(context);
    final giornoRealeOggi = giornoDietaService.getGiornoOggi(dieta?.dataInizio);
    
    // Se non c'è dieta, mostra messaggio
    if (dieta == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Nessuna dieta caricata',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Carica un PDF del piano alimentare',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
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

    return Column(
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
    );
  }

  /// Contenuto del tab Bodygram
  Widget _buildBodygramContent(BuildContext context, Persona persona) {
    final bodygram = persona.bodygramAttivo;
    
    // Se non ci sono dati Bodygram
    if (bodygram == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.monitor_heart_outlined, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Nessun dato corporeo disponibile',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Carica un PDF del report Bodygram per visualizzare i dati delle analisi corporee',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Mostra i dati del Bodygram
    final dateFormatter = DateFormat('d MMMM yyyy', 'it_IT');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Esame del ${dateFormatter.format(bodygram.dataEsame)}',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '${bodygram.eta} anni - ${bodygram.sesso}',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 24),

          // Section 1: Dati Base
          StatCard(
            title: 'Dati Base',
            icon: Icons.monitor_weight_outlined,
            children: [
              StatRow(
                icon: Icons.scale_outlined,
                label: 'Peso',
                value: bodygram.datiBase.peso.toStringAsFixed(1),
                unit: 'kg',
              ),
              Divider(color: Colors.grey.shade100),
              StatRow(
                icon: Icons.height_outlined,
                label: 'Altezza',
                value: (bodygram.datiBase.altezza * 100).toStringAsFixed(0),
                unit: 'cm',
              ),
              Divider(color: Colors.grey.shade100),
              StatRow(
                icon: Icons.calculate_outlined,
                label: 'BMI',
                value: bodygram.datiBase.bmi.toStringAsFixed(1),
                trailing: _buildBmiBadge(context, bodygram.datiBase.bmi),
              ),
            ],
          ),

          // Section 2: Composizione Corporea
          StatCard(
            title: 'Composizione',
            icon: Icons.pie_chart_outline,
            children: [
              _buildFatMassBar(context, bodygram),
              Divider(color: Colors.grey.shade100, height: 24),
              ProgressIndicatorBar(
                label: 'Massa Magra',
                value: bodygram.componenti.massaMagraPercentuale,
                valueText: '${bodygram.componenti.massaMagra.toStringAsFixed(1)} kg',
                color: AppColors.primary,
              ),
            ],
          ),

          // Section 3: Fluidi
          StatCard(
            title: 'Fluidi',
            icon: Icons.water_drop_outlined,
            children: [
              StatRow(
                icon: Icons.water_outlined,
                label: 'Acqua Totale',
                value: bodygram.fluidi.acquaTotale.toStringAsFixed(1),
                unit: 'Lt',
                trailing: Text(
                  '${bodygram.fluidi.acquaTotalePercentuale.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              Divider(color: Colors.grey.shade100),
              StatRow(
                icon: Icons.opacity_outlined,
                label: 'Idratazione',
                value: bodygram.idratazioneTissutale.toStringAsFixed(1),
                unit: '%',
                trailing: _buildHydrationBadge(context, bodygram),
              ),
            ],
          ),

          // Section 4: Metabolismo
          StatCard(
            title: 'Metabolismo',
            icon: Icons.bolt_outlined,
            children: [
              StatRow(
                icon: Icons.local_fire_department_outlined,
                label: 'Metabolismo Basale',
                value: bodygram.metabolismoBasale.toStringAsFixed(0),
                unit: 'kcal',
              ),
              Divider(color: Colors.grey.shade100),
              StatRow(
                icon: Icons.speed_outlined,
                label: 'Angolo di Fase',
                value: bodygram.angoloFase.toStringAsFixed(1),
                unit: '°',
                trailing: _buildPhaseAngleBadge(context, bodygram),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildBmiBadge(BuildContext context, double bmi) {
    Color color;
    String label;

    if (bmi < 18.5) {
      color = Colors.blue;
      label = 'Sottopeso';
    } else if (bmi < 25) {
      color = AppColors.primary;
      label = 'Normale';
    } else if (bmi < 30) {
      color = Colors.orange;
      label = 'Sovrappeso';
    } else {
      color = Colors.red;
      label = 'Obeso';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildFatMassBar(BuildContext context, Bodygram bodygram) {
    // Logic: warning if > 25 (men) or > 32 (women)
    final isMale = bodygram.sesso.toLowerCase().startsWith('m');
    final threshold = isMale ? 25.0 : 32.0;
    final isWarning = bodygram.massaGrassaPercentuale > threshold;

    return ProgressIndicatorBar(
      label: 'Massa Grassa',
      value: bodygram.massaGrassaPercentuale,
      valueText: '${bodygram.massaGrassa.toStringAsFixed(1)} kg',
      color: isWarning ? Colors.orange : AppColors.primary,
      isWarning: isWarning,
      badge: isWarning ? 'Attenzione' : 'Ottimo',
    );
  }

  Widget? _buildHydrationBadge(BuildContext context, Bodygram bodygram) {
    // Badge if hydration is between 70-76%
    if (bodygram.idratazioneTissutale >= 70 && bodygram.idratazioneTissutale <= 76) {
      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, size: 16, color: Colors.green),
      );
    }
    return null;
  }

  Widget? _buildPhaseAngleBadge(BuildContext context, Bodygram bodygram) {
    // Badge if phase angle is between 5-7
    if (bodygram.angoloFase >= 5 && bodygram.angoloFase <= 7) {
      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, size: 16, color: Colors.green),
      );
    }
    return null;
  }
}
