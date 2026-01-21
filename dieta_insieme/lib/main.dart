import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:io';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'theme/app_theme.dart';
import 'providers/app_state.dart';
import 'providers/pasto_oggi_provider.dart';
import 'services/giorno_dieta_service.dart';
import 'services/pasto_analisi_service.dart';
import 'services/pasto_assistant_service.dart';
import 'services/gemini_service.dart';
import 'services/storage_service.dart';
import 'providers/settings_provider.dart';
import 'screens/home_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'providers/chat_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('it_IT', null);
  
  final prefs = await SharedPreferences.getInstance();
  
  // Services instantiation
  final giornoDietaService = GiornoDietaService(prefs);
  final pastoAnalisiService = PastoAnalisiService();
  final geminiService = GeminiService();
  final pastoAssistantService = PastoAssistantService(geminiService);
  final storageService = StorageService(); // Note: AppState also uses StorageService internally, consider sharing instance or making singleton
  
  runApp(
    MultiProvider(
      providers: [
        Provider<GiornoDietaService>.value(value: giornoDietaService),
        ChangeNotifierProvider(create: (context) => AppState()),
        ChangeNotifierProvider(create: (context) => SettingsProvider(prefs)),
        ChangeNotifierProvider(create: (context) => ChatProvider(geminiService, giornoDietaService)),
        ChangeNotifierProvider(
          create: (context) => PastoOggiProvider(
            giornoDietaService: giornoDietaService,
            analisiService: pastoAnalisiService,
            assistantService: pastoAssistantService,
            storage: storageService,
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StreamSubscription _intentDataStreamSubscription;

  @override
  void initState() {
    super.initState();
    _initSharingIntent();
  }

  void _initSharingIntent() {
    // Per i file condivisi mentre l'app è in memoria
    _intentDataStreamSubscription = ReceiveSharingIntent.instance.getMediaStream().listen((List<SharedMediaFile> value) {
      if (value.isNotEmpty) {
        _handleSharedFile(value.first.path);
      }
    }, onError: (err) {
      print("getMediaStream error: $err");
    });

    // Per i file condivisi mentre l'app è chiusa
    ReceiveSharingIntent.instance.getInitialMedia().then((List<SharedMediaFile> value) {
      if (value.isNotEmpty) {
        _handleSharedFile(value.first.path);
      }
    });
  }

  Future<void> _handleSharedFile(String path) async {
    print("Tentativo di importazione file da: $path");
    
    // Rimuovi prefix "file://" se presente (bug noto su alcuni Android)
    if (path.startsWith("file://")) {
      path = path.substring(7);
    }

    // Decodifica l'URL se contiene caratteri speciali (come spazi %20)
    try {
      path = Uri.decodeFull(path);
    } catch (e) {
      print("Errore decoding path: $e");
    }
    
    // Piccolo delay per assicurarsi che il context sia pronto se l'app si sta avviando
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (!mounted) return;

    final context = navigatorKey.currentContext;
    if (context == null) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Backup Trovato'),
        content: const Text('Vuoi importare i dati da questo file? \n\nAttenzione: i dati attuali verranno uniti o sovrascritti.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx); // Chiudi dialog conferma
              
              // Mostra loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (ctx) => const Center(child: CircularProgressIndicator()),
              );

              try {
                final appState = Provider.of<AppState>(context, listen: false);
                await appState.importBackup(File(path));
                
                if (context.mounted) {
                  Navigator.pop(context); // Chiudi loading
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Dati importati con successo!')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context); // Chiudi loading
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Errore: $e')),
                  );
                }
              }
            },
            child: const Text('Importa'),
          ),
        ],
      ),
    );
  }
  
  // Chiave globale per accedere al contesto ovunque
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void dispose() {
    _intentDataStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Dieta Insieme',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}

