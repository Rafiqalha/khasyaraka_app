import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scout_os_app/features/mission/subfeatures/sku/controllers/sku_controller.dart';
import 'package:scout_os_app/features/mission/subfeatures/sku/models/sku_model.dart';

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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5DC),
        elevation: 0,
        title: Text(point.title, style: const TextStyle(color: Color(0xFF3E2723))),
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
          const Text(
            'Briefing Materi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3E2723),
            ),
          ),
          const SizedBox(height: 12),
          Text(point.description, style: const TextStyle(color: Color(0xFF3E2723))),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD600),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                setState(() {
                  _showBriefing = false;
                });
              },
              child: const Text('MULAI QUIZ'),
            ),
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
            style: const TextStyle(color: Color(0xFF3E2723)),
          ),
          const SizedBox(height: 12),
          Text(
            question.question,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF3E2723),
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
                  child: const Text('Kembali'),
                ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3E2723),
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  if (_currentIndex < point.questions.length - 1) {
                    setState(() => _currentIndex += 1);
                    return;
                  }
                  _submit(point);
                },
                child: Text(_currentIndex < point.questions.length - 1 ? 'Lanjut' : 'Kirim'),
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
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFFFF2B3) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF3E2723).withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: const Color(0xFF3E2723),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(text)),
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
        title: Text(result.isCompleted ? 'Lulus' : 'Belum Lulus'),
        content: Text('Skor Anda: ${result.score}%'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Kembali'),
          ),
        ],
      ),
    );
  }
}
