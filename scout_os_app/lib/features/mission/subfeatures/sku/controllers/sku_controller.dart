import 'package:flutter/material.dart';
import 'package:scout_os_app/features/mission/subfeatures/sku/models/sku_model.dart';
import 'package:scout_os_app/features/mission/subfeatures/sku/services/sku_repository.dart';

class SkuController extends ChangeNotifier {
  SkuController({SkuRepository? repository})
    : _repository = repository ?? SkuRepository();

  final SkuRepository _repository;

  double bantaraProgress = 0;
  bool isLaksanaUnlocked = false;
  bool isLoading = false;
  String? errorMessage;

  List<SkuPointStatusModel> points = [];
  SkuPointDetailModel? selectedPoint;

  Future<void> loadOverview() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final overview = await _repository.fetchOverview();
      bantaraProgress = overview.bantaraProgress;
      isLaksanaUnlocked = overview.isLaksanaUnlocked;
    } catch (e) {
      errorMessage = 'Gagal memuat overview SKU.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPoints(String level) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      points = await _repository.fetchPoints(level);
    } catch (e) {
      errorMessage = 'Gagal memuat poin SKU.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPointDetail(String pointId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      selectedPoint = await _repository.fetchPointDetail(pointId);
    } catch (e) {
      errorMessage = 'Gagal memuat detail SKU.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<SkuSubmitResultModel?> submitAnswers({
    required String pointId,
    required List<int> answers,
  }) async {
    try {
      final result = await _repository.submitAnswers(
        pointId: pointId,
        answers: answers,
      );
      await loadPoints(selectedPoint?.level ?? 'bantara');
      await loadOverview();
      return result;
    } catch (e) {
      errorMessage = 'Gagal submit jawaban.';
      notifyListeners();
      return null;
    }
  }
}
