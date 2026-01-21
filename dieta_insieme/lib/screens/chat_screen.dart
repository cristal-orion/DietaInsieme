import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../providers/app_state.dart';
import '../widgets/chat_message_bubble.dart';
import '../widgets/assistente_input_bar.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateContext();
      _scrollToBottom();
    });
  }

  void _updateContext() {
    final appState = Provider.of<AppState>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.updatePersone(appState.persone);
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assistente Personale'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Cancella cronologia',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Cancellare la chat?'),
                  content: const Text('Questa azione cancellerà tutta la cronologia della conversazione.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Annulla'),
                    ),
                    TextButton(
                      onPressed: () {
                        Provider.of<ChatProvider>(context, listen: false).clearHistory();
                        Navigator.pop(context);
                      },
                      child: const Text('Cancella', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          // Auto-scroll when new messages arrive
          if (chatProvider.messages.isNotEmpty) {
             WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
          }

          return Column(
            children: [
              Expanded(
                child: chatProvider.messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            const Text(
                              'Ciao! Sono il tuo assistente.\nChiedimi consigli sulla dieta o inviami foto di alimenti.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: chatProvider.messages.length,
                        itemBuilder: (context, index) {
                          return ChatMessageBubble(message: chatProvider.messages[index]);
                        },
                      ),
              ),
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
                  isLoading: chatProvider.isLoading,
                  onInvia: (text, imageBytes) {
                    chatProvider.inviaMessaggio(text, imageBytes);
                  },
                  onRicetta: () {
                    chatProvider.inviaMessaggio("Suggeriscimi una ricetta bilanciata basata sulle nostre diete.");
                  },
                  onAlternative: () {
                    chatProvider.inviaMessaggio("Quali sono delle buone alternative per uno spuntino sano?");
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
