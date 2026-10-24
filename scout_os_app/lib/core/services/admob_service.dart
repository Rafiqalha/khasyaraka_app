import 'package:flutter/foundation.dart';

/// Reward item representation for simulated or granted rewards
class RewardItem {
  final num amount;
  final String type;
  const RewardItem(this.amount, this.type);
}

/// Pradigi OS AdMobService Stub.
/// 
/// In Pradigi AI OS, commercial third-party ads are eliminated to maintain a
/// calm, focused, and distraction-free learning operating system environment.
class AdMobService {
  static final AdMobService _instance = AdMobService._internal();
  factory AdMobService() => _instance;
  AdMobService._internal();

  Future<void> initialize() async {
    debugPrint('ℹ️ [Pradigi OS] Commercial ads are disabled in AI OS mode.');
  }

  void showRewardedAd({
    required Function(RewardItem) onUserEarnedReward,
    VoidCallback? onAdDismissed,
    VoidCallback? onAdFailed,
  }) {
    debugPrint('🎁 [Pradigi OS] Reward granted automatically without commercial ad interruption.');
    onUserEarnedReward(const RewardItem(1, 'hearts'));
    onAdDismissed?.call();
  }
}
