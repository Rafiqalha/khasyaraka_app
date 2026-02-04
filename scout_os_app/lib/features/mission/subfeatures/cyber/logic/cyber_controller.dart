import 'package:flutter/material.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/data/sandi_model.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/data/sandi_repository.dart';

/// Cyber Controller - Tools Only (NO EXAM/QUESTIONS)
/// 
/// 100% OFFLINE - All processing client-side
class CyberController extends ChangeNotifier {
  CyberController({SandiRepository? repository})
      : _repository = repository ?? SandiRepository();

  final SandiRepository _repository;

  // Dashboard State
  List<SandiModel> sandiList = [];
  bool isLoading = false;
  String? errorMessage;

  // Tool Page State
  SandiModel? selectedSandi;
  String inputText = '';
  bool isEncryptMode = true; // true = ENCRYPT, false = DECRYPT
  String? result;
  bool isProcessing = false;

  /// Load all Sandi types (hardcoded, offline)
  void loadSandiList() {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      sandiList = _repository.getAllSandi();
      if (sandiList.isEmpty) {
        errorMessage = 'No Sandi types available';
      }
    } catch (e) {
      errorMessage = 'Failed to load Sandi types: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Select a Sandi for tool page
  void selectSandi(SandiModel sandi) {
    selectedSandi = sandi;
    inputText = '';
    result = null;
    isEncryptMode = true;
    notifyListeners();
  }

  /// Update input text
  void updateInputText(String text) {
    inputText = text;
    notifyListeners();
  }

  /// Toggle encrypt/decrypt mode
  void toggleOperationMode() {
    isEncryptMode = !isEncryptMode;
    result = null; // Clear result when switching mode
    notifyListeners();
  }

  /// Process cipher (encrypt or decrypt)
  void processCipher() {
    if (selectedSandi == null || inputText.isEmpty) {
      return;
    }

    isProcessing = true;
    notifyListeners();

    try {
      result = _repository.processCipher(
        text: inputText,
        codename: selectedSandi!.codename,
        isEncrypt: isEncryptMode,
      );
    } catch (e) {
      result = '[Error] Processing failed: $e';
    } finally {
      isProcessing = false;
      notifyListeners();
    }
  }

  /// Clear input and result
  void clear() {
    inputText = '';
    result = null;
    notifyListeners();
  }

  /// Copy result to clipboard (helper method for UI)
  Future<void> copyResult(BuildContext context) async {
    if (result == null || result!.isEmpty) return;

    // This will be handled by UI layer
    // Just notify that copy action should happen
    notifyListeners();
  }

  /// Reset tool page
  void resetToolPage() {
    selectedSandi = null;
    inputText = '';
    result = null;
    isEncryptMode = true;
    isProcessing = false;
    notifyListeners();
  }
}
