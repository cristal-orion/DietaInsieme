import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pasto_oggi_provider.dart';
import '../providers/app_state.dart';
import '../models/pasto.dart';
import '../widgets/giorno_dieta_header.dart';
import '../widgets/pasto_tab_selector.dart';
import '../widgets/alimenti_comuni_section.dart';
import '../widgets/scelta_alternativa_card.dart';
import '../widgets/alimenti_separati_section.dart';
import '../widgets/assistente_input_bar.dart';
import '../widgets/chat_message_bubble.dart';
import '../theme/app_theme.dart';

class PastoOggiScreen extends StatefulWidget {
  const PastoOggiScreen({super.key});

  @override
  State<PastoOggiScreen> createState() => _PastoOggiScreenState();
}

class _PastoOggiScreenState extends State<PastoOggiScreen> {
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    // Inizializza il provider con le persone dallo stato globale
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Inizializza il provider con le persone dallo stato globale
      _updatePastoProvider();
    });
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updatePastoProvider();
  }
  
  void _updatePastoProvider() {
    final appState = Provider.of<AppState>(context, listen: false);
    if (appState.persone.length >= 2) {
      final pastoProvider = Provider.of<PastoOggiProvider>(context, listen: false);
      // Re-init only if needed or data changed, though init is cheap enough
      pastoProvider.init(
        appState.persone[0],
        appState.persone[1],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cosa mangiamo oggi?'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
               _mostraDialogImpostaGiorno(context);
            },
          ),
        ],
      ),
      body: Consumer2<PastoOggiProvider, AppState>(
        builder: (context, provider, appState, child) {
          // Check if data updated in AppState and re-init if needed
          if (appState.persone.length >= 2) {
             // We don't want to re-init on every build, but we need to ensure provider has latest data
             // The didChangeDependencies above helps, but explicit check here ensures reactivity
             // If the provider's people don't match appState's people, re-init
             if (provider.nomePersona1 != appState.persone[0].nome || 
                 provider.nomePersona2 != appState.persone[1].nome) {
               // Schedule update for next frame to avoid build conflicts
               WidgetsBinding.instance.addPostFrameCallback((_) {
                 provider.init(appState.persone[0], appState.persone[1]);
               });
             }
          }

          if (!provider.isConfigurato) {
            return const Center(child: Text('Servono almeno due persone caricate'));
          }

          final pasto = provider.pastoAnalizzato;
          if (pasto == null) {
            return const Center(child: Text('Dati del pasto non disponibili'));
          }

          return Column(
            children: [
              Expanded(
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Header Giorno
                    GiornoDietaHeader(
                      giornoCorrente: provider.giornoCorrente,
                      onModifica: () => _mostraDialogImpostaGiorno(context),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Selettore Pasto (Pranzo/Cena)
                    PastoTabSelector(
                      selectedPasto: provider.pastoSelezionato,
                      onPastoChanged: provider.setPasto,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Messaggio compatibilità
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                      ),
                      child: Text(
                        pasto.messaggioCompatibilita,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Sezione Alimenti Comuni
                    if (pasto.alimentiComuni.isNotEmpty) ...[
                      AlimentiComuniSection(
                        alimenti: pasto.alimentiComuni,
                        nomePersona1: provider.nomePersona1,
                        nomePersona2: provider.nomePersona2,
                      ),
                      const SizedBox(height: 24),
                    ],
                    
                    // Sezione Scelte (Alternative)
                    if (pasto.scelteDaFare.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.swap_horiz, color: Colors.blue.shade700, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'DA SCEGLIERE INSIEME',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.1,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ...pasto.scelteDaFare.map((scelta) => SceltaAlternativaCard(
                        scelta: scelta,
                        nomePersona1: provider.nomePersona1,
                        nomePersona2: provider.nomePersona2,
                        onSceltaEffettuata: (val) => provider.effettuaScelta(scelta.categoria, val),
                      )),
                      const SizedBox(height: 24),
                    ],
                    
                    // Sezione Separati
                    if (pasto.alimentiSeparati.isNotEmpty) ...[
                      AlimentiSeparatiSection(alimenti: pasto.alimentiSeparati),
                      const SizedBox(height: 24),
                    ],
                    
                    // Chat History
                    if (provider.chatHistory.isNotEmpty) ...[
                      const Divider(thickness: 1, height: 40),
                      Text(
                        '💬 Conversazione',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...provider.chatHistory.map((msg) => ChatMessageBubble(message: msg)),
                    ],
                    
                    // Spazio per input bar (bottom padding)
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              
              // Input Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: AssistenteInputBar(
                  isLoading: provider.isLoadingChat,
                  onInvia: (text, imageBytes) {
                     provider.inviaMessaggio(text); // TODO: Handle imageBytes in provider
                     _scrollToBottom();
                  },
                  onRicetta: () {
                    provider.richiediRicetta();
                    _scrollToBottom();
                  },
                  onAlternative: () {
                    provider.richiediAlternative();
                    _scrollToBottom();
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
  
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  
  void _mostraDialogImpostaGiorno(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Imposta Giorno'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Quale giorno della dieta è oggi?'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: List.generate(7, (index) {
                final giorno = index + 1;
                return ActionChip(
                  label: Text('Giorno $giorno'),
                  onPressed: () {
                    Provider.of<PastoOggiProvider>(context, listen: false)
                        .impostaOggiComeGiorno(giorno);
                    Navigator.pop(context);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
