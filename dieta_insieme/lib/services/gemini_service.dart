import 'dart:convert';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../utils/prompts.dart';

class GeminiService {
  GenerativeModel? _model;
  String _currentApiKey = '';
  String _currentModelId = 'gemini-2.5-flash';

  GeminiService({String? apiKey, String? modelId}) {
    if (apiKey != null && apiKey.isNotEmpty) {
      _currentApiKey = apiKey;
      _currentModelId = modelId ?? 'gemini-2.0-flash';
      _initModel();
    }
  }

  void _initModel() {
    if (_currentApiKey.isEmpty) {
      _model = null;
      return;
    }
    _model = GenerativeModel(
      model: _currentModelId,
      apiKey: _currentApiKey,
    );
  }

  bool get isConfigured => _model != null && _currentApiKey.isNotEmpty;

  String get currentModelId => _currentModelId;

  /// Aggiorna API key e/o modello
  void updateSettings({String? apiKey, String? modelId}) {
    if (apiKey != null) {
      _currentApiKey = apiKey;
    }
    if (modelId != null) {
      _currentModelId = modelId;
    }
    _initModel();
  }

  void _checkConfigured() {
    if (!isConfigured) {
      throw Exception('Gemini non configurato. Vai in Impostazioni per inserire l\'API Key.');
    }
  }

  Future<Map<String, dynamic>> parseDietaPdf(Uint8List pdfBytes) async {
    _checkConfigured();
    final prompt = dietaParsingPrompt;

    final content = [
      Content.multi([
        TextPart(prompt),
        DataPart('application/pdf', pdfBytes),
      ])
    ];

    final response = await _model!.generateContent(content);
    final jsonString = response.text ?? '';
    
    // Pulisci eventuale markdown
    final cleanJson = jsonString
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();
    
    return jsonDecode(cleanJson) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> parseBodygramPdf(Uint8List pdfBytes) async {
    _checkConfigured();
    final prompt = bodygramParsingPrompt;

    final content = [
      Content.multi([
        TextPart(prompt),
        DataPart('application/pdf', pdfBytes),
      ])
    ];

    final response = await _model!.generateContent(content);
    final jsonString = response.text ?? '';
    
    final cleanJson = jsonString
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();
    
    return jsonDecode(cleanJson) as Map<String, dynamic>;
  }
  
  Future<GenerateContentResponse> chat(List<Content> history) async {
    _checkConfigured();
    final chat = _model!.startChat(history: history.sublist(0, history.length - 1));
    return chat.sendMessage(history.last);
  }

  Future<String> simpleChat(String fullPrompt) async {
    _checkConfigured();
    final content = [Content.text(fullPrompt)];
    final response = await _model!.generateContent(content);
    return response.text ?? 'Nessuna risposta generata.';
  }

  Future<String> chatWithImage(String prompt, Uint8List imageBytes) async {
    _checkConfigured();
    final content = [
      Content.multi([
        TextPart(prompt),
        DataPart('image/jpeg', imageBytes),
      ])
    ];
    final response = await _model!.generateContent(content);
    return response.text ?? 'Nessuna risposta generata per l\'immagine.';
  }
}
