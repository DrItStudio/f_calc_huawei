import 'package:flutter/services.dart';

class HuaweiAds {
  static const MethodChannel _channel = MethodChannel('huawei_ads');

  static Future<void> showInterstitial() async {
    await _channel.invokeMethod('showInterstitial');
  }

  static Future<bool> showRewarded() async {
    final result = await _channel.invokeMethod('showRewarded');
    return result == true;
  }
}
