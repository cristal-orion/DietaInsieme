# DietaInsieme

App Flutter per la gestione di diete personalizzate con assistente AI integrato.

## Funzionalità

- Importazione diete da file PDF tramite AI (Gemini)
- Gestione profili multipli (es. coppia)
- Visualizzazione piano alimentare settimanale
- Chat con assistente nutrizionista AI
- Analisi foto alimenti
- Import/Export configurazione (.dieta)

## Setup

### Prerequisiti

- Flutter SDK >= 3.0
- Dart SDK >= 3.0
- Android Studio / VS Code
- API Key di Google Gemini

### Installazione

1. Clona il repository:
```bash
git clone https://github.com/cristal-orion/DietaInsieme.git
cd DietaInsieme/dieta_insieme
```

2. Installa le dipendenze:
```bash
flutter pub get
```

3. Esegui l'app con la tua API key:
```bash
flutter run --dart-define=GEMINI_API_KEY=la_tua_api_key
```

### Build APK

Per creare un APK di produzione:

```bash
flutter build apk --profile --split-per-abi --dart-define=GEMINI_API_KEY=la_tua_api_key
```

L'APK sarà disponibile in `build/app/outputs/flutter-apk/app-arm64-v8a-profile.apk`

## Known Issues

### Build Release su Android 16 (API 36)

La build `--release` presenta problemi di connettività di rete su dispositivi con Android 16 (API 36). 
Come workaround, utilizzare la build `--profile` che funziona correttamente su tutti i dispositivi.

**Sintomo:** `SocketException: Failed host lookup` quando si tenta di usare la chat AI.

**Dispositivi testati:**
- Nothing Phone A2 (Android 16) - Release ❌ / Profile ✅
- Honor (Android 15) - Release ✅ / Profile ✅

## Struttura Progetto

```
dieta_insieme/
├── lib/
│   ├── main.dart
│   ├── models/          # Modelli dati (Persona, Dieta, Pasto, etc.)
│   ├── providers/       # State management (Provider)
│   ├── screens/         # Schermate UI
│   ├── services/        # Servizi (Gemini AI, Storage)
│   ├── widgets/         # Widget riutilizzabili
│   └── theme/           # Tema e stili
├── android/             # Configurazione Android
└── pubspec.yaml         # Dipendenze
```

## Licenza

Progetto privato.
