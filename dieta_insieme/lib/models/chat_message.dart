import 'dart:convert';
import 'dart:typed_data';

class ChatMessage {
  String testo;
  final bool isUser;
  final DateTime timestamp;
  final Uint8List? imageBytes;

  ChatMessage({
    required this.testo,
    required this.isUser,
    DateTime? timestamp,
    this.imageBytes,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'testo': testo,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'imageBytes': imageBytes != null ? base64Encode(imageBytes!) : null,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      testo: json['testo'] as String,
      isUser: json['isUser'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
      imageBytes: json['imageBytes'] != null 
          ? base64Decode(json['imageBytes'] as String) 
          : null,
    );
  }
}
