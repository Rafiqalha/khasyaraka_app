class ChatResponse {
  final String response;
  final int tokensRemaining;
  final String cipherMood;

  ChatResponse({
    required this.response,
    required this.tokensRemaining,
    required this.cipherMood,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      response: json['response'] ?? '',
      tokensRemaining: json['tokens_remaining'] ?? 0,
      cipherMood: json['cipher_mood'] ?? 'strict',
    );
  }
}
