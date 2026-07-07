import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:scout_os_app/core/network/api_service.dart';
import 'package:scout_os_app/features/ai/data/repositories/ai_repository.dart';
import 'package:scout_os_app/features/ai/data/models/chat_response.dart';

class CipherChatPage extends StatefulWidget {
  const CipherChatPage({super.key});

  @override
  State<CipherChatPage> createState() => _CipherChatPageState();
}

class _CipherChatPageState extends State<CipherChatPage> {
  late final AiRepository _aiRepository;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  
  bool _isLoading = false;
  int _tokensRemaining = 3; // Default until first call or fetch
  String _cipherMood = 'encouraging';

  @override
  void initState() {
    super.initState();
    _aiRepository = AiRepository(context.read<ApiService>());
    
    // Initial welcome message
    _messages.add({
      'role': 'cipher',
      'text': 'Salam Pramuka! Aku Cipher, asisten AI pelindung siber. Ada sandi atau rahasia yang ingin kamu pecahkan hari ini?',
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _tokensRemaining == 0) return;

    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _isLoading = true;
      _messageController.clear();
    });
    
    _scrollToBottom();

    try {
      final response = await _aiRepository.sendMessage(text);
      
      setState(() {
        _messages.add({'role': 'cipher', 'text': response.response});
        _tokensRemaining = response.tokensRemaining;
        _cipherMood = response.cipherMood;
        _isLoading = false;
      });

      if (_cipherMood == 'warning') {
        _showToast('Token hampir habis!', Colors.orange);
      } else if (_cipherMood == 'strict') {
        _showToast('Token habis! Upgrade ke Pro 🔐', Colors.red);
      }
      
    } catch (e) {
      setState(() {
        _isLoading = false;
        // Check if error is token exhausted
        if (e.toString().contains('TOKEN_EXHAUSTED')) {
          _tokensRemaining = 0;
          _cipherMood = 'strict';
          _showToast('Token habis! Upgrade ke Pro 🔐', Colors.red);
        } else {
          _messages.add({'role': 'cipher', 'text': 'Maaf, jaringan siber sedang terganggu. Coba lagi nanti!'});
        }
      });
    }
    
    _scrollToBottom();
  }

  void _showToast(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Color _getMoodColor() {
    if (_cipherMood == 'strict' || _tokensRemaining <= 1) return Colors.red;
    if (_cipherMood == 'warning' || _tokensRemaining <= 4) return Colors.orange;
    return const Color(0xFF00FF41); // Matrix green
  }

  @override
  Widget build(BuildContext context) {
    final moodColor = _getMoodColor();

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19), // Dark cyber background
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0F19),
        elevation: 1,
        shadowColor: moodColor.withValues(alpha: 0.5),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: moodColor, width: 2),
              ),
              child: const CircleAvatar(
                radius: 16,
                backgroundColor: Colors.black,
                child: Icon(Icons.memory, color: Color(0xFF00FF41), size: 20),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CIPHER AI',
                  style: GoogleFonts.orbitron(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (_isLoading)
                  Text(
                    'Mengetik...',
                    style: GoogleFonts.orbitron(
                      color: const Color(0xFF00FF41),
                      fontSize: 10,
                    ),
                  ),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: moodColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: moodColor, width: 1),
            ),
            child: Row(
              children: [
                Icon(Icons.battery_charging_full, color: moodColor, size: 14),
                const SizedBox(width: 4),
                Text(
                  '$_tokensRemaining token',
                  style: TextStyle(
                    color: moodColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isLoading) {
                  return _buildLoadingBubble();
                }
                
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                return _buildChatBubble(msg['text'], isUser);
              },
            ),
          ),
          _buildInputField(),
        ],
      ),
    );
  }

  Widget _buildChatBubble(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF1E293B) : const Color(0xFF052e16),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          border: Border.all(
            color: isUser ? Colors.transparent : const Color(0xFF00FF41).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isUser ? Colors.white : const Color(0xFFe2e8f0),
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF052e16),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(16),
          ),
          border: Border.all(color: const Color(0xFF00FF41).withValues(alpha: 0.3), width: 1),
        ),
        child: const Text('...', style: TextStyle(color: Color(0xFF00FF41), fontSize: 16, letterSpacing: 2)),
      ),
    );
  }

  Widget _buildInputField() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        border: Border(top: BorderSide(color: Color(0xFF1E293B), width: 1)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                maxLength: 500,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Tanya Cipher tentang sandi & siber...',
                  hintStyle: const TextStyle(color: Colors.white38),
                  counterText: '',
                  filled: true,
                  fillColor: const Color(0xFF1E293B),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: (_messageController.text.trim().isNotEmpty && _tokensRemaining > 0 && !_isLoading)
                  ? _sendMessage
                  : null,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (_messageController.text.trim().isNotEmpty && _tokensRemaining > 0 && !_isLoading)
                      ? const Color(0xFF00FF41)
                      : Colors.grey.shade800,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.send,
                  color: (_messageController.text.trim().isNotEmpty && _tokensRemaining > 0 && !_isLoading)
                      ? Colors.black
                      : Colors.grey.shade600,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
