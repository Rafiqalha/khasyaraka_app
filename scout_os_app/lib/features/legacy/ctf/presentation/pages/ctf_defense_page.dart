import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scout_os_app/features/ctf/data/repositories/ctf_repository.dart';
import 'package:scout_os_app/features/ctf/data/models/ctf_models.dart';
import 'package:scout_os_app/features/ctf/presentation/pages/ctf_attack_page.dart';
import 'package:scout_os_app/core/widgets/duo_button.dart';

class CtfDefensePage extends StatefulWidget {
  final int roomId;
  final int myTeamId;

  const CtfDefensePage({
    super.key,
    required this.roomId,
    required this.myTeamId,
  });

  @override
  State<CtfDefensePage> createState() => _CtfDefensePageState();
}

class _CtfDefensePageState extends State<CtfDefensePage> {
  final CTFRepository _repo = CTFRepository();
  bool _isLoading = true;
  CTFStateResponse? _state;
  Timer? _pollingTimer;

  String? _selectedImageId;
  String? _selectedMethod;
  final TextEditingController _keyController = TextEditingController();
  bool _isSubmitted = false;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _keyController.dispose();
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

        if (state.room.phase == 'attack') {
          _pollingTimer?.cancel();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => CtfAttackPage(
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

  Future<void> _submitDefense() async {
    if (_selectedImageId == null || _selectedMethod == null || _keyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih gambar, metode, dan isi kunci sandi!')),
      );
      return;
    }

    try {
      await _repo.submitDefense(
        widget.roomId,
        widget.myTeamId,
        _selectedMethod!,
        _keyController.text,
        _selectedImageId!,
      );
      setState(() {
        _isSubmitted = true;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Flag tersembunyi! Siap untuk fase Attack ⚔️')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _state == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(child: CircularProgressIndicator(color: Color(0xFF1CB0F6))),
      );
    }

    final timeLeft = _state!.phaseTimeLeft;
    final mins = timeLeft ~/ 60;
    final secs = timeLeft % 60;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          'DEFENSE PHASE',
          style: GoogleFonts.fredoka(color: const Color(0xFF1CB0F6), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Container(
            color: const Color(0xFF1CB0F6).withValues(alpha: 0.1),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.timer, color: Color(0xFF1CB0F6), size: 20),
                const SizedBox(width: 8),
                Text(
                  '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}',
                  style: GoogleFonts.fredoka(
                    color: const Color(0xFF1CB0F6),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFE5E5E5), width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text('FLAG KAMU', style: GoogleFonts.fredoka(color: const Color(0xFF1CB0F6), fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    _state!.myTeam.flag,
                    style: GoogleFonts.nunito(
                      color: Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'RAHASIA - Jangan perlihatkan ke lawan!',
                    style: GoogleFonts.nunito(color: const Color(0xFFFF4B4B), fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Pilih Gambar Budaya', style: GoogleFonts.fredoka(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: culturalImagePool.length,
                itemBuilder: (context, index) {
                  final img = culturalImagePool[index];
                  final isSelected = _selectedImageId == img.id;
                  return GestureDetector(
                    onTap: _isSubmitted ? null : () => setState(() => _selectedImageId = img.id),
                    child: Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected ? const Color(0xFF1CB0F6) : const Color(0xFFE5E5E5),
                          width: isSelected ? 3 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                              child: Image.network(img.url, fit: BoxFit.cover),
                            ),
                          ),
                          Container(
                            color: isSelected ? const Color(0xFF1CB0F6) : const Color(0xFFF7F7F7),
                            padding: const EdgeInsets.all(6),
                            child: Text(
                              img.name,
                              style: GoogleFonts.nunito(
                                fontSize: 10, 
                                color: isSelected ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Text('Pilih Metode Sandi', style: GoogleFonts.fredoka(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildMethodBtn('caesar', 'Caesar'),
                _buildMethodBtn('vigenere', 'Vigenere'),
                _buildMethodBtn('morse', 'Morse'),
                _buildMethodBtn('kotak', 'Sandi Kotak'),
              ],
            ),
            const SizedBox(height: 24),
            Text('Masukkan Kunci Enkripsi', style: GoogleFonts.fredoka(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            TextField(
              controller: _keyController,
              enabled: !_isSubmitted,
              style: GoogleFonts.nunito(color: Colors.black87, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF7F7F7),
                hintText: _getKeyHint(),
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
                  borderSide: const BorderSide(color: Color(0xFF1CB0F6), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 32),
            DuoButton(
              text: _isSubmitted ? 'MENUNGGU FASE ATTACK...' : 'SEMBUNYIKAN FLAG 🔐',
              onPressed: _isSubmitted ? null : _submitDefense,
              variant: _isSubmitted ? DuoButtonVariant.outline : DuoButtonVariant.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodBtn(String id, String label) {
    final isSelected = _selectedMethod == id;
    return GestureDetector(
      onTap: _isSubmitted ? null : () => setState(() => _selectedMethod = id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1CB0F6).withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? const Color(0xFF1CB0F6) : const Color(0xFFE5E5E5), width: 2),
        ),
        child: Text(
          label,
          style: GoogleFonts.nunito(
            color: isSelected ? const Color(0xFF1CB0F6) : Colors.grey.shade600,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String _getKeyHint() {
    switch (_selectedMethod) {
      case 'caesar': return 'Masukkan shift (1-25)';
      case 'vigenere': return 'Masukkan kata kunci (huruf saja)';
      case 'morse': return 'Kunci otomatis (isi bebas)';
      case 'kotak': return 'Masukkan ukuran grid (3-6)';
      default: return 'Pilih metode sandi dulu';
    }
  }
}
