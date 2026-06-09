import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ai_assistant_provider.dart';
import '../providers/language_provider.dart';
import '../models/ai_message.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AiAssistantProvider>(context);
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.translate('ai_assistant')),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: provider.messages.length,
              itemBuilder: (context, index) {
                final message = provider.messages[index];
                final isUser = message.sender == MessageSender.user;
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isUser ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      message.text,
                      style: TextStyle(color: isUser ? Colors.white : null),
                    ),
                  ),
                );
              },
            ),
          ),
          if (provider.isTyping)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: LinearProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (v) {
                      if (v.isNotEmpty) {
                        provider.sendMessage(v, lang.currentLanguage);
                        _controller.clear();
                      }
                    },
                    decoration: InputDecoration(
                      hintText: lang.translate('search_dest'),
                      border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(30))),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      provider.sendMessage(_controller.text, lang.currentLanguage);
                      _controller.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.mic),
        onPressed: () {
          // Voice Simulation
          String voiceQuery = "Tell me about transport";
          if (lang.currentLanguage == AppLanguage.amharic) voiceQuery = "ስለ ትራንስፖርት ንገረኝ";
          provider.sendMessage(voiceQuery, lang.currentLanguage);
          ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('Simulated Voice: "$voiceQuery"')),
          );
        },
      ),
    );
  }
}
