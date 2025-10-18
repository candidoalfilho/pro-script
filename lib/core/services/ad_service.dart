import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../constants/app_constants.dart';

class AdService {
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;
  
  // Singleton
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();
  
  // Initialize
  Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }
  
  // Banner Ad
  String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return AppConstants.androidBannerId;
    } else if (Platform.isIOS) {
      return AppConstants.iosBannerId;
    }
    throw UnsupportedError('Unsupported platform');
  }
  
  void loadBannerAd({required Function(BannerAd) onAdLoaded}) {
    _bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          onAdLoaded(ad as BannerAd);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );
    _bannerAd!.load();
  }
  
  void disposeBannerAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
  }
  
  BannerAd? get bannerAd => _bannerAd;
  
  // Interstitial Ad
  String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return AppConstants.androidInterstitialId;
    } else if (Platform.isIOS) {
      return AppConstants.iosInterstitialId;
    }
    throw UnsupportedError('Unsupported platform');
  }
  
  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
          
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _isInterstitialAdReady = false;
              loadInterstitialAd(); // Load next ad
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _isInterstitialAdReady = false;
              loadInterstitialAd(); // Load next ad
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isInterstitialAdReady = false;
        },
      ),
    );
  }
  
  void showInterstitialAd() {
    if (_isInterstitialAdReady && _interstitialAd != null) {
      _interstitialAd!.show();
    }
  }
  
  void disposeInterstitialAd() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isInterstitialAdReady = false;
  }
  
  bool get isInterstitialAdReady => _isInterstitialAdReady;
}

