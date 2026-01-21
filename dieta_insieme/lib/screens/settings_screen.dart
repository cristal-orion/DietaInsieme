import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../providers/settings_provider.dart';
import '../providers/app_state.dart';
import '../models/pasto.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
                      onTap: () async {
                        try {
                          // Mostra dialog di caricamento
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (ctx) => const Center(child: CircularProgressIndicator()),
                          );
                          
                          final file = await appState.exportBackup();
                          
                          // Chiudi dialog
                          if (context.mounted) Navigator.pop(context);
                          
                          await Share.shareXFiles(
                            [XFile(file.path, mimeType: 'application/json')],
                            text: 'Ecco il backup di DietaInsieme! Tocca il file per importarlo.',
                          );
                        } catch (e) {
                          if (context.mounted) {
                            // Chiudi dialog se aperto
                            Navigator.of(context, rootNavigator: true).popUntil((route) => route.settings.name != null);
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Errore esportazione: $e')),
                            );
                          }
                        }
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Icon(Icons.download, color: Colors.white),
                      ),
                      title: const Text('Importa Dati'),
                      subtitle: const Text('Carica un file di backup (.json)'),
                      onTap: () async {
                        try {
                          final result = await FilePicker.platform.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['json'],
                          );

                          if (result != null && result.files.single.path != null) {
                            final path = result.files.single.path!;
                            
                             // Mostra dialog di caricamento
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (ctx) => const Center(child: CircularProgressIndicator()),
                            );

                            await appState.importBackup(File(path));
                            
                            // Chiudi dialog
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Importazione completata con successo!')),
                              );
                            }
                          }
                        } catch (e) {
                          if (context.mounted) {
                            // Chiudi dialog se aperto
                            Navigator.of(context, rootNavigator: true).popUntil((route) => route.settings.name != null);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Errore importazione: $e')),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),

              const Divider(height: 48),

              _buildSectionTitle(context, 'Ciclo Dieta'),
              const SizedBox(height: 16),
              ...appState.persone.map((p) => Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.calendar_month)),
                  title: Text('Riavvia dieta di ${p.nome}'),
                  subtitle: const Text('Imposta oggi come Giorno 1'),
                  trailing: const Icon(Icons.refresh),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text('Riavviare dieta per ${p.nome}?'),
                        content: const Text(
                          'Questo imposterà oggi come il nuovo Giorno 1 della dieta. Vuoi procedere?'
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Annulla'),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              await appState.riavviaDieta(p.nome);
                              if (ctx.mounted) {
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Dieta di ${p.nome} riavviata!')),
                                );
                              }
                            },
                            child: const Text('Riavvia'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              )),
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
}
