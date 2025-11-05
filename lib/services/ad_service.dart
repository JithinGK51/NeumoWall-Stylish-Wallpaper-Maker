import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static const String _testBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111'; // Test Ad Unit ID
  static const String _testInterstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712'; // Test Interstitial Ad Unit ID
  
  // Production Ad Unit IDs (replace with your actual AdMob ad unit IDs)
  static const String _productionBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111'; // Replace with your banner ad unit ID
  static const String _productionInterstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712'; // Replace with your interstitial ad unit ID
  
  static bool get isProduction => const bool.fromEnvironment('PRODUCTION', defaultValue: false);
  
  static String get bannerAdUnitId {
    if (isProduction) {
      return _productionBannerAdUnitId;
    }
    return _testBannerAdUnitId;
  }
  
  static String get interstitialAdUnitId {
    if (isProduction) {
      return _productionInterstitialAdUnitId;
    }
    return _testInterstitialAdUnitId;
  }
  
  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }
  
  static BannerAd createBannerAd({
    required AdSize adSize,
    BannerAdListener? listener,
  }) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: adSize,
      request: const AdRequest(),
      listener: listener ?? _defaultBannerListener,
    )..load();
  }
  
  static final BannerAdListener _defaultBannerListener = BannerAdListener(
    onAdLoaded: (ad) {
      debugPrint('Banner ad loaded: ${ad.adUnitId}');
    },
    onAdFailedToLoad: (ad, error) {
      debugPrint('Banner ad failed to load: ${ad.adUnitId}, error: $error');
      ad.dispose();
    },
    onAdOpened: (ad) {
      debugPrint('Banner ad opened: ${ad.adUnitId}');
    },
    onAdClosed: (ad) {
      debugPrint('Banner ad closed: ${ad.adUnitId}');
    },
  );
}

