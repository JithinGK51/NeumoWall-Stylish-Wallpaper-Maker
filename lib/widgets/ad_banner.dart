import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_service.dart';

class AdBanner extends StatefulWidget {
  final String screenName;
  
  const AdBanner({
    super.key,
    required this.screenName,
  });

  @override
  State<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _bannerAd = AdService.createBannerAd(
      adSize: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Failed to load ad: $error');
          ad.dispose();
          setState(() {
            _isAdLoaded = false;
          });
        },
        onAdOpened: (ad) {
          debugPrint('Ad opened');
        },
        onAdClosed: (ad) {
          debugPrint('Ad closed');
        },
      ),
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _bannerAd?.size.height.toDouble() ?? 50,
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: _isAdLoaded && _bannerAd != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AdWidget(ad: _bannerAd!),
            )
          : Container(
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              ),
              child: Center(
                child: Icon(
                  Icons.ads_click,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  size: 24,
                ),
              ),
            ),
    );
  }
}
