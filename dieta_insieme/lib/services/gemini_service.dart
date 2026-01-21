import 'dart:convert';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../utils/prompts.dart';

class GeminiService {
  // API Key should be set via environment variable or secure storage
  // Set your API key in: android/app/src/main/AndroidManifest.xml as meta-data
  // Or use --dart-define=GEMINI_API_KEY=your_key when building
  static const _apiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: ''); 
  
  late GenerativeModel _model;
  
  GeminiService() {
    if (_apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY not set. Use --dart-define=GEMINI_API_KEY=your_key');
    }
    _model = GenerativeModel(
      // Aggiornato al modello Gemini 3 Flash (Preview) per test
      model: 'gemini-3-flash-preview', 
      apiKey: _apiKey,
    );
  }

  // Method to allow setting API key dynamically if needed (e.g. from user input)
  void setApiKey(String apiKey) {
    _model = GenerativeModel(
      model: 'gemini-3-flash-preview', 
      apiKey: apiKey,
    );
  }

  Future<Map<String, dynamic>> parseDietaPdf(Uint8List pdfBytes) async {
    final prompt = dietaParsingPrompt;
    
    final content = [
      Content.multi([
        TextPart(prompt),
        DataPart('application/pdf', pdfBytes),
      ])
    ];

    final response = await _model.generateContent(content);
    final jsonString = response.text ?? '';
    
    // Pulisci eventuale markdown
    final cleanJson = jsonString
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();
    
    return jsonDecode(cleanJson) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> parseBodygramPdf(Uint8List pdfBytes) async {
    final prompt = bodygramParsingPrompt;
    
    final content = [
      Content.multi([
        TextPart(prompt),
        DataPart('application/pdf', pdfBytes),
      ])
    ];

    final response = await _model.generateContent(content);
    final jsonString = response.text ?? '';
    
    final cleanJson = jsonString
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();
    
    return jsonDecode(cleanJson) as Map<String, dynamic>;
  }
  
  Future<GenerateContentResponse> chat(List<Content> history) async {
    final chat = _model.startChat(history: history.sublist(0, history.length - 1));
    return chat.sendMessage(history.last);
  }

  Future<String> simpleChat(String fullPrompt) async {
    final content = [Content.text(fullPrompt)];
    final response = await _model.generateContent(content);
    return response.text ?? 'Nessuna risposta generata.';
  }

  Future<String> chatWithImage(String prompt, Uint8List imageBytes) async {
    final content = [
      Content.multi([
        TextPart(prompt),
        DataPart('image/jpeg', imageBytes), // Assume JPEG for now, or detect mime type
      ])
    ];
    final response = await _model.generateContent(content);
    return response.text ?? 'Nessuna risposta generata per l\'immagine.';
  }
}
