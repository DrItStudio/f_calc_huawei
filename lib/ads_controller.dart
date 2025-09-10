import 'dart:io';
import 'billing_manager.dart';
import 'huawei_ads.dart'; // Dart-обёртка для MethodChannel

class AdsController {
  static final AdsController _instance = AdsController._internal();
  factory AdsController() => _instance;
  AdsController._internal();

  // Используем реальную рекламу
  static const bool ADS_ENABLED =
      true; // Показываем рекламу для монетизации приложения
  static const bool TEST_MODE = false; // Используем реальные рекламные блоки

  // Huawei Ads IDs - реальные ID для Huawei AppGallery
  static const String interstitialId = 'f9r2juupby';

  bool isSubscribed = false;
  bool premiumGranted = false;
  DateTime? _lastInterstitialShown;

  /// Инициализация рекламы
  Future<void> init({bool personalized = true}) async {
    await _checkSubscriptionStatus();
  }

  Future<void> _checkSubscriptionStatus() async {
    try {
      if (BillingManager.isInitialized) {
        isSubscribed = await BillingManager.checkSubscriptionStatus();
        print('Subscription status checked: $isSubscribed');
      } else {
        isSubscribed = false;
        print('BillingManager not initialized, subscription status: false');
      }
    } catch (e) {
      print('Error checking subscription status: $e');
      isSubscribed = false;
    }
  }

  void updateSubscriptionStatus(bool subscribed) {
    print('Updating subscription status to: $subscribed');
    isSubscribed = subscribed;
  }

  Future<void> showInterstitial() async {
    // Проверяем глобальный флаг включения рекламы
    if (!ADS_ENABLED) {
      print('Ads disabled for this version, not showing interstitial ad');
      return;
    }

    if (isSubscribed) {
      print('Subscription active, not showing interstitial ad');
      return;
    }

    if (TEST_MODE) {
      // В тестовом режиме минимизируем показы рекламы
      final now = DateTime.now();
      if (_lastInterstitialShown != null &&
          now.difference(_lastInterstitialShown!).inMinutes < 60) {
        // В тестовом режиме показываем рекламу максимум раз в час
        print('Test mode: ad cooldown active, skipping interstitial');
        return;
      }
    }

    print('Showing Huawei interstitial ad');
    await HuaweiAds.showInterstitial();
    _lastInterstitialShown = DateTime.now();
  }

  Future<void> showInterstitialIfNeeded() async {
    // Проверяем глобальный флаг включения рекламы
    if (!ADS_ENABLED) {
      print('Ads disabled for this version, not showing interstitial ad');
      return;
    }

    if (isSubscribed) {
      print('Subscription active, not showing interstitial ad');
      return;
    }

    final now = DateTime.now();
    if (_lastInterstitialShown == null ||
        now.difference(_lastInterstitialShown!).inMinutes >= 20) {
      print('Showing Huawei interstitial ad (cooldown passed)');
      await HuaweiAds.showInterstitial();
      _lastInterstitialShown = now;
    } else {
      final minutesLeft =
          20 - now.difference(_lastInterstitialShown!).inMinutes;
      print('Interstitial ad cooldown: $minutesLeft minutes left');
    }
  }

  Future<void> showRewardedForPremium(Function() onPremiumGranted,
      {Function()? onAdFailedToShow}) async {
    // Проверяем глобальный флаг включения рекламы
    if (!ADS_ENABLED) {
      print('Ads disabled for this version, granting premium directly');
      // В этом случае просто предоставляем премиум-функцию без просмотра рекламы
      onPremiumGranted();
      return;
    }

    if (TEST_MODE) {
      // В тестовом режиме имитируем успешный просмотр рекламы
      print('Test mode: simulating successful rewarded ad view');
      // Небольшая задержка для имитации загрузки рекламы
      await Future.delayed(Duration(milliseconds: 300));
      onPremiumGranted();
      return;
    }

    if (isSubscribed) {
      print('Subscription active, not showing rewarded ad');
      onPremiumGranted();
      return;
    }

    print('Showing Huawei rewarded ad');
    try {
      final rewarded = await HuaweiAds.showRewarded();
      if (rewarded) {
        premiumGranted = true;
        onPremiumGranted();
      } else {
        if (onAdFailedToShow != null) onAdFailedToShow();
      }
    } catch (e) {
      print('Error showing rewarded ad: $e');
      if (onAdFailedToShow != null) onAdFailedToShow();
    }
  }

  bool canUsePremium() {
    return isSubscribed || premiumGranted;
  }

  bool tryUsePremium() {
    if (isSubscribed) {
      print('Premium access granted via subscription');
      return true;
    }

    if (premiumGranted) {
      print('Premium access granted via rewarded ad (one-time use)');
      premiumGranted = false;
      return true;
    }

    print('Premium access denied - no subscription or rewarded ad');
    return false;
  }

  void dispose() {
    print('Disposing AdsController resources');
    _lastInterstitialShown = null;
    premiumGranted = false;
  }
}
