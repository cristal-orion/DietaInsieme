import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../providers/settings_provider.dart';
import '../models/pasto.dart';
import '../providers/pasto_oggi_provider.dart';
import '../services/giorno_dieta_service.dart';
import '../widgets/persona_pasto_card.dart';
import '../theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'upload_screen.dart';
import 'dieta_screen.dart';
import 'pasto_oggi_screen.dart';
import 'settings_screen.dart';
import 'chat_screen.dart'; // Added import

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _mealRefreshTimer;
  TipoPasto? _lastPasto;

  @override
  void initState() {
    super.initState();
    // Controlla ogni 30 secondi se il pasto corrente è cambiato
    _mealRefreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted) return;
      final settings = Provider.of<SettingsProvider>(context, listen: false);
      final nuovoPasto = settings.getPastoCorrente();
      if (nuovoPasto != _lastPasto) {
        setState(() {
          _lastPasto = nuovoPasto;
        });
      }
    });
  }

  @override
  void dispose() {
    _mealRefreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final currentPasto = settings.getPastoCorrente();
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('DietaInsieme'),
        backgroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Aggiungi',
            onSelected: (value) {
              if (value == 'persona') {
                _showAddPersonDialog(context);
              } else if (value == 'pdf') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UploadScreen()),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'persona',
                child: ListTile(
                  leading: Icon(Icons.person_add),
                  title: Text('Aggiungi persona'),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
              const PopupMenuItem(
                value: 'pdf',
                child: ListTile(
                  leading: Icon(Icons.file_upload),
                  title: Text('Carica documento PDF'),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, state, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, currentPasto.label),
                const SizedBox(height: 32),
                if (state.persone.isEmpty)
                  _buildEmptyState(context)
                else ...[
                  // Mostriamo una card per ogni persona col pasto corrente
                  ...state.persone.map((persona) {
                    // Calcoliamo il giorno specifico per questa persona
                    final giornoDietaService = Provider.of<GiornoDietaService>(context, listen: false);
                    final giornoPersona = giornoDietaService.getGiornoOggi(persona.dietaAttiva?.dataInizio);
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: PersonaPastoCard(
                        persona: persona,
                        tipoPasto: currentPasto,
                        giorno: giornoPersona,
                        onTap: () {
                           if (persona.dietaAttiva != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DietaScreen(persona: persona),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Nessuna dieta caricata per ${persona.nome}')),
                              );
                            }
                        },
                      ),
                    );
                  }),
                ],
                const SizedBox(height: 16),
                _buildConfrontoCard(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String pastoLabel) {
    final now = DateTime.now();
    final formatter = DateFormat('EEEE d MMMM', 'it_IT');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'È ora di $pastoLabel! 🍽️',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  formatter.format(now).toUpperCase(),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.primary,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            )),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            const Text(
              'Nessuna persona aggiunta.',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _showAddPersonDialog(context),
              icon: const Icon(Icons.person_add),
              label: const Text('Aggiungi Persona'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddPersonDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nuova Persona'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nome',
            hintText: 'Es. Michele',
          ),
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Provider.of<AppState>(context, listen: false)
                    .addPersona(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Salva'),
          ),
        ],
      ),
    );
  }

  Widget _buildConfrontoCard(BuildContext context) {
    return Card(
      color: AppColors.primary,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PastoOggiScreen(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.compare_arrows_rounded, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CONFRONTA DIETE',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Trova cosa mangiare insieme',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
