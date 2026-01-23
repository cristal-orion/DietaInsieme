import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../providers/settings_provider.dart';
import '../providers/app_state.dart';
import '../models/pasto.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _apiKeyController;
  bool _obscureApiKey = true;

  @override
  void initState() {
    super.initState();
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    _apiKeyController = TextEditingController(text: settings.apiKey);
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Impostazioni'),
      ),
      body: Consumer2<SettingsProvider, AppState>(
        builder: (context, settings, appState, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // === ORARI PASTI ===
              _buildSectionTitle(context, 'Orari Pasti'),
              const SizedBox(height: 8),
              const Text(
                'Imposta gli orari per visualizzare automaticamente il pasto corretto nella Home.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ...TipoPasto.values
                  .where((t) => t != TipoPasto.duranteGiornata)
                  .map((tipo) => _buildTimeSetting(context, settings, tipo)),

              const Divider(height: 48),

              // === GESTIONE DATI ===
              _buildSectionTitle(context, 'Gestione Dati'),
              const SizedBox(height: 8),
              const Text(
                'Esporta i tuoi dati per condividerli o farne un backup, oppure importa un file di backup.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),

              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.blueAccent,
                        child: Icon(Icons.share, color: Colors.white),
                      ),
                      title: const Text('Esporta Dati'),
                      subtitle: const Text('Condividi le diete con altri'),
                      onTap: () => _esportaDati(context, appState),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Icon(Icons.download, color: Colors.white),
                      ),
                      title: const Text('Importa Dati'),
                      subtitle: const Text('Carica un file di backup (.json)'),
                      onTap: () => _importaDati(context, appState),
                    ),
                  ],
                ),
              ),

              const Divider(height: 48),

              // === CICLO DIETA ===
              _buildSectionTitle(context, 'Ciclo Dieta'),
              const SizedBox(height: 8),
              const Text(
                'Riavvia il ciclo settimanale della dieta impostando oggi come Giorno 1.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              if (appState.persone.isEmpty)
                Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey.shade300,
                      child: const Icon(Icons.person_off, color: Colors.white),
                    ),
                    title: const Text('Nessuna persona'),
                    subtitle: const Text('Carica prima una dieta'),
                  ),
                )
              else
                ...appState.persone.map((p) => Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.calendar_month),
                        ),
                        title: Text('Riavvia dieta di ${p.nome}'),
                        subtitle: const Text('Imposta oggi come Giorno 1'),
                        trailing: const Icon(Icons.refresh),
                        onTap: () => _riavviaDieta(context, appState, p.nome),
                      ),
                    )),

              const Divider(height: 48),

              // === AVANZATE (ExpansionTile) ===
              Card(
                clipBehavior: Clip.antiAlias,
                child: ExpansionTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.settings, color: Colors.white),
                  ),
                  title: const Text(
                    'Avanzate',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    settings.hasApiKey ? 'API Key configurata' : 'API Key non configurata',
                    style: TextStyle(
                      color: settings.hasApiKey ? Colors.green : Colors.orange,
                      fontSize: 12,
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // API Key
                          const Text(
                            'API Key Google Gemini',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _apiKeyController,
                            obscureText: _obscureApiKey,
                            decoration: InputDecoration(
                              hintText: 'Inserisci la tua API Key',
                              border: const OutlineInputBorder(),
                              suffixIcon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(_obscureApiKey
                                        ? Icons.visibility
                                        : Icons.visibility_off),
                                    onPressed: () {
                                      setState(() {
                                        _obscureApiKey = !_obscureApiKey;
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.save),
                                    onPressed: () => _salvaApiKey(context, settings),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Ottieni la tua API Key da Google AI Studio (aistudio.google.com)',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                          ),

                          const SizedBox(height: 24),

                          // Modello
                          const Text(
                            'Modello AI',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<GeminiModel>(
                            value: settings.geminiModel,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            items: GeminiModel.values.map((model) {
                              return DropdownMenuItem(
                                value: model,
                                child: Text(model.displayName),
                              );
                            }).toList(),
                            onChanged: (model) async {
                              if (model != null) {
                                await settings.setGeminiModel(model);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Modello cambiato: ${model.displayName}')),
                                  );
                                }
                              }
                            },
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Modello attuale: ${settings.geminiModel.modelId}',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Padding extra in fondo per assicurare lo scroll
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
    );
  }

  Widget _buildTimeSetting(
      BuildContext context, SettingsProvider settings, TipoPasto tipo) {
    final time = settings.getOrario(tipo);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Text(
            tipo.tipoEmoji,
            style: const TextStyle(fontSize: 20),
          ),
        ),
        title: Text(tipo.label),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(
            time.format(context),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        onTap: () async {
          final newTime = await showTimePicker(
            context: context,
            initialTime: time,
          );
          if (newTime != null) {
            settings.setOrario(tipo, newTime);
          }
        },
      ),
    );
  }

  Future<void> _esportaDati(BuildContext context, AppState appState) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const Center(child: CircularProgressIndicator()),
      );

      final file = await appState.exportBackup();

      if (context.mounted) Navigator.pop(context);

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/json')],
        text: 'Ecco il backup di DietaInsieme! Tocca il file per importarlo.',
      );
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true)
            .popUntil((route) => route.settings.name != null);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore esportazione: $e')),
        );
      }
    }
  }

  Future<void> _importaDati(BuildContext context, AppState appState) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final path = result.files.single.path!;

        if (!context.mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => const Center(child: CircularProgressIndicator()),
        );

        await appState.importBackup(File(path));

        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Importazione completata con successo!')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true)
            .popUntil((route) => route.settings.name != null);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore importazione: $e')),
        );
      }
    }
  }

  void _riavviaDieta(BuildContext context, AppState appState, String nome) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Riavviare dieta per $nome?'),
        content: const Text(
          'Questo imposterà oggi come il nuovo Giorno 1 della dieta. Vuoi procedere?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () async {
              await appState.riavviaDieta(nome);
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Dieta di $nome riavviata!')),
                );
              }
            },
            child: const Text('Riavvia'),
          ),
        ],
      ),
    );
  }

  Future<void> _salvaApiKey(BuildContext context, SettingsProvider settings) async {
    final newKey = _apiKeyController.text.trim();
    if (newKey.isNotEmpty) {
      await settings.setApiKey(newKey);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('API Key salvata!')),
        );
      }
    }
  }
}
