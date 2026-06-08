enum MessageSender { user, ai }

class AiMessage {
  final String text;
  final MessageSender sender;
  final DateTime timestamp;

  AiMessage({
    required this.text,
    required this.sender,
    required this.timestamp,
  });
}
