import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService {
  static final AdMobService _instance = AdMobService._internal();
  factory AdMobService() => _instance;
  AdMobService._internal();

  RewardedAd? _rewardedAd;
  bool _isLoading = false;

  // Production Ad Unit ID for Rewarded Ads (Android)
  final String _adUnitId = Platform.isAndroid
      ? 'ca-app-pub-5745748999370612/2195527571'
      : 'ca-app-pub-3940256099942544/1712485313'; // Keep iOS Test ID for now

  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    _loadRewardedAd();
  }

  void _loadRewardedAd() {
    if (_isLoading) return;
    _isLoading = true;

    RewardedAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('🎬 [AdMob] Rewarded Ad loaded');
          _rewardedAd = ad;
          _isLoading = false;
        },
        onAdFailedToLoad: (error) {
          debugPrint('❌ [AdMob] Failed to load Rewarded Ad: ${error.message}');
          _rewardedAd = null;
          _isLoading = false;
          // Retry after delay?
        },
      ),
    );
  }

  void showRewardedAd({
    required Function(RewardItem) onUserEarnedReward,
    VoidCallback? onAdDismissed,
    VoidCallback? onAdFailed,
  }) {
    if (_rewardedAd == null) {
      debugPrint('⚠️ [AdMob] Ad not ready yet. Reloading...');
      _loadRewardedAd();
      onAdFailed?.call();
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) => debugPrint('🎬 [AdMob] Ad showed'),
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('🎬 [AdMob] Ad dismissed');
        ad.dispose();
        _rewardedAd = null;
        _loadRewardedAd(); // Preload next ad
        onAdDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('❌ [AdMob] Ad failed to show: ${error.message}');
        ad.dispose();
        _rewardedAd = null;
        _loadRewardedAd();
        onAdFailed?.call();
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        debugPrint(
          '💰 [AdMob] User earned reward: ${reward.amount} ${reward.type}',
        );
        onUserEarnedReward(reward);
      },
    );
  }
}
