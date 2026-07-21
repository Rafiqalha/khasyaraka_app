import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scout_os_app/features/arena/logic/arena_controller.dart';
import 'package:scout_os_app/features/arena/presentation/pages/arena_results_page.dart';
import 'package:scout_os_app/core/widgets/duo_button.dart';
import 'package:google_fonts/google_fonts.dart';

class ArenaGameplayPage extends StatefulWidget {
  const ArenaGameplayPage({super.key});

  @override
  State<ArenaGameplayPage> createState() => _ArenaGameplayPageState();
}

class _ArenaGameplayPageState extends State<ArenaGameplayPage> {
  final TextEditingController _answerController = TextEditingController();

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ArenaController>();
    final state = controller.currentState;

    if (state == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (state.status == 'finished') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ChangeNotifierProvider.value(
              value: controller,
              child: const ArenaResultsPage(),
            ),
          ),
        );
      });
    }

    final q = state.question;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('SOAL ${q?.index ?? 0} / ${q?.total ?? 10}', style: GoogleFonts.fredoka(color: const Color(0xFF1CB0F6), fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9600).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFF9600), width: 2),
                ),
                child: Text(
                  '⏱️ ${q?.timeRemainingSecs ?? 0}s',
                  style: GoogleFonts.fredoka(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFFFF9600)),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          // Leaderboard Sidebar
          Container(
            width: 120,
            decoration: const BoxDecoration(
              color: Color(0xFFF7F7F7),
              border: Border(right: BorderSide(color: Color(0xFFE5E5E5), width: 2)),
            ),
            child: ListView.builder(
              itemCount: state.leaderboard.length,
              itemBuilder: (context, index) {
                final team = state.leaderboard[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  title: Text(team.teamName, style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text('${team.score} pts', style: GoogleFonts.nunito(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                  leading: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: index == 0 ? const Color(0xFFFF9600) : Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text('${index + 1}', style: GoogleFonts.fredoka(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                );
              },
            ),
          ),
          // Question Area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (q != null) ...[
                    Container(
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFE5E5E5), width: 2),
                      ),
                      child: Text(
                        q.text,
                        style: GoogleFonts.fredoka(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (state.alreadyAnswered)
                      Center(
                        child: Text(
                          '✅ Menunggu soal berikutnya...',
                          style: GoogleFonts.nunito(fontSize: 18, color: const Color(0xFF58CC02), fontWeight: FontWeight.bold),
                        ),
                      )
                    else ...[
                      TextField(
                        controller: _answerController,
                        style: GoogleFonts.nunito(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
                        decoration: InputDecoration(
                          labelText: 'Jawaban Anda',
                          labelStyle: GoogleFonts.nunito(color: Colors.grey.shade500, fontWeight: FontWeight.bold),
                          filled: true,
                          fillColor: const Color(0xFFF7F7F7),
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
                      const SizedBox(height: 16),
                      DuoButton(
                        text: 'KIRIM JAWABAN',
                        onPressed: () {
                          controller.submitAnswer(_answerController.text);
                          _answerController.clear();
                        },
                        variant: DuoButtonVariant.green,
                      ),
                    ]
                  ]
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
