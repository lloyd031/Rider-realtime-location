import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdState
{
  Future<InitializationStatus> initialization;
  AdState(this.initialization);
  String get bannerAdUnitId=> Platform.isAndroid
  ?'ca-app-pub-1970483100245335/9085413871'
  :'ca-app-pub-3940256099942544/2934735716';
  //ca-app-pub-3940256099942544/6300978111
  
  BannerAdListener get bannerAdListener => _adListener;
  final BannerAdListener _adListener = BannerAdListener(
  onAdLoaded: (ad) => print(""),
  
  onAdClosed: (ad) => ad.dispose(),
  onAdFailedToLoad: (ad,error) => print("error to load"),
  onAdOpened: (ad) => print(""),
  onAdClicked: (ad) => print(""),     
  );
   
  String get appOpenAdUnitId=> Platform.isAndroid
  ?'ca-app-pub-1970483100245335/6582997283'
  :'ca-app-pub-3940256099942544/5575463023';
  
  //ca-app-pub-3940256099942544/9257395921


  String get rewardedAdUnitId=> Platform.isAndroid
  ?'ca-app-pub-1970483100245335/6148860359'
  :'ca-app-pub-3940256099942544/1712485313';
} 
