import 'package:flutter/material.dart';
import '../screens/ai_assistant_screen.dart';

class AIAssistantFAB extends StatelessWidget {
  const AIAssistantFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'ai_fab_${UniqueKey()}',
      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AiAssistantScreen())),
      backgroundColor: Colors.indigo,
      child: const Icon(Icons.smart_toy, color: Colors.white),
    );
  }
}
