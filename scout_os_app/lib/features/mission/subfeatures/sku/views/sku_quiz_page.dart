import 'package:scout_os_app/core/widgets/grass_sos_loader.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scout_os_app/features/mission/subfeatures/sku/controllers/sku_controller.dart';
import 'package:scout_os_app/features/mission/subfeatures/sku/models/sku_model.dart';
import 'package:scout_os_app/core/widgets/duo_button.dart';
import 'package:google_fonts/google_fonts.dart';

class SkuQuizPage extends StatefulWidget {
  const SkuQuizPage({super.key, required this.pointId});

  final String pointId;

  @override
  State<SkuQuizPage> createState() => _SkuQuizPageState();
}

class _SkuQuizPageState extends State<SkuQuizPage> {
  int _currentIndex = 0;
  final Map<int, int> _answers = {};
  bool _showBriefing = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<SkuController>().loadPointDetail(widget.pointId);
      if (mounted) {
        setState(() {
          _showBriefing = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SkuController>();
    final point = controller.selectedPoint;

    if (controller.isLoading || point == null) {
      return const Scaffold(body: Center(child: GrassSosLoader()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          point.title,
          style: GoogleFonts.fredoka(color: const Color(0xFF1CB0F6), fontWeight: FontWeight.bold),
        ),
      ),
      body: _showBriefing ? _buildBriefing(point) : _buildQuiz(point),
    );
  }

  Widget _buildBriefing(SkuPointDetailModel point) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Briefing Materi',
            style: GoogleFonts.fredoka(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            point.description,
            style: GoogleFonts.nunito(color: Colors.grey.shade700, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          DuoButton(
            text: 'MULAI QUIZ',
            onPressed: () {
              setState(() {
                _showBriefing = false;
              });
            },
            variant: DuoButtonVariant.green,
          ),
        ],
      ),
    );
  }

  Widget _buildQuiz(SkuPointDetailModel point) {
    final question = point.questions[_currentIndex];
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pertanyaan ${_currentIndex + 1} / ${point.questions.length}',
            style: GoogleFonts.nunito(color: Colors.grey.shade500, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Text(
            question.question,
            style: GoogleFonts.fredoka(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          for (int i = 0; i < question.options.length; i++)
            _buildOptionTile(i, question.options[i]),
          const Spacer(),
          Row(
            children: [
              if (_currentIndex > 0)
                TextButton(
                  onPressed: () => setState(() => _currentIndex -= 1),
                  child: Text('KEMBALI', style: GoogleFonts.nunito(color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
                ),
              const Spacer(),
              SizedBox(
                width: 150,
                child: DuoButton(
                  text: _currentIndex < point.questions.length - 1 ? 'LANJUT' : 'KIRIM',
                  onPressed: () {
                    if (_currentIndex < point.questions.length - 1) {
                      setState(() => _currentIndex += 1);
                      return;
                    }
                    _submit(point);
                  },
                  variant: DuoButtonVariant.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(int index, String text) {
    final selected = _answers[_currentIndex] == index;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => setState(() => _answers[_currentIndex] = index),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF1CB0F6).withValues(alpha: 0.1) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? const Color(0xFF1CB0F6) : const Color(0xFFE5E5E5),
              width: selected ? 2 : 2,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: selected ? const Color(0xFF1CB0F6) : Colors.grey.shade400,
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(text, style: GoogleFonts.nunito(color: selected ? const Color(0xFF1CB0F6) : Colors.black87, fontWeight: selected ? FontWeight.bold : FontWeight.w600, fontSize: 16))),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit(SkuPointDetailModel point) async {
    final answers = List<int>.generate(
      point.questions.length,
      (index) => _answers[index] ?? -1,
    );

    final result = await context.read<SkuController>().submitAnswers(
      pointId: point.id,
      answers: answers,
    );

    if (!mounted || result == null) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Color(0xFFE5E5E5), width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          result.isCompleted ? 'LULUS!' : 'BELUM LULUS',
          style: GoogleFonts.fredoka(color: result.isCompleted ? const Color(0xFF58CC02) : const Color(0xFFFF4B4B), fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Skor Anda: ${result.score}%',
          style: GoogleFonts.nunito(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('KEMBALI', style: GoogleFonts.nunito(color: const Color(0xFF1CB0F6), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
