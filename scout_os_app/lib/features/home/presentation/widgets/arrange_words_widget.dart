import 'package:flutter/material.dart';
import 'package:scout_os_app/core/constants/app_colors.dart';

class ArrangeWordsWidget extends StatefulWidget {
  final List<String> words;
  final Function(String) onAnswerChanged; // Mengirim String kalimat jadi

  const ArrangeWordsWidget({
    super.key, 
    required this.words, 
    required this.onAnswerChanged
  });

  @override
  State<ArrangeWordsWidget> createState() => _ArrangeWordsWidgetState();
}

class _ArrangeWordsWidgetState extends State<ArrangeWordsWidget> {
  late List<String> availableWords;
  List<String> selectedWords = [];

  @override
  void initState() {
    super.initState();
    // Copy list agar tidak merubah aslinya & acak
    availableWords = List.from(widget.words);
    availableWords.shuffle(); 
  }

  void _updateParent() {
    // Gabungkan list kata menjadi satu kalimat string dengan spasi
    String sentence = selectedWords.join(" ");
    widget.onAnswerChanged(sentence);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // KOTAK JAWABAN (ATAS)
        Container(
          constraints: const BoxConstraints(minHeight: 120),
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          decoration: BoxDecoration(
            // UBAH: Pakai scoutWhite, bukan Colors.white
            color: AppColors.scoutWhite, 
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300, width: 2),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: selectedWords.map((word) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedWords.remove(word);
                    availableWords.add(word);
                    _updateParent();
                  });
                },
                child: Chip(
                  label: Text(
                    word, 
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.scoutBrown, // Teks coklat
                    )
                  ),
                  backgroundColor: AppColors.scoutWhite,
                  side: BorderSide(color: AppColors.forestGreen),
                  elevation: 2,
                ),
              );
            }).toList(),
          ),
        ),
        
        const SizedBox(height: 24),
        const Center(
          child: Text(
            "Ketuk kata di bawah untuk menyusun:", 
            style: TextStyle(color: AppColors.textGrey)
          )
        ),
        const SizedBox(height: 12),

        // BANK KATA (BAWAH)
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: availableWords.map((word) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  availableWords.remove(word);
                  selectedWords.add(word);
                  _updateParent();
                });
              },
              child: Chip(
                label: Text(
                  word,
                  style: const TextStyle(color: AppColors.textDark),
                ),
                // PERBAIKAN UTAMA: Ganti paperWhite jadi scoutWhite
                backgroundColor: AppColors.scoutWhite, 
                side: BorderSide(color: Colors.grey.shade400),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}