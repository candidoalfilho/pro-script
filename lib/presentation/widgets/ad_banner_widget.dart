import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../core/services/ad_service.dart';

class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({super.key});
  
  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  
  @override
  void initState() {
    super.initState();
    _loadAd();
  }
  
  void _loadAd() {
    AdService().loadBannerAd(
      onAdLoaded: (ad) {
        setState(() {
          _bannerAd = ad;
          _isAdLoaded = true;
        });
      },
    );
  }
  
  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    if (!_isAdLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }
    
    return Container(
      height: _bannerAd!.size.height.toDouble(),
      alignment: Alignment.center,
      child: AdWidget(ad: _bannerAd!),
    );
  }
}

