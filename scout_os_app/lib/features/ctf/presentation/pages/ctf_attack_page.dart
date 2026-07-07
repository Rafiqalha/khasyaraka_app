import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scout_os_app/features/ctf/data/repositories/ctf_repository.dart';
import 'package:scout_os_app/features/ctf/data/models/ctf_models.dart';
import 'package:scout_os_app/features/ctf/presentation/pages/ctf_patching_page.dart';
import 'package:scout_os_app/features/ctf/presentation/pages/ctf_results_page.dart';
import 'package:scout_os_app/features/ai/data/models/chat_response.dart';
import 'package:scout_os_app/core/widgets/duo_button.dart';

class CtfAttackPage extends StatefulWidget {
  final int roomId;
  final int myTeamId;

  const CtfAttackPage({
    super.key,
    required this.roomId,
    required this.myTeamId,
  });

  @override
  State<CtfAttackPage> createState() => _CtfAttackPageState();
}

class _CtfAttackPageState extends State<CtfAttackPage> with SingleTickerProviderStateMixin {
  final CTFRepository _repo = CTFRepository();
  bool _isLoading = true;
  CTFStateResponse? _state;
  Timer? _pollingTimer;

  late TabController _tabController;
  final TextEditingController _chatController = TextEditingController();
  final TextEditingController _flagController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, String>> _chatHistory = [];
  bool _isAiTyping = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _tabController.dispose();
    _chatController.dispose();
    _flagController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _startPolling() {
    _pollState();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _pollState();
    });
  }

  Future<void> _pollState() async {
    try {
      final state = await _repo.getState(widget.roomId, widget.myTeamId);
      if (mounted) {
        setState(() {
          _state = state;
          _isLoading = false;
        });

        // Initialize chat history from recent logs if empty
        if (_chatHistory.isEmpty && state.recentLogs.isNotEmpty) {
          _chatHistory = state.recentLogs.map((log) => {
            'role': 'user', 'text': log.prompt,
            'response': log.aiResponse
          }).toList();
        }

        // Navigation conditions based on phase
        if (state.room.phase == 'patching' && state.patchChallenge != null) {
          _pollingTimer?.cancel();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => CtfPatchingPage(
                roomId: widget.roomId,
                myTeamId: widget.myTeamId,
              ),
            ),
          );
        } else if (state.room.phase == 'finished') {
          _pollingTimer?.cancel();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => CtfResultsPage(
                roomId: widget.roomId,
                myTeamId: widget.myTeamId,
              ),
            ),
          );
        }
      }
    } catch (e) {
      // Ignored
    }
  }

  Future<void> _sendPrompt() async {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _chatHistory.add({'role': 'user', 'text': text});
      _isAiTyping = true;
      _chatController.clear();
    });
    _scrollToBottom();

    try {
      final resp = await _repo.attackWithAI(widget.roomId, widget.myTeamId, text);
      setState(() {
        _chatHistory.add({'role': 'ai', 'text': resp.response});
        _isAiTyping = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _chatHistory.add({'role': 'ai', 'text': 'Error: ${e.toString()}'});
        _isAiTyping = false;
      });
      _scrollToBottom();
    }
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

  Future<void> _submitFlag() async {
    final text = _flagController.text.trim();
    if (text.isEmpty) return;
    
    // Add simple validate before API
    if (!text.startsWith("FLAG{PRADIGI_") || !text.endsWith("}")) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Format salah! Harus FLAG{PRADIGI_XXXXXX}')),
      );
      return;
    }

    try {
      final res = await _repo.submitFlag(widget.roomId, widget.myTeamId, text);
      if (res['correct'] == true) {
        // Force poll to get patching state immediately
        _pollState();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Flag salah! Coba lagi 🔍', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _state == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: Color(0xFFFF4B4B))),
      );
    }

    final timeLeft = _state!.phaseTimeLeft;
    final mins = timeLeft ~/ 60;
    final secs = timeLeft % 60;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          'ATTACK PHASE',
          style: GoogleFonts.fredoka(color: const Color(0xFFFF4B4B), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFFF4B4B),
          labelColor: const Color(0xFFFF4B4B),
          unselectedLabelColor: Colors.grey,
          labelStyle: GoogleFonts.fredoka(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'TANYA CIPHER', icon: Icon(Icons.smart_toy)),
            Tab(text: 'SUBMIT FLAG', icon: Icon(Icons.flag)),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xFFFF4B4B).withValues(alpha: 0.1),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.timer, color: Color(0xFFFF4B4B), size: 20),
                const SizedBox(width: 8),
                Text(
                  '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}',
                  style: GoogleFonts.fredoka(
                    color: const Color(0xFFFF4B4B),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAiChatTab(),
                _buildSubmitFlagTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiChatTab() {
    return Column(
      children: [
        // Target display
        if (_state!.opponentTeam.defenseImageUrl.isNotEmpty)
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE5E5E5), width: 2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(_state!.opponentTeam.defenseImageUrl, width: 60, height: 60, fit: BoxFit.cover),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('TARGET DITEMUKAN', style: GoogleFonts.fredoka(color: const Color(0xFFFF4B4B), fontSize: 14, fontWeight: FontWeight.bold)),
                      Text('Gunakan petunjuk budaya ini dan tanyakan pada Cipher', style: GoogleFonts.nunito(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _chatHistory.length + (_isAiTyping ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _chatHistory.length) {
                return const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Cipher sedang mengetik...', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                  ),
                );
              }
              final msg = _chatHistory[index];
              if (msg['response'] != null) {
                return Column(
                  children: [
                    _buildChatBubble(msg['text']!, true),
                    _buildChatBubble(msg['response']!, false),
                  ],
                );
              }
              return _buildChatBubble(msg['text']!, msg['role'] == 'user');
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _chatController,
                  style: GoogleFonts.nunito(color: Colors.black87, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    hintText: 'Minta hint dari Cipher... (1 Token)',
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFFF7F7F7),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Color(0xFFE5E5E5), width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Color(0xFFE5E5E5), width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Color(0xFFFF4B4B), width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: const Color(0xFFFF4B4B),
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: _isAiTyping ? null : _sendPrompt,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChatBubble(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFFFF4B4B).withValues(alpha: 0.1) : Colors.white,
          border: Border.all(color: isUser ? const Color(0xFFFF4B4B) : const Color(0xFFE5E5E5), width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(text, style: GoogleFonts.nunito(color: Colors.black87, fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _buildSubmitFlagTab() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.flag, size: 80, color: Color(0xFFFF4B4B)),
          const SizedBox(height: 24),
          Text(
            'MASUKKAN FLAG LAWAN',
            style: GoogleFonts.fredoka(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            'Jika flag benar, alarm musuh akan menyala!',
            style: GoogleFonts.nunito(color: Colors.black54, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _flagController,
            style: const TextStyle(color: Colors.black87, fontSize: 18, fontFamily: 'Courier', fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF7F7F7),
              hintText: 'FLAG{PRADIGI_XXXXXX}',
              hintStyle: const TextStyle(color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFE5E5E5), width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFE5E5E5), width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFFF4B4B), width: 2),
              ),
            ),
          ),
          const SizedBox(height: 32),
          DuoButton(
            text: 'SUBMIT FLAG ⚑',
            onPressed: _submitFlag,
            variant: DuoButtonVariant.red,
          ),
        ],
      ),
    );
  }
}
